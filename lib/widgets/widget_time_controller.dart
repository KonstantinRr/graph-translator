import 'dart:async';

/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'package:flutter/material.dart';
import 'package:graph_translator/widgets/widget_graph.dart';

class WidgetTimeController extends StatefulWidget {
  final GraphController controller;
  const WidgetTimeController({@required this.controller,
    Key key}) : super(key: key);

  @override
  TimeControllerState createState() => TimeControllerState();
}

class TimeControllerState extends State<WidgetTimeController> {
  TextEditingController stepText;
  Timer periodic;

  @override
  void initState() {
    super.initState();
    stepText = TextEditingController();
  }

  @override
  void dispose() {
    periodic?.cancel();
    stepText.dispose();
    super.dispose();
  }

  void _onPause() {
    periodic?.cancel();
    periodic = null;
  }
  
  void _onPlay() {
    periodic?.cancel();
    periodic = Timer.periodic(Duration(milliseconds: 200), (t) {
      widget.controller.updateGraphState((g) { g.simulatePositions(1); });
    });
  }
  void _onStep() { }
  void _onSteps() { }

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(icon: Icon(Icons.pause), onPressed: _onPause, tooltip: 'Pause',),
              IconButton(icon: Icon(Icons.play_arrow), onPressed: _onPlay, tooltip: 'Play',),
              IconButton(icon: Icon(Icons.keyboard_arrow_right), onPressed: _onStep, tooltip: 'Step',),
              Container(
                height: 40.0,
                width: 120.0,
                alignment: Alignment.center,
                child: Row(
                  children: <Widget> [
                    Text('Step Count:'),
                    SizedBox(width: 10),
                    Expanded(child: TextField(
                      controller: stepText,
                      decoration: InputDecoration.collapsed(
                        hintText: '1',
                      ),
                    ))
                  ]
                ),
              ),
              IconButton(icon: Icon(Icons.last_page), onPressed: _onSteps, tooltip: 'Steps',),
            ],
          )
        )
      )
    );
  }
}