import 'package:flutter/material.dart';
import '../models/diff_model.dart';

class DiffView extends StatelessWidget {
  final Map<String, List<DiffHunkModel>> diffs;

  const DiffView({super.key, required this.diffs});

  @override
  Widget build(BuildContext context) {
    if (diffs.isEmpty) {
      return const Center(child: Text('No changes to show'));
    }

    return DefaultTabController(
      length: diffs.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: diffs.keys.map((path) => Tab(text: path.split('/').last)).toList(),
          ),
          Expanded(
            child: TabBarView(
              children: diffs.values.map((hunks) => _FileDiffView(hunks: hunks)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _FileDiffView extends StatelessWidget {
  final List<DiffHunkModel> hunks;
  const _FileDiffView({required this.hunks});

  @override
  Widget build(BuildContext context) {
    final lines = hunks.expand((h) => h.lines).toList();

    return Container(
      color: const Color(0xFF0D1117), // GitHub dark background
      child: ListView.builder(
        itemCount: lines.length,
        itemBuilder: (context, index) {
          final line = lines[index];
          return _DiffLineRow(line: line);
        },
      ),
    );
  }
}

class _DiffLineRow extends StatelessWidget {
  final DiffLineModel line;
  const _DiffLineRow({required this.line});

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final String leftText;
    final String rightText;

    switch (line.type) {
      case DiffLineType.addition:
        bgColor = Colors.green.withValues(alpha: 0.15);
        leftText = "";
        rightText = line.content;
        break;
      case DiffLineType.deletion:
        bgColor = Colors.red.withValues(alpha: 0.15);
        leftText = line.content;
        rightText = "";
        break;
      case DiffLineType.context:
        bgColor = Colors.transparent;
        leftText = line.content;
        rightText = line.content;
        break;
    }

    return Container(
      color: bgColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LineNumber(num: line.leftLineNumber),
          Expanded(child: _CodeLine(text: leftText, type: line.type)),
          const VerticalDivider(width: 1, color: Colors.white10),
          _LineNumber(num: line.rightLineNumber),
          Expanded(child: _CodeLine(text: rightText, type: line.type)),
        ],
      ),
    );
  }
}

class _LineNumber extends StatelessWidget {
  final int? num;
  const _LineNumber({this.num});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      padding: const EdgeInsets.only(right: 8),
      alignment: Alignment.centerRight,
      child: Text(
        num?.toString() ?? "",
        style: const TextStyle(color: Colors.white24, fontSize: 12, fontFamily: 'monospace'),
      ),
    );
  }
}

class _CodeLine extends StatelessWidget {
  final String text;
  final DiffLineType type;
  const _CodeLine({required this.text, required this.type});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Text(
        text.replaceFirst('\n', ''),
        style: TextStyle(
          color: type == DiffLineType.addition ? Colors.green[200] : 
                 type == DiffLineType.deletion ? Colors.red[200] : Colors.white70,
          fontFamily: 'monospace',
          fontSize: 13,
        ),
      ),
    );
  }
}
