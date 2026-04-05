import 'package:cue/cue.dart';
import 'package:flutter/material.dart';

/// A [RawDialogRoute] that drives its enter/exit transition with a [CueController].
///
/// The page content is wrapped in a [Cue] widget, so every [Actor] inside
/// the modal automatically subscribes to the route's animation. There is no
/// need to pass a controller explicitly — Actors pick it up via [CueScope].
///
/// The transition itself is a pass-through (`transitionBuilder` returns the
/// child unchanged); all animation logic lives in the Actors.
///
/// ## Usage
///
/// Push it directly for full control:
///
/// ```dart
/// Navigator.of(context).push(
///   CueDialogRoute(
///     motion: Spring.smooth(),
///     reverseMotion: Spring.snappy(),
///     pageBuilder: (context, _, _) => MyModalContent(),
///   ),
/// );
/// ```
///
/// Or use the [showCueDialog] convenience function for the common case.
///
/// ## hideOnPushNext
///
/// When `true` (the default) and another [CueModalRouteMixin] route is pushed
/// on top, this route's content is hidden via [Visibility.maintain]. This
/// enables seamless stacking — e.g. a nested [CueModalTransition] inside a
/// modal won't show both layers simultaneously.
class CueDialogRoute<T extends Object?> extends RawDialogRoute<T> with CueModalRouteMixin<T> {
  /// Default constructor.
  CueDialogRoute({
    required super.pageBuilder,
    super.barrierDismissible,
    super.barrierLabel,
    super.barrierColor,
    required this.motion,
    this.reverseMotion,
    this.onAnimationStatusChanged,
    this.hideOnPushNext = true,
  }) : super(transitionBuilder: (_, _, _, child) => child);

  /// Motion used for the enter transition.
  @override
  final CueMotion motion;

  /// Motion used for the exit transition. Defaults to [motion] when not set.
  @override
  final CueMotion? reverseMotion;

  /// Called whenever the route's [AnimationStatus] changes.
  /// Also called with [AnimationStatus.dismissed] on dispose.
  @override
  final AnimationStatusListener? onAnimationStatusChanged;

  /// When `true`, hides this route's content while another [CueModalRouteMixin]
  /// route is on top. Defaults to `true`.
  @override
  final bool hideOnPushNext;
}

/// Shows a Cue-animated dialog using [CueDialogRoute].
///
/// Equivalent to calling `Navigator.of(context).push(CueDialogRoute(...))`,
/// but captures the ambient theme and handles `useRootNavigator` for you.
///
/// The [builder] receives the modal's [BuildContext], which has a [CueScope]
/// ancestor — so any [Actor] inside can animate with the route's controller
/// without extra setup.
///
/// ```dart
/// showCueDialog(
///   context: context,
///   motion: Spring.smooth(),
///   builder: (context) => Actor(
///     acts: [.fadeIn(), .slideY(from: 0.2)],
///     child: AlertDialog(title: Text('Hello')),
///   ),
/// );
/// ```
@optionalTypeArgs
Future<T?> showCueDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  String barrierLabel = 'CueDialog',
  Color barrierColor = const Color(0x80000000),
  CueMotion motion = .defaultTime,
  CueMotion? reverseMotion,
  bool useRootNavigator = true,
}) {
  assert(debugCheckHasMaterialLocalizations(context));
  final CapturedThemes themes = InheritedTheme.capture(
    from: context,
    to: Navigator.of(context, rootNavigator: useRootNavigator).context,
  );
  return Navigator.of(context, rootNavigator: useRootNavigator).push<T>(
    CueDialogRoute<T>(
      pageBuilder: (context, _, _) => themes.wrap(builder(context)),
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      barrierColor: barrierColor,
      motion: motion,
      reverseMotion: reverseMotion,
    ),
  );
}
