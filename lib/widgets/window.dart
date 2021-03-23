import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:graph_translator/state_events.dart';
import 'package:graph_translator/widgets/window_controller.dart';

class WindowWidget extends StatelessWidget {
  final WindowData data;
  final double dragWidth, dragCornerWidth;
  final Color color;
  const WindowWidget(
      {@required this.data,
      this.dragWidth = 10.0,
      this.dragCornerWidth = 15.0,
      this.color = Colors.transparent,
      Key key})
      : super(key: key);

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

  Widget buildListener(void Function(Offset) cb) {
    return Container(
      color: color,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerMove: (moveEvent) => cb(moveEvent.delta),
      ),
    );
  }

  Widget buildContent(BuildContext context, WindowState state) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5.0,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
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
              ),
            ],
          ),
          if (state.resizeWidth)
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              width: dragWidth,
              child: buildListener(
                  (delta) => data.expandSize(Offset(delta.dx, 0))),
            ),
          if (state.resizeWidth)
            Positioned(
              top: 0,
              left: 0,
              bottom: 0,
              width: dragWidth,
              child: buildListener(
                  (delta) => data.expandOrigin(Offset(delta.dx, 0))),
            ),
          if (state.resizeHeight)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: dragWidth,
              child: buildListener(
                  (delta) => data.expandOrigin(Offset(0, delta.dy))),
            ),
          if (state.resizeHeight)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: dragWidth,
              child: buildListener(
                  (delta) => data.expandSize(Offset(0, delta.dy))),
            ),
          if (state.resizeWidth && state.resizeHeight) ...[
            Positioned(
              top: 0,
              right: 0,
              width: dragCornerWidth,
              height: dragCornerWidth,
              child: buildListener((delta) {
                // top right
                data.expandOrigin(Offset(0.0, delta.dy));
                data.expandSize(Offset(delta.dx, 0.0));
              }),
            ),
            Positioned(
              top: 0,
              left: 0,
              width: dragCornerWidth,
              height: dragCornerWidth,
              child: buildListener((delta) {
                // top left
                data.expandOrigin(delta);
              }),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              width: dragCornerWidth,
              height: dragCornerWidth,
              child: buildListener((delta) {
                // bottom left
                data.expandOrigin(Offset(delta.dx, 0.0));
                data.expandSize(Offset(0.0, delta.dy));
              }),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              width: dragCornerWidth,
              height: dragCornerWidth,
              child: buildListener((delta) {
                // bottom right
                data.expandSize(delta);
              }),
            ),
          ]
        ],
      ),
    );
  }
}
