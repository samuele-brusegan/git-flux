class DiffHunkModel {
  final String header;
  final List<DiffLineModel> lines;

  DiffHunkModel({required this.header, required this.lines});
}

class DiffLineModel {
  final int? leftLineNumber;
  final int? rightLineNumber;
  final String content;
  final DiffLineType type;

  DiffLineModel({
    this.leftLineNumber,
    this.rightLineNumber,
    required this.content,
    required this.type,
  });
}

enum DiffLineType {
  addition,
  deletion,
  context,
}
