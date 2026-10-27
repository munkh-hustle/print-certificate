// NOTE ON IMPORTS: `Value` / `Value.absent()` (Drift companions) and
// `SqliteException` must be imported explicitly here. `data/db/database.dart`
// only imports drift internally, so without this line analysis fails with
// "Undefined name 'Value'" and "The name 'SqliteException' isn't a type".
import 'package:drift/drift.dart' show Value, SqliteException;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/db/database.dart';
import '../../providers/db_provider.dart';
import '../../providers/submissions_provider.dart';
import '../../services/certificate_id_service.dart';

/// Step 4 — "Add submission" dialog for fake/manual entries.
///
/// Shown via [showAddSubmissionDialog]. On save it inserts one row into the
/// `Submissions` table with a freshly generated certificate ID.
///
/// A [ConsumerStatefulWidget]: the state class below uses `ref` to resolve
/// the DB, the certificate service, and the courses list from providers.
/// If you change the base class here, change `createState` too — that
/// mismatch is what previously produced "Missing concrete implementation of
/// 'ConsumerStatefulWidget.createState'".
class AddSubmissionDialog extends ConsumerStatefulWidget {
  const AddSubmissionDialog({super.key});

  @override
  ConsumerState<AddSubmissionDialog> createState() =>
      _AddSubmissionDialogState();

  /// Returns true if a submission was saved (so callers can refresh anything
  /// that isn't already stream-driven).
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const AddSubmissionDialog(),
    );
    return result ?? false;
  }
}

Future<void> showAddSubmissionDialog(BuildContext context) async {
  // The submissions list is Drift-stream-driven, so no manual invalidation
  // is needed after a successful save.
  await AddSubmissionDialog.show(context);
}

class _AddSubmissionDialogState extends ConsumerState<AddSubmissionDialog> {
  static const _uuid = Uuid();

  final _formKey = GlobalKey<FormState>();
  final _surnameController = TextEditingController();
  final _nameController = TextEditingController();
  final _civilNumberController = TextEditingController();

  Course? _course;
  bool _saving = false;

  @override
  void dispose() {
    _surnameController.dispose();
    _nameController.dispose();
    _civilNumberController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    // Keep the dialog open on failure (per spec), but surface the problem.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);

    final surname = _surnameController.text.trim();
    final name = _nameController.text.trim();
    final civilNumber = _civilNumberController.text.trim();
    final course = _course;

    try {
      final db = await ref.read(appDatabaseProvider.future);
      final idService = await ref.read(certificateIdServiceProvider.future);
      final certificateId = await idService.next();

      // TODO(Step 8): replace with real SHA-256 sheetRowHash
      // (SHA-256 of "$timestamp|$surname|$name|$civilNumber|$courseNameRaw").
      // For manual/fake rows we just need a unique, non-colliding value.
      final sheetRowHash = 'manual-${_uuid.v4()}';

      await db.insertSubmission(
        SubmissionsCompanion.insert(
          surname: surname,
          name: name,
          civilNumber: civilNumber, // PII: keep exact, do NOT lowercase.
          sheetRowHash: sheetRowHash,
          courseId: course != null ? Value(course.id) : const Value.absent(),
          courseNameRaw:
              course != null ? Value(course.name) : const Value.absent(),
          status: const Value('new'), // explicit, matches column default
          createdAt: DateTime.now().millisecondsSinceEpoch,
          certificateId: Value(certificateId),
        ),
      );

      // Guard against the dialog being dismissed while we awaited the DB.
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on SqliteException catch (e) {
      // Most likely a UNIQUE constraint hit on sheet_row_hash (shouldn't
      // happen with UUIDs, but surface it readably rather than crashing).
      // DEBT(Step 2): submissions.sheet_row_hash carries both a column-level
      // UNIQUE constraint and a separately created unique index; not fixed
      // here on purpose.
      // NOTE: no `isConstraintFailure` check — that getter does not exist on
      // this sqlite3 version's SqliteException; we match the message instead.
      if (mounted) {
        setState(() => _saving = false);
        final isUniqueViolation =
            e.message.contains('UNIQUE constraint failed');
        _showError(isUniqueViolation
            ? 'This submission already exists (duplicate row hash).'
            : 'Database error while saving: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        _showError('Could not save the submission: $e');
      }
    }
  }

  String? _requiredNotEmpty(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Required' : null;

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesListProvider);

    return AlertDialog(
      title: const Text('Add submission'),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _surnameController,
                  decoration: const InputDecoration(labelText: 'Surname'),
                  textCapitalization: TextCapitalization.words,
                  autofocus: true,
                  validator: _requiredNotEmpty,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  textCapitalization: TextCapitalization.words,
                  validator: _requiredNotEmpty,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _civilNumberController,
                  decoration:
                      const InputDecoration(labelText: 'Civil number'),
                  validator: _requiredNotEmpty,
                ),
                const SizedBox(height: 12),
                _CourseDropdown(
                  coursesAsync: coursesAsync,
                  selected: _course,
                  onChanged: (v) => setState(() => _course = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed:
              _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

/// Course selector with a "— none —" (null) option, since
/// `Submissions.courseId` is nullable.
class _CourseDropdown extends StatelessWidget {
  const _CourseDropdown({
    required this.coursesAsync,
    required this.selected,
    required this.onChanged,
  });

  final AsyncValue<List<Course>> coursesAsync;
  final Course? selected;
  final ValueChanged<Course?> onChanged;

  @override
  Widget build(BuildContext context) {
    return coursesAsync.when(
      loading: () => const InputDecorator(
        decoration: InputDecoration(
            labelText: 'Course', hintText: 'Loading courses…'),
        child: SizedBox.shrink(),
      ),
      error: (e, _) => const InputDecorator(
        decoration: InputDecoration(
            labelText: 'Course', hintText: 'Courses unavailable'),
        child: SizedBox.shrink(),
      ),
      data: (courses) {
        final items = <DropdownMenuItem<Course?>>[
          const DropdownMenuItem<Course?>(
            value: null,
            child: Text('— none —'),
          ),
          for (final c in courses)
            DropdownMenuItem<Course?>(value: c, child: Text(c.name)),
        ];
        return DropdownButtonFormField<Course?>(
          value: selected,
          decoration: const InputDecoration(labelText: 'Course'),
          items: items,
          onChanged: onChanged,
        );
      },
    );
  }
}
