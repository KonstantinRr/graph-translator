/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'package:flutter/material.dart';
import 'package:graph_translator/state_events.dart';

class EditorController {
  final zoom = EventController<double>();

  void dispose() {
    zoom.dispose();
  }
}

class EditorTextPainter extends CustomPainter {
  const EditorTextPainter();

  @override
  void paint(Canvas canvas, Size size) {
    TextSpan span = TextSpan(
      style: TextStyle(color: Colors.blue[800] as Color),
      text: 'Hello\n\nWorld',
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset.zero);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class EditorWidget extends StatelessWidget {
  final EditorController controller;
  const EditorWidget({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(400, 400),
      painter: EditorTextPainter(),
    );
  }
}
