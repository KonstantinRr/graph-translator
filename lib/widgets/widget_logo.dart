/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'package:flutter/material.dart';

/// The application logo [Widget].
class WidgetLogo extends StatelessWidget {
  /// The widget's size
  final double size;
  /// The margin around the [Widget]
  final EdgeInsets margin;

  /// Creates a [WidgetLogo] using a [size] and [margin].
  const WidgetLogo({@required this.size, this.margin, Key key}) :
    assert(size != null, 'Size must not be null'),
    super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: size, height: size,
      decoration: const BoxDecoration(
        image: const DecorationImage(
          fit: BoxFit.contain,
          image: const AssetImage('assets/icon/network512.png')
        )
      ),
    );
  }
}
