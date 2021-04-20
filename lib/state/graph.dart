/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:graph_translator/util.dart';
import 'package:graph_translator/widgets/widget_graph.dart';

import 'package:quiver/core.dart';
import 'package:vector_math/vector_math.dart' as vec;

import 'package:graph_translator/state_events.dart';

String typeToString<T>() => T.toString();

abstract class SuperComponent extends Component implements Paintable {
  Set<Component> findSelectedComponents(Rect r) {
    return children
        .where((i) =>
            i is ComponentObject && r.contains((i as ComponentObject).offset))
        .toSet();
  }

  @override
  ComponentPainter painter(PaintSettings settings) =>
      SuperComponentPainter(settings, this);

  int get length => children.length;
  Iterable<Component> get children => [];
}

class SuperComponentPainter extends ComponentPainter {
  final SuperComponent component;
  const SuperComponentPainter(PaintSettings settings, this.component)
      : super(settings);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    if (component is ComponentObject) {
      canvas.translate(
        (component as ComponentObject).x,
        (component as ComponentObject).y,
      );
    }

    for (var child in component.children) {
      if (child is Paintable) {
        (child as Paintable).painter(settings).paint(canvas, size);
      }
    }
    if (component is ComponentObject) {
      canvas.restore();
    }
  }

  @override
  Rect size() {
    //MaxExtension.maxArg(component.children.where((element) => element is ).)
    if (component.children.isEmpty) {
      return component.children
          .where((e) => e is Paintable)
          .map((e) => (e as Paintable).painter(settings).size())
          .reduce((value, element) => value.expandToInclude(element));
    }
    return component is ComponentObject
        ? Rect.fromCenter(
            center: (component as ComponentObject).offset,
            width: 0.0,
            height: 0.0)
        : Rect.zero;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

abstract class Component extends ListenerHandler<Component> {
  final UniqueKey key = UniqueKey();
  Component? parent;

  void notify([Component? src]) {
    notifyListeners(src);
    parent?.notify(src ?? this);
  }

  void read(Map<String, dynamic> map);
  Map<String, dynamic> toJson() => {'type': 'Component'};
}

class ComponentConnector {
  ComponentObject? p1, p2;

  void setComponents(ComponentObject p1, ComponentObject p2) {
    this.p1 = p1;
    this.p2 = p2;
  }
}

mixin UndirectedComponentConnector on ComponentConnector {
  bool operator ==(o) =>
      o is UndirectedComponentConnector &&
      ((p1 == o.p1 && p2 == o.p2) || (p1 == o.p2 && p2 == o.p1));
  int get hashCode =>
      hash2(p1.hashCode, p2.hashCode) ^ hash2(p2.hashCode, p1.hashCode);
}

mixin DirectedComponentConnector on ComponentConnector {
  ComponentObject? get source => p1;
  ComponentObject? get destination => p2;

  bool operator ==(o) =>
      o is UndirectedComponentConnector && p1 == p2 || p2 == p1;
  int get hashCode =>
      hash2(p1.hashCode, p2.hashCode) ^ hash2(p2.hashCode, p1.hashCode);
}

abstract class ComponentPainter extends CustomPainter {
  final PaintSettings settings;
  const ComponentPainter(this.settings);

  Rect size();
}

class PaintSettings {
  final SelectionNotifier selection;
  final Map<String, dynamic> vars = {};
  PaintSettings(this.selection);

  void addVar(String key, dynamic variable) {
    vars[key] = variable;
  }

  T? getVar<T>(String key) {
    var value = vars[key];
    return value is T ? value : null;
  }
}

abstract class Paintable {
  const Paintable();
  ComponentPainter painter(PaintSettings settings);
}

mixin ComponentObject {
  /// Stores the coordinates
  double x = 0.0, y = 0.0;

  void setCoords(double? x, double? y) {
    if (x != null) this.x = x;
    if (y != null) this.y = y;
  }

  void randPosition([Rect? region, math.Random? rand]) {
    rand ??= math.Random();
    region ??= Rect.fromLTWH(-300, -300, 600, 600);
    x = rand.nextDouble() * region.width + region.left;
    y = rand.nextDouble() * region.height + region.top;
  }

  void applyTranslation(Canvas canvas) {
    canvas.translate(x, y);
  }

  Offset get offset => Offset(x, y);
  Size get size => Size(x, y);
  vec.Vector2 get vector => vec.Vector2(x, y);
}

abstract class Node extends Component
    with ComponentObject
    implements Paintable {
  @override
  NodePainter painter(PaintSettings settings) => NodePainter(settings, this);
}

class NodePainter extends ComponentPainter {
  final Node nd;
  final double? _radius;
  const NodePainter(PaintSettings settings, this.nd, {double? radius})
      : _radius = radius,
        super(settings);

  double get radius {
    if (_radius != null) return _radius!;
    var settingsVar = settings.getVar<double>('nodeRadius');
    if (settingsVar != null) return settingsVar;
    return 5.0;
  }

  Rect size() => Rect.fromCircle(center: nd.offset, radius: radius);

  @override
  void paint(Canvas canvas, Size csize) {
    /*
    if (settings.selection.isSelected(nd)) {
      var selectionPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.blue.withOpacity(0.4);
      var rect = size();
      canvas.drawRect(rect, selectionPaint);
    }
    */

    var nodePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black;
    if (settings.selection.isSelected(nd)) {
      nodePaint.color = Colors.lightBlue;
    }
    canvas.drawCircle(nd.offset, radius, nodePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MaxExtension {
  static Pair<int, T?> maxTuple<T extends Comparable<T>>(Iterable<T> iter) {
    if (iter.isEmpty) return Pair(-1, null);

    var iterator = iter.iterator;
    iterator.moveNext();

    var value = iterator.current;
    int idx = 0;
    for (var i = 1; iterator.moveNext(); i++) {
      if (iterator.current.compareTo(value) == 1) {
        idx = i;
        value = iterator.current;
      }
    }
    return Pair(idx, value);
  }

  static int argMax<T extends Comparable<T>>(Iterable<T> iter) =>
      maxTuple(iter).t1;
  static T? max<T extends Comparable<T>>(Iterable<T> iter) => maxTuple(iter).t2;
}

abstract class Graph extends SuperComponent {
  List<Node> get listNodes;

  static final double Function(Node) compMaxX = (nd) => nd.x,
      compMinX = (nd) => -nd.x,
      compMaxY = (nd) => nd.y,
      compMinY = (nd) => -nd.y,
      compMaxAbsX = (nd) => nd.x.abs(),
      compMinAbsX = (nd) => -nd.x.abs(),
      compMaxAbsY = (nd) => nd.y.abs(),
      compMinAbsY = (nd) => -nd.y.abs();
}
