/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

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

  Offset offset, offsetScale;
  Size size, scale;
  bool resizeWidth, resizeHeight, move;
  BoxConstraints constraints;

  Widget Function(BuildContext) builder;

  WindowState(
      {this.offset = Offset.zero,
      this.size = const Size(100, 100),
      this.resizeWidth = true,
      this.resizeHeight = true,
      this.move = true,
      this.offsetScale = Offset.zero,
      this.scale = Size.zero,
      this.displayName = 'Window',
      this.constraints = const BoxConstraints(
          minWidth: 100, minHeight: 100, maxWidth: 1000, maxHeight: 1000),
      this.type = WindowType.Minimized,
      Widget Function(BuildContext)? builder}) : 
        builder = builder ??
            ((context) => Container(
                  alignment: Alignment.center,
                  child: Text('No Content'),
                ));

  WindowState copyWith(
      {Size? size,
      Size? scale,
      Offset? offset,
      Offset? offsetScale,
      BoxConstraints? constraints,
      String? displayName,
      bool? resizeWidth,
      bool? resizeHeight,
      WindowType? type,
      Widget Function(BuildContext)? builder}) {
    return WindowState(
      size: size ?? this.size,
      offset: offset ?? this.offset,
      constraints: constraints ?? this.constraints,
      scale: scale ?? this.scale,
      offsetScale: offsetScale ?? this.offsetScale,
      displayName: displayName ?? this.displayName,
      resizeHeight: resizeHeight ?? this.resizeHeight,
      resizeWidth: resizeWidth ?? this.resizeWidth,
      type: type ?? this.type,
      builder: builder ?? this.builder,
    );
  }

  WindowState copyWithSize(Size newSize) {
    var newScale = Size(
      size.width == 0.0 ? 0.0 : scale.width * (newSize.width / size.width),
      size.height == 0.0 ? 0.0 : scale.height * (newSize.height / size.height),
    );
    return copyWith(
      size: newSize,
      scale: newScale,
    );
  }

  WindowState copyWithOffset(Offset newOffset) {
    var newOffsetScale = Offset(
      offset.dx == 0.0 ? 0.0 : offsetScale.dx * (newOffset.dx / offset.dx),
      offset.dy == 0.0 ? 0.0 : offsetScale.dy * (newOffset.dy / offset.dy),
    );
    return copyWith(
      offset: newOffset,
      offsetScale: newOffsetScale,
    );
  }
}

class WindowData {
  // private members //

  /// The event controller that is responsible for dispatching all window event
  /// changes.
  EventController<WindowState> _eventController;

  /// The entry that is used to display this
  OverlayEntry? _entry;
  // public API //

  EventController<WindowState> get eventController => _eventController;

  WindowData({WindowState? initial})
      : _eventController =
            EventController<WindowState>(initial ?? WindowState()) {
    _entry = _createOverlayEntry();
  }

  WindowState get state {
    assert(eventController.lastEvent != null, 'WindowState must contain last element!');
    return eventController.lastEvent as WindowState;
  }

  void insert(BuildContext context) {
    assert(_entry != null, 'Entry must not be null!');
    Overlay.of(context)?.insert(_entry as OverlayEntry);
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
    _eventController.dispose();
  }

  /// Creates a new event and moves the window
  void move(Offset offset) {
    eventController.addEvent(state.copyWithOffset(
      state.offset + offset,
    ));
  }

  void expandSize(Offset offset) {
    _eventController.addEvent(
      state.copyWithSize(
        state.constraints.constrain(Size(
          state.size.width + offset.dx,
          state.size.height + offset.dy,
        )),
      ),
    );
  }

  Offset offsetFromSize(Size size) => Offset(size.width, size.height);
  Size sizeFromOffset(Offset offset) => Size(offset.dx, offset.dy);

  void expandOrigin(Offset dOffset) {
    Size newSize = state.constraints.constrain(
      Size(state.size.width - dOffset.dx, state.size.height - dOffset.dy));
    Offset oldEnd = state.offset + offsetFromSize(state.size);
    Offset newEnd = state.offset + offsetFromSize(newSize);

    var difference = state.offset + (oldEnd - newEnd);
    eventController.addEvent(
      state.copyWithSize(newSize).copyWithOffset(difference),
    );
  }

  void expand(Size size) {
    Offset newOffset = Offset(
      state.offset.dx + (size.width < 0 ? size.width : 0),
      state.offset.dy + (size.height < 0 ? size.height : 0),
    );
    Size newSize = Size(
      state.size.width + (size.width > 0 ? size.width : 0),
      state.size.height + (size.height > 0 ? size.height : 0),
    );
    _eventController.addEvent(
      state.copyWithSize(newSize).copyWithOffset(newOffset),
    );
  }

  /// Creates a new event and sets the state of the window
  void setState(WindowType type) {
    eventController.addEvent(state.copyWith(
      type: type,
    ));
  }

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

  static Window? of(BuildContext context, String name, {bool require = true}) {
    var ctx = context.findAncestorStateOfType<WindowControllerState>();
    if (ctx == null) {
      assert(!require, 'WindowController must not be null');
      return null;
    }
    return Window(ctx, name);
  }
}

/// The [Widget] that combines all the functionality in a single
class WindowController extends StatefulWidget {
  final Widget child;
  final Map<String, WindowState> initialStates;
  const WindowController(
      {required this.child, this.initialStates = const {}, Key? key})
      : super(key: key);

  @override
  WindowControllerState createState() => WindowControllerState();
}

class WindowControllerState extends State<WindowController> {
  final Map<String, WindowData> state = {};

  WindowData getWindowData(String title, {WindowState? initial}) {
    if (state.containsKey(title)) {
      return state[title] as WindowData;
    } else {
      addWindow(title, initial);
      return state[title] as WindowData;
    }
  }

  void addWindow(String title, WindowState? initial) {
    if (state.containsKey(title))
      (state[title] as WindowData).dispose();
    WindowData data = WindowData(initial: initial);
    data.insert(context);
    state[title] = data;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      for (var entry in widget.initialStates.entries)
        addWindow(entry.key, entry.value);
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
  static WindowControllerState? of(BuildContext context, {bool require = true}) {
    var ctx = context.findAncestorStateOfType<WindowControllerState>();
    assert(!require || ctx != null, 'WindowController must not be null');
    return ctx;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
