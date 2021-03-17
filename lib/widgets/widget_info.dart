import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graph_translator/state/graph.dart';
import 'package:graph_translator/state_events.dart';
import 'package:graph_translator/state_manager.dart';

class WidgetInfo extends StatelessWidget {
  const WidgetInfo({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var state = StateManagerProvider.of(context);
    return Container(
      width: 200.0,
      height: 500.0,
      child: Scrollbar(
        child: SingleChildScrollView(
          child: EventStreamBuilder<Component>(
            controller: state.selected,
            builder: (context, comp) {
              return Text('$comp');
            },
          ),
        ),
      ),
    );
  }
}
