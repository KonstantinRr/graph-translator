/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'package:flutter/material.dart';
import 'package:graph_translator/state/graph_directed.dart';
import 'package:graph_translator/widgets/widget_graph.dart';
import 'package:graph_translator/widgets/widget_protobar.dart';
import 'package:graph_translator/widgets/window_controller.dart';

class GraphControllerProvider extends StatefulWidget {
  final GraphController Function() creator;
  final Widget child;
  const GraphControllerProvider({required this.creator,
    required this.child, Key? key}) : super(key: key);
  
  @override
  GraphControllerProviderState createState() => GraphControllerProviderState();

  static GraphController? of(BuildContext context, {bool require = true}) {
    var ctx = context.findAncestorStateOfType<GraphControllerProviderState>();
    assert(!require || ctx != null, 'ProtoBarManagerState must not be null');
    return ctx?.controller;
  }
}

class GraphControllerProviderState extends State<GraphControllerProvider> {
  late final GraphController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.creator();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class RouteHome extends StatefulWidget {
  const RouteHome({Key? key});

  @override
  RouteHomeState createState() => RouteHomeState();
}

class RouteHomeState extends State<RouteHome> {
  late final GraphController controller;
  GlobalKey<WindowControllerState> key = GlobalKey();

  @override
  void initState() {
    super.initState();
    controller = GraphController(
        graph: DirectedGraph.example());
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
            /*
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
              scale: Size(0.2, 1.0),
              resizeHeight: false,
              resizeWidth: false,
              move: false,
              offsetScale: Offset(0.8, 0.0),
              type: WindowType.Open,
            ),
            'structure': WindowState(
              builder: (context) => WidgetComponents(
                component: controller.graph,
              ),
              displayName: 'Structure',
              resizeHeight: false,
              resizeWidth: false,
              move: false,
              scale: Size(0.3, 1.0),
            )
            */
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget> [
              Expanded(child: LayoutBuilder(
                builder: (context, constraints) => Stack(
                  fit: StackFit.loose,
                  children: <Widget>[
                    Positioned.fill(
                      child: GraphWidget(
                        controller: controller,
                      ),
                    ),
                    Positioned(
                      top: 0.0, left: 0.0, right: 0.0,
                      child: ProtoBar(
                        controller: controller,
                      ),
                    ),
                  ],
                ),),
              )
            ]
          )
        ),
    );
  }
}
