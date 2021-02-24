/// MIT License
/// 
/// Copyright (c) 2017 Matan Lurey
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

import 'dart:async';
import 'dart:math' as math show max, min;

int _previous = 0;

/// A cross-platform implementation for requesting the next animation frame.
///
/// Returns a [Future<num>] that completes as close as it can to the next
/// frame, given that it will attempt to be called 60 times per second (60 FPS)
/// by default - customize by setting the [target].
Future<num> nextFrame([num target = 60]) {
  final current = new DateTime.now().millisecondsSinceEpoch;
  final call = math.max(0, (1000 ~/ target) - (current - _previous));
  return new Future.delayed(
    new Duration(milliseconds: call),
    () => _previous = new DateTime.now().millisecondsSinceEpoch,
  );
}

/// Returns a [Stream] that fires every [animationFrame].
///
/// May provide a function that returns a future completing in the next
/// available frame. For example in a browser environment this may be delegated
/// to `window.animationFrame`:
///
/// ```
/// eachFrame(animationFrame: () => window.animationFrame)
/// ```
Stream<num> eachFrame({Future<num> animationFrame(): nextFrame}) {
  StreamController<num> controller;
  var cancelled = false;
  void onNext(num timestamp) {
    if (cancelled) return;
    controller.add(timestamp);
    animationFrame().then(onNext);
  }
  controller = new StreamController<num>(
    sync: true,
    onListen: () {
      animationFrame().then(onNext);
    },
    onCancel: () {
      cancelled = true;
    },
  );
  return controller.stream;
}

/// Computes frames-per-second given a [Stream<num>] of timestamps.
///
/// The resulting [Stream] is capped at reporting a maximum of 60 FPS.
///
/// ```
/// // Listens to FPS for 10 frames, and reports at FPS, printing to console.
/// eachFrame()
///   .take(10)
///   .transform(const ComputeFps())
///   .listen(print);
/// ```
class ComputeFps implements StreamTransformer<num, num> {
  final num _filterStrength;

  /// Create a transformer.
  ///
  /// Optionally specify a `filterStrength`, or how little to reflect temporary
  /// variations in FPS. A value of `1` will only keep the last value.
  const ComputeFps([this._filterStrength = 20]);

  @override
  Stream<num> bind(Stream<num> stream) {
    StreamController<num> controller;
    StreamSubscription<num> subscription;
    num frameTime = 0;
    num lastLoop;
    controller = new StreamController<num>(
      sync: true,
      onListen: () {
        subscription = stream.listen((thisLoop) {
          if (lastLoop != null) {
            var thisFrameTime = thisLoop - lastLoop;
            frameTime += (thisFrameTime - frameTime) / _filterStrength;
            controller.add(math.min(1000 / frameTime, 60));
          }
          lastLoop = thisLoop;
        });
      },
      onCancel: () => subscription.cancel(),
    );
    return controller.stream;
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() {
    throw UnimplementedError();
  }
}