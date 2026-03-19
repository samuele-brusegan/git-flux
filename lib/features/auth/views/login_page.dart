import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flux_git/data/models/account.dart';
import 'package:flux_git/features/auth/bloc/auth_bloc.dart';
import 'package:flux_git/features/auth/bloc/auth_state_events.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AuthProvider? _selectedProvider;
  final _serverUrlController = TextEditingController();
  bool _skipSsl = false;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().stream.listen((state) {
      if (state is Authenticated) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) GoRouter.of(context).go('/');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: Center(
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'FluxGit',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Select your provider to get started'),
                  const SizedBox(height: 32),
                  if (_selectedProvider == null)
                    _ProviderList(onSelected: (p) => setState(() => _selectedProvider = p))
                  else
                    _LoginDetails(
                      provider: _selectedProvider!,
                      urlController: _serverUrlController,
                      skipSsl: _skipSsl,
                      onSkipSslChanged: (v) => setState(() => _skipSsl = v),
                      onBack: () => setState(() => _selectedProvider = null),
                      onLogin: () {
                        context.read<AuthBloc>().add(LoginRequested(
                              provider: _selectedProvider!,
                              serverUrl: _serverUrlController.text.isEmpty ? null : _serverUrlController.text,
                              skipSslVerify: _skipSsl,
                            ));
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProviderList extends StatelessWidget {
  final Function(AuthProvider) onSelected;
  const _ProviderList({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProviderCard(
          label: 'GitHub',
          icon: Icons.code,
          onTap: () => onSelected(AuthProvider.github),
        ),
        const SizedBox(height: 12),
        _ProviderCard(
          label: 'GitLab',
          icon: Icons.data_usage,
          onTap: () => onSelected(AuthProvider.gitlab),
        ),
        const SizedBox(height: 12),
        _ProviderCard(
          label: 'Gitea',
          icon: Icons.storage,
          onTap: () => onSelected(AuthProvider.gitea),
        ),
      ],
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ProviderCard({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            const Spacer(),
            const Icon(Icons.chevron_right, size: 20, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}

class _LoginDetails extends StatelessWidget {
  final AuthProvider provider;
  final TextEditingController urlController;
  final bool skipSsl;
  final ValueChanged<bool> onSkipSslChanged;
  final VoidCallback onBack;
  final VoidCallback onLogin;

  const _LoginDetails({
    required this.provider,
    required this.urlController,
    required this.skipSsl,
    required this.onSkipSslChanged,
    required this.onBack,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
            Text('Login to ${provider.name.toUpperCase()}'),
          ],
        ),
        const SizedBox(height: 16),
        if (provider == AuthProvider.gitea) ...[
          TextField(
            controller: urlController,
            decoration: const InputDecoration(
              labelText: 'Server URL',
              hintText: 'https://gitea.example.com',
            ),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            title: const Text('Skip SSL Verification'),
            value: skipSsl,
            onChanged: (v) => onSkipSslChanged(v ?? false),
          ),
          const SizedBox(height: 16),
        ],
        ElevatedButton(
          onPressed: onLogin,
          child: const Text('Connect Account'),
        ),
      ],
    );
  }
}
