/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'package:fraction/fraction.dart';
import 'dart:math' as math;

import 'package:graph_translator/state/graph.dart';

class DirectedNode extends Component with ComponentObject {
  /// Stores the incoming and outgoing edges
  List<DirectedEdge> outEdges, inEdges;

  DirectedNode(
      {List<DirectedEdge> outEdges,
      List<DirectedEdge> inEdges,
      double x,
      double y})
      : outEdges = outEdges ?? [],
        inEdges = inEdges ?? [] {
    setCoords(x, y);
  }
  DirectedNode.random({List<DirectedEdge> outEdges, List<DirectedEdge> inEdges})
      : outEdges = outEdges ?? [],
        inEdges = inEdges ?? [] {
    randPosition();
  }

  /// Returns the edge idx that connects nd to this
  int incomingEdgeIdxFrom(DirectedNode nd) =>
      inEdges.indexWhere((element) => element.p1 == nd);

  /// Returns the edge idx that connects this to nd
  int outgoingEdgeIdxTo(DirectedNode nd) =>
      outEdges.indexWhere((element) => element.p2 == nd);

  /// Returns the edge that connects nd to this
  DirectedEdge incomingEdgeFrom(DirectedNode nd) =>
      inEdges.firstWhere((element) => element.p1 == nd, orElse: () => null);

  /// Returns the edge that connects this to nd
  DirectedEdge outgoingEdgeTo(DirectedNode nd) =>
      outEdges.firstWhere((element) => element.p2 == nd, orElse: () => null);

  @override
  void read(Map<String, dynamic> map) {}

  @override
  Map<String, dynamic> toJson() => {'type': typeToString<DirectedNode>()};
}

/// The general interface of a directed edge
abstract class DirectedEdge extends Component
    with ComponentConnector, DirectedComponentConnector {}

/// A weigthed implementation of [DirectedEdge]
class DirectedWeightedEdge extends DirectedEdge {
  Fraction weight;

  DirectedWeightedEdge(DirectedNode source, DirectedNode destination,
      [Fraction weight])
      : weight = weight ?? Fraction(1) {
    setComponents(source, destination);
  }

  @override
  void read(Map<String, dynamic> map) {}

  @override
  Map<String, dynamic> toJson() => {};
}

/// An unweighted implementation of [DirectedEdge]
class DirectedUnweightedEdge extends DirectedEdge {
  DirectedUnweightedEdge(DirectedNode source, DirectedNode destination) {
    setComponents(source, destination);
  }

  @override
  void read(Map<String, dynamic> map) {}

  @override
  Map<String, dynamic> toJson() {}
}

class DirectedGraph<NodeType extends DirectedNode,
    EdgeType extends DirectedEdge> extends SuperComponent {
  List<NodeType> nodes;

  DirectedGraph([List<NodeType> nodes]) : nodes = nodes ?? [];
  DirectedGraph.example({int nodeCount, int connectionCount}) {
    random(nodeCount: nodeCount, connectionCount: connectionCount);
  }

  /// Creates a randomized graph with the given node and connection count.
  /// The default [nodeCount] is 10, the default [connectionCount] is 20
  void random(
      {int nodeCount,
      int connectionCount,
      NodeType Function() nodeCreator,
      EdgeType Function(NodeType, NodeType) edgeCreator}) {
    // The random object that is used in this function
    final rand = math.Random();
    // sets the default nodeCount and connectionCount
    nodeCount ??= 10;
    connectionCount ??= 20;

    if (nodeCreator == null) {
      if (NodeType == DirectedNode)
        nodeCreator = (() => DirectedNode.random() as NodeType);
      else
        throw Exception(
            'Cannot identify default creator for generic node type');
    }

    if (edgeCreator == null) {
      if (EdgeType == DirectedUnweightedEdge)
        edgeCreator = ((v1, v2) => DirectedUnweightedEdge(v1, v2) as EdgeType);
      else if (EdgeType == DirectedWeightedEdge)
        edgeCreator = ((v1, v2) => DirectedWeightedEdge(v1, v2) as EdgeType);
      else
        throw Exception('Cannot identify default function for generic type');
    }

    nodes = [];
    for (var i = 0; i < nodeCount; i++) nodes.add(nodeCreator());

    for (var i = 0; i < connectionCount; i++) {
      NodeType start = nodes[rand.nextInt(nodes.length)];
      NodeType end = nodes[rand.nextInt(nodes.length)];
      var edge = edgeCreator(start, end);
      addEdge(edge);
    }
  }

  bool addEdge(EdgeType edge, {bool replace = true}) {
    if (!(edge is DirectedEdge))
      throw FormatException('Edge must be instance of DirectedEdge');
    DirectedNode source = edge.source, destination = edge.destination;

    var idxOut = source.outgoingEdgeIdxTo(edge.destination);
    var idxIn = destination.incomingEdgeIdxFrom(edge.source);
    if (idxOut == -1 && idxIn != -1 || idxOut != -1 && idxIn == -1)
      throw Exception('Graph is in invalid state. Please fix');

    bool r1 = true, r2 = true;
    if (idxOut != -1) {
      if (replace) source.outEdges[idxOut] = edge;
      r1 = replace;
    } else {
      source.outEdges.add(edge);
    }

    if (idxIn != -1) {
      if (replace) destination.inEdges[idxIn] = edge;
      r2 = replace;
    } else
      destination.inEdges.add(edge);

    return r1 && r2;
  }

  @override
  Iterable<Component> get children => nodes;

  @override
  void read(Map<String, dynamic> map) {}

  @override
  Map<String, dynamic> toJson() => {};
}
