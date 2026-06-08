import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flux_git/data/models/user_preferences.dart';
import 'package:flux_git/features/onboarding/bloc/onboarding_cubit.dart';
import 'package:go_router/go_router.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  SkillLevel _selected = SkillLevel.beginner;

  static const _levels = <(SkillLevel, String, String, IconData)>[
    (
      SkillLevel.beginner,
      'Beginner',
      'New to Git. Show me guided hints and simplified labels.',
      Icons.eco_outlined,
    ),
    (
      SkillLevel.intermediate,
      'Intermediate',
      'I know commits and branches. Keep tips concise.',
      Icons.trending_up,
    ),
    (
      SkillLevel.advanced,
      'Advanced',
      'Comfortable with rebase and merge. Hide hand-holding.',
      Icons.rocket_launch_outlined,
    ),
  ];

  Future<void> _continue() async {
    await context.read<OnboardingCubit>().completeOnboarding(_selected);
    if (!mounted) return;
    GoRouter.of(context).go('/?tour=1');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome to FluxGit',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'How comfortable are you with Git?',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                ..._levels.map((level) {
                  final (value, title, subtitle, icon) = level;
                  final isSelected = _selected == value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => setState(() => _selected = value),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : Colors.white10,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              icon,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.white54,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    subtitle,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle,
                                  color: theme.colorScheme.primary),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _continue,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Get Started'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
