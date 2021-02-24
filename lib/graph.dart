/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'package:flutter/painting.dart';
import 'dart:math' as math;

import 'package:vector_math/vector_math.dart';

class Node {
  double x, y;
  List<Edge> outEdges, inEdges;

  Node(this.x, this.y, [List<Edge> outEdges, List<Edge> inEdges]) :
    outEdges = outEdges ?? [],
    inEdges = inEdges ?? [];

  Offset get offset => Offset(x, y);
  Vector2 get vec => Vector2(x, y);
}

class Edge {
  Node destination, source;

  Edge(this.source, this.destination);
}

class DirectedGraph {
  List<Node> nodes;

  void simulatePositions(double maxWidth, double maxHeight, int iterations) {
    var rand = math.Random();
    for (var nd in nodes) {
      nd.x = rand.nextDouble() * maxWidth;
      nd.y = rand.nextDouble() * maxHeight;
    }

    for (var t = 0; t < iterations; t++) {
      List<Vector2> newPositions = List.filled(nodes.length, Vector2.zero());
      for (var i = 0; i < nodes.length; i++) {
        Vector2 force = Vector2.zero();
        for (var edge in nodes[i].outEdges) {
          Vector2 distance = edge.source.vec - edge.destination.vec;
          //distance.length2;
          //distance.normalized() * ;
        }
        newPositions[i] = force;
      }
      // Applies the new positions
      for (var i = 0; i < nodes.length; i++) {
        nodes[i].x = newPositions[i].x;
        nodes[i].y = newPositions[i].y;
      }
    }
  }

  DirectedGraph([List<Node> nodes]) : nodes = nodes ?? [];
  DirectedGraph.example() {
    var rand = math.Random();
    nodes = [];
    for (var i = 0; i < 10; i++) {
      nodes.add(Node(
        rand.nextDouble() * 600,
        rand.nextDouble() * 600,
      ));
    }

    for (var i = 0; i < 10; i++) {
      Node start = nodes[rand.nextInt(nodes.length)];
      Node end = nodes[rand.nextInt(nodes.length)];
      var edge = Edge(start, end);
      start.outEdges.add(edge);
      end.inEdges.add(edge);
    }
  }
}
