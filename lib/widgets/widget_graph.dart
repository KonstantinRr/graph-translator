/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:graph_translator/state/graph.dart';

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

class GraphControllerState {
  final DirectedGraph graph;
  final GraphTranslator translator;
  const GraphControllerState(this.graph, this.translator);
}

class GraphController {
  DirectedGraph _graph;
  GraphTranslator _translator;
  StreamController<GraphControllerState> _controller;

  GraphController({DirectedGraph graph, GraphTranslator translator}) :
    _controller = StreamController.broadcast(),
    _graph = graph ?? DirectedGraph(),
    _translator = translator ?? GraphTranslator();

  Stream<GraphControllerState> get events => _controller.stream;
  GraphControllerState get state => GraphControllerState(_graph, _translator);

  GraphTranslator get translator => _translator;
  DirectedGraph get graph => _graph;

  set graph(DirectedGraph graph) {
    if (_graph != graph) {
      _graph = graph;
      notify();
    }
  }

  set translator(GraphTranslator translator) {
    if (_translator != translator) {
      _translator = translator;
      notify();
    }
  }

  void updateGraphState(
    void Function(DirectedGraph) func, {bool nt=true}) {
    func(_graph);
    notify(nt);
  }

  void updateViewState(
    void Function(GraphTranslator) func, {bool nt=true}) {
    func(_translator);
    notify(nt);
  }

  void notify([bool nt=true]) {
    if (nt) _controller.add(state);
  }

  void dispose() {
    _controller.close();
  }
}

class GraphWidget extends StatelessWidget {
  final GraphController controller;

  GraphWidget({@required this.controller, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(),
      child: Listener(
      //onPointerDown: (event) { print('Down'); },
      //onPointerHover: (event) { print('Hover'); },
      onPointerMove: (moveEvent) {
        controller.updateViewState((view) {
          view.applyTranslation(-moveEvent.delta * controller.translator.zoom);
        });
      },
      behavior: HitTestBehavior.opaque,
      child: StreamBuilder<GraphControllerState>(
        stream: controller.events,
        initialData: controller.state,
        builder: (context, snap) {
          if (snap.hasError)
            return Center(child: Text('Error'));
          if (snap.hasData) {
            return CustomPaint(
              painter: GraphPainter(
                snap.data.graph,
                snap.data.translator,
              ),
            );
          }
          return Center(child: Text('No Data'));
        }
      )
    ));
  }
}
