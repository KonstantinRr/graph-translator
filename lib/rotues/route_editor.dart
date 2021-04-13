/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'package:flutter/material.dart';
import 'package:graph_translator/editor/editor_widget.dart';

class RouteEditor extends StatefulWidget {
  const RouteEditor({Key? key}) : super(key: key);

  @override
  RouteEditorState createState() => RouteEditorState();
}

class RouteEditorState extends State<RouteEditor> {
  final controller = EditorController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EditorWidget(
        controller: controller,
      ),
    );
  }
}
