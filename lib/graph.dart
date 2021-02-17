

import 'package:flutter/painting.dart';
import 'dart:math' as math;

class Node {
  double x, y;
  List<Edge> outEdges, inEdges;

  Offset get offset => Offset(x, y);

  Node(this.x, this.y, [List<Edge> outEdges, List<Edge> inEdges]) :
    outEdges = outEdges ?? [], inEdges = inEdges ?? [];
}

class Edge {
  Node destination, source;

  Edge(this.source, this.destination);
}

class DirectedGraph {
  List<Node> nodes;

  DirectedGraph([List<Node> nodes]) : nodes = nodes ?? [];
  DirectedGraph.example() {
    var rand = math.Random();
    nodes = [];
    for (var i = 0; i < 1000; i++) {
      nodes.add(Node(
        rand.nextDouble() * 600,
        rand.nextDouble() * 600,
      ));
    }
  }
}
