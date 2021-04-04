import 'package:flutter/material.dart';
import 'package:graph_translator/widgets/widget_graph.dart';

class WidgetZoom extends StatelessWidget {
  final GraphController controller;
  const WidgetZoom({required this.controller, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            controller.updateViewState((v) {
              return v..applyZoom(1.1);
            });
          },
          icon: Icon(Icons.zoom_in),
        ),
        IconButton(
          onPressed: () {
            controller.updateViewState((v) {
              return v..applyZoom(1.0 / 1.1);
            });
          },
          icon: Icon(Icons.zoom_out),
        )
      ],
    );
  }
}
