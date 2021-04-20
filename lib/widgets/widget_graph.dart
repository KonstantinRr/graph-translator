/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:graph_translator/main.dart';
import 'package:graph_translator/state/graph.dart';
import 'package:graph_translator/state/graph_directed.dart';
import 'package:graph_translator/state_events.dart';
import 'package:graph_translator/state_manager.dart';

class GraphTranslator extends ChangeNotifier {
  double _zoom;
  double _dx, _dy;

  GraphTranslator({double zoom = 1.0, double dx = 0.0, double dy = 0.0}) :
    _zoom = zoom, _dx = dx, _dy = dy;

  double get zoom => _zoom;
  double get dx => _dx;
  double get dy => _dy;

  set zoom(double zoom) {
    _zoom = zoom;
    notifyListeners();
  }

  set dx(double dx) {
    _dx = dx;
    notifyListeners();
  }
  
  set dy(double dy) {
    _dy = dy;
    notifyListeners();
  }

  void applyZoom(double azoom) {
    _zoom *= azoom;
    notifyListeners();
  }

  void applyTranslation(Offset offset) {
    _dx += offset.dx / _zoom;
    _dy += offset.dy / _zoom;
    notifyListeners();
  }



  Offset forward(Offset tx) => tx.translate(_dx, _dy).scale(_zoom, _zoom);
  Offset reverse(Offset tx) => tx.scale(1 / _zoom, 1 / _zoom).translate(-_dx, -_dy);

  Offset get offset => Offset(_dx, _dy);
  Size get size => Size(_dx, _dy);

  bool operator ==(o) =>
      o is GraphTranslator && o._zoom == _zoom && o._dx == _dx && o._dy == _dy;

  @override
  int get hashCode => hashValues(_zoom, _dx, _dy);
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

    if (state.graph is Paintable) state.graph.painter().paint(canvas, size);

    if (state.source != null && state.destination != null) {
      var paint = Paint()
        ..color = Colors.blue.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawRect(
          Rect.fromPoints(state.source as Offset, state.destination as Offset),
          paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SelectionAreaNotifier extends ChangeNotifier {

  final Offset? _source, _destination;
  SelectionAreaNotifier({Offset? source, Offset? destination}) : _source = source, _destination = destination;

  Rect? get rect => _source != null && _destination != null ? Rect.fromPoints(_source!, _destination!) : null;
  Offset? get source => _source;
  Offset? get destination => _destination;

  @override
  String toString() => 'source: $_source dest: $_destination';
}

class ActionController extends ChangeNotifier {
  final List<ReversibleEvent> undoStack = [], redoStack = [];

  void executeEvent(ReversibleEvent event) {
    event.forward();
    undoStack.add(event);
    // clears the redo stack
    if (redoStack.isNotEmpty) {
      if (event == redoStack.last) {
        redoStack.removeLast();
      } else {
        redoStack.clear();
      }
    }
    notifyListeners();
  }

  bool get canUndo => undoStack.isNotEmpty;
  bool get canRedo => redoStack.isNotEmpty;

  void clear() {
    undoStack.clear();
    redoStack.clear();
  }

  void undoAll() {
    if (undoStack.isNotEmpty) {
      undoStack.forEach((e) => e.reverse());
      redoStack.addAll(undoStack);
      undoStack.clear();
      notifyListeners();
    }
  }

  void redoAll() {
    if (redoStack.isNotEmpty) {
      redoStack.forEach((e) => e.forward());
      undoStack.addAll(redoStack);
      redoStack.clear();
      notifyListeners();
    }
  }

  void undo() {
    assert(canUndo);
    var value = undoStack.removeLast();
    value.reverse();
    redoStack.add(value);
    notifyListeners();
  }

  void redo() {
    assert(canRedo);
    var value = redoStack.removeLast();
    value.forward();
    undoStack.add(value);
    notifyListeners();
  }
}

class SelectionNotifier extends ChangeNotifier {
  List<Component> _selected;

  SelectionNotifier({List<Component>? selected}) : _selected = selected ?? [];

  List<Component> get selected => _selected;
  set selected(List<Component> selected) {
    _selected = selected;
    notifyListeners();
  }

  void updateWith(dynamic Function(List<Component>) functor) {
    var val = functor(_selected);
    notifyListeners();
  }
}

class GraphState extends ChangeNotifier {
  SuperComponent _component;
}

class GraphController {
  EventController<GraphControllerState> _controller;
  ActionController _action = ActionController();
  SelectionNotifier selection = SelectionNotifier();
  SelectionAreaNotifier area = SelectionAreaNotifier();
  GraphTranslator translator = GraphTranslator();
  ValueListenable<SuperComponent> _component = ValueListenable();

  GraphController({SuperComponent? graph, GraphTranslator? translator})
      : _controller = EventController(GraphControllerState(
          graph ?? DirectedGraph(),
          GraphTranslator(),
          null,
          null,
        ));

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
          if (controller.selectionSource != null &&
              controller.selectionDestination != null) {
            var rect = Rect.fromPoints(
                controller.selectionSource!, controller.selectionDestination!);
            controller.g
            //controller.
          }
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
