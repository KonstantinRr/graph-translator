/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'package:flutter/material.dart';

class RouteUnknown extends StatelessWidget {
  const RouteUnknown({Key key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Error 404: Unknwon Page'),
      ),
    );
  }
}