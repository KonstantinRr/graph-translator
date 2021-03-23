import 'package:flutter/material.dart';
import 'package:graph_translator/widgets/widget_graph.dart';

class WidgetGenerator extends StatefulWidget {
  final GraphController controller;
  const WidgetGenerator({@required this.controller, Key key}) : super(key: key);

  @override
  WidgetGeneratorState createState() => WidgetGeneratorState();
}

class WidgetGeneratorState extends State<WidgetGenerator> {
  double sliderNodes = 10;
  double sliderEdges = 20;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.bodyText1.copyWith(color: Colors.black);
    return ElevatedButton(
      onPressed: () {
        widget.controller.updateGraphState((g) {
          g.random(
              nodeCount: sliderNodes.round(),
              connectionCount: sliderEdges.round());
        });
      },
      style: ElevatedButton.styleFrom(
        primary: Colors.white, // background
      ),
      child: Column(
        children: <Widget>[
          Container(
            height: 60.0,
            width: 200.0,
            alignment: Alignment.center,
            child: Text(
              'Generate',
              style: theme.textTheme.button.copyWith(color: Colors.black),
            ),
          ),
          Row(
            children: <Widget>[
              Column(
                children: [
                  Container(
                    height: 40.0,
                    width: 70.0,
                    alignment: Alignment.center,
                    child: Text(
                      'Nodes ${sliderNodes.round()}',
                      style: style,
                    ),
                  ),
                  Container(
                    height: 40.0,
                    width: 70.0,
                    alignment: Alignment.center,
                    child: Text(
                      'Edges ${sliderEdges.round()}',
                      style: style,
                    ),
                  )
                ],
              ),
              Column(
                children: <Widget>[
                  SizedBox(
                    height: 40.0,
                    width: 130.0,
                    child: Slider(
                      value: sliderNodes,
                      min: 1,
                      max: 100,
                      divisions: null,
                      onChanged: (double value) => setState(
                        () {
                          sliderNodes = value;
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40.0,
                    width: 130.0,
                    child: Slider(
                      value: sliderEdges,
                      min: 1,
                      max: 200,
                      divisions: null,
                      onChanged: (double value) => setState(
                        () {
                          sliderEdges = value;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WidgetSimulate extends StatelessWidget {
  final GraphController controller;
  const WidgetSimulate({@required this.controller, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return ElevatedButton(
      onPressed: () {
        controller.updateGraphState((g) {
          //g.simulatePositions(1000);
        });
      },
      style: ElevatedButton.styleFrom(
        primary: Colors.white, // background
      ),
      child: Container(
        height: 60.0,
        width: 200.0,
        alignment: Alignment.center,
        child: Text(
          'Simulate',
          style: theme.textTheme.button.copyWith(color: Colors.black),
        ),
      ),
    );
  }
}
