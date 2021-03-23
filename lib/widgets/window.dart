import 'package:flutter/material.dart';
import 'package:graph_translator/state_events.dart';
import 'package:graph_translator/widgets/window_controller.dart';

class WindowWidget extends StatelessWidget {
  final WindowData data;
  const WindowWidget({@required this.data, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EventStreamBuilder<WindowState>(
      controller: data.eventController,
      builderError: (context, err) => Positioned(
        top: 0.0,
        left: 0.0,
        width: 100.0,
        height: 100.0,
        child: Container(
          alignment: Alignment.center,
          child: Text('$err'),
        ),
      ),
      builderNoData: (context) => Positioned.fill(
        child: Container(),
      ),
      builder: (context, state) => Positioned(
        height: state.size.height,
        width: state.size.width,
        left: state.offset.dx,
        top: state.offset.dy,
        child: buildContent(context, state),
      ),
    );
  }

  Widget buildContent(BuildContext context, WindowState state) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Listener(
            behavior: HitTestBehavior.deferToChild,
            onPointerMove: (moveEvent) {
              data.move(moveEvent.delta);
            },
            child: Container(
              height: 30.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Color(0xffF6F6F6),
              ),
              padding: EdgeInsets.only(left: 10, right: 5),
              child: Material(
                type: MaterialType.transparency,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text('${state.displayName}'),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Icon(
                        Icons.minimize,
                        size: 20,
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Icon(
                        Icons.close,
                        size: 20,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 1.0,
            color: Colors.grey[300],
          ),
          Expanded(
            child: state.builder(context),
          )
        ],
      ),
    );
  }
}
