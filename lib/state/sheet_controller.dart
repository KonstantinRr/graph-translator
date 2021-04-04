

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:graph_translator/widgets/widget_graph.dart';

/*
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

class Sheet {
  String name;
  UID uid;

  GraphController controller;
}

class SheetController {
  List<Sheet> sheets;

  SheetDescriptor findDescriptorByName(String name) {
    for (var key in sheets.keys) {
      if (key.name == name)
        return key;
    }
    return null;
  }

  Sheet findByName(String name) => sheets[findDescriptorByName(name)];

  SheetDescriptor findDescriptorByUID

  void addSheet({String name, String uid, GraphController controller}) {
    uid ??= generateUID();
    sheets.length 
  }

  void removeSheet(SheetDescriptor)
}
*/