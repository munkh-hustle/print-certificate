import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Courses, Submissions, Certificates, Settings, CertificateCounter],
)
class AppDatabase extends _$AppDatabase {
  /// Accepts an optional [executor] so tests can inject an in-memory DB.
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _lazyConnection());

  /// Builds the real on-disk database lazily (directory + app.db created on
  /// first use).
  factory AppDatabase.local() => AppDatabase(_lazyConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) async {
          await migrator.createAll();
          // Performance indices for the queries the UI runs constantly.
          await customStatement(
            'CREATE INDEX idx_submissions_status '
            'ON submissions (status)',
          );
          await customStatement(
            'CREATE INDEX idx_submissions_certificate_id '
            'ON submissions (certificate_id)',
          );
          await customStatement(
            'CREATE INDEX idx_submissions_course_id '
            'ON submissions (course_id)',
          );
          // Belt & braces alongside the column-level UNIQUE on sheet_row_hash.
          await customStatement(
            'CREATE UNIQUE INDEX idx_submissions_sheet_row_hash '
            'ON submissions (sheet_row_hash)',
          );
        },
      );

  @override
  Future<void> close() {
    return super.close();
  }

  // ---------------------------------------------------------------------
  // Submission helpers
  // ---------------------------------------------------------------------

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
    final row = await (selectOnly(submissions)
          ..addColumns([submissions.id])
          ..where(submissions.sheetRowHash.equals(hash)))
        .getSingleOrNull();
    return row != null;
  }

  // ---------------------------------------------------------------------
  // Race-safe certificate ID generation
  // ---------------------------------------------------------------------

  /// Returns the next certificate id for [year], e.g. `CERT-2026-000001`.
  /// Runs inside a transaction against the single-row-per-year counter so
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

/// Opens (and creates if needed) the production database at
/// `<Application Support>/app.db`.
AppDatabase openAppDatabase() {
  return AppDatabase(_lazyConnection());
}

LazyDatabase _lazyConnection() {
  return LazyDatabase(_openConnection);
}

Future<QueryExecutor> _openConnection() async {
  final dir = await getApplicationSupportDirectory();
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  final file = File(p.join(dir.path, 'app.db'));
  return NativeDatabase.createInBackground(file);
}
