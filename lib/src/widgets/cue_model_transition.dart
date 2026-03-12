import 'package:cue/cue.dart';
import 'package:cue/src/core/curves.dart';
import 'package:cue/src/motion/cue_animation_controller.dart';
import 'package:cue/src/motion/cue_motion.dart';
import 'package:flutter/material.dart';

@optionalTypeArgs
typedef ShowModalFunction<T extends Object> = Future<T?> Function();

typedef ModalContentBuilder = Widget Function(BuildContext context, Rect triggerRect);

class CueModalTransition extends StatefulWidget {
  const CueModalTransition({
    super.key,
    required this.triggerBuilder,
    required this.builder,
    this.backdrop,
    this.alignment,
    this.barrierDismissible = true,
    this.barrierLabel = 'ModalTransition',
    this.barrierColor = const Color(0x80000000),
    this.motion = .defaultDuration,
    this.reverseMotion,
    this.hideTriggerOnTransition = false,
  });

  final ModalContentBuilder builder;
  final Widget Function(BuildContext context, ShowModalFunction showDialog) triggerBuilder;
  final AlignmentGeometry? alignment;
  final Widget? backdrop;
  final bool barrierDismissible;
  final Color? barrierColor;
  final CueMotion motion;
  final CueMotion? reverseMotion;
  final String barrierLabel;
  final bool hideTriggerOnTransition;

  @override
  State<CueModalTransition> createState() => _CueModalTransitionState();
}

class _CueModalTransitionState extends State<CueModalTransition> {
  final GlobalKey _triggerKey = GlobalKey();
  bool _isModalOpen = false;
  final LayerLink _link = LayerLink();

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: Visibility.maintain(
        key: _triggerKey,
        visible: !_isModalOpen || !widget.hideTriggerOnTransition,
        child: widget.triggerBuilder(context, _showModel),
      ),
    );
  }

  @optionalTypeArgs
  Future<T?> _showModel<T extends Object>() {
    final renderBox = _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    final triggerOffset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final triggerRect = triggerOffset & (renderBox?.size ?? Size.zero);
    final model = _ModalRoute<T>(
      barrierDismissible: widget.barrierDismissible,
      barrierLabel: widget.barrierLabel,
      barrierColor: widget.barrierColor,
      transitionBuilder: (context, anim, _, child) => child,
      motion: widget.motion,
      reverseMotion: widget.reverseMotion,
      onAnimationStatusChanged: (status) {
        if (mounted) {
          setState(() {
            _isModalOpen = !status.isDismissed;
          });
        }
      },
      pageBuilder: (context, animation, _) {
        return _ModelContent(
          animation: animation,
          backdrop: widget.backdrop,
          alignment: widget.alignment,
          builder: widget.builder,
          barrierDismissible: widget.barrierDismissible,
          triggerRect: triggerRect,
          link: _link,
        );
      },
    );
    if (widget.hideTriggerOnTransition) {
      setState(() {
        _isModalOpen = true;
      });
    }
    return Navigator.of(context).push<T>(model);
  }
}

class _ModelContent extends StatelessWidget {
  const _ModelContent({
    this.backdrop,
    this.alignment,
    required this.animation,
    required this.builder,
    required this.barrierDismissible,
    required this.triggerRect,
    required this.link,
  });

  final Animation<double> animation;
  final Widget? backdrop;
  final AlignmentGeometry? alignment;
  final ModalContentBuilder builder;
  final bool barrierDismissible;
  final Rect triggerRect;
  final LayerLink link;

  @override
  Widget build(BuildContext context) {
    final resolvedAlignment = alignment?.resolve(Directionality.of(context));
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          if (backdrop case final backdrop?)
            Positioned.fill(
              child: barrierDismissible
                  ? GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: backdrop,
                    )
                  : backdrop,
            ),
          if (resolvedAlignment case final alignment?)
            CustomSingleChildLayout(
              delegate: _ModalPositionDelegate(
                triggerRect: triggerRect,
                alignment: alignment,
              ),
              child: CompositedTransformFollower(
                link: link,
                followerAnchor: alignment,
                targetAnchor: alignment,
                child: builder(context, triggerRect),
              ),
            )
          else
            builder(context, triggerRect),
        ],
      ),
    );
  }
}

class _ModalPositionDelegate extends SingleChildLayoutDelegate {
  final Rect triggerRect;
  final Alignment alignment;

  _ModalPositionDelegate({required this.triggerRect, required this.alignment});

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // Calculate the base position (top-left corner of trigger)
    final baseOffset = triggerRect.topLeft;
    // Calculate the offset within the trigger box based on alignment
    final triggerAlignmentOffset = alignment.alongSize(triggerRect.size);

    // Calculate the offset for the modal based on alignment (inverted)
    final modalAlignmentOffset = alignment.alongSize(childSize);

    // Combine offsets: base position + trigger alignment - modal alignment
    return Offset(
      baseOffset.dx - modalAlignmentOffset.dx + triggerAlignmentOffset.dx,
      baseOffset.dy - modalAlignmentOffset.dy + triggerAlignmentOffset.dy,
    );
  }

  @override
  bool shouldRelayout(_ModalPositionDelegate oldDelegate) {
    return triggerRect != oldDelegate.triggerRect || alignment != oldDelegate.alignment;
  }
}

class _ModalRoute<T extends Object> extends RawDialogRoute<T> {
  _ModalRoute({
    required super.pageBuilder,
    super.barrierDismissible,
    super.barrierLabel,
    super.barrierColor,
    super.transitionBuilder,
    required this.motion,
    this.reverseMotion,
    required this.onAnimationStatusChanged,
  }) : super();

  final CueMotion motion;
  final CueMotion? reverseMotion;
  final AnimationStatusListener onAnimationStatusChanged;

  @override
  Curve get barrierCurve => BoundedCurve(curve: Curves.easeIn);

  @override
  AnimationController createAnimationController() {
    final ctrl = CueAnimationController(
      motion: motion,
      reverseMotion: reverseMotion,
      vsync: navigator!,
    );

    ctrl.addStatusListener(onAnimationStatusChanged);
    return ctrl;
  }

  @override
  Animation<double> createAnimation() {
    return controller!.view;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return Cue(
      animations: (controller as CueAnimationController).animations,
      child: super.buildPage(context, animation, secondaryAnimation),
    );
  }

  @override
  void dispose() {
    controller?.removeStatusListener(onAnimationStatusChanged);
    super.dispose();
  }

  @override
  Simulation? createSimulation({required bool forward}) {
    return null;
  }
}
