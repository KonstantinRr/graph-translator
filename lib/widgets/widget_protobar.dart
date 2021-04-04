import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graph_translator/state_events.dart';
import 'package:graph_translator/widgets/widget_time_controller.dart';

class Pair<T1, T2> {
  final T1 t1;
  final T2 t2;

  const Pair(this.t1, this.t2);
}

enum _ProtoBarValue { Design, Prototype }

class _ProtoBarEvent {
  final _ProtoBarValue value;
  const _ProtoBarEvent(this.value);
}

enum _ProtoBarState { Open, Close }


class _ProtoBarManager extends StatefulWidget {
  final Widget child;
  const _ProtoBarManager({required this.child, Key? key}) : super(key: key);

  @override
  _ProtoBarManagerState createState() => _ProtoBarManagerState();
}

class _ProtoBarManagerState extends State<_ProtoBarManager> {
  final event =
      EventController<_ProtoBarEvent>(_ProtoBarEvent(_ProtoBarValue.Design));
  final offsetMap =
      EventController<Map<_ProtoBarValue, Pair<Offset, Size>>>(const {
    _ProtoBarValue.Design: Pair(Offset.zero, Size.zero),
    _ProtoBarValue.Prototype: Pair(Offset.zero, Size.zero),
  });
  final state = EventController<_ProtoBarState>(_ProtoBarState.Open);

  @override
  void dispose() {
    event.dispose();
    offsetMap.dispose();
    state.dispose();
    super.dispose();
  }

  static _ProtoBarManagerState? of(BuildContext context, {bool require = true}) {
    var ctx = context.findAncestorStateOfType<_ProtoBarManagerState>();
    assert(!require || ctx != null, 'ProtoBarManagerState must not be null');
    return ctx;
  }

  void animateTo(_ProtoBarValue key) {
    event.addEvent(_ProtoBarEvent(key));
  }

  void setBarState(_ProtoBarState newState) {
    state.addEvent(newState);
  }

  void regiserOffset(_ProtoBarValue key, Pair<Offset, Size> value) {
    var newMap = (offsetMap.lastEvent as Map<_ProtoBarValue, Pair<Offset, Size>>)
      .map((key, value) => MapEntry(key, value));
    newMap[key] = value;
    offsetMap.addEvent(newMap);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _SelectionAnimatorPainter extends CustomPainter {
  final Color color;
  final double value, length;
  const _SelectionAnimatorPainter(this.color, this.value, this.length);

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

class _SelectionAnimator extends StatefulWidget {
  final Color color;
  const _SelectionAnimator({required this.color, Key? key}) : super(key: key);
  @override
  _SelectionAnimatorState createState() => _SelectionAnimatorState();
}

class _SelectionAnimatorState extends State<_SelectionAnimator>
    with SingleTickerProviderStateMixin {
  StreamSubscription? subscription;
  CombinedStream? combinedStream;
  late final AnimationController controller;
  late Animation<double> size, offset;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );
  }

  void clearState() {
    subscription?.cancel();
    combinedStream?.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    clearState();

    var state = _ProtoBarManagerState.of(context) as _ProtoBarManagerState;
    combinedStream = CombinedStream([state.offsetMap, state.event]);
    setStopped(getFromList(combinedStream?.lastEvent));

    subscription = combinedStream?.stream.listen((event) {
      setState(() {
        var pair = getFromList(event);
        setMoving(pair);
      });
    });
  }

  Pair<Offset, Size> getFromList(List? event) {
    assert(event != null, 'Event must not be null');

    var key = ((event as List)[1] as _ProtoBarEvent).value;
    return (event[0] as Map<_ProtoBarValue, Pair<Offset, Size>>)[key] as Pair<Offset, Size>;
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
    clearState();
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
              _SelectionAnimatorPainter(widget.color, offset.value, size.value),
        ),
      ),
    );
  }
}

class RegisterSizeWidget extends StatelessWidget {
  final _ProtoBarValue registerKey;
  final Widget child;
  final GlobalKey parent;
  const RegisterSizeWidget(
      {required this.registerKey,
      required this.child,
      required this.parent,
      Key? key})
      : super(key: key);

  void register(BuildContext context) {
    var parentBox = parent.currentContext?.findRenderObject();
    var box = context.findRenderObject() as RenderBox;
    var state = _ProtoBarManagerState.of(context);
    var offset = box.localToGlobal(Offset.zero, ancestor: parentBox);

    state?.regiserOffset(registerKey, Pair(offset, box.size));
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      register(context);
    });
    return child;
  }
}

class ProtoBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _ProtoBarManager(
      child: Container(
        color: Colors.white,
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, 
            children: [
              Row(
                children: [
                  Expanded(child: _ProtoBarHeader(),),
                  _ProtoBarContentHeader(),
                  _ProtoBarStateButton(),
                ],
              ),
              _ProtoBarContent(),
            ],
          ),
        ),
      )
    );
  }
}

class _ProtoBarStateButton extends StatelessWidget {
  const _ProtoBarStateButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var provider = _ProtoBarManagerState.of(context)
      as _ProtoBarManagerState;
    return EventStreamBuilder<_ProtoBarState>(
      controller: provider.state,
      builder: (context, data) {
        switch (data) {
          case _ProtoBarState.Open:
            return IconButton(
              icon: Icon(Icons.arrow_upward),
              onPressed: () =>
                provider.setBarState(_ProtoBarState.Close),
            );
          case _ProtoBarState.Close:
            return IconButton(
              icon: Icon(Icons.arrow_downward),
              onPressed: () =>
                provider.setBarState(_ProtoBarState.Open),
            );
        }
      },
    );
  }
}

class _ProtoBarContentHeader extends StatelessWidget {
  const _ProtoBarContentHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        //WidgetTimeController(),
        IconButton(
          icon: Icon(Icons.text_fields),
          onPressed: () { },
        )
      ],
    );
  }
}

class _ProtoBarContent extends StatefulWidget {
  const _ProtoBarContent({Key? key}) : super(key: key);

  @override
  _ProtoBarContentState createState() => _ProtoBarContentState();
}

class _ProtoBarContentState extends State<_ProtoBarContent> 
  with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late StreamSubscription subscription;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
  }

  void clearState() {
    //subscription.cancel();
  }

  @override
  void dispose() {
    clearState();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _ProtoBarHeader extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey parentKey = GlobalKey();
  final double height;

  _ProtoBarHeader({this.height = kToolbarHeight, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var style = Theme.of(context).textTheme.button?.copyWith(color: Colors.grey[800]);
    return SizedBox(
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
              registerKey: _ProtoBarValue.Design,
              parent: parentKey,
              child: TextButton(
                onPressed: () {
                  var state = _ProtoBarManagerState.of(context)
                    as _ProtoBarManagerState;
                  state.animateTo(_ProtoBarValue.Design);
                },
                child: Text('Design', style: style,),
              ),
            ),
            RegisterSizeWidget(
              registerKey: _ProtoBarValue.Prototype,
              parent: parentKey,
              child: TextButton(
                onPressed: () {
                  var state = _ProtoBarManagerState.of(context)
                    as _ProtoBarManagerState;
                  state.animateTo(_ProtoBarValue.Prototype);
                },
                child: Text('Prototype', style: style,),
              ),
            ),
          ]),
          Positioned(
            bottom: 0.0,
            height: 2.0,
            left: 0.0,
            right: 0.0,
            child: _SelectionAnimator(
              color: Colors.grey[400] as Color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
