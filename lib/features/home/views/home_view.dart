import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flux_git/features/repository/bloc/repo_bloc.dart';
import 'package:flux_git/features/repository/bloc/repo_state_events.dart';
import 'package:flux_git/features/auth/bloc/auth_bloc.dart';
import 'package:flux_git/features/auth/bloc/auth_state_events.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _isLoading = false;

  void _setLoading(bool loading) {
    if (mounted) {
      setState(() => _isLoading = loading);
    }
  }

  Future<void> _handleNewRepository() async {
    final path = await _showInputDialog(
      title: 'Create New Repository',
      label: 'Repository path',
      hint: '/path/to/new/repo',
    );
    if (!mounted) return;
    if (path == null || path.isEmpty) return;

    _setLoading(true);
    context.read<RepoBloc>().add(CreateRepository(path));
  }

  Future<void> _handleCloneRepository() async {
    final url = await _showInputDialog(
      title: 'Clone Repository',
      label: 'Repository URL',
      hint: 'https://github.com/user/repo.git',
    );
    if (!mounted) return;
    if (url == null || url.isEmpty) return;

    final path = await _showInputDialog(
      title: 'Clone Repository',
      label: 'Destination path',
      hint: '/path/to/clone/repo',
    );
    if (!mounted) return;
    if (path == null || path.isEmpty) return;

    _setLoading(true);
    context.read<RepoBloc>().add(CloneRepository(url, path));
  }

  Future<String?> _showInputDialog({
    required String title,
    required String label,
    required String hint,
  }) async {
    final controller = TextEditingController();
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<AuthBloc>().add(LogoutRequested(authState.currentAccount));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final currentAccount = authState is Authenticated ? authState.currentAccount : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FluxGit'),
        actions: [
          if (currentAccount != null)
            Row(
              children: [
                Text(currentAccount.username),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Logout',
                  onPressed: _handleLogout,
                ),
              ],
            ),
        ],
      ),
      body: BlocListener<RepoBloc, RepoState>(
        listener: (context, state) {
          if (state is RepoError || state is RepoLoaded) {
            if (_isLoading) {
              _setLoading(false);
            }
            if (state is RepoError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is RepoLoaded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Operation completed')),
              );
            }
          }
        },
        child: Stack(
          children: [
            Padding(
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
                        onTap: _isLoading ? null : _handleNewRepository,
                      ),
                      const SizedBox(width: 24),
                      _ActionCard(
                        title: 'Clone Repository',
                        description: 'Clone from GitHub, GitLab or Gitea',
                        icon: Icons.cloud_download_outlined,
                        onTap: _isLoading ? null : _handleCloneRepository,
                      ),
                      const SizedBox(width: 24),
                      _ActionCard(
                        title: 'Open Local',
                        description: 'Open an existing repository on your machine',
                        icon: Icons.folder_open_outlined,
                        onTap: _isLoading
                            ? null
                            : () async {
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
            if (_isLoading)
              Container(
                color: Colors.black54,
                child: const Center(child: CircularProgressIndicator()),
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
  final VoidCallback? onTap;

  const _ActionCard({
    required this.title,
    required this.description,
    required this.icon,
    this.onTap,
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
