

import 'package:flutter/material.dart';

class TimeController extends StatefulWidget {
  const TimeController({Key key}) : super(key: key);

  @override
  TimeControllerState createState() => TimeControllerState();
}

class TimeControllerState extends State<TimeController> {
  TextEditingController stepText;
  
  @override
  void initState() {
    super.initState();
    stepText = TextEditingController();
  }

  @override
  void dispose() {
    stepText.dispose();
    super.dispose();
  }

  void _onPause() { }
  void _onPlay() { }
  void _onStep() { }
  void _onSteps() { }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0)),
      elevation: 2.0,
      color: Colors.white,
      child: Row(
        children: [
          IconButton(icon: Icon(Icons.pause), onPressed: _onPause,),
          IconButton(icon: Icon(Icons.play_arrow), onPressed: _onPlay,),
          IconButton(icon: Icon(Icons.star), onPressed: _onStep,),
          TextField(
            controller: stepText,
          ),
          IconButton(icon: Icon(Icons.play_arrow), onPressed: _onSteps)
        ],
      )
    );
  }
}