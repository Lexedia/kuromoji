import 'package:kuromoji/src/dict/connection_costs.dart';
import 'package:kuromoji/src/viterbi/viterbi_lattice.dart';
import 'package:kuromoji/src/viterbi/viterbi_node.dart';

class ViterbiSearcher {
  final ConnectionCosts connectionCosts;

  ViterbiSearcher(this.connectionCosts);

  List<ViterbiNode> search(ViterbiLattice lattice) {
    _forward(lattice);
    return _backward(lattice);
  }

  void _forward(ViterbiLattice lattice) {
    for (var i = 1; i < lattice.nodes.length; i++) {
      for (final node in lattice.nodes[i]) {
        var cost = 999999;
        ViterbiNode? shortestPrevNode;

        final prevNodes = lattice.nodes[node.startPos - 1];
        for (final prevNode in prevNodes) {
          final edgeCost = connectionCosts.get(prevNode.rightId, node.leftId);
          final newCost = prevNode.shortestCost + edgeCost + node.cost;
          if (newCost < cost) {
            shortestPrevNode = prevNode;
            cost = newCost;
          }
        }

        node.prev = shortestPrevNode;
        node.shortestCost = cost;
      }
    }
  }

  List<ViterbiNode> _backward(ViterbiLattice lattice) {
    final shortestPath = <ViterbiNode>[];
    final eos = lattice.nodes.last.first;

    var nodeBack = eos.prev;
    while (nodeBack != null && nodeBack.type != 'BOS') {
      shortestPath.add(nodeBack);
      nodeBack = nodeBack.prev;
    }

    return shortestPath.reversed.toList();
  }
}
