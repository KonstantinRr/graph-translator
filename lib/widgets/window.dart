import 'package:flutter/material.dart';

class WindowWidget extends StatelessWidget {
  final Widget child;
  final String title;
  const WindowWidget({@required this.title, @required this.child, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 2.0,
      color: Colors.white,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: <Widget>[
            Row(
              children: [
                IconButton(onPressed: () {}, icon: Icon(Icons.close)),
              ],
            ),
            Divider(),
            SizedBox(height: 60.0, child: child),
          ],
        ),
      ),
    );
  }
}
