import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AcademyView extends StatelessWidget {
  const AcademyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FluxGit Academy')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _AcademyCard(
            title: 'Git Basics',
            description: 'Learn the fundamentals: commit, push, pull.',
            content: '''
# Git Basics
Git is a distributed version control system.
## Commits
A commit is a snapshot of your project at a specific point in time.
''',
          ),
          const SizedBox(height: 24),
          _AcademyCard(
            title: 'Advanced Rebase',
            description: 'Master clean histories with interactive rebase.',
            content: '''
# Interactive Rebase
Use `git rebase -i` to squash, edit, or reorder commits.
''',
          ),
        ],
      ),
    );
  }
}

class _AcademyCard extends StatelessWidget {
  final String title;
  final String description;
  final String content;

  const _AcademyCard({
    required this.title,
    required this.description,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(color: Colors.white54)),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            MarkdownBody(data: content),
          ],
        ),
      ),
    );
  }
}
