import 'package:flutter/material.dart';
import 'package:git2dart/git2dart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flux_git/features/repository/bloc/repo_bloc.dart';
import 'package:flux_git/features/repository/bloc/repo_state_events.dart';
import 'package:flux_git/features/repository/widgets/commit_graph_painter.dart';
import 'package:flux_git/features/repository/widgets/branch_switcher.dart';
import 'package:flux_git/features/repository/views/diff_view.dart';

class RepoView extends StatelessWidget {
  final String path;
  const RepoView({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<RepoBloc, RepoState>(
          builder: (context, state) {
            String title = path.split('/').last;
            if (state is RepoLoaded) {
              title += ' (${state.branchName})';
            }
            return Text(title);
          },
        ),
        actions: [
          BlocBuilder<RepoBloc, RepoState>(
            builder: (context, state) {
              if (state is RepoLoaded) {
                return TextButton.icon(
                  onPressed: () => _showBranchSwitcher(context, state.branches, state.branchName),
                  icon: const Icon(Icons.account_tree_outlined, size: 18),
                  label: Text(state.branchName),
                  style: TextButton.styleFrom(foregroundColor: Colors.blue),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          BlocBuilder<RepoBloc, RepoState>(
            builder: (context, state) {
              if (state is RepoLoaded) {
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.cloud_sync_outlined),
                  onSelected: (value) {
                    if (value == 'fetch') {
                      context.read<RepoBloc>().add(const FetchRemote('origin'));
                    } else if (value == 'pull') {
                      context.read<RepoBloc>().add(PullRemote('origin', state.branchName));
                    } else if (value == 'push') {
                      context.read<RepoBloc>().add(PushRemote('origin', state.branchName));
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'fetch', child: Text('Fetch (origin)')),
                    const PopupMenuItem(value: 'pull', child: Text('Pull (origin)')),
                    const PopupMenuItem(value: 'push', child: Text('Push (origin)')),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<RepoBloc>().add(RefreshRepository()),
          ),
        ],
      ),
      body: BlocBuilder<RepoBloc, RepoState>(
        builder: (context, state) {
          if (state is RepoLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is RepoError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is RepoLoaded) {
            return _RepoContent(state: state);
          }
          return const Center(child: Text('Please select a repository'));
        },
      ),
    );
  }
}

class _RepoContent extends StatelessWidget {
  final RepoLoaded state;
  const _RepoContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Commit Log with Graph
        Expanded(
          flex: 2,
          child: ListView.builder(
            itemCount: state.commits.length,
            itemBuilder: (context, index) {
              final commit = state.commits[index];
              return CustomPaint(
                painter: CommitGraphPainter(
                  nodes: state.nodes,
                  index: index,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.only(left: 60),
                  title: Text(
                    commit.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${commit.author.name} • ${commit.oid.sha.substring(0, 7)}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                  ),
                  onTap: () {},
                ),
              );
            },
          ),
        ),
        const VerticalDivider(width: 1, color: Colors.white10),
        // Staging / Status Area
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('CHANGES', style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 1.5, color: Colors.blue)),
              ),
              Expanded(
                child: ListView(
                  children: state.status.entries.map((entry) {
                    final status = entry.value;
                    final isStaged = status.isStaged;
                    final isConflicted = status.contains(GitStatus.conflicted);

                    return ListTile(
                      dense: true,
                      leading: isConflicted 
                        ? const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20)
                        : Checkbox(
                            value: isStaged,
                            onChanged: (val) {
                              context.read<RepoBloc>().add(ToggleFileSelection(entry.key, isStaged));
                            },
                          ),
                      title: Text(entry.key.split('/').last, style: const TextStyle(fontSize: 14)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.key, style: const TextStyle(fontSize: 10, color: Colors.white38)),
                          if (isConflicted)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  TextButton(
                                    onPressed: () => context.read<RepoBloc>().add(ResolveConflict(entry.key, useOurs: true)),
                                    child: const Text('OURS', style: TextStyle(fontSize: 10)),
                                  ),
                                  TextButton(
                                    onPressed: () => context.read<RepoBloc>().add(ResolveConflict(entry.key, useOurs: false)),
                                    child: const Text('THEIRS', style: TextStyle(fontSize: 10)),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      trailing: _StatusIcon(status: status),
                      onTap: isConflicted ? null : () {
                        context.read<RepoBloc>().add(LoadDiff(staged: isStaged));
                        _showDiffSheet(context);
                      },
                    );
                  }).toList(),
                ),
              ),
              _CommitBox(),
            ],
          ),
        ),
      ],
    );
  }
}

void _showBranchSwitcher(BuildContext context, List<Branch> branches, String currentBranch) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => BranchSwitcher(
      currentBranch: currentBranch,
      branches: branches,
    ),
  );
}

void _showDiffSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF0D1117),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return BlocBuilder<RepoBloc, RepoState>(
            builder: (context, state) {
              if (state is RepoLoaded && state.currentDiff != null) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Diff View', style: Theme.of(context).textTheme.titleLarge),
                    ),
                    Expanded(child: DiffView(diffs: state.currentDiff!)),
                  ],
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          );
        },
      );
    },
  );
}

class _StatusIcon extends StatelessWidget {
  final Set<GitStatus> status;
  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    if (status.contains(GitStatus.indexNew) || status.contains(GitStatus.wtNew)) {
      icon = Icons.add_circle_outline;
      color = Colors.green;
    } else if (status.contains(GitStatus.indexModified) || status.contains(GitStatus.wtModified)) {
      icon = Icons.edit_note;
      color = Colors.blue;
    } else if (status.contains(GitStatus.indexDeleted) || status.contains(GitStatus.wtDeleted)) {
      icon = Icons.remove_circle_outline;
      color = Colors.red;
    } else if (status.contains(GitStatus.indexRenamed) || status.contains(GitStatus.wtRenamed)) {
      icon = Icons.move_up;
      color = Colors.purple;
    } else {
      icon = Icons.help_outline;
      color = Colors.white24;
    }

    return Icon(icon, color: color, size: 16);
  }
}

extension GitStatusSetExt on Set<GitStatus> {
  bool get isStaged => contains(GitStatus.indexNew) || 
                       contains(GitStatus.indexModified) || 
                       contains(GitStatus.indexDeleted) ||
                       contains(GitStatus.indexRenamed) ||
                       contains(GitStatus.indexTypeChange);
  
  bool get isNew => contains(GitStatus.wtNew) || contains(GitStatus.indexNew);
  bool get isModified => contains(GitStatus.wtModified) || contains(GitStatus.indexModified);
  bool get isDeleted => contains(GitStatus.wtDeleted) || contains(GitStatus.indexDeleted);
  bool get isRenamed => contains(GitStatus.wtRenamed) || contains(GitStatus.indexRenamed);
}

class _CommitBox extends StatefulWidget {
  @override
  State<_CommitBox> createState() => _CommitBoxState();
}

class _CommitBoxState extends State<_CommitBox> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Commit message...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            maxLines: 3,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  context.read<RepoBloc>().add(CommitChanges(
                    message: _controller.text,
                    authorName: "User", // This should come from settings/auth
                    authorEmail: "user@example.com",
                  ));
                  _controller.clear();
                }
              },
              child: const Text('Commit Changes'),
            ),
          ),
        ],
      ),
    );
  }
}
