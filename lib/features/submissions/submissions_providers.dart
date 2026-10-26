import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../providers/db_provider.dart';

/// Streams all submissions (newest first) straight from Drift.
///
/// No status filter in Step 4 — `watchSubmissions` supports one, but the
/// filter UI is out of scope here.
///
/// The DB opens asynchronously ([appDatabaseProvider] is a FutureProvider),
/// so we await it inside the stream before delegating to Drift's `watch()`,
/// which re-emits on every write to `submissions` — adding a row updates the
/// list automatically (no manual refresh needed).
final submissionsListProvider = StreamProvider<List<Submission>>((ref) async* {
  final db = await ref.watch(appDatabaseProvider.future);
  yield* db.watchSubmissions();
});
