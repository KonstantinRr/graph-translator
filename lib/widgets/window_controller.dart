import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graph_translator/state_events.dart';
import 'package:graph_translator/widgets/window.dart';

/// Contains the different states that a window can have
enum WindowType {
  Open,
  Closed,
  Minimized,
}

/// Collects all window state information in a single class
class WindowState {
  String displayName;
  WindowType type;

  Offset offset;
  Size size;
  BoxConstraints constraints;

  Widget Function(BuildContext) builder;

  WindowState(
      {this.offset = Offset.zero,
      this.size = const Size(100, 100),
      this.displayName,
      this.constraints,
      this.type = WindowType.Minimized,
      Widget Function(BuildContext) builder})
      : builder = builder ??
            ((context) => Container(
                  alignment: Alignment.center,
                  child: Text('No Content'),
                ));

  WindowState copyWith(
      {Size size,
      Offset offset,
      BoxConstraints constraints,
      String displayName,
      WindowType type,
      Widget Function(BuildContext) builder}) {
    return WindowState(
      size: size ?? this.size,
      offset: offset ?? this.offset,
      constraints: constraints ?? this.constraints,
      displayName: displayName ?? this.displayName,
      type: type ?? this.type,
      builder: builder ?? this.builder,
    );
  }
}

class WindowData {
  // private members //

  /// The event controller that is responsible for dispatching all window event
  /// changes.
  EventController<WindowState> _eventController;

  /// The entry that is used to display this
  OverlayEntry _entry;
  // public API //

  EventController<WindowState> get eventController => _eventController;

  WindowData({WindowState initial})
      : _eventController =
            EventController<WindowState>(initial ?? WindowState()) {
    _entry = _createOverlayEntry();
  }

  void insert(BuildContext context) {
    Overlay.of(context).insert(_entry);
  }

  void remove() {
    _entry?.remove();
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(builder: (context) => WindowWidget(data: this));
  }

  void dispose() {
    remove();
    _entry = null;
    _eventController?.dispose();
    _eventController = null;
  }

  /// Creates a new event and moves the window
  void move(Offset offset) {
    eventController.addEvent(eventController.lastEvent.copyWith(
      offset: eventController.lastEvent.offset + offset,
    ));
  }

  /// Creates a new event and sets the state of the window
  void setState(WindowType type) {
    eventController.addEvent(eventController.lastEvent.copyWith(
      type: type,
    ));
  }

  WindowState get state => eventController.lastEvent;

  /// Creates a new event and minimizes the window
  void minimize() => setState(WindowType.Minimized);

  /// Creates a new event and opens the window
  void open() => setState(WindowType.Open);

  /// Creates a new event and closes the window
  void close() => setState(WindowType.Closed);
}

/// A reference to a window that is used by clients to make changes to the
/// window. A Window object can be obtained by calling
/// [WindowControllerState.getWindow].
class Window {
  WindowControllerState stateRef;
  String title;

  Window(this.stateRef, this.title);

  static Window of(BuildContext context, String name, {bool require = true}) {
    var ctx = context.findAncestorStateOfType<WindowControllerState>();
    assert(!require || ctx != null, 'WindowController must not be null');
    if (ctx == null) return null;
    return Window(ctx, name);
  }
}

/// The [Widget] that combines all the functionality in a single
class WindowController extends StatefulWidget {
  final Widget child;
  final Map<String, WindowState> initialStates;
  const WindowController(
      {@required this.child, this.initialStates = const {}, Key key})
      : super(key: key);

  @override
  WindowControllerState createState() => WindowControllerState();
}

class WindowControllerState extends State<WindowController> {
  final Map<String, WindowData> state = {};

  WindowData getWindowData(String title, {WindowState initial}) {
    if (state.containsKey(title)) {
      return state[title];
    } else {
      addWindow(title, initial);
      return state[title];
    }
  }

  void addWindow(String title, WindowState initial) {
    if (state.containsKey(title)) state[title].dispose();
    WindowData data = WindowData(initial: initial);
    data.insert(context);
    state[title] = data;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      for (var entry in widget.initialStates.entries) {
        addWindow(entry.key, entry.value);
      }
    });
  }

  @override
  void dispose() {
    for (var value in state.values) value.dispose();
    super.dispose();
  }

  /// Captures a [WindowControllerState] from a [BuildContext].
  /// Throws an exception if [require] is true and the [WindowControllerState]
  /// is null.
  static WindowControllerState of(BuildContext context, {bool require = true}) {
    var ctx = context.findAncestorStateOfType<WindowControllerState>();
    assert(!require || ctx != null, 'WindowController must not be null');
    return ctx;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
