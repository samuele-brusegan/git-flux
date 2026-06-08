import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flux_git/data/models/user_preferences.dart';
import 'package:flux_git/data/services/asset_manager.dart';
import 'package:flux_git/features/onboarding/bloc/onboarding_cubit.dart';

class AcademyView extends StatefulWidget {
  const AcademyView({super.key});

  @override
  State<AcademyView> createState() => _AcademyViewState();
}

class _AcademyViewState extends State<AcademyView> {
  final _assetManager = AssetManager();
  late Future<List<AcademyLesson>> _lessonsFuture;

  @override
  void initState() {
    super.initState();
    _lessonsFuture = _assetManager.loadLessons();
  }

  /// Lessons whose minimum level is at or below the user's skill level.
  List<AcademyLesson> _visible(List<AcademyLesson> all, SkillLevel level) {
    return all
        .where((l) => l.minLevel.index <= level.index)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final skillLevel = context.watch<OnboardingCubit>().state.skillLevel;

    return Scaffold(
      appBar: AppBar(title: const Text('FluxGit Academy')),
      body: FutureBuilder<List<AcademyLesson>>(
        future: _lessonsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load lessons: ${snapshot.error}'));
          }

          final lessons = _visible(snapshot.data ?? [], skillLevel);
          if (lessons.isEmpty) {
            return const Center(child: Text('No lessons available yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: lessons.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              return _LessonCard(
                lesson: lesson,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _LessonPage(
                      lesson: lesson,
                      assetManager: _assetManager,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final AcademyLesson lesson;
  final VoidCallback onTap;

  const _LessonCard({required this.lesson, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: const Icon(Icons.menu_book_outlined, size: 32),
        title: Text(lesson.title,
            style: Theme.of(context).textTheme.titleLarge),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(lesson.description,
              style: const TextStyle(color: Colors.white54)),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _LessonPage extends StatelessWidget {
  final AcademyLesson lesson;
  final AssetManager assetManager;

  const _LessonPage({required this.lesson, required this.assetManager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: FutureBuilder<String>(
        future: assetManager.loadContent(lesson),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load: ${snapshot.error}'));
          }
          return Markdown(
            data: snapshot.data ?? '',
            padding: const EdgeInsets.all(24),
            sizedImageBuilder: (config) {
              final uri = config.uri;
              if (uri.scheme == 'http' || uri.scheme == 'https') {
                return Image.network(uri.toString(),
                    width: config.width, height: config.height);
              }
              // Resolve relative images against the bundled academy folder.
              final path = 'assets/academy/${uri.path}';
              return Image.asset(
                path,
                width: config.width,
                height: config.height,
                errorBuilder: (_, _, _) => Text(config.alt ?? '[image]'),
              );
            },
          );
        },
      ),
    );
  }
}
