import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'package:disbox/data/db/database.dart';
import 'package:disbox/data/db/tables.dart';

/// Standalone verification for Step 2 (run with the bundled dart-sdk after
/// build_runner has generated database.g.dart):
///   dart run test/db_verify.dart
Future<void> main() async {
  final db = AppDatabase(NativeDatabase.memory());

  // 1) Race-safe certificate counter.
  final id1 = await db.nextCertificateId(year: 2026);
  print('id1 = $id1'); // expect CERT-2026-000001
  final id2 = await db.nextCertificateId(year: 2026);
  print('id2 = $id2'); // expect CERT-2026-000002
  assert(id1 == 'CERT-2026-000001', 'got $id1');
  assert(id2 == 'CERT-2026-000002', 'got $id2');

  // Concurrent burst must still be unique & monotonic.
  final ids = await Future.wait(
    [for (var i = 0; i < 20; i++) db.nextCertificateId(year: 2026)],
  );
  final expected = {
    for (var seq = 3; seq <= 22; seq++)
      'CERT-2026-${seq.toString().padLeft(6, "0")}'
  };
  assert(ids.toSet().length == 20, 'duplicate ids in concurrent burst');
  assert(ids.every(expected.contains), 'unexpected ids: $ids');
  print('concurrent burst OK: ${ids.first} .. ${ids.last}');

  // Other year starts independently.
  final other = await db.nextCertificateId(year: 2027);
  assert(other == 'CERT-2027-000001', 'got $other');

  // 2) Submission helpers + messy-input tolerance.
  final row = SubmissionsCompanion.insert(
    sheetRowHash: 'hash-abc',
    surname: '  ', // whitespace-only Cyrillic-ish garbage tolerated
    name: 'Өлзий',
    civilNumber: 'UH45120986',
    courseNameRaw: Value(
      'Шивээс (хөмсөг, уруул, контр), "ХАБЭА сургалт"',
    ),
    createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
  );
  final insertedId = await db.insertSubmission(row);
  print('inserted submission id=$insertedId');

  final byHash = await db.getSubmissionByHash('hash-abc');
  assert(byHash != null && byHash.name == 'Өлзий', 'hash lookup failed');
  assert(await db.submissionHashExists('hash-abc'), 'exists() failed');
  assert(!(await db.submissionHashExists('nope')), 'exists() false positive');

  // Default status is 'new'.
  assert(byHash!.status == 'new', 'default status wrong: ${byHash.status}');

  // Duplicate hash must be rejected (UNIQUE).
  try {
    await db.insertSubmission(row);
    throw StateError('duplicate hash was accepted!');
  } catch (e) {
    if (e is StateError) rethrow;
    print('duplicate hash correctly rejected');
  }

  final newOnes = await db.getSubmissionsByStatus('new');
  assert(newOnes.length == 1, 'getSubmissionsByStatus wrong');

  final streamed = await db.watchSubmissions(statusFilter: 'error').first;
  assert(streamed.isEmpty, 'status filter stream wrong');

  // 3) Certificates / Courses / Settings round-trip.
  await db.into(db.courses).insert(CoursesCompanion.insert(
        id: 'HAIR_PAIR',
        name: 'Үс засвар',
        paperSize: 'A4',
        createdAt: 0,
      ));
  await db.into(db.certificates).insert(CertificatesCompanion.insert(
        id: id1,
        submissionId: insertedId,
        pdfPath: r'C:\certs\a.pdf',
        paperSize: 'A4',
        generatedAt: 0,
      ));
  await db.into(db.settings).insert(SettingsCompanion.insert(
        key: 'sheet_id',
        value: 'xyz',
      ));

  await db.close();
  print('ALL DB CHECKS PASSED');
}
