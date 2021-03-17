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
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            GraphWidget(
              controller: controller,
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  WidgetTimeController(controller: controller),
                  WidgetZoom(
                    controller: controller,
                  )
                ],
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  WidgetGenerator(
                    controller: controller,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  WidgetSimulate(controller: controller),
                  WidgetInfo(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
