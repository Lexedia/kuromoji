import 'package:kuromoji/src/viterbi/viterbi_node.dart';

class ViterbiLattice {
  final List<List<ViterbiNode>> nodes;

  var eosPos = 1;

  ViterbiLattice(this.nodes);

  factory ViterbiLattice.create() {
    final bosNode = ViterbiNode(
      name: -1,
      startPos: 0,
      length: 0,
      leftId: 0,
      rightId: 0,
      cost: 0,
      type: 'BOS',
    );
    bosNode.shortestCost = 0;
    return ViterbiLattice([
      [bosNode],
    ]);
  }

  void append(ViterbiNode node) {
    final endPos = node.startPos + node.length - 1;
    if (eosPos < endPos) {
      eosPos = endPos;
    }
    while (nodes.length <= endPos) {
      nodes.add([]);
    }
    final prevNodes = nodes[endPos];
    prevNodes.add(node);
    nodes[endPos] = prevNodes;
  }

  void appendEos() {
    int lastIndex = nodes.length;
    eosPos++;

    while (nodes.length <= lastIndex) {
      nodes.add([]);
    }

    nodes[lastIndex].add(
      ViterbiNode(
        name: -1,
        startPos: eosPos,
        length: 0,
        leftId: 0,
        rightId: 0,
        cost: 0,
        type: 'EOS',
      ),
    );
  }
}
