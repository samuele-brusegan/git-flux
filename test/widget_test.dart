import 'package:flutter_test/flutter_test.dart';

// Import the main feature entry points to ensure the whole Dart tree compiles.
import 'package:flux_git/app.dart';
import 'package:flux_git/core/router/app_router.dart';
import 'package:flux_git/data/services/asset_manager.dart';
import 'package:flux_git/data/services/git_service.dart';
import 'package:flux_git/features/academy/views/academy_view.dart';
import 'package:flux_git/features/onboarding/views/onboarding_view.dart';
import 'package:flux_git/features/onboarding/tutorial_targets.dart';
import 'package:flux_git/features/repository/views/conflict_view.dart';
import 'package:flux_git/features/terminal/views/terminal_view.dart';

void main() {
  test('core widgets and services are constructible', () {
    expect(const ConflictView(path: 'a.txt'), isNotNull);
    expect(const AcademyView(), isNotNull);
    expect(const OnboardingView(), isNotNull);
    expect(const TerminalView(), isNotNull);
    expect(AssetManager(), isNotNull);
    expect(GitService(), isNotNull);
    expect(buildTutorialTargets(TutorialKeys()), isNotEmpty);
    expect(appRouter, isNotNull);
    expect(FluxGitApp, isNotNull);
  });
}
