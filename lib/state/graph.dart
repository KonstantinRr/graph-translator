/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fraction/fraction.dart';
import 'package:graph_translator/util.dart';
import 'package:graph_translator/widgets/widget_graph.dart';

import 'package:quiver/core.dart';
import 'package:vector_math/vector_math.dart' as vec;

import 'package:graph_translator/state_events.dart';

String typeToString<T>() => T.toString();

abstract class SuperComponent extends Component implements Paintable {
  Set<Component> findSelectedComponents(PaintSettings settings, Rect r) {
    return children
        .where((i) =>
            i is ComponentObject && r.contains((i as ComponentObject).offset))
        .toSet();
  }

  List<Component> hitTest(PaintSettings settings, Offset offset) {
    return children
        .where((e) =>
            e is Paintable &&
            ((e as Paintable).painter(settings).size().contains(offset)))
        .toList();
  }

  void removeComponent(Component component);
  void removeComponents(Set<Component> components) {
    components.forEach((element) => removeComponent(element));
  }

  @override
  ComponentPainter painter(PaintSettings settings) =>
      SuperComponentPainter(settings, this);

  int get length => children.length;
  Iterable<Component> get children => [];

  @override
  void read(Map<String, dynamic> data) {
    super.toJson();
    // TODO
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': typeToString<SuperComponent>(),
        'parent': super.toJson(),
      };
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

  @override
  Map<String, dynamic> toJson() => {
        'type': typeToString<SuperComponentPainter>(),
        'component': component.toJson(),
        'parent': super.toJson(),
      };
}

abstract class Component extends ListenerHandler<Component>
    implements Serializable {
  final UniqueKey key = UniqueKey();
  Component? parent;

  void notify([Component? src]) {
    notifyListeners(src);
    parent?.notify(src ?? this);
  }

  @override
  void read(Map<String, dynamic> data) {
    // TODO
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': typeToString<Component>(),
      };
}

class ComponentConnector implements Serializable {
  ComponentObject? p1, p2;

  void setComponents(ComponentObject p1, ComponentObject p2) {
    this.p1 = p1;
    this.p2 = p2;
  }

  @override
  void read(Map<String, dynamic> data) {
    // TODO
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': typeToString<ComponentConnector>(),
        'p1': p1?.toJson(),
        'p2': p2?.toJson(),
      };
}

mixin UndirectedComponentConnector on ComponentConnector {
  bool operator ==(o) =>
      o is UndirectedComponentConnector &&
      ((p1 == o.p1 && p2 == o.p2) || (p1 == o.p2 && p2 == o.p1));
  int get hashCode =>
      hash2(p1.hashCode, p2.hashCode) ^ hash2(p2.hashCode, p1.hashCode);

  @override
  void read(Map<String, dynamic> toJson) {
    super.toJson();
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': typeToString<UndirectedComponentConnector>(),
        'parent': super.toJson(),
      };
}

mixin DirectedComponentConnector on ComponentConnector {
  ComponentObject? get source => p1;
  ComponentObject? get destination => p2;

  bool operator ==(o) =>
      o is DirectedComponentConnector && ((p1 == o.p1 && p2 == o.p2));
  int get hashCode => hash2(p1.hashCode, p2.hashCode);

  @override
  void read(Map<String, dynamic> toJson) {
    super.toJson();
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': typeToString<UndirectedComponentConnector>(),
        'parent': super.toJson(),
      };
}

abstract class ComponentPainter extends CustomPainter implements Serializable {
  final PaintSettings settings;
  const ComponentPainter(this.settings);

  void paintRectBorder(Canvas canvas, Size csize,
      {double inflation = 0.0, Paint? paint}) {
    var rect = size().inflate(inflation);
    paint ??= Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke;

    canvas.drawRect(rect, paint);
  }

  Rect size();

  @override
  void read(Map<String, dynamic> data) {
    // TODO
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': typeToString<ComponentPainter>(),
        'paintSettings': settings.toJson(),
      };
}

class PaintSettings implements Serializable {
  final SelectionNotifier selection;
  final Map<String, dynamic> _vars = {};
  final List<List<Pair<String, dynamic>>> _changes = [[]];
  PaintSettings(this.selection);

  void setVar(String key, dynamic variable) {
    _vars[key] = variable;
  }

  void addVar(String key, dynamic variable) {
    _changes.last.add(Pair(key, _vars[key]));
    _vars[key] = variable;
  }

  void addVarSave(String key, dynamic variable) {
    save();
    addVar(key, variable);
  }

  bool get canRestore => _changes.isNotEmpty;

  void save() {
    _changes.add([]);
  }

  void restore() {
    assert(canRestore, 'Cannot restore, Stack is empty!');
    for (var i in _changes.last.reversed) {
      _vars[i.t1] = i.t1;
    }
    _changes.removeLast();
  }

  T? getVar<T>(String key) {
    var value = _vars[key];
    return value is T ? value : null;
  }

