/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Iterable<E> mapIndexed<E, T>(
    Iterable<T> items, E Function(int index, T item) f) sync* {
  var index = 0;
  for (final item in items) {
    yield f(index, item);
    index = index + 1;
  }
}

class ListenerHandler<T> {
  dynamic listenerData;

  void notifyListeners(T? event) {
    if (listenerData is void Function(T?))
      listenerData(event);
    else if (listenerData is List) {
      listenerData.forEach((e) => e(event));
    }
  }

  void addListener(void Function(T?) listener) {
    if (listenerData is void Function(T?)) {
      listenerData = <void Function(T)>[listenerData, listener];
    } else if (listenerData is List) {
      listenerData.add(listener);
    } else {
      // null case
      listenerData = listener;
    }
  }

  void removeListener(void Function(T?) listener) {
    if (listener == listenerData) {
      listenerData = null;
    } else if (listenerData is List) {
      var ldata = listenerData as List;
      ldata.remove(listener);
      if (ldata.length == 1) {
        listenerData = ldata.first;
      }
    }
  }

  T? get lastEvent => null;
}

abstract class LastAccessibleStream<T> extends ListenerHandler<T> {
  late final StreamSubscription subscription;

  LastAccessibleStream() {
    subscription = stream.listen((event) {
      notifyListeners(event);
    });
  }

  void dispose() => subscription.cancel();

  Stream<T> get stream;
  T? get lastEvent;
}

class EventController<T> extends LastAccessibleStream<T> {
  StreamController<T> streamController = StreamController.broadcast();
  T? _lastEvent;

  EventController([this._lastEvent]);

  Stream<T> get stream => streamController.stream;

  T? get lastEvent => _lastEvent;

  void addEvent(T event) {
    streamController.add(event);
    _lastEvent = event;
  }

  void dispose() {
    streamController.close();
  }
}

class CombinedStream extends LastAccessibleStream<List> {
  final List<EventController> controllers;
  final _outController = StreamController<List>.broadcast();
  late final List<StreamSubscription> subscriptions;

  CombinedStream(this.controllers) {
    subscriptions = mapIndexed<StreamSubscription, EventController>(
      controllers,
      (idx, stream) => stream.stream.listen(
        (event) {
          var lastStateList = lastEvent;
          lastStateList[idx] = event;
          _outController.add(lastStateList);
        },
      ),
    ).toList();
  }

  List get lastEvent => controllers.map((e) => e.lastEvent).toList();

  @override
  void dispose() {
    subscriptions.forEach((stream) => stream.cancel());
    _outController.close();
    super.dispose();
  }

  Stream<List> get stream => _outController.stream;
}

class EventValueBuilder<T extends Listenable> extends StatefulWidget {
  final dynamic notifier;
  final Widget Function(BuildContext) builder;

  const EventValueBuilder(
      {required T notifier, required this.builder, Key? key})
      : notifier = notifier, super(key: key);
    
  const EventValueBuilder.multiple(
    {required List<T> notifiers, required this.builder, Key? key})
    : notifier = notifiers, super(key: key);


  @override
  EventValueBuilderState<T> createState() => EventValueBuilderState<T>();
}

class EventValueBuilderState<T extends Listenable>
    extends State<EventValueBuilder<T>> {
  @override
  void initState() {
    super.initState();
    if (widget.notifier is List) {
      widget.notifier.forEach((e) => e.addListener(listen));
    } else {
      widget.notifier.addListener(listen);
    }
  }

  @override
  void dispose() {
    if (widget.notifier is List) {
      widget.notifier.forEach((e) => e.removeListener(listen));
    } else {
      widget.notifier.removeListener(listen);
    }
    super.dispose();
  }

  void listen() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}

class EventStreamBuilder<T> extends StatelessWidget {
  final EventController<T> controller;
  final Widget Function(BuildContext, T) builder;
  final Widget Function(BuildContext) builderNoData;
  final Widget Function(BuildContext, dynamic) builderError;
  final bool useBuilderOnNull;

  EventStreamBuilder(
      {required this.controller,
      required this.builder,
      Widget Function(BuildContext)? builderNoData,
      Widget Function(BuildContext, dynamic)? builderError,
      this.useBuilderOnNull = true})
      : builderNoData =
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
          return builder(context, snap.data as T);
        return builderNoData(context);
      },
    );
  }
}
