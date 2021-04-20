/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:graph_translator/state/graph.dart';

class TreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class WidgetSingleComponent extends StatefulWidget {
  final Component component;
  final int initialLength;
  const WidgetSingleComponent(
      {required this.component, this.initialLength = 16, Key? key})
      : super(key: key);

  @override
  WidgetSingleComponentState createState() => WidgetSingleComponentState();
}

class WidgetSingleComponentState extends State<WidgetSingleComponent> {
  late WidgetComponentsState state;
  late int currentMaxLength;

  static const elementsMinLength = 5;
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
    state = WidgetComponentsState.of(context) as WidgetComponentsState;
    state.map[widget.component] = () => setState(() {});
  }

  @override
  void dispose() {
    state.map.remove(widget.component);
    super.dispose();
  }

  void onMore() {
    setState(() => currentMaxLength =
        math.max(currentMaxLength - decreaseSize, elementsMinLength));
  }

  void onLess() {
    setState(() => currentMaxLength =
        math.min(currentMaxLength + addSize, elementsMaxLength));
  }

  Component get component => widget.component;

  Widget buildList(BuildContext context, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        child,
        Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: (component as SuperComponent)
                  .children
                  .take(currentMaxLength)
                  .map((comp) => WidgetSingleComponent(
                        component: comp,
                      ))
                  .toList(),
            )),
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: Row(
            children: [
              Card(
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: onLess,
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      width: 25.0,
                      height: 25.0,
                      alignment: Alignment.center,
                      child: Text('+'),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Card(
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: onMore,
                    child: Container(
                      width: 25.0,
                      height: 25.0,
                      alignment: Alignment.center,
                      child: Text('-'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget object = Text(component.runtimeType.toString());

    return Container(
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child:
            component is SuperComponent ? buildList(context, object) : object,
      ),
    );
  }
}

class WidgetComponents extends StatefulWidget {
  final Component component;
  const WidgetComponents({required this.component, Key? key}) : super(key: key);

  @override
  WidgetComponentsState createState() => WidgetComponentsState();
}

class WidgetComponentsState extends State<WidgetComponents> {
  final map = <Component, void Function()>{};

  @override
  void initState() {
    super.initState();
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

  static WidgetComponentsState? of(BuildContext context,
      {bool require = true}) {
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
