/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'package:fraction/fraction.dart';
import 'dart:math' as math;

import 'package:graph_translator/state/graph.dart';

class DirectedNode<EdgeType extends DirectedEdge> extends Component {
  /// Stores the incoming and outgoing edges
  List<EdgeType> outEdges, inEdges;

  DirectedNode(
      {List<EdgeType> outEdges, List<EdgeType> inEdges, double x, double y})
      : outEdges = outEdges ?? [],
        inEdges = inEdges ?? [],
        super(x: x, y: y);

  DirectedNode.random({List<EdgeType> outEdges, List<EdgeType> inEdges})
      : outEdges = outEdges ?? [],
        inEdges = inEdges ?? [],
        super.random();

  /// Returns the edge idx that connects nd to this
  int incomingEdgeIdxFrom(DirectedNode<EdgeType> nd) =>
      inEdges.indexWhere((element) => element.source == nd);

  /// Returns the edge idx that connects this to nd
  int outgoingEdgeIdxTo(DirectedNode<EdgeType> nd) =>
      outEdges.indexWhere((element) => element.destination == nd);

  /// Returns the edge that connects nd to this
  EdgeType incomingEdgeFrom(DirectedNode<EdgeType> nd) =>
      inEdges.firstWhere((element) => element.source == nd, orElse: () => null);

  /// Returns the edge that connects this to nd
  EdgeType outgoingEdgeTo(DirectedNode<EdgeType> nd) => outEdges
      .firstWhere((element) => element.destination == nd, orElse: () => null);
}

/// The general interface of a directed edge
abstract class DirectedEdge {
  DirectedNode<DirectedEdge> destination, source;

  DirectedEdge(this.source, this.destination);
}

/// A weigthed implementation of [DirectedEdge]
class DirectedWeightedEdge extends DirectedEdge {
  Fraction weight;

  DirectedWeightedEdge(DirectedNode source, DirectedNode destination,
      [Fraction weight])
      : weight = weight ?? Fraction(1),
        super(source, destination);
}

/// An unweighted implementation of [DirectedEdge]
class DirectedUnweightedEdge extends DirectedEdge {
  DirectedUnweightedEdge(DirectedNode source, DirectedNode destination)
      : super(source, destination);
}

class DirectedGraph<NodeType extends DirectedNode,
    EdgeType extends DirectedEdge> extends Component {
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
    var idxOut = edge.source.outgoingEdgeIdxTo(edge.destination);
    var idxIn = edge.destination.incomingEdgeIdxFrom(edge.source);
    if (idxOut == -1 && idxIn != -1 || idxOut != -1 && idxIn == -1)
      throw Exception('Graph is in invalid state. Please fix');

    bool r1 = true, r2 = true;
    if (idxOut != -1) {
      if (replace) edge.source.outEdges[idxOut] = edge;
      r1 = replace;
    } else {
      edge.source.outEdges.add(edge);
    }

    if (idxIn != -1) {
      if (replace) edge.destination.inEdges[idxIn] = edge;
      r2 = replace;
    } else {
      edge.destination.inEdges.add(edge);
    }

    return r1 && r2;
  }
}
