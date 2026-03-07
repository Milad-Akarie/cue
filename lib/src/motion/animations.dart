import 'package:cue/cue.dart';
import 'package:flutter/widgets.dart';

class CueProgressAnimation<T> extends Animation<T>
    with AnimationLocalListenersMixin, AnimationLocalStatusListenersMixin {
  T _value;
  AnimationStatus _status;

  CueProgressAnimation({
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

abstract class _CueAnimationBase<T> extends Animation<T> {
  final Animation<double> parent;

  _CueAnimationBase({required this.parent});

  final _wrappers = <VoidCallback, VoidCallback>{};

  bool get isReverseOrDismissed =>
      parent.status == AnimationStatus.reverse || parent.status == AnimationStatus.dismissed;

  CueAnimtable<T> get animtable;

  @override
  T get value => animtable.transform(parent.value, parent.status);

  @override
  void addListener(VoidCallback listener) {
    parent.addListener(
      _wrappers[listener] ??= () {
        if (animtable.shouldNotify(parent.status)) listener();
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

class CueAnimation<T> extends _CueAnimationBase<T> {
  @override
  final CueAnimtable<T> animtable;

  CueAnimation({required super.parent, required this.animtable});
}

class DeferredCueAnimation<T> extends _CueAnimationBase<T> {
  ActContext context;

  DeferredCueAnimation({
    required super.parent,
    required this.context,
  });

  CueAnimtable<T>? _animatable;

  @override
  CueAnimtable<T> get animtable {
    if (_animatable == null) {
      throw StateError('Animatable is not set yet');
    }
    return _animatable!;
  }

  bool get hasAnimatable => _animatable != null;

  void setAnimatable(CueAnimtable<T>? animatable) {
    _animatable = animatable;
  }
}

abstract class CueAnimtable<T> {
  const CueAnimtable();
  T transform(double t, AnimationStatus status);
  bool shouldNotify(AnimationStatus status);

  static CueAnimtable<U> resolve<U>(ActorRole role, Animatable<U> animtable, [Animatable<U>? reverse]) {
    return switch (role) {
      ActorRole.forward => ForwardAnimatable(animtable),
      ActorRole.reverse => ReverseAnimatable(animtable),
      ActorRole.both => DualAnimatable(forward: animtable, reverse: reverse),
    };
  }
}

class ForwardAnimatable<T> extends CueAnimtable<T> {
  final Animatable<T> inner;
  const ForwardAnimatable(this.inner);

  @override
  bool shouldNotify(AnimationStatus status) => status.isForwardOrCompleted;

  @override
  T transform(double t, AnimationStatus status) {
    return inner.transform(shouldNotify(status) ? t : 1.0);
  }
}

class ReverseAnimatable<T> extends CueAnimtable<T> {
  final Animatable<T> inner;
  const ReverseAnimatable(this.inner);

  @override
  T transform(double t, AnimationStatus status) {
    return inner.transform(shouldNotify(status) ? 1.0 - t : 0.0);
  }

  @override
  bool shouldNotify(AnimationStatus status) {
    return status == AnimationStatus.reverse || status == AnimationStatus.dismissed;
  }
}

class DualAnimatable<T> extends CueAnimtable<T> {
  final Animatable<T> forward;
  final Animatable<T> _reverse;

  DualAnimatable({required this.forward, required Animatable<T>? reverse}) : _reverse = reverse ?? forward;

  @override
  bool shouldNotify(AnimationStatus status) => true;

  @override
  T transform(double t, AnimationStatus status) {
    final isReversing = status == AnimationStatus.reverse || status == AnimationStatus.dismissed;
    return isReversing ? _reverse.transform(t) : forward.transform(t);
  }
}

class AlwaysStoppedAnimatable<T> extends CueAnimtable<T> {
  final T value;

  const AlwaysStoppedAnimatable(this.value);

  @override
  bool shouldNotify(AnimationStatus status) => false;

  @override
  T transform(double t, AnimationStatus status) => value;
}
