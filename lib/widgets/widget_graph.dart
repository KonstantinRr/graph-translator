/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:graph_translator/main.dart';
import 'package:graph_translator/state/graph.dart';
import 'package:graph_translator/state/graph_directed.dart';
import 'package:graph_translator/state_events.dart';

class GraphTranslator {
  double zoom;
  double dx, dy;

  GraphTranslator({this.zoom = 1.0, this.dx = 0.0, this.dy = 0.0});

  void applyZoom(double azoom) {
    zoom *= azoom;
  }

  void applyTranslation(Offset offset) {
    dx += offset.dx / zoom;
    dy += offset.dy / zoom;
  }

  Offset forward(Offset tx) => tx.translate(dx, dy).scale(zoom, zoom);
  Offset reverse(Offset tx) => tx.scale(1 / zoom, 1 / zoom).translate(-dx, -dy);

  Offset get offset => Offset(dx, dy);

  bool operator ==(o) =>
      o is GraphTranslator && o.zoom == zoom && o.dx == dx && o.dy == dy;

  @override
  int get hashCode => hashValues(zoom, dx, dy);
}

class GraphPainter extends CustomPainter {
  final GraphControllerState state;
  final bool skipInvisible;
  const GraphPainter(this.state, {this.skipInvisible = false});

  GraphTranslator get translator => state.translator;
  SuperComponent get graph => state.graph;

  Offset pointScale(Offset offset) {
    return Offset((offset.dx + translator.dx) * translator.zoom,
        (offset.dy + translator.dy) * translator.zoom);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // applies rendering transformations
    //canvas.scale(1.0 / max(size.width, size.height));
    canvas.translate(-translator.dx, -translator.dy);
    canvas.scale(translator.zoom);

    if (state.graph is Paintable)
      (state.graph as Paintable).painter().paint(canvas, size);

    if (state.source != null && state.destination != null) {
      var paint = Paint()
        ..color = Colors.blue.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromPoints(
        state.source as Offset,
        state.destination as Offset
      ), paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class GraphControllerState {
  final SuperComponent graph;
  final GraphTranslator translator;
  final Offset? source, destination;
  const GraphControllerState(
      this.graph, this.translator, this.source, this.destination);

  GraphControllerState copyWith(
      {SuperComponent? graph,
      GraphTranslator? translator,
      Nullable<Offset>? source,
      Nullable<Offset>? destination}) {
    return GraphControllerState(
        graph ?? this.graph,
        translator ?? this.translator,
        source == null ? this.source : source.value,
        destination == null ? this.destination : destination.value);
  }

  @override
  String toString() => 'source: $source dest: $destination';
}

class GraphController {
  EventController<GraphControllerState> _controller;

  GraphController({SuperComponent? graph, GraphTranslator? translator})
      : _controller = EventController(GraphControllerState(
          graph ?? DirectedGraph(),
          GraphTranslator(),
          null,
          null,
        ));

  Stream<GraphControllerState> get events => _controller.stream;
  GraphControllerState get state => _controller.lastEvent as GraphControllerState;

  GraphTranslator get translator => _controller.lastEvent?.translator as GraphTranslator;
  DirectedGraph get graph => _controller.lastEvent?.graph as DirectedGraph;
  Offset? get selectionSource => _controller.lastEvent?.source;
  Offset? get selectionDestination => _controller.lastEvent?.destination;

  set graph(DirectedGraph graph) =>
      _controller.addEvent(state.copyWith(graph: graph));
  set translator(GraphTranslator translator) =>
      _controller.addEvent(state.copyWith(translator: translator));
  set selectionSource(Offset? source) =>
      _controller.addEvent(state.copyWith(source: Nullable(source)));
  set selectionDestination(Offset? destination) =>
      _controller.addEvent(state.copyWith(destination: Nullable(destination)));

  void updateGraphState(DirectedGraph Function(DirectedGraph) func) =>
      graph = func(graph);
  void updateViewState(GraphTranslator Function(GraphTranslator) func) =>
      translator = func(translator);

  void dispose() {
    _controller.dispose();
  }
}

class GraphWidget extends StatelessWidget {
  final GraphController controller;

  GraphWidget({required this.controller, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(),
      child: Listener(
        //onPointerDown: (event) { print('Down'); },
        //onPointerHover: (event) { print('Hover'); },
        onPointerUp: (upEvent) {
          controller.selectionSource = null;
          controller.selectionDestination = null;
        },
        onPointerDown: (downEvent) {
          if (downEvent.buttons & kPrimaryMouseButton != 0) {
            controller.selectionSource =
                controller.translator.forward(downEvent.localPosition);
          }
        },
        onPointerMove: (moveEvent) {
          if (moveEvent.buttons & kSecondaryMouseButton != 0) {
            controller.updateViewState((view) {
              return view
                ..applyTranslation(
                    -moveEvent.delta * controller.translator.zoom);
            });
          }
          if (moveEvent.buttons & kPrimaryMouseButton != 0) {
            //print('Down 2');
            controller.selectionDestination =
                controller.translator.forward(moveEvent.localPosition);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: EventStreamBuilder<GraphControllerState>(
          controller: controller._controller,
          builder: (context, data) {
            return CustomPaint(
              painter: GraphPainter(data),
            );
          },
        ),
      ),
    );
  }
}
