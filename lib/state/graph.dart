import 'package:flutter/cupertino.dart';
import 'package:quiver/core.dart';
import 'dart:math' as math;

import 'package:vector_math/vector_math.dart';

abstract class SuperComponent extends Component {
  List<Component> children();
}

abstract class Component {
  void read(Map<String, dynamic> map);
  Map<String, dynamic> toJson();
}

mixin Input {
  Map<String, InputValue> data = {};

  void addInput(String key, InputValue value) {
    data[key] = value;
  }
}

class InputValue {
  ComponentConnector connected;
}

class NamedInput extends InputValue {}

class AnyInput extends InputValue {
  List<Input> inputs;

  void addInput(Input input) {
    inputs.add(input);
  }
}

mixin ComponentConnector on Component {
  ComponentObject p1, p2;

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
  ComponentObject get source => p1;
  ComponentObject get destination => p2;

  bool operator ==(o) =>
      o is UndirectedComponentConnector && p1 == p2 || p2 == p1;
  int get hashCode =>
      hash2(p1.hashCode, p2.hashCode) ^ hash2(p2.hashCode, p1.hashCode);
}

mixin ComponentObject {
  /// Stores the coordinates
  double x, y;

  void setCoords(double x, double y) {
    this.x = x;
    this.y = y;
  }

  void randPosition([Rect region, math.Random rand]) {
    rand ??= math.Random();
    region ??= Rect.fromLTWH(-300, -300, 600, 600);
    x = rand.nextDouble() * region.width + region.left;
    y = rand.nextDouble() * region.height + region.top;
  }

  Offset get offset => Offset(x, y);
  Size get size => Size(x, y);
  Vector2 get vec => Vector2(x, y);
}
