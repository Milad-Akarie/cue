import 'package:cue/cue.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Signature for the function that shows the modal, passed to [triggerBuilder].
@optionalTypeArgs
typedef ShowModalFunction<T extends Object> = Future<T?> Function();

/// Signature for the modal content builder used by [CueModalTransition].
///
/// `context` is the modal's build context (inside the pushed route).
/// `triggerRect` is the trigger widget's bounding box in global coordinates.
typedef ModalContentBuilder = Widget Function(BuildContext context, Rect triggerRect);

/// A hero-like expand transition that morphs any widget into a full modal.
///
/// [CueModalTransition] captures the screen-space [Rect] of the trigger widget
/// and passes it to the [builder], letting you animate modal content from the
/// trigger's exact position, size, and visual style.
///
/// ## How it works
///
/// 1. [triggerBuilder] renders the tappable widget. Call the provided
///    `showModal()` callback to open the modal (wire it to `onPressed`,
///    `onTap`, or `onLongPress`).
/// 2. On open, the trigger's bounding rect is captured and passed as `rect`
///    to [builder]. The modal is pushed via [CueDialogRoute] using the
///    configured [motion].
/// 3. On close, `Navigator.of(context).pop()` reverses the transition using
///    [reverseMotion] (or [motion] if not set).
///
/// ## Using the trigger rect
///
/// The `rect` received in [builder] is the trigger's global bounding box.
/// Use it to anchor Actor animations to the trigger:
///
/// ```dart
/// builder: (context, rect) => Actor(
///   acts: [
///     // Moves an element from inside the trigger to a new position
///     .translateFromGlobalRect(rect),
///     // Expands from the trigger's own size
///     .sizedClip(from: .size(rect.size)),
///   ],
///   child: ...,
/// )
/// ```
///
/// ## Example — expanding options panel
///
/// ```dart
/// CueModalTransition(
///   alignment: Alignment.bottomRight,
///   barrierColor: Colors.transparent,
///   hideTriggerOnTransition: true,
///   motion: Spring.smooth(),
///   triggerBuilder: (context, open) => FloatingActionButton(
///     onPressed: open,
///     child: Icon(Iconsax.trash),
///   ),
///   builder: (context, rect) {
///     return Actor(
///       acts: [.translate(to: Offset(-28, -28))],
///       child: Material(
///         borderRadius: BorderRadius.circular(32),
///         child: Actor(
///           acts: [
///             .sizedClip(from: .size(rect.size), to: .width(220), alignment: .bottomRight),
///           ],
///           child: Column(
///             mainAxisSize: MainAxisSize.min,
///             children: [
///               // Icon flies from its position inside the FAB to its new spot
///               TextButton.icon(
///                 icon: Actor(
///                   acts: [
///                     .translateFromGlobalRect(rect),
///                     .iconTheme(from: IconThemeData(size: 24), to: IconThemeData(size: 20)),
///                   ],
///                   child: Icon(Iconsax.trash),
///                 ),
///                 label: Text('Delete'),
///                 onPressed: () {},
///               ),
///             ],
///           ),
///         ),
///       ),
///     );
///   },
/// )
/// ```
///
/// ## alignment
///
/// Controls which point of the modal aligns with the same point on the trigger.
/// `Alignment.bottomRight` anchors the modal's bottom-right corner to the
/// trigger's bottom-right corner — ideal for FABs and action buttons that
/// expand in-place. `Alignment.center` works well for inline buttons that
/// expand in place.
///
/// When `null` (the default), no alignment or positioning is applied at all —
/// the [builder] output is placed directly inside a full-screen [Stack] and
/// must position itself (e.g. using [Positioned], [Align], or
/// [FractionallySizedBox]).
///
/// ## backdrop
///
/// An optional widget layered behind the modal content but in front of the
/// barrier. Use it for animated blur or tint effects:
///
/// ```dart
/// backdrop: Actor(
///   motion: CueMotion.linear(200.ms),
///   acts: [.backdropBlur(to: 8)],
///   child: ColoredBox(color: Colors.black.withValues(alpha: .1)),
/// ),
/// ```
///
/// ## Nesting
///
/// [CueModalTransition] can be nested. The inner instance lives inside
/// `triggerBuilder` of the outer one, letting you bind different gestures
/// (e.g. tap vs. long-press) to different modals from the same trigger:
///
/// ```dart
/// CueModalTransition(
///   motion: .smooth(),
///   triggerBuilder: (_, showModal) {
///     return CueModalTransition(
///       motion: .smooth(),
///       triggerBuilder: (context, showModal2) {
///         return GestureDetector(
///           onTap: showModal,
///           onLongPress: showModal2,
///           child: MyButton(),
///         );
///       },
///       builder: (context, rect) => LongPressContent(rect: rect),
///     );
///   },
///   builder: (context, rect) => TapContent(rect: rect),
/// )
/// ```
class CueModalTransition extends StatefulWidget {
  /// Defualt constructor
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

