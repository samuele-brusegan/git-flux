import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

/// Keys identifying the widgets highlighted during the guided tour.
class TutorialKeys {
  final GlobalKey newRepo = GlobalKey();
  final GlobalKey cloneRepo = GlobalKey();
  final GlobalKey openLocal = GlobalKey();
  final GlobalKey recent = GlobalKey();
}

class _Step {
  final GlobalKey key;
  final String title;
  final String body;
  final ContentAlign align;
  const _Step(this.key, this.title, this.body, this.align);
}

List<TargetFocus> buildTutorialTargets(TutorialKeys keys) {
  final steps = <_Step>[
    _Step(keys.newRepo, 'Create a repository',
        'Initialize a brand-new Git repository on your machine.',
        ContentAlign.bottom),
    _Step(keys.cloneRepo, 'Clone a remote',
        'Pull down a project from GitHub, GitLab or Gitea.',
        ContentAlign.bottom),
    _Step(keys.openLocal, 'Open a local repo',
        'Browse and open a repository that already exists locally.',
        ContentAlign.bottom),
    _Step(keys.recent, 'Recent repositories',
        'Your recently opened repositories appear here for quick access.',
        ContentAlign.top),
  ];

  return steps
      .map(
        (s) => TargetFocus(
          identify: s.title,
          keyTarget: s.key,
          shape: ShapeLightFocus.RRect,
          radius: 16,
          contents: [
            TargetContent(
              align: s.align,
              builder: (context, controller) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.body,
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
      .toList();
}

/// Shows the guided coach-mark tour over the home screen.
void showTutorial(BuildContext context, TutorialKeys keys) {
  TutorialCoachMark(
    targets: buildTutorialTargets(keys),
    colorShadow: Colors.black,
    opacityShadow: 0.85,
    textSkip: 'SKIP',
    paddingFocus: 8,
  ).show(context: context);
}
