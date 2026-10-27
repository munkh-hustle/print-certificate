import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart';
import '../providers/db_provider.dart';

/// Generates sequential certificate IDs in the format `CERT-YYYY-NNNNNN`.
///
/// Example: `CERT-2026-000001` (per steps.txt).
///
/// - `YYYY` comes from `DateTime.now().year` at call time.
/// - `NNNNNN` is a per-year, zero-padded sequence counter kept in the
///   `CertificateCounter` table.
///
/// This is intentionally a *thin wrapper*: all counter logic lives in
/// [AppDatabase.nextCertificateId], which runs inside a transaction with an
/// upsert so concurrent callers can never receive the same number. Do not
/// duplicate that logic here — delegate.
class CertificateIdService {
  const CertificateIdService(this._db);

  final AppDatabase _db;

  /// Returns the next certificate ID for the current calendar year,
  /// e.g. `CERT-2026-000001`.
  Future<String> next() => _db.nextCertificateId(year: DateTime.now().year);
}

/// Riverpod handle on [CertificateIdService] so the UI never talks to the DB
/// directly for ID generation.
///
/// Shares the exact same singleton [AppDatabase] instance as the Settings
/// screen (both resolve [appDatabaseProvider]) — no second DB connection.
/// Because that provider is a `FutureProvider`, this one is too; consumers do
/// `await ref.watch(certificateIdServiceProvider.future)`.
final certificateIdServiceProvider =
    FutureProvider<CertificateIdService>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return CertificateIdService(db);
});
