import 'package:git2dart/git2dart.dart';
import '../models/diff_model.dart';

class DiffUtils {
  /// Processes a [Diff] and returns a map of file paths to their hunks.
  static Map<String, List<DiffHunkModel>> parseDiff(Diff diff) {
    final result = <String, List<DiffHunkModel>>{};

    for (final patch in diff.patches) {
      final fileName = patch.delta.newFile.path;
      final hunks = <DiffHunkModel>[];

      for (final hunk in patch.hunks) {
        final lines = <DiffLineModel>[];
        for (final line in hunk.lines) {
          lines.add(DiffLineModel(
            leftLineNumber: line.oldLineNumber == -1 ? null : line.oldLineNumber,
            rightLineNumber: line.newLineNumber == -1 ? null : line.newLineNumber,
            content: line.content,
            type: _mapLineType(line.origin),
          ));
        }
        hunks.add(DiffHunkModel(
          header: hunk.header,
          lines: lines,
        ));
      }
      result[fileName] = hunks;
    }

    return result;
  }

  static DiffLineType _mapLineType(GitDiffLine origin) {
    switch (origin) {
      case GitDiffLine.addition:
        return DiffLineType.addition;
      case GitDiffLine.deletion:
        return DiffLineType.deletion;
      default:
        return DiffLineType.context;
    }
  }
}
