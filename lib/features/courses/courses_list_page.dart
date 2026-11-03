import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../providers/courses_provider.dart';
import '../../providers/db_provider.dart';
import '../templates/template_editor_page.dart';
import 'add_edit_course_dialog.dart';

/// Step 5 — Courses management page (replaces the Templates placeholder tab).
///
/// Lists every course from `coursesListProvider` (live Drift `watch()`), with
/// a local search filter, an add/edit dialog, per-row actions (Edit /
/// Configure template / Delete) and a "Restore defaults" action that seeds
/// the built-in catalogue into an existing DB via
/// `AppDatabase.reseedCoursesIfEmpty()`.
class CoursesListPage extends ConsumerStatefulWidget {
  const CoursesListPage({super.key});

  @override
  ConsumerState<CoursesListPage> createState() => _CoursesListPageState();
}

class _CoursesListPageState extends ConsumerState<CoursesListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // -----------------------------------------------------------------------
  // Actions
  // -----------------------------------------------------------------------

  Future<void> _restoreDefaults() async {
    try {
      final db = await ref.read(appDatabaseProvider.future);
      await db.reseedCoursesIfEmpty();
      if (!mounted) return;
      _showSnack('Default courses restored.');
    } catch (e) {
      if (!mounted) return;
      _showSnack('Could not restore defaults: $e');
    }
  }

  Future<void> _configureTemplate(Course course) async {
    // TemplateEditorPage's constructor is `const TemplateEditorPage({required this.courseId})`.
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TemplateEditorPage(courseId: course.id)),
    );
  }

  Future<void> _deleteCourse(Course course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete course?'),
        content: Text(
          'Delete "${course.name}"?\n\n'
          'WARNING: submissions that reference this course will keep their '
          'course id but lose the course record (they become orphans). '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final db = await ref.read(appDatabaseProvider.future);
      // DEBT(Step 2): no FK — deleting orphans submissions.courseId
      await (db.delete(db.courses)..where((t) => t.id.equals(course.id)))
          .go();
      if (!mounted) return;
      _showSnack('Deleted "${course.name}".');
    } catch (e) {
      if (!mounted) return;
      _showSnack('Could not delete course: $e');
    }
  }

  void _openDialog({Course? initial}) {
    AddEditCourseDialog.open(context, initial: initial);
  }

  // -----------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        actions: [
          TextButton.icon(
            onPressed: _restoreDefaults,
            icon: const Icon(Icons.restore),
            label: const Text('Restore defaults'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search courses…',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
            ),
          ),
        ),
      ),
      body: coursesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to load courses: $error',
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(coursesListProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (courses) {
          if (courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No courses yet.'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _restoreDefaults,
                    icon: const Icon(Icons.restore),
                    label: const Text('Restore defaults'),
                  ),
                ],
              ),
            );
          }

          final query = _query.toLowerCase();
          final filtered = _query.isEmpty
              ? courses
              : courses
                  .where((c) => c.name.toLowerCase().contains(query))
                  .toList();

          if (filtered.isEmpty) {
            return Center(
              child: Text('No courses match "$_query".'),
            );
          }

          return ListView.separated(
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final course = filtered[index];
              return ListTile(
                title: Text(course.name),
                subtitle: Text(
                  '${course.paperSize} · '
                  '${course.templatePath != null ? 'template ✓' : 'no template'} · '
                  '${course.templateConfigJson != null ? 'configured' : 'not configured'}',
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) => switch (value) {
                    'edit' => _openDialog(initial: course),
                    'configure' => _configureTemplate(course),
                    'delete' => _deleteCourse(course),
                    _ => null,
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Edit'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'configure',
                      child: ListTile(
                        leading: Icon(Icons.dashboard_customize_outlined),
                        title: Text('Configure template'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete_outline),
                        title: Text('Delete'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openDialog(),
        icon: const Icon(Icons.add),
        label: const Text('New course'),
      ),
    );
  }
}
