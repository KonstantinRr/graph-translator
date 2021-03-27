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
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    var state = ProtoBarManagerState.of(context);
    combinedStream = CombinedStream([state.offsetMap, state.event]);
    setStopped(combinedStream.lastEvent);

    /*
    subscription = combinedStream.stream.listen((event) {
      var pair = state.offsetMap[event.value];
      assert(pair != null, 'Value must exist in OffsetMap');
      setState(() {
        var curve = CurvedAnimation(
          curve: Curves.easeInOutQuad,
          parent: controller,
        );
        size = Tween(begin: size.value, end: pair.t2.width).animate(curve);
        offset = Tween(begin: offset.value, end: pair.t1.dx).animate(curve);
        controller.reset();
        controller.forward();
      });
    });
    */
  }

  Pair getFromList(List event) {
    var key = (event[1] as ProtoBarEvent);
    return (event[0] as Map<ProtoBarValue, Pair<Offset, Size>>)[key];
  }

  void setStopped(List event) {
    var key = (event[1] as ProtoBarEvent);
    var value = (event[0] as Map<ProtoBarValue, Pair<Offset, Size>>)[key];

    offset = AlwaysStoppedAnimation<double>(value.t1.dx);
    size = AlwaysStoppedAnimation<double>(value.t2.width);
  }

  void setMoving(List event) {
    /*
    var curve = CurvedAnimation(
      curve: Curves.easeInOutQuad,
      parent: controller,
    );
    size = Tween(begin: size.value, end: pair.t2.width).animate(curve);
    offset = Tween(begin: offset.value, end: pair.t1.dx).animate(curve);
    controller.reset();
    controller.forward();
    */
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
              SelectionAnimatorPainter(Colors.black, size.value, offset.value),
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

  Future<void> register(BuildContext context) async {
    var parentBox = parent.currentContext.findRenderObject();
    var box = context.findRenderObject() as RenderBox;
    var state = ProtoBarManagerState.of(context);
    var offset = box.localToGlobal(Offset.zero, ancestor: parentBox);

    state.regiserOffset(registerKey, Pair(offset, box.size));
  }

  @override
  Widget build(BuildContext context) {
    register(context);
    return child;
  }
}

class ProtoBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey parentKey = GlobalKey();
  final double height;

  ProtoBar({this.height = kToolbarHeight, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Build');
    return ProtoBarManager(
      child: Container(
        color: Colors.white,
        height: height,
        width: double.infinity,
        key: parentKey,
        child: Stack(
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
                  onPressed: () {},
                  child: Text('Design'),
                ),
              ),
              RegisterSizeWidget(
                registerKey: ProtoBarValue.Prototype,
                parent: parentKey,
                child: TextButton(
                  onPressed: () {},
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
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
