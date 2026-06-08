import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flux_git/data/services/git_service.dart';
import 'package:flux_git/features/repository/bloc/repo_bloc.dart';
import 'package:flux_git/features/repository/bloc/repo_state_events.dart';

/// Three-pane conflict resolver: Mine (ours) | Theirs | Merged (editable).
class ConflictView extends StatefulWidget {
  final String path;
  const ConflictView({super.key, required this.path});

  @override
  State<ConflictView> createState() => _ConflictViewState();
}

class _ConflictViewState extends State<ConflictView> {
  late final TextEditingController _mergedController;
  ConflictContents? _contents;
  String? _error;

  @override
  void initState() {
    super.initState();
    _mergedController = TextEditingController();
    _load();
  }

  void _load() {
    try {
      final contents = context.read<RepoBloc>().conflictContents(widget.path);
      _contents = contents;
      _mergedController.text =
          contents.merged.isNotEmpty ? contents.merged : contents.ours;
    } catch (e) {
      _error = e.toString();
    }
  }

  @override
  void dispose() {
    _mergedController.dispose();
    super.dispose();
  }

  void _useOurs() => _mergedController.text = _contents?.ours ?? '';
  void _useTheirs() => _mergedController.text = _contents?.theirs ?? '';
  void _useBoth() {
    final ours = _contents?.ours ?? '';
    final theirs = _contents?.theirs ?? '';
    _mergedController.text = '$ours\n$theirs';
  }

  void _save() {
    context
        .read<RepoBloc>()
        .add(SaveResolvedConflict(widget.path, _mergedController.text));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Resolve: ${widget.path.split('/').last}'),
        actions: [
          TextButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check, color: Colors.green),
            label: const Text('Mark Resolved',
                style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
      body: _error != null
          ? Center(child: Text('Error: $_error'))
          : Column(
              children: [
                _Toolbar(
                  onUseOurs: _useOurs,
                  onUseTheirs: _useTheirs,
                  onUseBoth: _useBoth,
                ),
                const Divider(height: 1),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Pane(
                        label: 'MINE (ours)',
                        color: Colors.blue,
                        child: _ReadOnlyText(text: _contents?.ours ?? ''),
                      ),
                      const VerticalDivider(width: 1, color: Colors.white10),
                      _Pane(
                        label: 'THEIRS',
                        color: Colors.purple,
                        child: _ReadOnlyText(text: _contents?.theirs ?? ''),
                      ),
                      const VerticalDivider(width: 1, color: Colors.white10),
                      _Pane(
                        label: 'MERGED (editable)',
                        color: Colors.green,
                        child: TextField(
                          controller: _mergedController,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      backgroundColor: theme.colorScheme.surface,
    );
  }
}

class _Toolbar extends StatelessWidget {
  final VoidCallback onUseOurs;
  final VoidCallback onUseTheirs;
  final VoidCallback onUseBoth;

  const _Toolbar({
    required this.onUseOurs,
    required this.onUseTheirs,
    required this.onUseBoth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const Text('Accept: '),
          const SizedBox(width: 8),
          OutlinedButton(onPressed: onUseOurs, child: const Text('Mine')),
          const SizedBox(width: 8),
          OutlinedButton(onPressed: onUseTheirs, child: const Text('Theirs')),
          const SizedBox(width: 8),
          OutlinedButton(onPressed: onUseBoth, child: const Text('Both')),
        ],
      ),
    );
  }
}

class _Pane extends StatelessWidget {
  final String label;
  final Color color;
  final Widget child;

  const _Pane({required this.label, required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: color.withValues(alpha: 0.15),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _ReadOnlyText extends StatelessWidget {
  final String text;
  const _ReadOnlyText({required this.text});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: SelectableText(
        text.isEmpty ? '(empty)' : text,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
      ),
    );
  }
}
