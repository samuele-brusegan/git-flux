import 'package:git2dart/git2dart.dart';
import '../widgets/commit_graph_painter.dart';

class GraphUtils {
  /// Transforms a list of [Commit] into a list of [GraphNode] for rendering.
  /// Assumes [commits] are in topological/reverse-chronological order.
  static List<GraphNode> calculateNodes(List<Commit> commits, Oid? headOid) {
    if (commits.isEmpty) return [];

    final nodes = <GraphNode>[];
    final activeColumns = <Oid?>[]; // Map column index to commit OID
    final commitToIndex = {for (int i = 0; i < commits.length; i++) commits[i].oid: i};

    for (int i = 0; i < commits.length; i++) {
      final commit = commits[i];
      final oid = commit.oid;

      // 1. Find or assign a column for this commit
      int col = activeColumns.indexOf(oid);
      if (col == -1) {
        // If not found, it's a new "root" or separate branch head
        col = activeColumns.indexOf(null); // Reuse empty slot
        if (col == -1) {
          col = activeColumns.length;
          activeColumns.add(oid);
        } else {
          activeColumns[col] = oid;
        }
      }

      // 2. Identify parent indices
      final parentIndices = commit.parents
          .map((p) => commitToIndex[p])
          .whereType<int>()
          .toList();

      // 3. Mark this column as "completed" for current commit,
      // and reserve spots for parents if they aren't already tracked.
      activeColumns[col] = null; // Clear current slot
      
      for (final pOid in commit.parents) {
        if (!activeColumns.contains(pOid)) {
          final emptySlot = activeColumns.indexOf(null);
          if (emptySlot != -1) {
            activeColumns[emptySlot] = pOid;
          } else {
            activeColumns.add(pOid);
          }
        }
      }

      nodes.add(GraphNode(
        column: col,
        parentIndices: parentIndices,
        isHead: oid == headOid,
      ));
    }

    return nodes;
  }
}
