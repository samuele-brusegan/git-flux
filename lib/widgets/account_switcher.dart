import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flux_git/data/models/account.dart';
import 'package:flux_git/features/auth/bloc/auth_bloc.dart';
import 'package:flux_git/features/auth/bloc/auth_state_events.dart';
import 'package:go_router/go_router.dart';

class AccountSwitcher extends StatelessWidget {
  const AccountSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _AccountTile(
                account: state.currentAccount,
                isActive: true,
                onTap: () {},
              ),
              const Divider(color: Colors.white12),
              ...state.allAccounts
                  .where((a) => a.id != state.currentAccount.id)
                  .map((a) => _AccountTile(
                        account: a,
                        isActive: false,
                        onTap: () => context.read<AuthBloc>().add(SwitchAccount(a)),
                      )),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => GoRouter.of(context).push('/auth'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Account'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AccountTile extends StatelessWidget {
  final Account account;
  final bool isActive;
  final VoidCallback onTap;

  const _AccountTile({
    required this.account,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage(account.avatarUrl),
      ),
      title: Text(account.username, style: const TextStyle(fontSize: 14)),
      subtitle: Text(account.provider.name, style: const TextStyle(fontSize: 12)),
      trailing: isActive ? const Icon(Icons.check, size: 16, color: Colors.green) : null,
      onTap: onTap,
    );
  }
}
