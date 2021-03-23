import 'package:fraction/fraction.dart';
import 'package:graph_translator/state/graph.dart';

class UndirectedNode<EdgeType extends UndirectedEdge> extends Component
    with ComponentObject {
  List<EdgeType> edges;

  UndirectedNode({double x, double y, List<EdgeType> edges})
      : edges = edges ?? [] {
    setCoords(x, y);
  }

  UndirectedNode.random([List<EdgeType> edges]) : edges = edges ?? [] {
    randPosition();
  }

  /// Returns the edge idx that connects nd to this
  int edgeIdxTo(UndirectedNode<EdgeType> nd) =>
      edges.indexWhere((element) => element.p1 == nd || element.p2 == nd);

  /// Returns the edge idx that connects this to nd
  EdgeType edgeTo(UndirectedNode<EdgeType> nd) =>
      edges.firstWhere((element) => element.p1 == nd || element.p2 == nd,
          orElse: () => null);

  @override
  void read(Map<String, dynamic> map) {}
  Map<String, dynamic> toJson() => {'edges': edges.map((e) => e.toJson())};
}

abstract class UndirectedEdge extends Component
    with ComponentConnector, UndirectedComponentConnector {}

class UndirectedUnweightedEdge extends UndirectedEdge {
  UndirectedUnweightedEdge(UndirectedNode v1, UndirectedNode v2) {
    setComponents(v1, v2);
  }

  @override
  void read(Map<String, dynamic> map) {}

  @override
  Map<String, dynamic> toJson() => {};
}

class UndirectedWeightedEdge extends UndirectedEdge {
  Fraction weight;
  UndirectedWeightedEdge(UndirectedNode v1, UndirectedNode v2,
      [Fraction weight])
      : weight = weight ?? Fraction(1) {
    setComponents(v1, v2);
  }

  @override
  void read(Map<String, dynamic> map) {}

  @override
  Map<String, dynamic> toJson() => {};
}

class GraphUndirected<NodeType extends UndirectedNode,
    EdgeType extends UndirectedEdge> extends SuperComponent {
  List<NodeType> nodes;

  bool addEdge(EdgeType edge, {bool replace = true}) {
    if (!(edge.p1 is UndirectedNode) || !(edge.p2 is UndirectedNode))
      throw FormatException('Edge must point to instance of UndirectedNode');
    UndirectedNode p1 = edge.p1, p2 = edge.p2;
    var nd1Idx = p1.edgeIdxTo(edge.p2);
    var nd2Idx = p2.edgeIdxTo(edge.p1);

    if (nd1Idx != -1) {
      if (replace) p1.edges[nd1Idx] = edge;
    } else {
      p1.edges.add(edge);
    }
    if (nd2Idx != -1) {
      if (replace) p2.edges[nd2Idx] = edge;
    } else
      p2.edges.add(edge);
    return true;
  }

  @override
  List<Component> children() => nodes;

  @override
  void read(Map<String, dynamic> map) {}

  @override
  Map<String, dynamic> toJson() =>
      {'nodes': nodes.map((e) => e.toJson()).toList()};
}
