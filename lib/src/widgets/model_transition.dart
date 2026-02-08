import 'package:cue/src/cue/cue.dart';
import 'package:cue/src/cue/cue_debug_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ModalTransition extends StatefulWidget {
  const ModalTransition({
    super.key,
    required this.builder,
    required this.triggerBuilder,
    this.duration = const Duration(milliseconds: 300),
    this.showDebug = false,
    this.backdrop,
    this.alignment,
    this.barrierDismissible = true,
    this.barrierColor = const Color(0x80000000),
  });

  final Duration duration;
  final Widget Function(BuildContext context, Rect triggerRect) builder;
  final Widget Function(BuildContext context, Future<T?> Function<T extends Object>() showDialog) triggerBuilder;
  final AlignmentGeometry? alignment;
  final bool showDebug;
  final Widget? backdrop;
  final bool barrierDismissible;
  final Color? barrierColor;

  @override
  State<ModalTransition> createState() => _ModalTransitionState();
}

class _ModalTransitionState extends State<ModalTransition> {
  final _triggerKey = GlobalKey();
  Animation<double> _transitionAnimation = AlwaysStoppedAnimation(0.0);

  @override
  Widget build(BuildContext context) {
    Animation<double> animation = _transitionAnimation;
    if (kDebugMode && widget.showDebug) {
      if (CueDebugProvider.isWrappedByDebugProvider(context)) {
        animation = CueDebugProvider.animationOf(context);
      }
    }
    return KeyedSubtree(
      key: _triggerKey,
      child: Cue.controlled(
        animation: animation,
        child: Builder(
          builder: (context) {
            return widget.triggerBuilder(context, _showModel);
          },
        ),
      ),
    );
  }

  Future<T?> _showModel<T extends Object>() {
    final renderBox = _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    final triggerOffset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final triggerSize = renderBox?.size ?? Size.zero;
    final triggerRect = triggerOffset & triggerSize;

    final model = _ModalRoute<T>(
      barrierDismissible: widget.barrierDismissible,
      barrierLabel: 'ModalTransition',
      barrierColor: widget.barrierColor,
      transitionDuration: widget.duration,
      transitionBuilder: (context, _, _, child) => child,
      pageBuilder: (context, animation, _) {
        return Cue.controlled(
          debug: widget.showDebug,
          animation: animation,
          child: Material(
            type: MaterialType.transparency,
            child: Stack(
              children: [
                if (widget.backdrop case final backdrop?)
                  Positioned.fill(
                    child: widget.barrierDismissible
                        ? GestureDetector(onTap: () => Navigator.of(context).pop(), child: backdrop)
                        : backdrop,
                  ),
                if (widget.alignment != null)
                  CustomSingleChildLayout(
                    delegate: _ModalPositionDelegate(
                      triggerOffset: triggerOffset,
                      triggerSize: triggerSize,
                      alignment: widget.alignment!.resolve(Directionality.of(context)),
                    ),
                    child: widget.builder(context, triggerRect),
                  )
                else
                  widget.builder(context, triggerRect),
              ],
            ),
          ),
        );
      },
      onAnimationControllerReady: (controller) {
        setState(() {
          _transitionAnimation = controller.view;
        });
      },
    );
    return Navigator.of(context).push(model);
  }
}

class _ModalPositionDelegate extends SingleChildLayoutDelegate {
  final Offset triggerOffset;
  final Size triggerSize;
  final Alignment alignment;

  _ModalPositionDelegate({required this.triggerOffset, required this.triggerSize, required this.alignment});

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // Calculate the base position (top-left corner of trigger)
    final baseOffset = triggerOffset;
    // Calculate the offset within the trigger box based on alignment
    final triggerAlignmentOffset = alignment.alongSize(triggerSize);

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
    return triggerOffset != oldDelegate.triggerOffset || triggerSize != oldDelegate.triggerSize;
  }
}

class _ModalRoute<T extends Object> extends RawDialogRoute<T> {
  _ModalRoute({
    required super.pageBuilder,
    required this.onAnimationControllerReady,
    super.barrierDismissible,
    super.barrierLabel,
    super.barrierColor,
    super.transitionDuration,
    super.transitionBuilder,
  });

  final ValueChanged<AnimationController> onAnimationControllerReady;

  @override
  AnimationController createAnimationController() {
    final ctrl = super.createAnimationController();
    onAnimationControllerReady(ctrl);
    return ctrl;
  }
}
