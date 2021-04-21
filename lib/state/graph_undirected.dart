/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:fraction/fraction.dart';
import 'package:graph_translator/state/graph.dart';

class UndirectedNode extends Node {
  List<UndirectedEdge> edges;

  UndirectedNode({
    double? x,
    double? y,
    List<UndirectedEdge>? edges,
  }) : edges = edges ?? [] {
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
      if (element.p1 == nd || element.p2 == nd) return element;
    return null;
  }

  @override
  void read(Map<String, dynamic> data) {
    super.read(data);
    // TODO
  }

  Map<String, dynamic> toJson() => {
        'type': typeToString<UndirectedNode>(),
        'parent': super.toJson(),
        'edges': edges.map((e) => e.toJson()),
      };
}

class UndirectedEdgePainter extends EdgePainter {
  const UndirectedEdgePainter(PaintSettings settings, UndirectedEdge edge)
      : super(settings, edge);

  UndirectedEdge get edge => connector as UndirectedEdge;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  @override
  void read(Map<String, dynamic> data) {
    super.read(data);
    // TODO
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': typeToString<UndirectedEdgePainter>(),
        'parent': super.toJson(),
      };
}

abstract class UndirectedEdge extends Component
    with ComponentConnector, UndirectedComponentConnector
    implements Paintable {
  @override
  UndirectedEdgePainter painter(PaintSettings settings) =>
      UndirectedEdgePainter(settings, this);

  @override
  void read(Map<String, dynamic> data) {
    super.read(data);
    // TODO
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': typeToString<UndirectedEdge>(),
        'parent': super.toJson(),
      };
}

class UndirectedUnweightedEdge extends UndirectedEdge {
  UndirectedUnweightedEdge(UndirectedNode v1, UndirectedNode v2) {
    setComponents(v1, v2);
  }

  @override
  void read(Map<String, dynamic> data) {
    super.read(data);
    // TODO
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'UndirectedUnweightedEdge',
        'parent': super.toJson(),
      };
}

class UndirectedWeightedEdge extends UndirectedEdge with Weighted {
  UndirectedWeightedEdge(UndirectedNode v1, UndirectedNode v2,
      [Fraction? weight]) {
    setWeightIf(weight);
    setComponents(v1, v2);
  }

  @override
  void read(Map<String, dynamic> data) {
    super.read(data);
    // TODO
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': typeToString<UndirectedWeightedEdge>(),
        'parent': super.toJson(),
        'weight': weight
      };
}

class GraphUndirected extends Graph {
  List<UndirectedNode> nodes;

  GraphUndirected([List<UndirectedNode>? nodes]) : nodes = nodes ?? [];

  @override
  List<Node> get listNodes => nodes;

  void removeComponent(Component component) {
    if (component is UndirectedNode) {
      var result = nodes.remove(component);
      // removes subcomponents
      if (result) {
        component.edges.forEach((element) {
          (element.p1 as UndirectedNode).edges.remove(element);
          (element.p2 as UndirectedNode).edges.remove(element);
        });
        component.edges.clear();
      }
    }
  }

  /// Creates a randomized graph with the given node and connection count.
  /// The default [nodeCount] is 10, the default [connectionCount] is 20
  void random({int? nodeCount, int? connectionCount}) {
    // The random object that is used in this function
    final rand = math.Random();
    // sets the default nodeCount and connectionCount
    nodeCount ??= 10;
    connectionCount ??= 20;

    nodes = [];
    for (var i = 0; i < nodeCount; i++) {
      nodes.add(createNode()..randPosition());
    }

    for (var i = 0; i < connectionCount; i++) {
      var start = nodes[rand.nextInt(nodes.length)];
      var end = nodes[rand.nextInt(nodes.length)];
      var edge = createEdge(start, end);
      addEdge(edge);
    }
  }

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
  UndirectedEdge createEdge(UndirectedNode n1, UndirectedNode n2) =>
      UndirectedUnweightedEdge(n1, n2);

  @override
  Iterable<Component> get children => nodes;

  @override
  void read(Map<String, dynamic> data) {
    super.read(data);
    // TODO
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': typeToString<GraphUndirected>(),
        'parent': super.toJson(),
      };

  @override
  UndirectedGraphPainter painter(PaintSettings settings) =>
      UndirectedGraphPainter(settings, this);
}

class UndirectedGraphPainter extends SuperComponentPainter {
  final bool skipInvisible;
  UndirectedGraphPainter(PaintSettings settings, GraphUndirected graph,
      {this.skipInvisible = false})
      : super(settings, graph);

  GraphUndirected get undirected => component as GraphUndirected;

  @override
  void paint(Canvas canvas, Size size) {
    var render = <UndirectedEdge>{};

    // perform rendering
    for (var node in undirected.nodes) {
      render.addAll(node.edges);
    }

    // render all edges to other nodes
    for (var edge in render) {
      edge.painter(settings).paint(canvas, size);
    }
    for (var node in undirected.nodes) {
      node.painter(settings).paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  @override
  void read(Map<String, dynamic> data) {
    super.read(data);
    // TODO
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': typeToString<UndirectedGraphPainter>(),
        'parent': super.toJson(),
        'skipInvisible': skipInvisible,
      };
}
