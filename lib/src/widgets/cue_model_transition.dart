import 'package:cue/cue.dart';
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
    this.motion = .defaultTime,
    this.reverseMotion,
    this.hideTriggerOnTransition = false,
    this.useRootNavigator = true,
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
  final bool useRootNavigator;

  @override
  State<CueModalTransition> createState() => _CueModalTransitionState();
}

class _CueModalTransitionState extends State<CueModalTransition> {
  final GlobalKey _triggerKey = GlobalKey();
  final LayerLink _link = LayerLink();
  final _openModalKey = ValueNotifier<Object?>(null);

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: ListenableBuilder(
        listenable: _openModalKey,
        child: widget.triggerBuilder(context, _showModel),
        builder: (context, child) {
          return Visibility.maintain(
            key: _triggerKey,
            visible: _openModalKey.value == null || !widget.hideTriggerOnTransition,
            child: child!,
          );
        },
      ),
    );
  }

  @optionalTypeArgs
  Future<T?> _showModel<T extends Object>() {
    final renderBox = _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    final triggerOffset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final triggerRect = triggerOffset & (renderBox?.size ?? Size.zero);
    final modalKey = Object();
    _openModalKey.value = modalKey;
    assert(debugCheckHasMaterialLocalizations(context));
    final CapturedThemes themes = InheritedTheme.capture(
      from: context,
      to: Navigator.of(context, rootNavigator: widget.useRootNavigator).context,
    );

    final model = CueDialogRoute<T>(
      barrierDismissible: widget.barrierDismissible,
      barrierLabel: widget.barrierLabel,
      barrierColor: widget.barrierColor,
      motion: widget.motion,
      reverseMotion: widget.reverseMotion,
      hideOnPushNext: widget.hideTriggerOnTransition,
      onAnimationStatusChanged: (status) {
        if (status.isDismissed && mounted && _openModalKey.value == modalKey) {
          _openModalKey.value = null;
        }
      },
      pageBuilder: (context, anim, _) {
        return themes.wrap(
          _ModelContent(
            backdrop: widget.backdrop,
            alignment: widget.alignment,
            builder: widget.builder,
            barrierDismissible: widget.barrierDismissible,
            triggerRect: triggerRect,
            link: _link,
          ),
        );
      },
    );

    return Navigator.of(context, rootNavigator: widget.useRootNavigator).push<T>(model);
  }
}

class _ModelContent extends StatelessWidget {
  const _ModelContent({
    this.backdrop,
    this.alignment,
    required this.builder,
    required this.barrierDismissible,
    required this.triggerRect,
    required this.link,
  });

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
