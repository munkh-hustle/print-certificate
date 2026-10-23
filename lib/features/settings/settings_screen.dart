import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../providers/db_provider.dart';
import '../../providers/settings_provider.dart';
import 'widgets/settings_field.dart';

/// Step 3 — real Settings screen.
///
/// Loads the three config values from the `Settings` table on open, validates
/// the pasted service-account JSON client-side, and persists everything in a
/// single DB transaction (all-or-nothing).
///
/// Explicit choice: StatefulWidget with local loading state (a FutureProvider
/// for the *values* would fight with the TextEditingController lifecycle —
/// controllers need one-time seeding, not rebuild-on-refetch).
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _saJsonController = TextEditingController();
  final _sheetIdController = TextEditingController();
  final _removeBgController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _obscureRemoveBg = true;

  /// Last successfully loaded/saved snapshot, used by "Revert".
  String _savedSaJson = '';
  String _savedSheetId = '';
  String _savedRemoveBg = '';

  @override
  void initState() {
    super.initState();
    // Load asynchronously AFTER the first frame: calling ref.read() directly
    // inside initState() can throw if a rebuild is in flight ("Tried to modify
    // a provider while building"). The post-frame callback guarantees we run
    // safely outside the build phase.
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _saJsonController.dispose();
    _sheetIdController.dispose();
    _removeBgController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final repo = await ref.read(settingsRepositoryProvider.future);
      final all = await repo.getAll();
      _applyValues(
        saJson: all[SettingKeys.googleServiceAccountJson] ?? '',
        sheetId: all[SettingKeys.googleSheetId] ?? '',
        removeBg: all[SettingKeys.removeBgApiKey] ?? '',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load settings: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyValues({
    required String saJson,
    required String sheetId,
    required String removeBg,
  }) {
    _savedSaJson = saJson;
    _savedSheetId = sheetId;
    _savedRemoveBg = removeBg;
    _saJsonController.text = saJson;
    _sheetIdController.text = sheetId;
    _removeBgController.text = removeBg;
  }

  void _revert() {
    _applyValues(
      saJson: _savedSaJson,
      sheetId: _savedSheetId,
      removeBg: _savedRemoveBg,
    );
    _formKey.currentState?.reset(); // drop stale validation errors
    setState(() {});
  }

  /// Inline validator for the SA JSON field ("Validate JSON" affordance).
  /// Empty is allowed (means "not configured yet"); non-empty must parse.
  String? _validateSaJson(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) return null;
    try {
      jsonDecode(value);
      return null;
    } on FormatException {
      return 'Invalid JSON — fix it or clear the field.';
    }
  }

  Future<void> _save() async {
    // All-or-nothing: if any field fails validation, persist nothing.
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings NOT saved — please fix the errors above.'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final db = await ref.read(appDatabaseProvider.future);
      final saJson = _saJsonController.text.trim();
      final sheetId = _sheetIdController.text.trim();
      final removeBg = _removeBgController.text.trim();

      await db.transaction(() async {
        await db.into(db.settings).insertOnConflictUpdate(
              SettingsCompanion.insert(
                key: SettingKeys.googleServiceAccountJson,
                value: saJson,
              ),
            );
        await db.into(db.settings).insertOnConflictUpdate(
              SettingsCompanion.insert(
                key: SettingKeys.googleSheetId,
                value: sheetId,
              ),
            );
        await db.into(db.settings).insertOnConflictUpdate(
              SettingsCompanion.insert(
                key: SettingKeys.removeBgApiKey,
                value: removeBg,
              ),
            );
      });

      _applyValues(saJson: saJson, sheetId: sheetId, removeBg: removeBg);
      if (!mounted) return;
      // NOTE: never log the SA JSON / API key values (they are secrets).
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Configuration',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // (a) Google Service Account JSON — multi-line textarea.
          // TODO(Step 11): stored plaintext in app.db for now; harden later.
          SettingsField(
            label: 'Google Service Account JSON',
            controller: _saJsonController,
            maxLines: 8,
            minLines: 5,
            hintText: r'{"type": "service_account", ...}',
            helperText:
                'Paste the whole downloaded service-account .json file.',
            validator: _validateSaJson,
          ),

          // (b) Google Sheet ID — single line.
          SettingsField(
            label: 'Google Sheet ID',
            controller: _sheetIdController,
            helperText:
                'The long ID between /d/ and /edit in the sheet URL.',
          ),

          // (c) remove.bg API key — optional, obscured with show/hide toggle.
          // TODO(Step 11): stored plaintext in app.db for now; harden later.
          SettingsField(
            label: 'remove.bg API Key',
            controller: _removeBgController,
            obscureText: _obscureRemoveBg,
            helperText: 'Optional. Leave empty to disable background removal.',
            footnote: 'Coming in Step 10',
            trailing: IconButton(
              icon: Icon(
                _obscureRemoveBg ? Icons.visibility_off : Icons.visibility,
              ),
              tooltip: _obscureRemoveBg ? 'Show' : 'Hide',
              onPressed: () =>
                  setState(() => _obscureRemoveBg = !_obscureRemoveBg),
            ),
          ),

          const SizedBox(height: 8),
          Row(
            children: [
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_saving ? 'Saving…' : 'Save'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: _saving ? null : _revert,
                child: const Text('Revert'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
