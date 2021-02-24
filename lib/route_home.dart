/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'package:flutter/material.dart';
import 'package:graph_translator/graph.dart';
import 'package:graph_translator/graph_widget.dart';

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
      graph: DirectedGraph.example()
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GraphWidget(
        controller: controller,
      ),
    );
  }
}