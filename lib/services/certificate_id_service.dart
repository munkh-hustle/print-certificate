import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart';
import '../providers/db_provider.dart';

/// Generates certificate IDs for new submissions.
///
/// Format: `CERT-YYYY-NNNNNN` — e.g. `CERT-2026-000001` (per steps.txt).
/// The year component comes from `DateTime.now().year` at call time, so IDs
/// roll over automatically on January 1st; the 6-digit sequence resets per
/// year because [AppDatabase.nextCertificateId] keeps a per-year counter row.
///
/// This is deliberately a *thin wrapper*: the race-safe counter logic
/// (transaction + upsert on `certificate_counter`) already lives in
/// `AppDatabase.nextCertificateId` and must not be reimplemented here.
/// The service exists only so the UI layer never touches the DB directly.
class CertificateIdService {
  const CertificateIdService(this._db);

  final AppDatabase _db;

  /// Returns the next certificate id for the current year,
  /// e.g. `CERT-2026-000001`. Pass [year] to override (tests / backdating).
  Future<String> next({int? year}) {
    return _db.nextCertificateId(year: year ?? DateTime.now().year);
  }
}

/// Exposes [CertificateIdService] to the widget layer; backed by the same
/// singleton [AppDatabase] the Settings screen uses ([appDatabaseProvider]).
final certificateIdServiceProvider =
    Provider<Future<CertificateIdService>>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return CertificateIdService(db);
});
