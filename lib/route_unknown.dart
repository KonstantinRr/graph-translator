

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