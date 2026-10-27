import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'seeds.dart';
import 'tables.dart';

// DEBT(Step 2): schemaVersion/onUpgrade and missing FKs are known Step 2 debt;
// left untouched here on purpose (Step 5 only adds helpers + seeding).

part 'database.g.dart';

/// Stable course id derived from a name: lowercase, whitespace/punctuation →
/// `_`, Cyrillic kept as-is. Collapsing runs of `_` keeps ids readable and the
/// trailing trim avoids ids like `barist_`.
String _courseIdFromName(String name) => name
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9\u0400-\u04FF]+'), '_')
    .replaceAll(RegExp(r'^_+|_+$'), '');

/// The Disbox local database (Drift / SQLite).
@DriftDatabase(
  tables: [Courses, Submissions, Certificates, Settings, CertificateCounter],
)
class AppDatabase extends _$AppDatabase {
  /// Accepts an optional [QueryExecutor] so tests can inject an in-memory DB.
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // NOTE: the old workaround here rewrote sqlite_master via UPDATE to
          // inject `DEFAULT 0` into certificate_counter.last_seq. SQLite
          // forbids that ("table sqlite_master may not be modified"), so the
          // default is now declared in tables.dart with
          // `.withDefault(const Constant(0))` and CREATE TABLE emits it.
          // Extra indices Drift cannot express declaratively on columns.
          await customStatement(
            // Lists are filtered by status constantly.
            'CREATE INDEX IF NOT EXISTS idx_submissions_status '
            'ON submissions (status)',
          );
          await customStatement(
            // Lookup by certificate id.
            'CREATE INDEX IF NOT EXISTS idx_submissions_certificate_id '
            'ON submissions (certificate_id)',
          );
          await customStatement(
            // Course join/filter.
            'CREATE INDEX IF NOT EXISTS idx_submissions_course_id '
            'ON submissions (course_id)',
          );
          // Unique index on the dedupe hash (the UNIQUE column constraint is
          // also enforced; this gives it a stable, explicit name).
          await customStatement(
            'CREATE UNIQUE INDEX IF NOT EXISTS idx_submissions_sheet_row_hash '
            'ON submissions (sheet_row_hash)',
          );
          // Step 5: seed default course list (idempotent — safe to leave here).
          await _seedCoursesIfEmpty();
        },
      );

  // -------------------------------------------------------------------------
  // Course helpers (Step 5)
  // -------------------------------------------------------------------------

  /// Streams all courses, newest first — backs `coursesListProvider`.
  Stream<List<Course>> watchCourses() {
    final query = select(courses)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch();
  }

  /// Updates a course's template configuration. Null arguments leave the
  /// corresponding column unchanged (only [paperSize] is non-nullable).
  Future<int> updateCourse(
    String id, {
    String? name,
    String? paperSize,
    String? templatePath,
    String? templateConfigJson,
  }) {
    return (update(courses)..where((t) => t.id.equals(id))).write(
      CoursesCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        paperSize: paperSize != null ? Value(paperSize) : const Value.absent(),
        // Explicit Value(null) → sets the column back to NULL (absent would
        // keep the old path), which is what "clear template file" means.
        templatePath:
            templatePath != null ? Value(templatePath) : const Value(null),
        templateConfigJson: templateConfigJson != null
            ? Value(templateConfigJson)
            : const Value(null),
      ),
    );
  }

  /// Inserts the default course list if the table is empty (idempotent).
  ///
  /// Called from `onCreate`; safe to call again later — it no-ops whenever any
  /// course row exists. Ids are stable slugs of the names so re-seeding across
  /// machines yields identical keys.
  Future<void> _seedCoursesIfEmpty() async {
    final existing = await select(courses).get();
    if (existing.isNotEmpty) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    var ts = now;
    await batch((b) {
      for (final name in kSeedCourseNames) {
        b.insert(courses, CoursesCompanion.insert(
              id: _courseIdFromName(name),
              name: name,
              paperSize: 'A4',
              createdAt: ++ts, // keeps rows distinct + newest-last ordering
            ));
      }
    });
  }

  static QueryExecutor _openConnection() {
    // Lazy so the default constructor works without an already-resolved
    // path_provider directory. In production prefer openAppDatabase(), which
    // passes its own executor.
    return LazyDatabase(() async {
      final dir = await getApplicationSupportDirectory();
      await dir.create(recursive: true);
      final file = File(p.join(dir.path, 'app.db'));
      return NativeDatabase.createInBackground(file);
    });
  }

  // -------------------------------------------------------------------------
  // Submission helpers
  // -------------------------------------------------------------------------

  /// Streams all submissions, newest first; optionally filtered by status
  /// ('new' | 'ready' | 'printed' | 'error').
  Stream<List<Submission>> watchSubmissions({String? statusFilter}) {
    final query = select(submissions)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    if (statusFilter != null) {
      query.where((t) => t.status.equals(statusFilter));
    }
    return query.watch();
  }

  Future<List<Submission>> getSubmissionsByStatus(String status) {
    return (select(submissions)
          ..where((t) => t.status.equals(status))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<int> insertSubmission(SubmissionsCompanion row) {
    return into(submissions).insert(row);
  }

  Future<Submission?> getSubmissionByHash(String hash) {
    return (select(submissions)..where((t) => t.sheetRowHash.equals(hash)))
        .getSingleOrNull();
  }

  Future<bool> submissionHashExists(String hash) async {
    final q = select(submissions)..where((t) => t.sheetRowHash.equals(hash));
    return (await q.get()).isNotEmpty;
  }

  // -------------------------------------------------------------------------
  // Race-safe certificate ID generation
  // -------------------------------------------------------------------------

  /// Returns the next certificate id for [year], e.g. `CERT-2026-000001`.
  ///
  /// Runs inside a transaction and upserts the per-year counter, so two
  /// concurrent callers can never receive the same sequence number.
  Future<String> nextCertificateId({required int year}) async {
    return transaction(() async {
      final row = await (select(certificateCounter)
            ..where((t) => t.year.equals(year)))
          .getSingleOrNull();
      final nextSeq = (row?.lastSeq ?? 0) + 1;

      await into(certificateCounter).insertOnConflictUpdate(
        CertificateCounterCompanion(
          year: Value(year),
          lastSeq: Value(nextSeq),
        ),
      );

      final seqStr = nextSeq.toString().padLeft(6, '0');
      return 'CERT-$year-$seqStr';
    });
  }
}

/// Opens (and creates if needed) the real on-disk app database.
///
/// Location: `<application support dir>/app.db`.
Future<AppDatabase> openAppDatabase() async {
  final dir = await getApplicationSupportDirectory();
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  final file = File(p.join(dir.path, 'app.db'));
  return AppDatabase(NativeDatabase.createInBackground(file));
}
