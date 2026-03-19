import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:git2dart/git2dart.dart';
import '../bloc/repo_bloc.dart';
import '../bloc/repo_state_events.dart';

class BranchSwitcher extends StatelessWidget {
  final String currentBranch;
  final List<Branch> branches;

  const BranchSwitcher({
    super.key,
    required this.currentBranch,
    required this.branches,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Branches', style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => _showCreateBranchDialog(context),
                  tooltip: 'New Branch',
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: branches.length,
              itemBuilder: (context, index) {
                final branch = branches[index];
                final isCurrent = branch.name == currentBranch;

                return ListTile(
                  leading: Icon(
                    Icons.account_tree_outlined,
                    color: isCurrent ? Colors.blue : Colors.white38,
                  ),
                  title: Text(
                    branch.name,
                    style: TextStyle(
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCurrent ? Colors.blue : Colors.white,
                    ),
                  ),
                  trailing: isCurrent ? const Icon(Icons.check, color: Colors.blue, size: 16) : null,
                  onTap: () {
                    if (!isCurrent) {
                      context.read<RepoBloc>().add(CheckoutBranch(branch.name));
                      Navigator.pop(context);
                    }
                  },
                  onLongPress: () => _showBranchActions(context, branch.name),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateBranchDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Branch'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Branch name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<RepoBloc>().add(CreateBranch(controller.text));
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close switcher
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showBranchActions(BuildContext context, String branchName) {
    showModalBottomSheet(
      context: context,
      builder: (innerContext) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.merge, color: Colors.green),
            title: Text('Merge $branchName into current'),
            onTap: () {
              context.read<RepoBloc>().add(MergeBranch(branchName));
              Navigator.pop(innerContext);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.call_merge, color: Colors.orange),
            title: Text('Rebase current onto $branchName'),
            onTap: () {
              context.read<RepoBloc>().add(RebaseBranch(branchName));
              Navigator.pop(innerContext);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
