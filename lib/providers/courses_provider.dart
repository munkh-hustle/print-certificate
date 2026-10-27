import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart';
import 'db_provider.dart';

/// Streams all courses (newest first) straight from Drift.
///
/// Mirrors `submissionsListProvider` in `submissions_provider.dart`: because
/// [appDatabaseProvider] is a `FutureProvider`, the body awaits `.future` and
/// then `yield*`-streams the Drift query. Riverpod wires the async dependency
/// for us and the UI just watches one stream.
final coursesListProvider = StreamProvider.autoDispose<List<Course>>((ref) async* {
  final db = await ref.watch(appDatabaseProvider.future);
  yield* (db.select(db.courses)
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .watch();
});
