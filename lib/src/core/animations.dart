import 'package:flutter/widgets.dart';

class DualAnimation<T extends Object?> extends Animation<T> with AnimationWithParentMixin<double> {
  @override
  final Animation<double> parent;

  final Animatable<T> forward;
  final Animatable<T> reverse;

  DualAnimation({
    required this.parent,
    required this.forward,
    required this.reverse,
  });

  bool get isReversing => parent.status == AnimationStatus.reverse || parent.status == AnimationStatus.dismissed;

  @override
  T get value => isReversing ? reverse.evaluate(parent) : forward.evaluate(parent);
}

class ForwardOrStoppedAnimation extends Animation<double> with AnimationWithFilterMixin {
  @override
  final Animation<double> parent;

  @override
  final List<AnimationStatus> allowedStatuses = [AnimationStatus.forward, AnimationStatus.completed];

  @override
  final double fixedTarget;

  ForwardOrStoppedAnimation(this.parent, [this.fixedTarget = 1.0]);
}

class ReverseOrStoppedAnimation extends Animation<double> with AnimationWithFilterMixin {
  @override
  final Animation<double> parent;

  @override
  final List<AnimationStatus> allowedStatuses = [AnimationStatus.reverse, AnimationStatus.dismissed];

  @override
  final double fixedTarget;

  ReverseOrStoppedAnimation(this.parent, [this.fixedTarget = 0.0]);

  @override
  double get value => shouldNotify ? 1.0 - parent.value : fixedTarget;
}

mixin AnimationWithFilterMixin on Animation<double> {
  bool get shouldNotify => allowedStatuses.contains(parent.status);

  double get fixedTarget;

  final _wrappers = <VoidCallback, VoidCallback>{};

  Animation<double> get parent;

  List<AnimationStatus> get allowedStatuses;

  @override
  double get value => shouldNotify ? parent.value : fixedTarget;

  @override
  void addListener(VoidCallback listener) {
    parent.addListener(
      _wrappers[listener] ??= () {
        if (shouldNotify) listener();
      },
    );
  }

  @override
  void removeListener(VoidCallback listener) {
    final wrapper = _wrappers.remove(listener);
    if (wrapper != null) parent.removeListener(wrapper);
  }

  @override
  void addStatusListener(AnimationStatusListener listener) {
    parent.addStatusListener(listener);
  }

  @override
  void removeStatusListener(AnimationStatusListener listener) {
    parent.removeStatusListener(listener);
  }

  @override
  AnimationStatus get status => parent.status;
}

class ProgressAnimation<T> extends Animation<T> with AnimationLocalListenersMixin, AnimationLocalStatusListenersMixin {
  T _value;
  AnimationStatus _status;

  ProgressAnimation({
    required T value,
    AnimationStatus status = AnimationStatus.dismissed,
  }) : _value = value,
       _status = status;

  @override
  T get value => _value;

  @override
  AnimationStatus get status => _status;

  void update(T value, {AnimationStatus status = AnimationStatus.forward}) {
    final valueChanged = _value != value;
    final statusChanged = _status != status;

    if (!valueChanged && !statusChanged) return;

    _value = value;
    _status = status;

    if (statusChanged) notifyStatusListeners(status);
    if (valueChanged) notifyListeners();
  }

  @override
  void didRegisterListener() {
    // NOOP
    // This animation is driven by an external source, so we don't need to do anything here.
  }

  @override
  void didUnregisterListener() {
    // NOOP
    // This animation is driven by an external source, so we don't need to do anything here.
  }
}
