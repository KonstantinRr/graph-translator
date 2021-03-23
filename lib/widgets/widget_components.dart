import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:graph_translator/state/graph.dart';

class WidgetSingleComponent extends StatefulWidget {
  final Component component;
  final int initialLength;
  const WidgetSingleComponent(
      {@required this.component, this.initialLength = 16, Key key})
      : super(key: key);

  @override
  WidgetSingleComponentState createState() => WidgetSingleComponentState();
}

class WidgetSingleComponentState extends State<WidgetSingleComponent> {
  int currentMaxLength;
  static const elementsMinLength = 10;
  static const elementsMaxLength = 100;
  static const addSize = 10, decreaseSize = 10;

  @override
  void initState() {
    super.initState();
    currentMaxLength = widget.initialLength;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var state = WidgetComponentsState.of(context);
    state.map[widget.component] = () => setState(() {});
  }

  @override
  void dispose() {
    var state = WidgetComponentsState.of(context);
    state.map.remove(widget.component);
    super.dispose();
  }

  Component get component => widget.component;

  @override
  Widget build(BuildContext context) {
    var length = component.length;

    Widget object = Text(component.runtimeType.toString());

    return Container(
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: length == 0
            ? object
            : Column(
                children: [
                  object,
                  Column(
                    children: component.children
                        .take(currentMaxLength)
                        .map((comp) => WidgetSingleComponent(
                              component: comp,
                            ))
                        .toList(),
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => setState(
                          () => currentMaxLength = math.max(
                              currentMaxLength + addSize, elementsMaxLength),
                        ),
                        child: Card(
                          child: Container(
                            width: 25.0,
                            height: 25.0,
                            child: Text('+'),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      InkWell(
                        onTap: () => setState(
                          () => currentMaxLength = math.min(
                              currentMaxLength - decreaseSize,
                              currentMaxLength - 10),
                        ),
                        child: Card(
                          child: Container(
                            width: 25.0,
                            height: 25.0,
                            child: Text('-'),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
      ),
    );
  }
}

class WidgetComponents extends StatefulWidget {
  final Component component;
  const WidgetComponents({@required this.component, Key key}) : super(key: key);

  @override
  WidgetComponentsState createState() => WidgetComponentsState();
}

class WidgetComponentsState extends State<WidgetComponents> {
  Map<Component, void Function()> map;

  @override
  void initState() {
    super.initState();
    map = {};
    widget.component.addListener(listener);
  }

  @override
  void dispose() {
    widget.component.removeListener(listener);
    map.clear();
    super.dispose();
  }

  Component get component => widget.component;

  void listener(Component component) {
    var value = map[component];
    if (value != null) value();
  }

  static WidgetComponentsState of(BuildContext context, {bool require = true}) {
    var state = context.findAncestorStateOfType<WidgetComponentsState>();
    assert(!require || state != null, 'WidgetComponentsState must not be null');
    return state;
  }

  @override
  Widget build(BuildContext context) {
    return WidgetSingleComponent(
      component: component,
    );
  }
}
