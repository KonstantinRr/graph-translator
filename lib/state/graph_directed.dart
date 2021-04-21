/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'dart:ui';

import 'package:fraction/fraction.dart';
import 'dart:math' as math;

import 'package:graph_translator/state/graph.dart';
import 'package:flutter/material.dart';
import 'package:graph_translator/util.dart';
import 'package:vector_math/vector_math.dart' as vec;

class DirectedNode extends Node {
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
  DirectedNode.random(
      {List<DirectedEdge>? outEdges, List<DirectedEdge>? inEdges})
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

class DirectedEdgePainter extends EdgePainter {
  final double? _arrowWidth, _arrowLength;
  const DirectedEdgePainter(PaintSettings settings, DirectedEdge edge,
      {double? arrowWidth, double? arrowLength})
      : _arrowWidth = arrowWidth,
        _arrowLength = arrowLength,
        super(settings, edge);

  DirectedEdge get edge => connector as DirectedEdge;

  double get arrowWidth {
    if (_arrowWidth != null) return _arrowWidth!;
    return settings.getVarAlternative<double>('arrowWidth', 5.0);
  }

  double get arrowLength {
    if (_arrowLength != null) return _arrowLength!;
    return settings.getVarAlternative<double>('arrowLength', 5.0);
  }

  double getSize() {
    if (edge.destination is Paintable) {
      var destPainter = (edge.destination as Paintable).painter(settings);
      if (destPainter is NodePainter) return destPainter.radius;
    }
    return 0.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);
    if (edge.source != null && edge.destination != null) {
      var stopDistance = getSize();

      var arrowPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.black;

      var connector =
          (edge.source!.vector - edge.destination!.vector).normalized();
      var stopVector = connector.scaled(stopDistance);
      var dest = (edge.destination!.vector + stopVector);

      var cross =
          vec.Vector2(-arrowWidth * connector.y, arrowWidth * connector.x);
      var t2 = (dest + connector.scaled(arrowLength));
      var q1 = t2 + cross;
      var q2 = t2 - cross;

      var path = Path();
      path.moveTo(dest.x, dest.y);
      path.lineTo(q1.x, q1.y);
      path.lineTo(q2.x, q2.y);
      path.close();

      canvas.drawPath(path, arrowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// The general interface of a directed edge
abstract class DirectedEdge extends Component
    with ComponentConnector, DirectedComponentConnector
    implements Paintable {
  @override
  DirectedEdgePainter painter(PaintSettings settings) =>
      DirectedEdgePainter(settings, this);
}

/// A weigthed implementation of [DirectedEdge]
class DirectedWeightedEdge extends DirectedEdge with Weighted {
  DirectedWeightedEdge(DirectedNode source, DirectedNode destination,
      [Fraction? weight]) {
    setWeightIf(weight);
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

class DirectedGraph extends Graph implements Paintable {
  late List<DirectedNode> nodes;

  List<Node> get listNodes => nodes;

  DirectedGraph([List<DirectedNode>? nodes]) : nodes = nodes ?? [];
  DirectedGraph.example({int? nodeCount, int? connectionCount}) {
    random(nodeCount: nodeCount, connectionCount: connectionCount);
  }

  DirectedNode createNode() => DirectedNode();
  DirectedEdge createdEdge(DirectedNode n1, DirectedNode n2) =>
      DirectedWeightedEdge(n1, n2);

  @override
  void removeComponent(Component component) {
    if (component is DirectedNode) {
      var removed = nodes.remove(component);
      // Removes the sub components and connections
      if (removed) {
        var b1 = component.inEdges
            .map((element) =>
                (element.source as DirectedNode).outEdges.remove(element))
            .any((e) => !e); // any which was not found
        var b2 = component.outEdges
            .map((element) =>
                (element.destination as DirectedNode).inEdges.remove(element))
            .any((e) => !e);
        component.inEdges.clear();
        component.outEdges.clear();
        assert(!b1, 'Value not in source');
        assert(!b2, 'Value not in destination');
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
  DirectedGraphPainter painter(PaintSettings settings) =>
      DirectedGraphPainter(settings, this);
}

class DirectedGraphPainter extends SuperComponentPainter {
  final bool skipInvisible;
  DirectedGraphPainter(PaintSettings settings, DirectedGraph graph,
      {this.skipInvisible = false})
      : super(settings, graph);

  DirectedGraph get directed => component as DirectedGraph;

  @override
  void paint(Canvas canvas, Size size) {
    // perform rendering
    for (var node in directed.nodes) {
      // render all edges to other nodes
      for (var edge in node.outEdges) {
        edge.painter(settings).paint(canvas, size);
      }
    }
    for (var node in directed.nodes) {
      if (skipInvisible) {
        //Rect renderRect = Rect.fromPoints(
        //  pointScale(Offset.zero), pointScale(Offset(size.width, size.height)));
        //var rect = Rect.fromCircle(center: node.offset, radius: radius);
        //if (rect.overlaps(renderRect)) {
        //  canvas.drawCircle(node.offset, radius, nodePaint);
        //  //count++;
        //}
        //canvas.drawCircle(node.offset, radius, nodePaint);
      } else {
        node.painter(settings).paint(canvas, size);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
