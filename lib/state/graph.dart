import 'package:flutter/cupertino.dart';
import 'dart:math' as math;

import 'package:vector_math/vector_math.dart';

abstract class Component {
  /// Stores the coordinates
  double x, y;

  Component({double x, double y})
      : x = x ?? 0.0,
        y = y ?? 0.0;

  Component.random([Rect region, math.Random rand]) {
    randPosition(region, rand);
  }

  void randPosition(Rect region, [math.Random rand]) {
    rand ??= math.Random();
    region = Rect.fromLTWH(-300, -300, 600, 600);
    x = rand.nextDouble() * region.width + region.left;
    y = rand.nextDouble() * region.height + region.top;
  }

  Offset get offset => Offset(x, y);
  Size get size => Size(x, y);
  Vector2 get vec => Vector2(x, y);
}
