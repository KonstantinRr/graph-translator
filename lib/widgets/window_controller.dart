import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graph_translator/state_events.dart';

/// Contains the different states that a window can have
enum WindowType {
  Open,
  Closed,
  Minimized,
}

/// Collects all window state information in a single class
class WindowState {
  Rect rect;
  WindowType type;

  WindowState({this.rect = Rect.zero, this.type = WindowType.Minimized});

  WindowState copyWith({Rect rect, WindowType type}) {
    return WindowState(
      rect: rect ?? this.rect,
      type: type ?? this.type,
    );
  }
}

class WindowData {
  EventController<WindowState> _eventController;
  OverlayEntry _entry;

  WindowData(this._eventController, this._entry);

  EventController<WindowState> get eventController => _eventController;
  OverlayEntry get entry => _entry;
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

  /// Creates a new event and moves the window
  void move(Offset offset) {
    var win = stateRef.getWindowData(title);
    var eventController = win.eventController;
    eventController.addEvent(eventController.lastEvent.copyWith(
      rect: eventController.lastEvent.rect.shift(offset),
    ));
  }

  /// Creates a new event and sets the state of the window
  void setState(WindowType type) {
    var win = stateRef.getWindowData(title);
    var eventController = win.eventController;
    eventController.addEvent(eventController.lastEvent.copyWith(
      type: type,
    ));
  }

  WindowState get state =>
      stateRef.getWindowData(title).eventController.lastEvent;

  /// Creates a new event and minimizes the window
  void minimize() => setState(WindowType.Minimized);

  /// Creates a new event and opens the window
  void open() => setState(WindowType.Open);

  /// Creates a new event and closes the window
  void close() => setState(WindowType.Closed);
}

/// The [Widget] that combines all the functionality in a single
class WindowController extends StatefulWidget {
  final Widget child;
  const WindowController({@required this.child, Key key}) : super(key: key);

  @override
  WindowControllerState createState() => WindowControllerState();
}

class WindowControllerState extends State<WindowController> {
  final Map<String, WindowData> state = {};

  WindowData getWindowData(String title) {
    if (state.containsKey(title)) {
      return state[title];
    } else {
      createWindowData(title);
      return state[title];
    }
  }

  void createWindowData(String title) {
    var data = WindowData(EventController<WindowState>(WindowState()), null);
    data.eventController.stream.listen((event) {});
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      Overlay.of(context).insert(_createOverlayEntry());
    });
  }

  @override
  void dispose() {
    for (var value in state.values) {
      value.eventController.dispose();
      value.entry.remove();
    }
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

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject();
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: 100,
        top: 100,
        width: 50.0,
        height: 50.0,
        child: Material(
          elevation: 4.0,
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: <Widget>[
              ListTile(
                title: Text('Syria'),
              ),
              ListTile(
                title: Text('Lebanon'),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
