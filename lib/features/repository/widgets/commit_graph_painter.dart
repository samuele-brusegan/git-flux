import 'package:flutter/material.dart';

class CommitGraphPainter extends CustomPainter {
  final List<GraphNode> nodes;
  final int index;
  final Color baseColor;

  CommitGraphPainter({
    required this.nodes,
    required this.index,
    this.baseColor = Colors.blue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (index >= nodes.length) return;

    final paintLine = Paint()
      ..color = baseColor.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final paintNode = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill;

    const double nodeRadius = 6.0;
    const double columnWidth = 20.0;
    
    // Vertical center of the current row segment
    final double y = size.height / 2;

    // 1. Draw lines passing through or connecting to this row
    // This is simplified: we check if any node before this row connects to a node after this row
    // or if the current node connects to a parent.
    
    // For simplicity in this row-based painter:
    // Draw line from current node to its parents
    final node = nodes[index];
    final x = (node.column + 1) * columnWidth;

    for (final pIdx in node.parentIndices) {
      if (pIdx > index) {
        // Parent is below. Draw line from (x, y) to (px, nextRowY)
        final pNode = nodes[pIdx];
        final px = (pNode.column + 1) * columnWidth;
        
        final path = Path();
        path.moveTo(x, y);
        // Curve to the bottom of the current widget (size.height)
        path.cubicTo(x, y + size.height * 0.5, px, size.height, px, size.height);
        canvas.drawPath(path, paintLine);
      }
    }

    // Draw lines coming from above to nodes below (passing through)
    for (int i = 0; i < index; i++) {
      for (final pIdx in nodes[i].parentIndices) {
        if (pIdx > index) {
          // Lines from i to pIdx passes through row 'index'
          // We need to know which column it was in at this row.
          // For now, assume it stays in the parent's column or child's column.
          final px = (nodes[pIdx].column + 1) * columnWidth;
          canvas.drawLine(Offset(px, 0), Offset(px, size.height), paintLine);
        }
      }
    }

    // 2. Draw the node itself
    canvas.drawCircle(Offset(x, y), nodeRadius, paintNode);

    if (node.isHead) {
      final paintHead = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(Offset(x, y), nodeRadius + 2, paintHead);
    }
  }

  @override
  bool shouldRepaint(covariant CommitGraphPainter oldDelegate) {
    return oldDelegate.nodes != nodes || oldDelegate.index != index;
  }
}

class GraphNode {
  final int column;
  final List<int> parentIndices;
  final bool isHead;

  GraphNode({
    required this.column,
    required this.parentIndices,
    this.isHead = false,
  });
}