  /// Builds the modal content.
  ///
  /// `rect` is the trigger's bounding box in global (screen) coordinates.
  /// Use it to animate elements from the trigger's position:
  /// - `.sizedClip(from: .size(rect.size))` — expand from trigger size.
  /// - `.translateFromGlobalRect(rect)` — move an element from inside the trigger.
  /// - `.translateFromGlobal(rect.topLeft)` — translate from trigger origin.
  final ModalContentBuilder builder;

  /// Builds the trigger widget.
  ///
  /// The `showModal` callback opens the modal when called. Wire it to any
  /// gesture: `onPressed`, `onTap`, `onLongPress`, etc.
  ///
  /// ```dart
  /// triggerBuilder: (context, open) => FloatingActionButton(
  ///   onPressed: open,
  ///   child: Icon(Icons.add),
  /// ),
  /// ```
  final Widget Function(BuildContext context, ShowModalFunction showDialog) triggerBuilder;

  /// Anchors the modal to the same point on the trigger.
  ///
  /// `Alignment.bottomRight` is typical for FABs and corner buttons.
  /// `Alignment.center` works well for inline buttons that expand in place.
  /// When `null`, no positioning is applied — the [builder] output is placed
  /// directly inside a full-screen [Stack] and must position itself.
  final AlignmentGeometry? alignment;

  /// Optional widget rendered behind the modal content, in front of the barrier.
  ///
  /// Animate it with [Actor] for blur, tint, or overlay effects. Tapping it
  /// dismisses the modal when [barrierDismissible] is `true`.
  final Widget? backdrop;

  /// Whether tapping outside the modal dismisses it. Defaults to `true`.
  final bool barrierDismissible;

  /// Color of the modal barrier. Use `Colors.transparent` for contextual
  /// overlays where the underlying UI should remain visible.
  final Color? barrierColor;

  /// Accessibility label for the barrier. Defaults to `'ModalTransition'`.
  final String barrierLabel;

  /// Motion used when opening the modal.
  final CueMotion motion;

  /// Motion used when closing the modal. Defaults to [motion] when not set.
  final CueMotion? reverseMotion;

  /// When `true`, the trigger widget is hidden while the modal is open.
  ///
  /// Enables seamless morphing: the modal content can appear to grow out of
  /// the trigger without both being visible simultaneously.
  final bool hideTriggerOnTransition;

  /// Whether to push the route on the root navigator. Defaults to `true`.
  ///
  /// Set to `false` to scope the modal to a nested navigator (e.g. inside a
  /// tab or a nested [Navigator]).
  final bool useRootNavigator;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<CueMotion>('motion', motion));
    properties.add(DiagnosticsProperty<CueMotion>('reverseMotion', reverseMotion, defaultValue: null));
    properties.add(DiagnosticsProperty<AlignmentGeometry>('alignment', alignment, defaultValue: null));
    properties.add(ColorProperty('barrierColor', barrierColor, defaultValue: const Color(0x80000000)));
    properties.add(StringProperty('barrierLabel', barrierLabel, defaultValue: 'ModalTransition'));
    properties.add(FlagProperty('barrierDismissible', value: barrierDismissible, ifFalse: 'not dismissible'));
    properties.add(FlagProperty('hideTriggerOnTransition', value: hideTriggerOnTransition, ifTrue: 'hideTriggerOnTransition'));
    properties.add(FlagProperty('useRootNavigator', value: useRootNavigator, ifFalse: 'local navigator'));
  }

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
