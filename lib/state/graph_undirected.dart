import 'package:flutter/material.dart';
import 'package:fraction/fraction.dart';
import 'package:graph_translator/state/graph.dart';

class UndirectedNode extends Node {
  List<UndirectedEdge> edges;

  UndirectedNode({double ?x, double ?y, List<UndirectedEdge>? edges,})
      : edges = edges ?? [] {
    setCoords(x, y);
  }

  UndirectedNode.random([List<UndirectedEdge>? edges]) : edges = edges ?? [] {
    randPosition();
  }

  /// Returns the edge idx that connects nd to this
  int edgeIdxTo(UndirectedNode nd) =>
      edges.indexWhere((element) => element.p1 == nd || element.p2 == nd);

  /// Returns the edge idx that connects this to nd
  UndirectedEdge? edgeTo(UndirectedNode nd) {
    for (var element in edges)
      if (element.p1 == nd || element.p2 == nd)
        return element;
    return null;
  }

  @override
  void read(Map<String, dynamic> map) {}
  Map<String, dynamic> toJson() => {
        'type': typeToString<UndirectedNode>(),
        'parent': super.toJson(),
        'edges': edges.map((e) => e.toJson()),
      };
}

class UndirectedEdgePainter extends ComponentPainter {
  final UndirectedEdge edge;
  const UndirectedEdgePainter(this.edge);

  @override
  void paint(Canvas canvas, Size size) {
    var edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black;

    if (edge.p1 != null && edge.p2 != null)
      canvas.drawLine(
        edge.p1!.offset,
        edge.p2!.offset,
        edgePaint,
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

abstract class UndirectedEdge extends Component
    with ComponentConnector, UndirectedComponentConnector implements Paintable{
  @override
  UndirectedEdgePainter painter() => UndirectedEdgePainter(this);
}

class UndirectedUnweightedEdge extends UndirectedEdge {
  UndirectedUnweightedEdge(UndirectedNode v1, UndirectedNode v2) {
    setComponents(v1, v2);
  }

  @override
  void read(Map<String, dynamic> map) {}

  @override
  Map<String, dynamic> toJson() => {
        'type': 'UndirectedUnweightedEdge',
        'parent': super.toJson(),
      };
}

class UndirectedWeightedEdge extends UndirectedEdge {
  Fraction weight;
  UndirectedWeightedEdge(UndirectedNode v1, UndirectedNode v2,
      [Fraction? weight])
      : weight = weight ?? Fraction(1) {
    setComponents(v1, v2);
  }

  @override
  void read(Map<String, dynamic> map) {}

  @override
  Map<String, dynamic> toJson() => {
        'type': typeToString<UndirectedWeightedEdge>(),
        'parent': super.toJson(),
        'weight': weight
      };
}

abstract class GraphUndirected extends SuperComponent {
  List<UndirectedNode> nodes = [];

  bool addEdge(UndirectedEdge edge, {bool replace = true}) {
    if (!(edge.p1 is UndirectedNode) || !(edge.p2 is UndirectedNode))
      throw FormatException('Edge must point to instance of UndirectedNode');
    UndirectedNode p1 = edge.p1 as UndirectedNode,
      p2 = edge.p2 as UndirectedNode;
    var nd1Idx = p1.edgeIdxTo(p2);
    var nd2Idx = p2.edgeIdxTo(p1);

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

  UndirectedNode createNode() => UndirectedNode();
  UndirectedEdge createEdge(UndirectedNode n1, UndirectedNode n2) => UndirectedUnweightedEdge(n1, n2);

  @override
  Iterable<Component> get children => nodes;

  @override
  void read(Map<String, dynamic> map) {}

  @override
  Map<String, dynamic> toJson() => {
        'type': typeToString<GraphUndirected>(),
        'parent': super.toJson(),
        'nodes': nodes.map((e) => e.toJson()).toList(),
      };
}
