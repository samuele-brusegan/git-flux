import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flux_git/data/models/user_preferences.dart';
import 'package:flux_git/data/services/database_service.dart';

class OnboardingState extends Equatable {
  final SkillLevel skillLevel;
  final bool onboardingComplete;

  /// Whether preferences have been read from the database yet.
  final bool loaded;

  const OnboardingState({
    required this.skillLevel,
    required this.onboardingComplete,
    this.loaded = false,
  });

  OnboardingState copyWith({
    SkillLevel? skillLevel,
    bool? onboardingComplete,
    bool? loaded,
  }) {
    return OnboardingState(
      skillLevel: skillLevel ?? this.skillLevel,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      loaded: loaded ?? this.loaded,
    );
  }

  @override
  List<Object?> get props => [skillLevel, onboardingComplete, loaded];
}

class OnboardingCubit extends Cubit<OnboardingState> {
  final DatabaseService dbService;

  OnboardingCubit({required this.dbService})
      : super(const OnboardingState(
          skillLevel: SkillLevel.beginner,
          onboardingComplete: false,
        ));

  Future<void> load() async {
    final prefs = await dbService.loadPreferences();
    emit(OnboardingState(
      skillLevel: prefs.skillLevel,
      onboardingComplete: prefs.onboardingComplete,
      loaded: true,
    ));
  }

  Future<void> setSkillLevel(SkillLevel level) async {
    final prefs = UserPreferences()
      ..skillLevel = level
      ..onboardingComplete = state.onboardingComplete;
    await dbService.savePreferences(prefs);
    emit(state.copyWith(skillLevel: level));
  }

  Future<void> completeOnboarding(SkillLevel level) async {
    final prefs = UserPreferences()
      ..skillLevel = level
      ..onboardingComplete = true;
    await dbService.savePreferences(prefs);
    emit(state.copyWith(skillLevel: level, onboardingComplete: true));
  }
}
