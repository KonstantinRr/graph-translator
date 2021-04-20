/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:quiver/core.dart';
import 'package:vector_math/vector_math.dart' as vec;

import 'package:graph_translator/state_events.dart';

String typeToString<T>() => T.toString();

abstract class SuperComponent extends Component implements Paintable {
  List<Component> findSelectedComponents(Rect r) {
    return children
        .where((i) =>
            i is ComponentObject && r.contains((i as ComponentObject).offset))
        .toList();
  }

  @override
  ComponentPainter painter() => SuperComponentPainter(this);

  int get length => children.length;
  Iterable<Component> get children => [];
}

class SuperComponentPainter extends ComponentPainter {
  final SuperComponent component;
  const SuperComponentPainter(this.component);

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
        (child as Paintable).painter().paint(canvas, size);
      }
    }
    if (component is ComponentObject) {
      canvas.restore();
    }
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
  const ComponentPainter();
}

abstract class Paintable {
  const Paintable();
  ComponentPainter painter();
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
  NodePainter painter() => NodePainter(this);
}

class NodePainter extends ComponentPainter {
  final Node nd;
  final double _radius;
  const NodePainter(this.nd, {double radius = 5.0}) : _radius = radius;

  double get radius => _radius;

  @override
  void paint(Canvas canvas, Size size) {
    var nodePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black;

    canvas.drawCircle(nd.offset, radius, nodePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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

  int argMax<T extends Comparable<T>>(T Function(Node) functor) {
    List<Node> ref = listNodes;
    if (ref.isEmpty) return -1;

    var value = functor(ref[0]);
    int idx = 0;
    for (var i = 1; i < listNodes.length; i++) {
      if (functor(ref[i]).compareTo(value) == 1) idx = i;
    }
    return idx;
  }

  Node? nodeMax<T extends Comparable<T>>(T Function(Node) functor) {
    var idx = argMax<T>(functor);
    if (idx == -1) return null;
    return listNodes[idx];
  }
}
