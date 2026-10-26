import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/db/database.dart';
import '../../providers/db_provider.dart';
import '../../services/certificate_id_service.dart';

/// Step 4 — "Add submission" dialog for fake/manual data entry.
///
/// A [ConsumerStatefulWidget]: `showDialog` builds the route with the app's
/// `Navigator`, which lives under the root `ProviderScope` (see main.dart),
/// so Riverpod's `ref` is available here directly.
class AddSubmissionDialog extends ConsumerStatefulWidget {
  const AddSubmissionDialog({super.key});

  @override
  ConsumerState<AddSubmissionDialog> createState() => _AddSubmissionDialogState();
}

class _AddSubmissionDialogState extends ConsumerState<AddSubmissionDialog> {
  static const _noneCourseId = '__none__';

  final _formKey = GlobalKey<FormState>();
  final _surnameController = TextEditingController();
  final _nameController = TextEditingController();
  final _civilNumberController = TextEditingController();

  String _selectedCourseId = _noneCourseId;
  List<Course> _courses = const [];
  bool _coursesLoading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Load courses once, after the first frame (ref.read during build of the
    // route can race with provider initialization).
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCourses());
  }

  @override
  void dispose() {
    _surnameController.dispose();
    _nameController.dispose();
    _civilNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    try {
      final db = await ref.read(appDatabaseProvider.future);
      final courses = await (db.select(db.courses)
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .get();
      if (mounted) {
        setState(() {
          _courses = courses;
          _coursesLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _coursesLoading = false);
    }
  }

  String? _validateRequired(String? value) {
    return (value == null || value.trim().isEmpty) ? 'Required' : null;
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final surname = _surnameController.text.trim();
    final name = _nameController.text.trim();
    final civilNumber = _civilNumberController.text.trim();
    final course = _selectedCourseId == _noneCourseId
        ? null
        : _courses.firstWhere((c) => c.id == _selectedCourseId);

    setState(() => _saving = true);
    try {
      final db = await ref.read(appDatabaseProvider.future);
      final certService = await ref.read(certificateIdServiceProvider.future);

      // TODO(Step 8): replace with real SHA-256 sheetRowHash
      //   (SHA-256 of "$timestamp|$surname|$name|$civilNumber|$courseNameRaw").
      // A random UUID keeps the unique constraint happy for manual rows.
      final sheetRowHash = 'manual-${const Uuid().v4()}';

      await db.insertSubmission(
        SubmissionsCompanion.insert(
          surname: surname,
          name: name,
          civilNumber: civilNumber, // PII: stored exact, never lowercased.
          sheetRowHash: sheetRowHash,
          courseId: course != null
              ? Value(course.id)
              : const Value.absent(),
          courseNameRaw: course != null
              ? Value(course.name)
              : const Value.absent(),
          status: const Value('new'),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          certificateId: Value(await certService.next()),
        ),
      );

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      // Covers DriftSqlException on a duplicate sheet_row_hash (shouldn't
      // happen with UUIDs, but be safe) and any DB failure. The stream in
      // SubmissionsPage will refresh itself if the row actually landed.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save submission: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add submission'),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _surnameController,
                decoration: const InputDecoration(labelText: 'Овог (Surname)'),
                validator: _validateRequired,
                autofocus: true,
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Нэр (Name)'),
                validator: _validateRequired,
              ),
              TextFormField(
                controller: _civilNumberController,
                decoration:
                    const InputDecoration(labelText: 'РД дугаар (Civil number)'),
                validator: _validateRequired,
              ),
              const SizedBox(height: 8),
              // DEBT(Step 2): submissions.course_id has no enforced FK to the
              // courses table (foreign keys are Step 2 debt) — this dropdown,
              // populated from Courses, is the only guard that a chosen
              // courseId actually exists.
              //
              // NOTE: `initialValue:` below assumes Flutter >= 3.35, where
              // DropdownButtonFormField replaced the deprecated `value:`
              // parameter. If the analyzer flags it, rename to `value:`.
              DropdownButtonFormField<String>(
                initialValue: _selectedCourseId,
                decoration:
                    const InputDecoration(labelText: 'Сургалт (Course)'),
                items: [
                  if (_coursesLoading)
                    const DropdownMenuItem<String>(
                      value: _noneCourseId,
                      child: Text('— loading… —'),
                    )
                  else ...[
                    const DropdownMenuItem<String>(
                      value: _noneCourseId,
                      child: Text('— none —'),
                    ),
                    for (final c in _courses)
                      DropdownMenuItem<String>(
                        value: c.id,
                        child: Text(c.name),
                      ),
                  ],
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCourseId = value);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving
              ? null
              : () => Navigator.of(context).pop(),
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
