class ViterbiNode {
  final int name;
  final int startPos;
  final int length;
  final int leftId;
  final int rightId;
  final int cost;
  final String type;
  final String? surfaceForm;

  int shortestCost = 999999;
  ViterbiNode? prev;

  ViterbiNode({
    required this.name,
    required this.startPos,
    required this.length,
    required this.leftId,
    required this.rightId,
    required this.cost,
    required this.type,
    this.surfaceForm,
  });
}
