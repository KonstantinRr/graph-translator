/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graph_translator/state_events.dart';
import 'package:graph_translator/widgets/widget_components.dart';
import 'package:graph_translator/widgets/widget_graph.dart';

enum _WidgetInfoState { Open, Close }

class WidgetInfo extends StatefulWidget {
  final GraphController controller;
  const WidgetInfo({required this.controller, Key? key}) : super(key: key);

  @override
  WidgetInfoState createState() => WidgetInfoState();
}

class WidgetInfoState extends State<WidgetInfo> {
  final val = ValueNotifier(_WidgetInfoState.Open);

  GraphController get controller => widget.controller;

  static WidgetInfoState of(BuildContext context) =>
      context.findAncestorStateOfType<WidgetInfoState>()!;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Scrollbar(
          child: EventValueBuilder(
        notifier: controller.selection,
        builder: (context) {
          return ListView(
            children: controller.selection.selected
                .map((e) => WidgetComponents(component: e))
                .toList(),
          );
        },
      )),
    );
  }
}
