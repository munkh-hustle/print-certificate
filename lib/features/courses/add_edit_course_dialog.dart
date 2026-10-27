import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/db/database.dart';
import '../../providers/db_provider.dart';

/// Step 5 — create/edit dialog for a single [Course].
///
/// `initial == null` → create mode (fresh uuid id, name required).
/// `initial != null` → edit mode. The id is the text primary key and is
/// therefore immutable here; only name + paperSize are editable. Template
/// path/config live in the template editor, not in this dialog.
class AddEditCourseDialog extends ConsumerStatefulWidget {
  const AddEditCourseDialog({super.key, this.initial});

  final Course? initial;

  /// Convenience opener. Returns nothing meaningful — the list page refreshes
  /// reactively via `coursesListProvider`'s Drift `watch()` stream, so there
  /// is no need to pop a result back.
  static Future<void> open(BuildContext context, {Course? initial}) =>
      showDialog<void>(
        context: context,
        builder: (_) => AddEditCourseDialog(initial: initial),
      );

  @override
  ConsumerState<AddEditCourseDialog> createState() =>
      _AddEditCourseDialogState();
}

class _AddEditCourseDialogState extends ConsumerState<AddEditCourseDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController =
      TextEditingController(text: widget.initial?.name ?? '');
  late String _paperSize = widget.initial?.paperSize ?? 'A4';
  bool _saving = false;

  bool get _isEdit => widget.initial != null;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);
    try {
      final db = await ref.read(appDatabaseProvider.future);
      if (_isEdit) {
        // Direct update (not AppDatabase.updateCourse): that helper blanks
        // templatePath/templateConfigJson on every write, which must not
        // happen when only renaming a course or switching its paper size.
        await (db.update(db.courses)
              ..where((t) => t.id.equals(widget.initial!.id)))
            .write(CoursesCompanion(
          name: Value(name),
          paperSize: Value(_paperSize),
        ));
      } else {
        await db.into(db.courses).insert(CoursesCompanion.insert(
              id: const Uuid().v4(),
              name: name,
              paperSize: _paperSize,
              createdAt: DateTime.now().millisecondsSinceEpoch,
            ));
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Could not save course: $e')));
      // No pop on error — the user stays in the dialog to fix/retry.
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdit ? 'Edit course' : 'New course'),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                autofocus: true,
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                // `value:` (not `initialValue:`) — matches the pre-3.32 API
                // already used by _CourseDropdown in add_submission_dialog.dart,
                // so this file compiles on either SDK.
                value: _paperSize,
                decoration: const InputDecoration(labelText: 'Paper size'),
                items: const [
                  DropdownMenuItem(value: 'A4', child: Text('A4')),
                  DropdownMenuItem(value: 'A5', child: Text('A5')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _paperSize = value);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEdit ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}
