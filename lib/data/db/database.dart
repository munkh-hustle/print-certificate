import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'database.g.dart';

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
          // certificate_counter.last_seq: NOT NULL DEFAULT 0 (kept out of the
          // table definition so the generated insert companion takes a plain
          // int for lastSeq — see note in tables.dart).
          await customStatement(
            'UPDATE sqlite_master SET sql = '
            "REPLACE(sql, '\"last_seq\" INTEGER NOT NULL', "
            "'\"last_seq\" INTEGER NOT NULL DEFAULT 0') "
            "WHERE type = 'table' AND name = 'certificate_counter'",
          );
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
        },
      );

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
