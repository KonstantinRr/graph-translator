/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'dart:math' as math;

import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:vector_math/vector_math.dart' as vec;

class Pair<T1, T2> {
  final T1 t1;
  final T2 t2;

  const Pair(this.t1, this.t2);
}

extension VectorToOffsetSize on vec.Vector2 {
  Offset toOffset() => Offset(x, y);
  Size toSize() => Size(x, y);
}

extension OffsetToVector on Offset {
  vec.Vector2 toVector() => vec.Vector2(dx, dy);
}

extension SizeToVector on Size {
  vec.Vector2 toSize() => vec.Vector2(width, height);
}

class UID {
  final String data;

  factory UID([String? data]) {
    if (data == null)
      return UID.gen();
    return UID.fromString(data);
  }

  UID.fromString(this.data);

  factory UID.gen([int? seed,
    int componentLength = 4,
    int componentCount = 4,
    String components = 'abcdefghijklmnopqrstuvwxyz0123456789',
  ]) {
    var random = math.Random(seed);

    var idx = 0;
    Uint8List data = Uint8List(componentLength * componentCount + componentCount - 1);
    for (var count = 0; count < componentCount; count++) {
      for (var length = 0; length < componentLength; length++)
        data[idx++] = components[random.nextInt(components.length)].codeUnitAt(0);
      if (count < componentCount - 1)
        data[idx++] = 45;
    }
    return UID(String.fromCharCodes(data));
  }

  @override
  bool operator==(o) {
    if (o is UID)
      return o.data == data;
    if (o is String)
      return o == data;
    return false;
  }

  int get hashCode => data.hashCode;
  
  @override
  String toString() => data.toString();

  dynamic toJson() => data;
}
