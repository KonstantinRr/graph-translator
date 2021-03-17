import 'package:fraction/fraction.dart';
import 'package:graph_translator/state/graph.dart';
import 'package:quiver/core.dart';

class UndirectedNode<EdgeType extends UndirectedEdge> extends Component {
  List<EdgeType> edges;

  UndirectedNode({double x, double y, List<EdgeType> edges})
      : edges = edges ?? [],
        super(x: x, y: y);

  UndirectedNode.random([List<EdgeType> edges])
      : edges = edges ?? [],
        super.random();

  /// Returns the edge idx that connects nd to this
  int edgeIdxTo(UndirectedNode<EdgeType> nd) =>
      edges.indexWhere((element) => element.v1 == nd || element.v2 == nd);

  /// Returns the edge idx that connects this to nd
  EdgeType edgeTo(UndirectedNode<EdgeType> nd) =>
      edges.firstWhere((element) => element.v1 == nd || element.v2 == nd,
          orElse: () => null);
}

abstract class UndirectedEdge {
  UndirectedNode<UndirectedEdge> v1, v2;

  UndirectedEdge(this.v1, this.v2);

  bool operator ==(o) => o is UndirectedEdge && v1 == v2 || v2 == v1;
  int get hashCode => hash2(v1.hashCode, v2.hashCode);
}

class UndirectedUnweightedEdge extends UndirectedEdge {
  UndirectedUnweightedEdge(UndirectedNode v1, UndirectedNode v2)
      : super(v1, v2);

  bool operator ==(o) => o is UndirectedEdge && super == o;
  int get hashCode => super.hashCode;
}

class UndirectedWeightedEdge extends UndirectedEdge {
  Fraction weight;
  UndirectedWeightedEdge(UndirectedNode v1, UndirectedNode v2,
      [Fraction weight])
      : weight = weight ?? Fraction(1),
        super(v1, v2);

  bool operator ==(o) => o is UndirectedEdge && super == o;
  int get hashCode => super.hashCode;
}

class GraphUndirected<NodeType extends UndirectedNode,
    EdgeType extends UndirectedEdge> {
  List<NodeType> nodes;

  bool addEdge(EdgeType edge, {bool replace = true}) {
    var nd1Idx = edge.v1.edgeIdxTo(edge.v2);
    var nd2Idx = edge.v2.edgeIdxTo(edge.v1);

    if (nd1Idx != -1) {
      if (replace) edge.v1.edges[nd1Idx] = edge;
    } else {
      edge.v1.edges.add(edge);
    }
    if (nd2Idx != -1) {
      if (replace) edge.v2.edges[nd2Idx] = edge;
    } else
      edge.v2.edges.add(edge);
    return true;
  }
}
