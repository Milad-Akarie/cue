import 'package:flutter/widgets.dart';

class CueAnimation<T extends Object?> extends Animation<T> {
  final Animation<double> driver;
  final Animatable<T> forward;
  final Animatable<T>? reverse;

  CueAnimation({
    required this.driver,
    required this.forward,
    this.reverse,
  });

  late final _reverseDriver = ReverseAnimation(driver);

  bool get isReversing => driver.status == AnimationStatus.reverse || driver.status == AnimationStatus.dismissed;

  @override
  T get value {
    if (reverse == null) {
      return forward.evaluate(driver);
    }
    if (isReversing) {
      return reverse!.evaluate(_reverseDriver);
    }
    return forward.evaluate(driver);
  }

  @override
  AnimationStatus get status => driver.status;

  AnimationStatus get reverseStatus => _reverseDriver.status;

  @override
  void addListener(VoidCallback listener) => driver.addListener(listener);

  @override
  void removeListener(VoidCallback listener) => driver.removeListener(listener);

  @override
  void addStatusListener(AnimationStatusListener listener) => driver.addStatusListener(listener);

  @override
  void removeStatusListener(AnimationStatusListener listener) => driver.removeStatusListener(listener);
}
