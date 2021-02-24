/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NoTransitionsOnWeb extends PageTransitionsTheme {
  const NoTransitionsOnWeb();
  
  @override
  Widget buildTransitions<T>(
    route, context, animation, secondaryAnimation, child) {
    if (kIsWeb) return child;
    // build the default transtion
    return super.buildTransitions(
      route, context, animation, secondaryAnimation, child);
  }
}