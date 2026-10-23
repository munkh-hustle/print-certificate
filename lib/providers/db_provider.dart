import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart';

/// The single app-wide [AppDatabase].
///
/// `openAppDatabase()` is async (it resolves the application-support
/// directory first), so this is a [FutureProvider]. Everything that needs the
/// DB reads it through `ref.watch(appDatabaseProvider)` and awaits it.
final appDatabaseProvider = FutureProvider<AppDatabase>((ref) async {
  final db = await openAppDatabase();
  ref.onDispose(db.close);
  return db;
});
