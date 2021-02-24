/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'dart:async';

import 'package:flutter/material.dart';

class EventStreamBuilder<T extends EventParent<T>> extends StatelessWidget {
  final EventController<T> controller;
  final Widget Function(BuildContext, T) builder;
  final Widget Function(BuildContext) builderNoData;
  final Widget Function(BuildContext, dynamic) builderError;
  final bool useBuilderOnNull;

  EventStreamBuilder({
    @required this.controller, @required this.builder,
    Widget Function(BuildContext) builderNoData,
    Widget Function(BuildContext, dynamic) builderError,
    this.useBuilderOnNull = true
  }) :
    assert(controller != null, 'Controller must not be null!'),
    assert(builder != null, 'Builder must not be null'),
    assert(useBuilderOnNull != null, 'UseBuilderOnNull must not be null!'),
    builderNoData = builderNoData ?? ((context) => CircularProgressIndicator()),
    builderError = builderError ?? ((context, err) => Center(
      child: Text('An error occured $err!'),
    ));

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: controller.streamController.stream,
      initialData: controller.lastEvent,
      builder: (context, snap) {
        if (snap.hasError)
          return builderError(context, snap.error);
        if (snap.hasData || useBuilderOnNull)
          return builder(context, snap.data);
        return builderNoData(context);
      },
    );
  }
}




class StateManagerProvider extends InheritedWidget {
  final StateManagerWidgetState state;

  StateManagerProvider({
    @required this.state,
    Widget child}) : super(child: child);

  static StateManagerWidgetState of(BuildContext context, {bool require=true}) {
    var ctx = context.dependOnInheritedWidgetOfExactType<StateManagerProvider>();
    assert(!require || ctx != null, 'Provider must not be null');
    return ctx?.state;
  }

  @override
  bool updateShouldNotify(StateManagerProvider oldWidget) {
    return false;
  }
}

abstract class EventParent<T> {
  const EventParent();
}

// Widget //

class EventController<T extends EventParent<T>> {
  StreamController<T> streamController = StreamController.broadcast();
  T _lastEvent;

  Stream<T> get stream => streamController.stream;

  T get lastEvent => _lastEvent;

  void addEvent(T event) {
    streamController.add(event);
    _lastEvent = event;
  }

  void dispose() {
    streamController.close();
  }
}

class StateManagerWidget extends StatefulWidget {
  final Widget child;
  StateManagerWidget(this.child);

  @override
  StateManagerWidgetState createState() => StateManagerWidgetState();
}

class StateManagerWidgetState extends State<StateManagerWidget> {

  @override
  void initState() {
    super.initState();
    // Registers some handlers
  }

  @override
  void dispose() {
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return StateManagerProvider(
      state: this,
      child: widget.child
    );
  }
}