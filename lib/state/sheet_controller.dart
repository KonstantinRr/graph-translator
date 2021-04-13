/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'package:graph_translator/state/graph_directed.dart';
import 'package:graph_translator/util.dart';
import 'package:graph_translator/widgets/widget_graph.dart';

class Sheet {
  String name;
  UID uid;

  GraphController controller;

  Sheet({required this.name, required this.controller, required this.uid});


  @override
  bool operator==(o) => o is Sheet && o.uid == uid;

  @override
  int get hashCode => uid.hashCode;
}

class SheetController {
  List<Sheet> sheets;
  
  SheetController({List<Sheet>? sheets}) : sheets = sheets ?? [];

  Sheet? findByName(String name) {
    for (var sh in sheets) {
      if (sh.name == name) return sh;
    }
    return null;
  }

  Sheet? findByUID(UID uid) {
    for (var sh in sheets) {
      if (sh.uid == uid) return sh;
    }
    return null;
  }

  void addSheet(Sheet sheet) {
    sheets.add(sheet);
  }

  void addSheetFromCompoents({String? name, UID? uid, GraphController? controller}) {
    name ??= 'Sheet ${sheets.length}';
    uid ??= UID.gen();
    controller ??= GraphController(graph: DirectedGraph.example());

    addSheet(Sheet(
      name: name,
      uid: uid,
      controller: GraphController(graph: DirectedGraph.example()),
    ));
  }

  void removeSheet(Sheet sheet) {
    sheets.remove(sheet);
  }
}
