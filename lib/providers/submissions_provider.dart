import 'package:flutter_riverpod/flutter_riverpod.dart';

// `Course` no longer referenced here (its old provider moved to
// courses_provider.dart in Step 5); `Submission` still comes transitively
// from database.dart.
import '../data/db/database.dart';
import 'db_provider.dart';

// Re-export so existing consumers (submissions_page.dart,
// add_submission_dialog.dart) keep resolving `coursesListProvider` through
// this import path — the canonical definition lives in courses_provider.dart.
export 'courses_provider.dart' show coursesListProvider;

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

// DEBT(Step 2) note: the old one-shot `coursesListProvider` that used to live
// here was removed in Step 5 — it collided with the canonical streaming
// `coursesListProvider` in `courses_provider.dart` (ambiguous_import). All
// consumers now import that single provider instead.
