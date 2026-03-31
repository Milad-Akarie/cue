import 'package:cue/cue.dart';
import 'package:flutter/material.dart';

const double _defaultScrollControlDisabledMaxHeightRatio = 9.0 / 16.0;

class CueDialogRoute<T extends Object?> extends RawDialogRoute<T> with CueModalRouteMixin<T> {
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

  @override
  final CueMotion motion;

  @override
  final CueMotion? reverseMotion;

  @override
  final AnimationStatusListener? onAnimationStatusChanged;

  @override
  final bool hideOnPushNext;
}

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

class CueBottomSheetRoute<T extends Object?> extends ModalBottomSheetRoute<T> {
  CueBottomSheetRoute({
    required super.builder,
    super.barrierLabel,
    required super.isScrollControlled,
    super.backgroundColor,
    super.elevation,
    super.shape,
    super.clipBehavior,
    super.anchorPoint,
    super.barrierOnTapHint,
    super.capturedThemes,
    super.constraints,
    super.modalBarrierColor,
    super.isDismissible = true,
    super.enableDrag = true,
    super.showDragHandle,
    super.scrollControlDisabledMaxHeightRatio,
    super.settings,
    super.requestFocus,
    required this.cueController,
    super.useSafeArea = false,
    super.sheetAnimationStyle,
  }) : super(transitionAnimationController: cueController);
  final CueController cueController;

  @override
  Duration get transitionDuration {
    return Duration(milliseconds: (cueController.timeline.mainTrack.forwardDuration * 1000).round());
  }

  @override
  Duration get reverseTransitionDuration {
    return Duration(milliseconds: (cueController.timeline.mainTrack.reverseDuration * 1000).round());
  }

  @override
  Animation<double> createAnimation() {
    return ClampingAnimation(super.createAnimation());
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return Cue(
      timeline: cueController.timeline,
      child: super.buildPage(context, animation, secondaryAnimation),
    );
  }
}


 class ClampingAnimation extends Animation<double> with AnimationWithParentMixin<double> {
  ClampingAnimation(this.parent);

  @override
  final Animation<double> parent;

  @override
  double get value => parent.value.clamp(0.0, 1.0);
}

@optionalTypeArgs
Future<T?> showCueModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  CueMotion motion = .defaultTime,
  CueMotion? reverseMotion,
  Color? backgroundColor,
  String? barrierLabel,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  BoxConstraints? constraints,
  Color? barrierColor,
  bool isScrollControlled = false,
  double scrollControlDisabledMaxHeightRatio = _defaultScrollControlDisabledMaxHeightRatio,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  bool? showDragHandle,
  bool useSafeArea = false,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
  bool? requestFocus,
}) {
  assert(debugCheckHasMediaQuery(context));
  assert(debugCheckHasMaterialLocalizations(context));

  final NavigatorState navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  final MaterialLocalizations localizations = MaterialLocalizations.of(context);

  final cueController = CueController(
    vsync: navigator,
    motion: motion,
    reverseMotion: reverseMotion,
  );

  return navigator.push<T>(
    CueBottomSheetRoute<T>(
      builder: builder,
      cueController: cueController,
      capturedThemes: InheritedTheme.capture(from: context, to: navigator.context),
      isScrollControlled: isScrollControlled,
      scrollControlDisabledMaxHeightRatio: scrollControlDisabledMaxHeightRatio,
      barrierLabel: barrierLabel ?? localizations.scrimLabel,
      barrierOnTapHint: localizations.scrimOnTapHint(localizations.bottomSheetLabel),
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      constraints: constraints,
      isDismissible: isDismissible,
      modalBarrierColor: barrierColor ?? Theme.of(context).bottomSheetTheme.modalBarrierColor,
      enableDrag: enableDrag,
      showDragHandle: showDragHandle,
      settings: routeSettings,
      anchorPoint: anchorPoint,
      useSafeArea: useSafeArea,
      requestFocus: requestFocus,
    ),
  );
}
