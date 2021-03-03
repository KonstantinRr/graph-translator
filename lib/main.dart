/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'package:flutter/material.dart';
import 'package:graph_translator/rotues/rotue_splash.dart';
import 'package:graph_translator/rotues/route_home.dart';
import 'package:graph_translator/rotues/route_unknown.dart';
import 'package:graph_translator/util/transtion.dart';

void main() {
  runApp(const GraphTranslator());
}

class GraphTranslator extends StatelessWidget {
  const GraphTranslator({Key key}) : super(key: key);

  Route onGenerateRotue(RouteSettings settings) {
    switch(settings.name) {
      case 'splash': return MaterialPageRoute(
        builder: (context) => const RouteSplash());
      case '/': return MaterialPageRoute(
        builder: (context) => const RouteHome());
    }
    return null;
  }

  Route onGenerateUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => const RouteUnknown());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onUnknownRoute: onGenerateUnknownRoute,
      onGenerateRoute: onGenerateRotue,
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      initialRoute: '/',
      theme: ThemeData(
        sliderTheme: SliderThemeData(
          valueIndicatorTextStyle: TextStyle(color: Colors.black)
        ),
        scaffoldBackgroundColor: Color(0xfff2f2f2),
        pageTransitionsTheme: const NoTransitionsOnWeb(),
      ),
    );
  }
}
