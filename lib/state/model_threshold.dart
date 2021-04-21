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
}

class GlobalThresholdGraphPainter extends UndirectedGraphPainter {
  GlobalThresholdGraphPainter(
      PaintSettings settings, GlobalThresholdGraph graph)
      : super(settings, graph);

  @override
  void paint(Canvas canvas, Size size) {
    paintRectBorder(canvas, size);

    var render = <UndirectedEdge>{};

    // perform rendering
    for (var node in undirected.nodes) {
      render.addAll(node.edges);
    }

    // render all edges to other nodes
    for (var edge in render) {
      edge.painter(settings).paint(canvas, size);
    }
    settings.addVarSave('nodeColor', Colors.green);
    for (var node in undirected.nodes) {
      settings.setVar('nodeColor',
          (node as GlobalThresholdNode).state ? Colors.green : Colors.red);
      node.painter(settings).paint(canvas, size);
    }
    settings.restore();
  }
}

class ModelThreshold extends ModelGeneral {
  @override
  void reset() {}

  @override
  void computeStep() {}
}
