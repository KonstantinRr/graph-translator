/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'package:fraction/fraction.dart';
import 'dart:math' as math;

import 'package:graph_translator/state/graph.dart';
import 'package:flutter/material.dart';

class DirectedNode extends Component with ComponentObject {
  /// Stores the incoming and outgoing edges
  List<DirectedEdge> outEdges, inEdges;

  DirectedNode(
      {List<DirectedEdge>? outEdges,
      List<DirectedEdge>? inEdges,
      double? x,
      double? y})
      : outEdges = outEdges ?? [],
        inEdges = inEdges ?? [] {
    setCoords(x, y);
  }
  DirectedNode.random({List<DirectedEdge>? outEdges, List<DirectedEdge>? inEdges})
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
  DirectedEdge? incomingEdgeFrom(DirectedNode nd) {
    for (var element in inEdges) {
      if (element.p1 == nd) return element;
    }
    return null;
  }

  /// Returns the edge that connects this to nd
  DirectedEdge? outgoingEdgeTo(DirectedNode nd) {
    for (var element in outEdges) {
      if (element.p2 == nd) return element;
    }
    return null;
  }

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
      [Fraction? weight])
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
  Map<String, dynamic> toJson() => {};
}

abstract class NodeList<T> {
  List<T> get nodes;
}

class DirectedGraph extends SuperComponent implements Paintable {
  late List<DirectedNode> nodes;

  DirectedGraph([List<DirectedNode>? nodes]) : nodes = nodes ?? [];
  DirectedGraph.example({int? nodeCount, int? connectionCount}) {
    random(nodeCount: nodeCount, connectionCount: connectionCount);
  }

  DirectedNode createNode() => DirectedNode();
  DirectedEdge createdEdge(DirectedNode n1, DirectedNode n2) => DirectedUnweightedEdge(n1, n2);

  /// Creates a randomized graph with the given node and connection count.
  /// The default [nodeCount] is 10, the default [connectionCount] is 20
  void random(
      {int? nodeCount,
      int? connectionCount}) {
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
      var edge = createdEdge(start, end);
      addEdge(edge);
    }
  }

  bool addEdge(DirectedEdge edge, {bool replace = true}) {
    DirectedNode source = edge.source as DirectedNode,
      destination = edge.destination as DirectedNode;

    var idxOut = source.outgoingEdgeIdxTo(destination);
    var idxIn = destination.incomingEdgeIdxFrom(source);
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

  @override
  DirectedGraphPainter painter() => DirectedGraphPainter(this);
}


class DirectedGraphPainter extends ComponentPainter {
  final DirectedGraph graph;
  final bool skipInvisible;
  DirectedGraphPainter(this.graph, {this.skipInvisible = false});

  @override
  void paint(Canvas canvas, Size size) {
    var radius = 5.0;

    var nodePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black;

    var edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black;

    // perform rendering
    //int count = 0;
    for (var node in graph.nodes) {
      if (skipInvisible) {
        //Rect renderRect = Rect.fromPoints(
        //  pointScale(Offset.zero), pointScale(Offset(size.width, size.height)));
        //var rect = Rect.fromCircle(center: node.offset, radius: radius);
        //if (rect.overlaps(renderRect)) {
        //  canvas.drawCircle(node.offset, radius, nodePaint);
        //  //count++;
        //}
        canvas.drawCircle(node.offset, radius, nodePaint);
      } else {
        canvas.drawCircle(node.offset, radius, nodePaint);
      }
      // render all edges to other nodes
      for (var edge in node.outEdges) {
        if (edge.source != null && edge.destination != null)
          canvas.drawLine(
            (edge.source as ComponentObject).offset,
            (edge.destination as ComponentObject).offset,
            edgePaint,
          );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}