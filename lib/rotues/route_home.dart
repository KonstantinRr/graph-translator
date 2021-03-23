/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'package:flutter/material.dart';
import 'package:graph_translator/state/graph_directed.dart';
import 'package:graph_translator/widgets/widget_graph.dart';
import 'package:graph_translator/widgets/widget_info.dart';
import 'package:graph_translator/widgets/widget_reset.dart';
import 'package:graph_translator/widgets/widget_time_controller.dart';
import 'package:graph_translator/widgets/widget_zoom.dart';
import 'package:graph_translator/widgets/window_controller.dart';

class RouteHome extends StatefulWidget {
  const RouteHome({Key key});

  @override
  RouteHomeState createState() => RouteHomeState();
}

class RouteHomeState extends State<RouteHome> {
  GraphController controller;
  GlobalKey<WindowControllerState> key = GlobalKey();

  @override
  void initState() {
    super.initState();
    controller = GraphController(
        graph: DirectedGraph<DirectedNode, DirectedUnweightedEdge>.example());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: WindowController(
          key: key,
          initialStates: {
            'time': WindowState(
              builder: (context) =>
                  WidgetTimeController(controller: controller),
              displayName: 'Simulation Controller',
              size: Size(300, 100),
              type: WindowType.Open,
            ),
            'zoom': WindowState(
              builder: (context) => WidgetZoom(controller: controller),
              displayName: 'Zoom',
              size: Size(120, 100),
              type: WindowType.Open,
            ),
            'generator': WindowState(
              builder: (context) => WidgetGenerator(
                controller: controller,
              ),
              displayName: 'Generator',
              size: Size(250, 200),
              type: WindowType.Open,
            ),
            'simulate': WindowState(
              builder: (context) => WidgetSimulate(controller: controller),
              displayName: 'Simulate',
              size: Size(250, 100),
              type: WindowType.Open,
            ),
            'info': WindowState(
              builder: (context) => WidgetInfo(),
              displayName: 'Info',
              size: Size(250, 200),
              type: WindowType.Open,
            )
          },
          child: LayoutBuilder(
            builder: (context, constraints) => Stack(
              fit: StackFit.expand,
              children: <Widget>[
                GraphWidget(
                  controller: controller,
                ),
              ],
            ),
          )),
    );
  }
}
