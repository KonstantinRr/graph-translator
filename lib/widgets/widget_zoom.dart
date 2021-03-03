

import 'package:flutter/material.dart';
import 'package:graph_translator/widgets/widget_graph.dart';

class WidgetZoom extends StatelessWidget {
  final GraphController controller;
  const WidgetZoom({@required this.controller, Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0)),
      elevation: 2.0,
      color: Colors.white,
      child: Material(
        type: MaterialType.transparency,
        child: SizedBox(
          height: 60.0,
          child: Row(
            children: [
              IconButton(
                onPressed: () { controller.updateViewState((v) { v.applyZoom(1.1); }); },
                icon: Icon(Icons.zoom_in),
              ),
              IconButton(
                onPressed: () { controller.updateViewState((v) { v.applyZoom(1.0 / 1.1); }); },
                icon: Icon(Icons.zoom_out),
              )
            ],),
        )
      )
    );
  }
}