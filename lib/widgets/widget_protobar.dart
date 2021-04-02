import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graph_translator/state_events.dart';

class Pair<T1, T2> {
  final T1 t1;
  final T2 t2;

  const Pair(this.t1, this.t2);
}

enum ProtoBarValue { Design, Prototype }

class ProtoBarEvent {
  final ProtoBarValue value;
  const ProtoBarEvent(this.value);
}

class ProtoBarManager extends StatefulWidget {
  final Widget child;
  const ProtoBarManager({@required this.child, Key key}) : super(key: key);

  @override
  ProtoBarManagerState createState() => ProtoBarManagerState();
}

class ProtoBarManagerState extends State<ProtoBarManager> {
  final event =
      EventController<ProtoBarEvent>(ProtoBarEvent(ProtoBarValue.Design));
  final offsetMap =
      EventController<Map<ProtoBarValue, Pair<Offset, Size>>>(const {
    ProtoBarValue.Design: Pair(Offset.zero, Size.zero),
    ProtoBarValue.Prototype: Pair(Offset.zero, Size.zero),
  });

  @override
  void dispose() {
    event.dispose();
    super.dispose();
  }

  static ProtoBarManagerState of(BuildContext context, {bool require = true}) {
    var ctx = context.findAncestorStateOfType<ProtoBarManagerState>();
    assert(!require || ctx != null, 'ProtoBarManagerState must not be null');
    return ctx;
  }

  void animateTo(ProtoBarValue key) {
    event.addEvent(ProtoBarEvent(key));
  }

  void regiserOffset(ProtoBarValue key, Pair<Offset, Size> value) {
    var newMap = offsetMap.lastEvent.map((key, value) => MapEntry(key, value));
    newMap[key] = value;
    offsetMap.addEvent(newMap);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class SelectionAnimatorPainter extends CustomPainter {
  final Color color;
  final double value, length;
  const SelectionAnimatorPainter(this.color, this.value, this.length);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromPoints(
        Offset(value, 0.0),
        Offset(value + length, size.height),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SelectionAnimator extends StatefulWidget {
  const SelectionAnimator({Key key}) : super(key: key);
  @override
  SelectionAnimatorState createState() => SelectionAnimatorState();
}

class SelectionAnimatorState extends State<SelectionAnimator>
    with SingleTickerProviderStateMixin {
  StreamSubscription subscription;
  CombinedStream combinedStream;
  AnimationController controller;
  Animation<double> size, offset;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    var state = ProtoBarManagerState.of(context);
    combinedStream = CombinedStream([state.offsetMap, state.event]);
    setStopped(getFromList(combinedStream.lastEvent));

    
    subscription = combinedStream.stream.listen((event) {
      setState(() {
        var pair = getFromList(event);
        setMoving(pair);
      });
    });
  }

  Pair<Offset, Size> getFromList(List event) {
    var key = (event[1] as ProtoBarEvent).value;
    return (event[0] as Map<ProtoBarValue, Pair<Offset, Size>>)[key];
  }

  void setStopped(Pair<Offset, Size> value) {
    offset = AlwaysStoppedAnimation<double>(value.t1.dx);
    size = AlwaysStoppedAnimation<double>(value.t2.width);
  }

  void setMoving(Pair<Offset, Size> value) {
    var curve = CurvedAnimation(
      curve: Curves.easeInOut,
      parent: controller,
    );
    size = Tween(begin: size.value, end: value.t2.width).animate(curve);
    offset = Tween(begin: offset.value, end: value.t1.dx).animate(curve);
    controller.reset();
    controller.forward();
  }

  @override
  void dispose() {
    subscription.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => CustomPaint(
          painter:
              SelectionAnimatorPainter(Colors.black, offset.value, size.value),
        ),
      ),
    );
  }
}

class RegisterSizeWidget extends StatelessWidget {
  final ProtoBarValue registerKey;
  final Widget child;
  final GlobalKey parent;
  const RegisterSizeWidget(
      {@required this.registerKey,
      @required this.child,
      @required this.parent,
      Key key})
      : super(key: key);

  void register(BuildContext context) {
    var parentBox = parent.currentContext.findRenderObject();
    var box = context.findRenderObject() as RenderBox;
    var state = ProtoBarManagerState.of(context);
    var offset = box.localToGlobal(Offset.zero, ancestor: parentBox);

    state.regiserOffset(registerKey, Pair(offset, box.size));
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      register(context);
    });
    return child;
  }
}

class ProtoBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey parentKey = GlobalKey();
  final double height;

  ProtoBar({this.height = kToolbarHeight, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProtoBarManager(
      child: Builder(
        builder: (context) {
          return Container(
            color: Colors.white,
            height: height,
            width: double.infinity,
            child: Stack(
              key: parentKey,
              alignment: Alignment.center,
              children: <Widget>[
                Row(children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.menu),
                    color: Colors.grey,
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.home),
                    color: Colors.grey,
                    onPressed: () {},
                  ),
                  RegisterSizeWidget(
                    registerKey: ProtoBarValue.Design,
                    parent: parentKey,
                    child: TextButton(
                      onPressed: () {
                        var state = ProtoBarManagerState.of(context);
                        state.animateTo(ProtoBarValue.Design);
                      },
                      child: Text('Design'),
                    ),
                  ),
                  RegisterSizeWidget(
                    registerKey: ProtoBarValue.Prototype,
                    parent: parentKey,
                    child: TextButton(
                      onPressed: () {
                        var state = ProtoBarManagerState.of(context);
                        state.animateTo(ProtoBarValue.Prototype);
                      },
                      child: Text('Prototype'),
                    ),
                  ),
                ]),
                Positioned(
                  bottom: 0.0,
                  height: 2.0,
                  left: 0.0,
                  right: 0.0,
                  child: SelectionAnimator(),
                ),
              ],
            )
          );
        }
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
