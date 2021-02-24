/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:graph_translator/graph.dart';
import 'package:graph_translator/graph_painter.dart';

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
