/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:graph_translator/state/graph.dart';
import 'package:graph_translator/state/graph_undirected.dart';
import 'package:graph_translator/state/model_general.dart';

class GlobalThresholdNode extends UndirectedNode {
  bool state = false;
  GlobalThresholdNode({double? x, double? y}) : super(x: x, y: y);

  @override
  void read(Map<String, dynamic> data) {
    super.read(data);
    // TODO
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': typeToString<GlobalThresholdNode>(),
        'parent': super.toJson(),
        'state': state,
      };
}

class GlobalThresholdGraph extends GraphUndirected {
  final double threshold;

  GlobalThresholdGraph(this.threshold);

  @override
  UndirectedNode createNode() => GlobalThresholdNode();
  UndirectedEdge createEdge(UndirectedNode n1, UndirectedNode n2) =>
      UndirectedUnweightedEdge(n1, n2);

  @override
  GlobalThresholdGraphPainter painter(PaintSettings settings) =>
      GlobalThresholdGraphPainter(settings, this);

  @override
  void read(Map<String, dynamic> data) {
    super.read(data);
    // TODO
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': typeToString<GlobalThresholdGraph>(),
        'parent': super.toJson(),
        'threshold': threshold,
      };
}

class GlobalThresholdGraphPainter extends UndirectedGraphPainter {
  GlobalThresholdGraphPainter(
      PaintSettings settings, GlobalThresholdGraph graph)
      : super(settings, graph);

  void drawText(Canvas canvas, Offset offset, String text) {
    var span = TextSpan(
      style: TextStyle(color: Colors.grey[600]),
      text: text,
    );
    var tp = TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, offset);
  }

  @override
  void paint(Canvas canvas, Size csize) {
    var rect = size();
    paintRectBorder(canvas, csize, rect: rect);
    drawText(canvas, rect.topLeft, 'GlobalThresholdModel');

    var render = <UndirectedEdge>{};

    // perform rendering
    for (var node in undirected.nodes) {
      render.addAll(node.edges);
    }

    // render all edges to other nodes
    for (var edge in render) {
      edge.painter(settings).paint(canvas, csize);
    }
    settings.addVarSave('nodeColor', Colors.green);
    for (var node in undirected.nodes) {
      settings.setVar('nodeColor',
          (node as GlobalThresholdNode).state ? Colors.green : Colors.red);
      node.painter(settings).paint(canvas, csize);
    }
    settings.restore();
  }

  @override
  void read(Map<String, dynamic> data) {
    super.read(data);
    // TODO
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': typeToString<GlobalThresholdGraphPainter>(),
        'parent': super.toJson(),
      };
}

class ModelThreshold extends ModelGeneral {
  @override
  void reset() {}

  @override
  void computeStep() {}
}
