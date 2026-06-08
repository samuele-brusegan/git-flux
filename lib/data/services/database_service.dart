import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flux_git/data/models/account.dart';
import 'package:flux_git/data/models/repository_meta.dart';
import 'package:flux_git/data/models/user_preferences.dart';

class DatabaseService {
  late Isar _isar;

  Isar get isar => _isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [AccountSchema, RepositoryMetaSchema, UserPreferencesSchema],
      directory: dir.path,
    );
  }

  /// Returns the persisted user preferences, creating defaults on first launch.
  Future<UserPreferences> loadPreferences() async {
    final existing = await _isar.userPreferences.get(0);
    if (existing != null) return existing;

    final defaults = UserPreferences()
      ..skillLevel = SkillLevel.beginner
      ..onboardingComplete = false;
    await _isar.writeTxn(() => _isar.userPreferences.put(defaults));
    return defaults;
  }

  Future<void> savePreferences(UserPreferences prefs) async {
    await _isar.writeTxn(() => _isar.userPreferences.put(prefs));
  }

  Future<void> close() async {
    await _isar.close();
  }
}
