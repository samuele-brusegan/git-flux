import 'package:isar_community/isar.dart';

part 'user_preferences.g.dart';

enum SkillLevel { beginner, intermediate, advanced }

@collection
class UserPreferences {
  /// Single-row collection: always stored with a fixed id.
  Id id = 0;

  @enumerated
  late SkillLevel skillLevel;

  late bool onboardingComplete;
}
