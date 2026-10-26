import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart';
import 'db_provider.dart';

/// Streams all submissions (newest first) straight from Drift.
///
/// Because [appDatabaseProvider] is a `FutureProvider`, the natural type here
/// is a `StreamProvider` built off `.future` — Riverpod wires the async
/// dependencies for us and the UI just watches one stream.
///
/// No status filter for now; `AppDatabase.watchSubmissions` supports one, but
/// the filter UI is out of scope for Step 4.
final submissionsListProvider = StreamProvider<List<Submission>>((ref) async* {
  final db = await ref.watch(appDatabaseProvider.future);
  yield* db.watchSubmissions();
});

/// The courses table as a plain list, for the "Add submission" dropdown.
///
/// Loaded once per provider lifetime (`get()`, not `watch()`): the Courses
/// table is managed in later steps (Templates, Step 6), so live updates here
/// are not required yet.
final coursesListProvider = FutureProvider<List<Course>>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return db.select(db.courses).get();
});
