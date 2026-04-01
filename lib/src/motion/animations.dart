import 'package:cue/cue.dart';
import 'package:cue/src/timeline/track/track.dart';
import 'package:cue/src/timeline/track/track_config.dart';
import 'package:flutter/widgets.dart';

abstract class CueAnimation<T> extends Animation<T> with AnimationWithParentMixin<double> {
  @override
  final CueTrack parent;

  ReleaseToken get token;

  TrackConfig get trackConfig => parent.config;

  CueAnimation({required this.parent});

  CueAnimationImpl<S> map<S>(S Function(T value) selector) {
    return CueAnimationImpl<S>(
      parent: parent,
      token: token,
      animtable: _MappedCueAnimtable<T, S>(animtable, selector),
    );
  }

  bool get isReverseOrDismissed =>
      parent.status == AnimationStatus.reverse || parent.status == AnimationStatus.dismissed;

  CueAnimtable<T> get animtable;

  @override
  T get value => animtable.evaluate(parent);

  void release() => token.release();
}

class CueAnimationImpl<T> extends CueAnimation<T> {
  @override
  final CueAnimtable<T> animtable;

  @override
  final ReleaseToken token;

  CueAnimationImpl({required super.parent, required this.token, required this.animtable});
}

class _MappedCueAnimtable<T, S> extends CueAnimtable<S> {
  final CueAnimtable<T> parent;
  final S Function(T value) selector;

  _MappedCueAnimtable(this.parent, this.selector);

  @override
  S evaluate(CueTrack track) {
    return selector(parent.evaluate(track));
  }
}

class DeferredCueAnimation<T> extends CueAnimation<T> {
  ActContext context;

  @override
  final ReleaseToken token;

  DeferredCueAnimation({
    required super.parent,
    required this.context,
    required this.token,
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

class RetargetableCueAnimation<T> extends CueAnimation<T> {
  @override
  final ReleaseToken token;

  final CueController controller;

  RetargetableCueAnimation({
    required super.parent,
    required this.controller,
    required T initialValue,
    required this.token,
  }) : _animatable = _AlwaysStoppedAnimtable<T>(initialValue);

  late CueAnimtable<T> _animatable;

  @override
  CueAnimtable<T> get animtable => _animatable;

  void setValue(T newValue) {
    controller.stop();
    _animatable = _AlwaysStoppedAnimtable<T>(newValue);
    parent.setProgress(1.0, alwaysNotify: true);
  }

  void retarget(T newTarget, {bool forward = true}) {
    final currentValue = _animatable.evaluate(parent);
    _animatable = TweenAnimtable<T>(Tween(begin: currentValue, end: newTarget));
    if (forward) {
      controller.forward(from: 0.0);
    } else {
      controller.reverse(from: 1.0);
    }
  }
}

class _AlwaysStoppedAnimtable<T> extends CueAnimtable<T> {
  final T value;
  _AlwaysStoppedAnimtable(this.value);
  @override
  T evaluate(CueTrack track) => value;
}
