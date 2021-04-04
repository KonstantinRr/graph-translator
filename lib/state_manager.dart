import 'package:flutter/material.dart';
import 'package:graph_translator/state/graph.dart';
import 'package:graph_translator/state_events.dart';

class EventParent {
  DateTime time;

  EventParent([DateTime? time]) : time = time ?? DateTime.now();
}

enum ConnectionStatus { Connected, Connecting, Disconnected, Unknown }

class ConnectionEvent extends EventParent {
  ConnectionStatus status;
  ConnectionEvent(this.status) : super();
}

class StateManagerProvider extends InheritedWidget {
  final StateManagerWidgetState state;

  StateManagerProvider({required this.state, required Widget child})
      : super(child: child);

  static StateManagerWidgetState? of(BuildContext context,
      {bool require = true}) {
    var ctx =
        context.dependOnInheritedWidgetOfExactType<StateManagerProvider>();
    assert(!require || ctx != null, 'Provider must not be null');
    return ctx?.state;
  }

  @override
  bool updateShouldNotify(StateManagerProvider oldWidget) {
    return false;
  }
}

class StateManagerWidget extends StatefulWidget {
  final Widget child;

  const StateManagerWidget({required this.child,
    Key? key}) : super(key: key);

  @override
  StateManagerWidgetState createState() => StateManagerWidgetState();
}

class StateManagerWidgetState extends State<StateManagerWidget> {
  EventController<Component> _selected = EventController();

  void dothings() {}

  get selected => _selected;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _selected.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StateManagerProvider(state: this, child: widget.child);
  }
}