  T getVarAlternative<T>(String key, T alternative) {
    var value = _vars[key];
    return value is T ? value : alternative;
  }

  @override
  void read(Map<String, dynamic> data) {
    // TODO
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': typeToString<PaintSettings>(),
        // TODO
      };
}

abstract class Paintable implements Serializable {
  const Paintable();
  ComponentPainter painter(PaintSettings settings);

  @override
  void read(Map<String, dynamic> data) {}

  @override
  Map<String, dynamic> toJson() => {
        'type': typeToString<Paintable>(),
      };
}

mixin ComponentObject on Component {
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

  void applyTranslation(Offset offset) {
    x += offset.dx;
    y += offset.dy;
  }

  Offset get offset => Offset(x, y);
  Size get size => Size(x, y);
  vec.Vector2 get vector => vec.Vector2(x, y);

  @override
  void read(Map<String, dynamic> data) {
    super.read(data);
    // TODO
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': typeToString<ComponentObject>(),
        'parent': super.toJson(),
        'x': x,
        'y': y,
      };
}

abstract class Node extends Component
    with ComponentObject
    implements Paintable {
  @override
  NodePainter painter(PaintSettings settings) => NodePainter(settings, this);

  @override
  void read(Map<String, dynamic> data) {
    super.toJson();
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': typeToString<Node>(),
        'parent': super.toJson(),
      };
}

class NodePainter extends ComponentPainter {
  final Node nd;
  final double? _radius;
  final Color? _color;
  const NodePainter(PaintSettings settings, this.nd,
      {double? radius, Color? color})
      : _radius = radius,
        _color = color,
        super(settings);

  Color get color {
    if (_color != null) return _color!;
    return settings.getVarAlternative<Color>('nodeColor', Colors.black);
  }

  Color get selectionColor {
    return settings.getVarAlternative<Color>(
        'nodeSelectionColor', Colors.lightBlue);
  }

  double get radius {
    if (_radius != null) return _radius!;
    return settings.getVarAlternative<double>('nodeRadius', 5.0);
  }

  Rect size() => Rect.fromCircle(center: nd.offset, radius: radius);

  @override
  void paint(Canvas canvas, Size csize) {
    var nodePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    if (settings.selection.isSelected(nd)) {
      nodePaint.color = selectionColor;
    }
    canvas.drawCircle(nd.offset, radius, nodePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  @override
  void read(Map<String, dynamic> data) {
    super.read(data);
    // TODO
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': typeToString<NodePainter>(),
        'parent': super.toJson(),
        'nd': nd.toJson(),
        'radius': radius,
        'color': color,
      };
}

/*
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
*/
abstract class EdgePainter extends ComponentPainter {
  final ComponentConnector connector;
  const EdgePainter(PaintSettings settings, this.connector) : super(settings);

  void drawText(Canvas canvas, Fraction weight, Offset center) {
    var text = weight.toDouble().toStringAsFixed(2);
    var span = TextSpan(
      style: TextStyle(color: Colors.grey[600]),
      text: text,
    );
    var tp = TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, center);
  }

  @override
  void paint(Canvas canvas, Size size) {
    var edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black;

    if (connector.p1 != null && connector.p2 != null) {
      if (connector.p1 == connector.p2) {
        // recursive arrow (p1 == p2)
        var offset = connector.p1!.offset;

        canvas.drawOval(
          Rect.fromPoints(offset, offset + Offset(20.0, 20.0)),
          edgePaint,
        );

        if (connector is Weighted) {
          drawText(
            canvas,
            (connector as Weighted).weight,
            offset + Offset(20.0, 20.0),
          );
        }
      } else {
        canvas.drawLine(
          connector.p1!.offset,
          connector.p2!.offset,
          edgePaint,
        );
        if (connector is Weighted) {
          var center = (connector.p1!.vector + connector.p2!.vector)
            ..scale(0.5);
          drawText(canvas, (connector as Weighted).weight, center.toOffset());
        }
      }
    }
  }

  @override
  Rect size() {
    return connector.p1 != null && connector.p2 != null
        ? (connector.p1 == connector.p2
            ? Rect.fromPoints(
                connector.p1!.offset,
                connector.p2!.offset,
              )
            : connector.p1!.offset & Size(20.0, 20.0))
        : Rect.zero;
  }

  @override
  void read(Map<String, dynamic> data) {
    super.read(data);
    // TODO
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': typeToString<EdgePainter>(),
        'parent': super.toJson(),
        'connector': connector.toJson(),
      };
}

mixin Weighted on Component {
  Fraction weight = Fraction(1);

  void setWeightIf(Fraction? newWeight) {
    if (newWeight != null) weight = newWeight;
  }

  @override
  void read(Map<String, dynamic> data) {
    super.read(data);
    // TODO
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': typeToString<Weighted>(),
        'parent': super.toJson(),
        'weight': weight,
      };
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

  @override
  void read(Map<String, dynamic> data) {
    super.read(data);
    // TODO
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': typeToString<Graph>(),
        'parent': super.toJson(),
      };
}
