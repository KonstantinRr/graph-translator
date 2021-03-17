/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'package:flutter/material.dart';
import 'package:graph_translator/widgets/widget_logo.dart';
import 'package:graph_translator/widgets/widget_size_requirement.dart';

class RouteSplash extends StatefulWidget {
  final Duration delay;
  final bool skip;
  final String destination;

  const RouteSplash({
    this.destination = '/',
    this.skip = true,
    Key key,
    this.delay = const Duration(milliseconds: 700),
  }) : super(key: key);

  RouteSplashState createState() => RouteSplashState();
}

class RouteSplashState extends State<RouteSplash> {
  @override
  void initState() {
    super.initState();
    if (widget.skip)
      Future.delayed(widget.delay,
          () => Navigator.of(context).pushReplacementNamed(widget.destination));
  }

  @override
  Widget build(BuildContext context) {
    return WidgetSizeRequirement(
      minHeight: 270.0,
      minWidth: 270.0,
      builder: (context, _) => Scaffold(
        body: Stack(
          fit: StackFit.passthrough,
          children: <Widget>[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: const WidgetLogo(
                        size: 240, margin: const EdgeInsets.all(10.0)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
