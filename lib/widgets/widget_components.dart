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

class WidgetSingleComponent<T, Q> extends StatefulWidget {
  final T component;
  final List<T> Function(T) splitter;
  final Widget Function(BuildContext, T) builder;

  final int initialLength;
  const WidgetSingleComponent(
      {required this.component,
      this.initialLength = 16,
      required this.splitter,
      required this.builder,
      Key? key})
      : super(key: key);

  @override
  WidgetSingleComponentState<T, Q> createState() =>
      WidgetSingleComponentState<T, Q>();
}

class WidgetSingleComponentState<T, Q>
    extends State<WidgetSingleComponent<T, Q>> {
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

  void onMore() {
    setState(() => currentMaxLength =
        math.max(currentMaxLength - decreaseSize, elementsMinLength));
  }

  void onLess() {
    setState(() => currentMaxLength =
        math.min(currentMaxLength + addSize, elementsMaxLength));
  }

  Widget buildButtons(BuildContext context) {
    return Padding(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    List<T> subComponents = widget.splitter(widget.component);

    if (subComponents.isEmpty) {
      return widget.builder(context, widget.component);
    } else {
      return Column(
        children: [
          widget.builder(context, widget.component),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: subComponents.length == 1
                ? widget.builder(context, subComponents.first)
                : Column(
                    children: [
                      ...subComponents.map((e) => widget.builder(context, e)),
                      buildButtons(context),
                    ],
                  ),
          )
        ],
      );
    }
  }
}

/*
class WidgetComponentDetail extends StatelessWidget {
  final Component component;
  const WidgetComponentDetail({required this.component, Key? key}) : super(key: key);

  Widget recursiveBuilder(BuildContext context, Map<String, dynamic> data) {
    return WidgetSingleComponent<Map<String, dynamic>>(
      component: data,
      splitter: (data) => data.entries.toList(),
      builder: (context, object) {

      },
    )
  }

  @override
  Widget build(BuildContext context) {
    var data = component.toJson();

  }
}
*/

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

  void listener(Component? component) {
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
    return WidgetSingleComponent<Component, Component>(
      splitter: (component) =>
          component is SuperComponent ? component.children.toList() : [],
      builder: (context, data) {
        return Text(
          data.runtimeType.toString(),
          style: TextStyle(fontSize: 18),
        );
      },
      component: component,
    );
  }
}
