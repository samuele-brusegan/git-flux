import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flux_git/features/repository/bloc/repo_bloc.dart';
import 'package:flux_git/features/repository/bloc/repo_state_events.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, Samuele',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text('Manage your repositories and projects'),
            const SizedBox(height: 48),
            Row(
              children: [
                _ActionCard(
                  title: 'New Repository',
                  description: 'Initialize a new git repository locally',
                  icon: Icons.add_circle_outline,
                  onTap: () {},
                ),
                const SizedBox(width: 24),
                _ActionCard(
                  title: 'Clone Repository',
                  description: 'Clone from GitHub, GitLab or Gitea',
                  icon: Icons.cloud_download_outlined,
                  onTap: () {},
                ),
                const SizedBox(width: 24),
                _ActionCard(
                  title: 'Open Local',
                  description: 'Open an existing repository on your machine',
                  icon: Icons.folder_open_outlined,
                  onTap: () async {
                    // In a real app, use file_picker
                    // For demo, we'll try to open the current project dir
                    final path = '/home/samuele/Documents/dev/git-client';
                    context.read<RepoBloc>().add(LoadRepository(path));
                    context.go('/repo/${Uri.encodeComponent(path)}');
                  },
                ),
              ],
            ),
            const SizedBox(height: 48),
            Text('Recent Repositories', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const Expanded(
              child: Center(
                child: Text('No recent repositories found.', style: TextStyle(color: Colors.white38)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          height: 180,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
              const Spacer(),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(fontSize: 14, color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
