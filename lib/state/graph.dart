/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'package:flutter/painting.dart';
import 'package:fraction/fraction.dart';
import 'dart:math' as math;

import 'package:vector_math/vector_math.dart';

abstract class GraphInterface {

  void update();
}

class Node {
  /// Stores the coordinates 
  double x, y;
  List<Edge> outEdges, inEdges;

  Node(this.x, this.y, [List<Edge> outEdges, List<Edge> inEdges]) :
    outEdges = outEdges ?? [],
    inEdges = inEdges ?? [];

  Offset get offset => Offset(x, y);
  Vector2 get vec => Vector2(x, y);

  Edge connectsTo(Node nd) =>
    outEdges.firstWhere(
      (element) => element.destination == nd,
      orElse: () => null);
}

class Edge {
  Node destination, source;
  Fraction weight;

  Edge(this.source, this.destination, this.weight);
}

class FunctionSettings {
  final double k;
  final double repellFactor, repellPower;
  final double pullFactor, pullPower;

  const FunctionSettings({this.k = 10.0,
    this.repellFactor = 1.0, this.repellPower = 1.0,
    this.pullFactor = 1.0, this.pullPower = 1.0});
}

class DirectedGraph {
  List<Node> nodes;

  void simulatePositions(int iterations, {
    FunctionSettings nodeSettings, FunctionSettings edgeSettings}) 
  {
    // The default node settings, used if [nodeSettings] is null
    nodeSettings ??= const FunctionSettings(k: 300.0,
      repellFactor: 0.01, repellPower: 1.0,
      pullFactor: 0.0, pullPower: 0.0,
    );
    // The default edge settings, used if [edgeSettings] is null
    edgeSettings ??= const FunctionSettings(k: 100.0,
      repellFactor: 0.0, repellPower: 1.0,
      pullFactor: 0.005 , pullPower: 1.0
    );

    // Defines the force function that returns the force
    // that is applied to the current node.
    var forceFn = (Node nd1, Node nd2, FunctionSettings s) {
      Vector2 distanceVec = nd2.vec - nd1.vec;
      var d = distanceVec.length;
      var factor = 0.0;
      if (d < s.k)
        factor = (s.repellFactor * math.pow(d - s.k, s.repellPower));
      else if (d > s.k)
        factor = (s.pullFactor * math.pow(d - s.k, s.pullPower));
      return distanceVec.normalized() * factor;
    };

    for (var t = 0; t < iterations; t++) {
      List<Vector2> newPositions = List.filled(nodes.length, Vector2.zero());
      for (var i = 0; i < nodes.length; i++) {
        Vector2 force = Vector2.zero();
        for (var edge in nodes[i].outEdges)
          force += forceFn(nodes[i], edge.destination, edgeSettings);
        for (var otherNode in nodes) {
          if (otherNode != nodes[i])
            force += forceFn(nodes[i], otherNode, nodeSettings);
        }
        newPositions[i] = nodes[i].vec + force;
      }

      // Applies the new positions
      for (var i = 0; i < nodes.length; i++) {
        nodes[i].x = newPositions[i].x;
        nodes[i].y = newPositions[i].y;
      }
    }
  }

  DirectedGraph([List<Node> nodes]) : nodes = nodes ?? [];
  DirectedGraph.example({int nodeCount, int connectionCount}) {
    random(nodeCount: nodeCount, connectionCount: connectionCount);
  }

  /// Creates a randomized graph with the given node and connection count.
  /// The default [nodeCount] is 10, the default [connectionCount] is 20
  void random({int nodeCount, int connectionCount, bool directed})
  {
    // The random object that is used in this function
    final rand = math.Random();
    // sets the default nodeCount and connectionCount
    nodeCount ??= 10;
    connectionCount ??= 20;
    directed ??= true;

    nodes = [];
    for (var i = 0; i < nodeCount; i++) {
      nodes.add(Node(
        rand.nextDouble() * 600,
        rand.nextDouble() * 600,
      ));
    }

    for (var i = 0; i < connectionCount; i++) {
      Node start = nodes[rand.nextInt(nodes.length)];
      Node end = nodes[rand.nextInt(nodes.length)];

      if (directed)  
        addDirectedEdge(start, end, Fraction(1));
      else
        addUndirectedEdge(start, end, Fraction(1));
    }
  }

  bool addDirectedEdge(Node start, Node end, Fraction weight, {bool replace=true}) {
    var connectingEdge = start.connectsTo(end);
    if (connectingEdge == null) {
      var edge = Edge(start, end, weight);
      start.outEdges.add(edge);
      end.inEdges.add(edge);
      return true;
    } else if (replace) {
      connectingEdge.weight = weight;
      return true;
    }
    return false;
  }

  bool addUndirectedEdge(Node n1, Node n2, Fraction weight, {bool replace=true}) {
    var edge1 = n1.connectsTo(n2);
    var edge2 = n2.connectsTo(n1);
    var b1 = addDirectedEdge(n1, n2, weight);
    var b2 = addDirectedEdge(n2, n1, weight);
    return b1 || b2;
  }
}
