import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EventStreamBuilder<T> extends StatelessWidget {
  final EventController<T> controller;
  final Widget Function(BuildContext, T) builder;
  final Widget Function(BuildContext) builderNoData;
  final Widget Function(BuildContext, dynamic) builderError;
  final bool useBuilderOnNull;

  EventStreamBuilder(
      {@required this.controller,
      @required this.builder,
      Widget Function(BuildContext) builderNoData,
      Widget Function(BuildContext, dynamic) builderError,
      this.useBuilderOnNull = true})
      : assert(controller != null, 'Controller must not be null!'),
        assert(builder != null, 'Builder must not be null'),
        assert(useBuilderOnNull != null, 'UseBuilderOnNull must not be null!'),
        builderNoData =
            builderNoData ?? ((context) => CircularProgressIndicator()),
        builderError = builderError ??
            ((context, err) => Center(
                  child: Text('An error occured $err!'),
                ));

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: controller.streamController.stream,
      initialData: controller.lastEvent,
      builder: (context, snap) {
        if (snap.hasError) return builderError(context, snap.error);
        if (snap.hasData || useBuilderOnNull)
          return builder(context, snap.data);
        return builderNoData(context);
      },
    );
  }
}

class EventController<T> {
  StreamController<T> streamController = StreamController.broadcast();
  T _lastEvent;

  EventController([this._lastEvent]);

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
