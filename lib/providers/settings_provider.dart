import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repos/settings_repo.dart';
import 'db_provider.dart';

/// The app-wide [SettingsRepository], derived from the DB provider.
///
/// A plain [Provider] would need a concrete `AppDatabase` synchronously, but
/// the database opens asynchronously ([appDatabaseProvider] is a
/// FutureProvider). Simplest correct option: expose the repo as a
/// FutureProvider too; consumers do
///   `final repo = await ref.watch(settingsRepositoryProvider.future);`
/// Plain providers only (no code-gen) for consistency with the rest of the
/// app's Riverpod setup.
final settingsRepositoryProvider =
    FutureProvider<SettingsRepository>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return SettingsRepository(db);
});

/// Well-known Settings-table keys used by the app. Keeping them here means
/// nobody has to retype the string literals.
class SettingKeys {
  const SettingKeys._();

  /// Google service-account JSON (pasted into the textarea).
  static const String googleServiceAccountJson = 'google_service_account_json';

  /// Google Sheet ID (the long ID between /d/ and /edit in the URL).
  static const String googleSheetId = 'google_sheet_id';

  /// remove.bg API key; empty string == feature disabled.
  static const String removeBgApiKey = 'removebg_api_key';
}
