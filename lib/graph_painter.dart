

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:graph_translator/graph.dart';

class GraphTranslator {
  double zoom;
  double dx, dy;

  GraphTranslator({this.zoom = 1.0, this.dx = 0.0, this.dy = 0.0});

  bool operator ==(o) => o is GraphTranslator &&
    o.zoom == zoom && o.dx == dx && o.dy == dy;

  void applyZoom(double azoom) {
    zoom *= azoom;
  }

  void applyTranslation(Offset offset) {
    dx += offset.dx;
    dy += offset.dy;
  }

  @override
  int get hashCode => hashValues(zoom, dx, dy);
}

class GraphPainter extends CustomPainter {
  final GraphTranslator translator;
  final DirectedGraph graph;
  const GraphPainter(this.graph, this.translator);

  Offset pointScale(Offset offset) {
    return Offset(
      (offset.dx + translator.dx) * translator.zoom,
      (offset.dy + translator.dy) * translator.zoom
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // applies rendering transformations
    //canvas.scale(1.0 / max(size.width, size.height));
    canvas.translate(-translator.dx, -translator.dy);
    canvas.scale(translator.zoom);

    Rect renderRect = Rect.fromPoints(
      pointScale(Offset.zero),
      pointScale(Offset(size.width, size.height))
    );
    const radius = 5.0;
    
    var nodePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black;

    var edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black;

    // perform rendering
    //int count = 0;
    for (var node in graph.nodes) {
      var rect = Rect.fromCircle(center: node.offset, radius: radius);
      if (rect.overlaps(renderRect)) {
        canvas.drawCircle(node.offset, radius, nodePaint);
        //count++;
      }
      // render all edges to other nodes
      for (var edge in node.outEdges) {
        canvas.drawLine(edge.source.offset,
          edge.destination.offset, edgePaint);
      }
    }
    canvas.restore();
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}