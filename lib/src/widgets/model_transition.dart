import 'package:cue/src/cue/cue.dart';
import 'package:cue/src/cue/cue_debug_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@optionalTypeArgs
typedef ShowModalFunction<T extends Object> = Future<T?> Function();
typedef SimulationBuilder = Simulation Function(bool forward);
typedef ModalContentBuilder = Widget Function(BuildContext context, Rect triggerRect);

class ModalTransition extends StatefulWidget {
  const ModalTransition({
    super.key,
    required this.triggerBuilder,
    required this.builder,
    this.duration = const Duration(milliseconds: 300),
    this.showDebug = false,
    this.backdrop,
    this.alignment,
    this.barrierDismissible = true,
    this.barrierColor = const Color(0x80000000),
    this.simulation,
  });

  final Duration duration;
  final ModalContentBuilder builder;
  final Widget Function(BuildContext context, ShowModalFunction showDialog) triggerBuilder;
  final AlignmentGeometry? alignment;
  final bool showDebug;
  final Widget? backdrop;
  final bool barrierDismissible;
  final Color? barrierColor;
  final SimulationBuilder? simulation;

  @override
  State<ModalTransition> createState() => _ModalTransitionState();
}

class _ModalTransitionState extends State<ModalTransition> {
  final _triggerKey = GlobalKey();
  late final _showDebug = ValueNotifier<bool>(widget.showDebug);
  Animation<double> _transitionAnimation = AlwaysStoppedAnimation(0.0);

  @override
  void didUpdateWidget(covariant ModalTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (kDebugMode) {
      if (oldWidget.showDebug != widget.showDebug) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showDebug.value = widget.showDebug;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Animation<double> animation = _transitionAnimation;
    if (kDebugMode && widget.showDebug) {
      if (CueDebugTools.isWrappedByDebugProvider(context)) {
        if (CueDebugTools.animationOf(context) case var debugAnimation?) {
          animation = debugAnimation;
        }
      }
    }
    return Cue(
      key: _triggerKey,
      animation: animation,
      child: Hero(
        tag: 'modal_transition_',
        child: Builder(
          builder: (context) {
            return widget.triggerBuilder(context, _showModel);
          },
        ),
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
      barrierLabel: 'ModalTransition',
      barrierColor: widget.barrierColor,
      transitionDuration: widget.duration,
      transitionBuilder: (context, _, _, child) => child,
      simulation: widget.simulation,
      pageBuilder: (context, animation, _) {
        return _ModelContent(
          animation: animation,
          backdrop: widget.backdrop,
          alignment: widget.alignment,
          builder: (context, rect) {
            return Builder(
              builder: (ctx) {
                return widget.builder(context, rect);
              },
            );
          },
          barrierDismissible: widget.barrierDismissible,
          showDebug: _showDebug,
          triggerRect: triggerRect,
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

class _ModelContent extends StatelessWidget {
  const _ModelContent({
    this.backdrop,
    this.alignment,
    required this.animation,
    required this.builder,
    required this.barrierDismissible,
    required this.showDebug,
    required this.triggerRect,
  });

  final Animation<double> animation;
  final Widget? backdrop;
  final AlignmentGeometry? alignment;
  final ModalContentBuilder builder;
  final bool barrierDismissible;
  final ValueNotifier<bool> showDebug;
  final Rect triggerRect;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: showDebug,
      child: Material(
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
            if (alignment != null)
              CustomSingleChildLayout(
                delegate: _ModalPositionDelegate(
                  triggerRect: triggerRect,
                  alignment: alignment!.resolve(Directionality.of(context)),
                ),
                child: builder(context, triggerRect),
              )
            else
              builder(context, triggerRect),
          ],
        ),
      ),
      builder: (context, debug, child) {
        return Cue(
          debug: debug,
          animation: animation,
          child: child!,
        );
      },
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
    required this.onAnimationControllerReady,
    super.barrierDismissible,
    super.barrierLabel,
    super.barrierColor,
    super.transitionDuration,
    super.transitionBuilder,
    this.simulation,
  });

  final SimulationBuilder? simulation;
  final ValueChanged<AnimationController> onAnimationControllerReady;

  @override
  AnimationController createAnimationController() {
    final ctrl = super.createAnimationController();
    onAnimationControllerReady(ctrl);
    return ctrl;
  }

  @override
  Simulation? createSimulation({required bool forward}) {
    if (simulation case final simulation?) {
      return simulation(forward);
    }
    return super.createSimulation(forward: forward);
  }
}
