import 'package:drift/drift.dart';

import '../db/database.dart';

/// Thin key/value wrapper around the Drift `Settings` table.
///
/// No business logic, no validation, no UI concerns here — validation lives
/// in the UI layer (see `features/settings/settings_screen.dart`).
///
/// NOTE(Step 11): values (incl. the Google service-account JSON and the
/// remove.bg API key) are currently stored plaintext in app.db. Step 11 will
/// harden this storage; do not implement encryption now.
class SettingsRepository {
  const SettingsRepository(this._db);

  final AppDatabase _db;

  /// Returns the value for [key], or null if it was never saved.
  Future<String?> get(String key) async {
    final row = await (_db.select(_db.settings)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  /// Inserts or replaces the value for [key] (upsert on the primary key).
  Future<void> set(String key, String value) {
    return _db.into(_db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(key: key, value: value),
        );
  }

  /// Removes [key] if present; no-op otherwise.
  Future<void> delete(String key) {
    return (_db.delete(_db.settings)..where((t) => t.key.equals(key))).go();
  }

  /// One-shot snapshot of every stored setting.
  Future<Map<String, String>> getAll() async {
    final rows = await _db.select(_db.settings).get();
    return {for (final row in rows) row.key: row.value};
  }

  /// Live view of all settings; re-emits whenever the table changes.
  Stream<Map<String, String>> watchAll() {
    return _db.select(_db.settings).watch().map(
          (rows) => {for (final row in rows) row.key: row.value},
        );
  }
}
