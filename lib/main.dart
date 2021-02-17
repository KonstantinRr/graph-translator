import 'package:flutter/material.dart';
import 'package:graph_translator/route_home.dart';
import 'package:graph_translator/route_unknown.dart';
import 'package:graph_translator/transtion.dart';

void main() {
  runApp(GraphTranslator());
}
class GraphTranslator extends StatelessWidget {
  const GraphTranslator({Key key}) : super(key: key);

  Route onGenerateRotue(RouteSettings settings) {
    switch(settings.name) {
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
        pageTransitionsTheme: const NoTransitionsOnWeb(),
      ),
    );
  }
}
