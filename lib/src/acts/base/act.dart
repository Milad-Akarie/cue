import 'dart:math' as math;
import 'dart:ui';

import 'package:cue/cue.dart';
import 'package:cue/src/acts/base/deferred_tween_act.dart';
import 'package:cue/src/acts/base/animatable_act.dart';
import 'package:cue/src/acts/base/tween_act.dart';
import 'package:cue/src/timeline/track/track_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

part '../sized_clip.dart';
part '../fractional_size.dart';
part '../translate.dart';
part '../parallax.dart';
part '../decorate.dart';
part '../color_tint.dart';
part '../rotate.dart';
part '../rotate_layout.dart';
part '../scale.dart';
part '../sized_box.dart';
part '../opacity.dart';
part '../blur.dart';
part '../align.dart';
part '../padding.dart';
part '../style.dart';
part '../clip.dart';
part '../slide.dart';
part '../position.dart';
part '../transfrom.dart';
part '../card.dart';
part '../paint.dart';
part '../path_motion.dart';

/// A declarative description of a single animated property on a widget.
///
/// ## Overview
///
/// An [Act] describes **what** should be animated and **between which values**,
/// but does not drive the animation itself. It is consumed by an [Actor] widget,
/// which builds the actual animation tracks and applies the visual output to
/// its child. The animation is driven externally by a parent [Cue] widget.
///
/// Acts are immutable value objects. They are compared by equality
/// (implemented on all concrete subclasses), so an unchanged act in a rebuilt
/// [Actor] will reuse the cached animation without rebuilding it.
///
/// ## Using acts
///
/// Prefer the `Act.` shorthand factories over constructing concrete classes
/// directly — they are designed for dot-syntax in act lists:
///
/// ```dart
/// Actor(
///   acts: [
///     .scale(from: 0.8),
///     .fadeIn(),
///     .slideUp(),
///     .blur(from: 8),
///   ],
///   child: MyWidget(),
/// )
/// ```
///
/// Most concrete act classes also expose a `.keyframed()` constructor for
/// multi-step sequences. Use [Keyframes] for motion-based keyframes or
/// [Keyframes.fractional] for time-positioned keyframes:
///
/// ```dart
/// Actor(
///   acts: [
///     ScaleAct.keyframed(
///       frames: Keyframes([
///         .key(1.2),
///         .key(1.0, motion: .bouncy()),
///       ], motion: .smooth()),
///     ),
///   ],
///   child: MyWidget(),
/// )
/// ```
///
/// ## Available Acts
///
/// ### Transform — Position & Scale
/// - `.scale(from: 1.0, to: 1.2)` — Scale by factor around [alignment] (default: `from: 1.0`)
///   - Presets: `.zoomIn()` (→ 1.1), `.zoomOut()` (→ 0.8)
/// - `.rotate(from: 0, to: 180)` — Rotate around 2D [alignment] in degrees
///   - Variants: `.rotate3D(to: Rotation3D(x: 90, y: 0, z: 0))`, `.flipX()`, `.flipY()`
/// - `.rotateLayout(to: 90)` — Rotate while recomputing layout space; prefer `.rotate` for performance
/// - `.translate(from: Offset.zero, to: Offset(100, 0))` — Translate by pixels
///   - Variants: `.translateX()`, `.translateY()`, `.translateFromGlobal()`,
///     `.translateFromGlobalRect()`, `.translateFromGlobalKey()`
/// - `.slide(from: Offset.zero, to: Offset(1, 0))` — Slide by widget-size fraction
///   - Presets: `.slideUp()` (→ `Offset(0,-1)`), `.slideDown()`, `.slideFromLeading()`,
///     `.slideFromTrailing()`, `.slideX(from: -1)`, `.slideY(from: 0.5)`
/// - `.stretch(from: Stretch.none, to: Stretch(x: 1.2, y: 0.8))` — Scale axes independently
/// - `.skew(from: Skew.zero, to: Skew(x: 0.3))` — Skew transformation
/// - `.transform(to: matrix)` — Custom Matrix4 transformation (from defaults to identity)
/// - `.parallax(slide: 0.5, axis: Axis.vertical)` — slides the child when the timeline plays or scrubs (scroll-based),
///
/// ### Visual Effects — Opacity & Filters
/// - `.opacity(from: 0.0, to: 1.0)` — Animate opacity
///   - Presets: `.fadeIn(from: 0.0)` (→ 1.0), `.fadeOut(from: 1.0)` (→ 0.0)
/// - `.blur(from: 0.0, to: 10.0)` — Apply Gaussian blur
///   - Presets: `.focus(from: 10.0)` (→ 0), `.unfocus(to: 10.0)` (0 → x)
/// - `.backdropBlur(from: 0.0, to: 10.0)` — Blur content rendered behind this widget
/// - `.colorTint(from: Colors.transparent, to: color)` — Color overlay tint
///
/// ### Layout — Size & Clipping
/// - `.sizedClip(from: NSize, to: NSize)` — Animate size with clipping
///   - `NSize.width(200)` — fixed width, child height
///   - `NSize.height(double.infinity)` — fixed height (∞ resolves to max constraint)
///   - `NSize.childSize` — both axes follow child (`NSize(w: null, h: null)`)
/// - `.sizedBox(width: .tween(80, 200), height: .fixed(100))` — Animate container size;
///   `double.infinity` resolves to parent's max constraint
/// - `.fractionalSize(widthFactor: .tween(.2, 1.0), heightFactor: .fixed(.5))` — Size as fraction of parent
/// - `.clipHeight(fromFactor: 0.0, toFactor: 1.0)` — Clip height by fraction (0 = fully clipped).
/// - `.clipWidth(fromFactor: 0.0, toFactor: 1.0)` — Clip width by fraction.
/// - `.clip(borderRadius: .circular(12))` — Expand/contract clip with rounded corners.
/// - `.circularClip()` — Circular reveal/hide from [alignment] (default: `topLeft`).
/// - `.padding(from: EdgeInsets.zero, to: EdgeInsets.all(16))` — Animate padding
/// - `.align(from: .center, to: .topLeft)` — Change alignment within parent
///
/// ### Decoration — Style & Visual Properties
/// - `.decorate(color: .tween(Colors.white, Colors.blue), borderRadius: .fixed(.circular(8)))` —
///   Animate box decoration properties. Each property independently accepts `.tween()` or `.fixed()`:
///   `color`, `borderRadius`, `border`, `boxShadow`, `gradient`.
///   Prefer [DecoratedBoxActor] for composing multiple animated decoration layers.
/// - `.textStyle(from: style1, to: style2)` — Interpolate text style properties
/// - `.iconTheme(from: theme1, to: theme2)` — Interpolate icon theme properties
///
/// ### Positional — Stack-based Layout
/// - `.position(start: 0, top: 0, end: 0, bottom: 0)` — Animate [Positioned] properties;
///   use `Position.fill(...)` or `Position(start: 10, top: 20, width: 100)`
///
/// ### Specialized Acts (no `Act.` shorthand — use class directly)
/// - `CardAct(elevation: .tween(2, 8), color: .tween(white, grey))` —
///   Animate card surface: elevation, background color, shadow color, border radius, margin.
///   Prefer [CardActor] for better readability (similar to [DecoratedBoxActor])
/// - `PaintAct(painter: myPainter)` —
///   Animate a progress value (0 → 1) passed to a custom [Painter]; use `paintOnTop: true` for foreground
/// - `PathMotionAct(path: myPath)` —
///   Move the widget along a custom [Path]; set `rotateToTangent: true` to face the movement direction
///
/// ## Keyframed Variants
///
/// **Most acts support keyframed animations** for multi-step sequences:
///
/// ```dart
/// // Motion-based keyframes (each keyframe can have its own motion):
/// ScaleAct.keyframed(
///   frames: Keyframes([
///     .key(0.8),
///     .key(1.2, motion: .bouncy()),
///     .key(1.0),
///   ], motion: .smooth()),
/// )
///
/// // Time-positioned keyframes (at 0%, 40%, 100% of duration):
/// ScaleAct.keyframed(
///   frames: Keyframes.fractional([
///     .key(0.8, at: 0.0),
///     .key(1.2, at: 0.4),
///     .key(1.0, at: 1.0),
///   ], duration: Duration(milliseconds: 600)),
/// )
/// ```
///
/// ## Keys and uniqueness
///
/// Every act has a [key] — an [ActKey] that identifies its type. An [Actor]
/// may contain **at most one act per key**. Attempting to combine two acts
/// with the same key throws a [StateError] at runtime.
///
/// Some acts that appear distinct share a key. All slide variants (`.slide`,
/// `.slideX`, `.slideY`, `.slideUp`, `.slideDown`, `.slideFromLeading`,
/// `.slideFromTrailing`) share `ActKey('Slide')` and cannot be combined.
///
/// ## Motion
///
/// Each act can carry its own optional [CueMotion]. When provided it overrides
/// the [Actor]-level and [Cue]-level motion for that act only. When omitted
/// the act inherits motion from its [Actor] (or the ancestor [Cue]).
///
/// ## Reverse behavior
///
/// Most acts accept a `reverse` parameter of type [ReverseBehavior], which
/// controls how the act behaves when the animation plays in reverse:
///
/// - `ReverseBehavior.mirror()` *(default)* — animates back to the `from` value.
/// - `ReverseBehavior.exclusive()` — the act only plays in reverse; the forward pass is instant.
/// - `ReverseBehavior.none()` — the act only plays forward; the reverse pass is instant.
/// - `ReverseBehavior.to(value)` — animates to a custom target value on reverse.
///
/// **`.mirror()` and `.to()` both accept `motion` and `delay` parameters.**
/// These are the only way to set a reverse-specific motion or delay directly
/// on an act — there is no separate `reverseMotion`/`reverseDelay` parameter
/// on the factory constructors themselves:
///
/// ```dart
/// .fadeIn(reverse: ReverseBehavior.mirror(
///   motion: .linear(150.ms),   // reverse-only motion for this act
///   delay: 50.ms,              // extra delay before reversing
/// ))
///
/// .scale(to: 1.1, reverse: ReverseBehavior.to(
///   0.95,
///   motion: .bouncy(),         // animate to 0.95 with a bounce on reverse
/// ))
/// ```
///
/// **Keyframed acts use [KFReverseBehavior] instead of [ReverseBehavior].**
/// It has the same four variants, but `.to()` accepts a `Keyframes<T>` rather
/// than a plain value, and **neither `.mirror()` nor `.to()` accept a `motion`
/// parameter** — only `delay` is supported:
///
/// ```dart
/// SizedBoxAct.keyframed(
///   frames: Keyframes([...], motion: .smooth()),
///   reverse: KFReverseBehavior.mirror(delay: 50.ms),
/// )
///
/// SizedBoxAct.keyframed(
///   frames: forwardFrames,
///   reverse: KFReverseBehavior.to(reverseFrames, delay: 50.ms),
/// )
/// ```
///
/// ## Delays
///
/// The `delay` parameter offsets the act's start within the animation. It is
/// **added to** the [Actor]-level delay — both stack:
/// ```dart
/// // Actor delay 100ms + act delay 200ms = act starts after 300ms
/// Actor(
///   delay: 100.ms,
///   acts: [.fadeIn(delay: 200.ms)],
///   child: MyWidget(),
/// )
/// ```
///
/// ## Extending Act
///
/// To implement a custom act, extend [Act] and implement:
/// - [key] — return a unique [ActKey] identifying this type
/// - [resolve] — merge act-specific motion/delay with the inherited [ActContext]
/// - [buildAnimation] — register tracks on the [CueTimeline] and return a [CueAnimation]
/// - [applyInternal] — wrap the child widget using the running [CueAnimation]'s value
abstract class Act {
  /// Default constructor
  const Act();

  /// {@macro act.scale}
  const factory Act.scale({
    double from,
    double to,
    CueMotion? motion,
    ReverseBehavior<double> reverse,
    Duration delay,
    AlignmentGeometry alignment,
  }) = ScaleAct;

  /// {@macro act.scale.zoom_in}
  const factory Act.zoomIn({
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<double> reverse,
    AlignmentGeometry alignment,
  }) = ScaleAct.zoomIn;

  /// {@macro act.scale.zoom_out}
  const factory Act.zoomOut({
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<double> reverse,
    AlignmentGeometry alignment,
  }) = ScaleAct.zoomOut;

  /// {@macro act.stretch}
  const factory Act.stretch({
    Stretch from,
    required Stretch to,
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<Stretch> reverse,
  }) = StretchAct;

  /// {@macro act.fractional_size}
  const factory Act.fractionalSize({
    AnimatableValue<double>? widthFactor,
    AnimatableValue<double>? heightFactor,
    AnimatableValue<AlignmentGeometry>? alignment,
    CueMotion? motion,
    ReverseBehavior<FractionalSize> reverse,
    Duration delay,
  }) = FractionalSizeAct;

  /// {@macro act.translate}
  const factory Act.translate({
    Offset from,
    Offset to,
    CueMotion? motion,
    ReverseBehavior<Offset> reverse,
    Duration delay,
  }) = TranslateAct;

  /// {@macro act.parallax}
  const factory Act.parallax({
    required double slide,
    Axis axis,
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<double> reverse,
  }) = ParallaxAct;

  /// {@macro act.translate.x}
  const factory Act.translateX({
    double from,
    double to,
    CueMotion? motion,
    Duration delay,

    ReverseBehavior<double> reverse,
  }) = TranslateAct.fromX;

  /// {@macro act.translate.y}
  const factory Act.translateY({
    double from,
    double to,
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<double> reverse,
  }) = TranslateAct.y;

  /// {@macro act.translate.fromGlobal}
  const factory Act.translateFromGlobal({
    required Offset offset,
    Offset toLocal,
    CueMotion? motion,
    Duration delay,
  }) = TranslateAct.fromGlobal;

  /// {@macro act.translate.from_global_rect}
  const factory Act.translateFromGlobalRect(
    Rect rect, {
    AlignmentGeometry alignment,
    Offset toLocal,
    CueMotion? motion,
    Duration delay,
  }) = TranslateAct.fromGlobalRect;

  /// {@macro act.translate.from_global_key}
  const factory Act.translateFromGlobalKey(
    GlobalKey key, {
    AlignmentGeometry alignment,
    Offset toLocal,
    CueMotion? motion,
    Duration delay,
  }) = TranslateAct.fromGlobalKey;

  /// {@macro act.slide}
  const factory Act.slide({
    Offset from,
    Offset to,
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<Offset> reverse,
  }) = SlideAct;

  /// {@macro act.slide.x}
  const factory Act.slideX({
    double from,
    double to,
    CueMotion? motion,
    ReverseBehavior<double> reverse,
    Duration delay,
  }) = SlideAct.x;

  /// {@macro act.slide.y}
  const factory Act.slideY({
    double from,
    double to,
    CueMotion? motion,
    ReverseBehavior<double> reverse,
    Duration delay,
  }) = SlideAct.y;

  /// {@macro act.slide.up}
  const factory Act.slideUp({
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<Offset> reverse,
  }) = SlideAct.up;

  /// {@macro act.slide.down}
  const factory Act.slideDown({
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<Offset> reverse,
  }) = SlideAct.down;

  /// {@macro act.slide.fromLeading}
  const factory Act.slideFromLeading({
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<Offset> reverse,
  }) = SlideAct.fromLeading;

  /// {@macro act.slide.fromTrailing}
  const factory Act.slideFromTrailing({
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<Offset> reverse,
  }) = SlideAct.fromTrailing;

  /// {@macro act.opacity}
  const factory Act.opacity({
    required double from,
    required double to,
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<double> reverse,
  }) = OpacityAct;

  /// {@macro act.opacity.fade_in}
  const factory Act.fadeIn({
    double from,
    CueMotion? motion,
    ReverseBehavior<double> reverse,

    Duration delay,
  }) = OpacityAct.fadeIn;

  /// {@macro act.opacity.fade_out}
  const factory Act.fadeOut({
    double from,
    CueMotion? motion,
    ReverseBehavior<double> reverse,
    Duration delay,
  }) = OpacityAct.fadeOut;

  /// {@macro act.align}
  const factory Act.align({
    AlignmentGeometry from,
    AlignmentGeometry to,
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<AlignmentGeometry> reverse,
  }) = AlignAct;

  /// {@macro act.padding}
  const factory Act.padding({
    EdgeInsetsGeometry from,
    EdgeInsetsGeometry to,
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<EdgeInsetsGeometry> reverse,
  }) = PaddingAct;

  /// {@macro act.blur}
  const factory Act.blur({
    double from,
    double to,
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<double> reverse,
  }) = BlurAct;

  /// {@macro act.blur.focus}
  const factory Act.focus({
    double from,
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<double> reverse,
  }) = BlurAct.focus;

  /// {@macro act.blur.unfocus}
  const factory Act.unfocus({
    double to,
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<double> reverse,
  }) = BlurAct.unfocus;

  /// {@macro act.backdrop_blur}
  const factory Act.backdropBlur({
    double from,
    double to,
    CueMotion? motion,
    BlendMode blendMode,
    Duration delay,
    ReverseBehavior<double> reverse,
  }) = BackdropBlurAct;

  /// {@macro act.color_tint}
  const factory Act.colorTint({
    required Color from,
    required Color to,
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<Color> reverse,
  }) = ColorTintAct;

  /// {@macro act.sized_box}
  const factory Act.sizedBox({
    AnimatableValue<double>? width,
    AnimatableValue<double>? height,
    AlignmentGeometry alignment,
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<Size> reverse,
  }) = SizedBoxAct;

  /// {@macro act.sized_clip}
  const factory Act.sizedClip({
    NSize? from,
    NSize? to,
    CueMotion? motion,
    AlignmentGeometry alignment,
    ClipGeometry clipGeometry,
    Clip clipBehavior,
    Duration delay,
    ReverseBehavior<NSize> reverse,
  }) = SizedClipAct;

  /// {@macro act.clip}
  const factory Act.clip({
    BorderRadiusGeometry borderRadius,
    AlignmentGeometry alignment,
    bool useSuperellipse,
    CueMotion? motion,
    Duration delay,
  }) = ClipAct;

  /// {@macro act.clip.height}
  const factory Act.clipHeight({
    double fromFactor,
    double toFactor,
    AlignmentGeometry alignment,
    CueMotion? motion,
    Duration delay,
  }) = ClipAct.height;

  /// {@macro act.clip.width}
  const factory Act.clipWidth({
    double fromFactor,
    double toFactor,
    AlignmentGeometry alignment,
    CueMotion? motion,
    Duration delay,
  }) = ClipAct.width;

  /// {@macro act.clip.circular}
  const factory Act.circularClip({
    AlignmentGeometry alignment,
    CueMotion? motion,
    Duration delay,
  }) = ClipAct.circular;

  /// {@macro act.rotate}
  const factory Act.rotate({
    double from,
    double to,
    CueMotion? motion,
    RotateUnit unit,
    RotateAxis axis,
    Duration delay,
    AlignmentGeometry alignment,
    ReverseBehavior<double> reverse,
  }) = RotateAct;

  /// {@macro act.rotate3d}
  const factory Act.rotate3D({
    Rotation3D from,
    Rotation3D to,
    CueMotion? motion,
    Rotate3DUnit unit,
    double perspective,
    AlignmentGeometry alignment,
    Duration delay,
    ReverseBehavior<Rotation3D> reverse,
  }) = Rotate3DAct;

  /// {@macro act.rotate_layout}
  const factory Act.rotateLayout({
    double from,
    double to,
    CueMotion? motion,
    RotateUnit unit,
    Duration delay,
    ReverseBehavior<double> reverse,
  }) = RotateLayoutAct;

  /// {@macro act.rotate3d.flipX}
  const factory Act.flipX({
    CueMotion? motion,
    Duration delay,
    double perspective,
  }) = Rotate3DAct.flipX;

  /// {@macro act.rotate3d.flipY}
  const factory Act.flipY({
    CueMotion? motion,
    Duration delay,
    double perspective,
  }) = Rotate3DAct.flipY;

  /// {@macro act.skew}
  const factory Act.skew({
    Skew from,
    Skew to,
    AlignmentGeometry? alignment,
    Offset? origin,
    CueMotion? motion,
    ReverseBehavior<Skew> reverse,
    Duration delay,
  }) = SkewAct;

  /// {@macro act.text_style}
  const factory Act.textStyle({
    required TextStyle from,
    required TextStyle to,
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<TextStyle> reverse,
  }) = TextStyleAct;

  /// {@macro act.icon_theme}
  const factory Act.iconTheme({
    required IconThemeData from,
    required IconThemeData to,
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<IconThemeData> reverse,
  }) = IconThemeAct;

  /// {@macro act.transform}
  factory Act.transform({
    Matrix4? from,
    required Matrix4 to,
    CueMotion? motion,
    AlignmentGeometry alignment,
    Duration delay,
    ReverseBehavior<Matrix4> reverse,
  }) = TransformAct;

  /// {@macro act.decorate}
  const factory Act.decorate({
    AnimatableValue<Color>? color,
    AnimatableValue<BorderRadiusGeometry>? borderRadius,
    AnimatableValue<BoxBorder>? border,
    AnimatableValue<List<BoxShadow>>? boxShadow,
    AnimatableValue<Gradient>? gradient,
    BoxShape shape,
    DecorationPosition position,
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<Decoration> reverse,
  }) = DecoratedBoxAct;

  /// The unique identifier for this act type.
  ///
  /// Used by [Actor] to enforce the one-act-per-key rule and to key the
  /// animation cache. All instances of the same act type must return the
  /// same [ActKey].
  ActKey get key;

  /// Merges this act's own motion/delay settings with the inherited [ActContext].
  ///
  /// Called by [Actor] before building animations. Returns a new [ActContext]
  /// with act-specific overrides applied on top of the inherited values from
  /// the [Actor] and the parent [Cue].
  ActContext resolve(ActContext context);

  /// Builds and registers the animation tracks on [timline], returning a
  /// [CueAnimation] that provides the current animated value at each frame.
  ///
  /// Called once (or when the act changes) and the result is cached by [Actor].
  /// The returned animation must be released via [CueAnimation.release] when
  /// the act is removed or the [Actor] is disposed — [Actor] handles this
  /// automatically.
  CueAnimation<Object?> buildAnimation(CueTimeline timline, ActContext context);

  /// Wraps [child] with the visual output driven by [animation].
  ///
  /// Called every build. Receives the live [animation] whose [CueAnimation.value]
  /// reflects the current playback position. Should return a widget that
  /// applies the animated value — e.g. a [Transform], [Opacity], or
  /// [ClipRRect] — wrapping [child].
  Widget applyInternal(BuildContext context, covariant CueAnimation<Object?> animation, Widget child);
}

/// Resolved animation context passed to an [Act] when building its animation.
///
/// Holds the final motion, reverse motion, delays, and text direction after
/// all inheritance and override rules have been applied by [Actor]. Acts
/// receive this via [Act.resolve] and [Act.buildAnimation] — they should not
/// construct it directly.
class ActContext {
  /// The motion for the forward pass of this act.
  final CueMotion motion;

  /// The motion for the reverse pass of this act.
  final CueMotion reverseMotion;

  /// Delay before the forward animation starts.
  final Duration delay;

  /// Delay before the reverse animation starts.
  final Duration reverseDelay;

  /// The text direction at the point where this [Actor] lives in the tree.
  /// Used by directional acts (e.g. slide from leading/trailing).
  final TextDirection textDirection;

  /// The current animated value of this act's previous animation, captured
  /// just before a re-animation started. Non-null only when
  /// `fromCurrentValue: true` is set on [Cue.onChange]. Acts use this as
  /// the implicit `from` for smooth mid-flight transitions.
  final Object? implicitFrom;

  /// Internal constructor.
  const ActContext({
    required this.motion,
    required this.reverseMotion,
    this.delay = Duration.zero,
    this.reverseDelay = Duration.zero,
    this.textDirection = TextDirection.ltr,
    this.implicitFrom,
  });

  /// Creates a copy of this context with the given fields replaced by new values.
  ActContext copyWith({
    TextDirection? textDirection,
    Object? implicitFrom,
    CueMotion? motion,
    CueMotion? reverseMotion,
    Duration? delay,
    Duration? reverseDelay,
  }) {
    return ActContext(
      motion: motion ?? this.motion,
      reverseMotion: reverseMotion ?? this.reverseMotion,
      delay: delay ?? this.delay,
      reverseDelay: reverseDelay ?? this.reverseDelay,
      textDirection: textDirection ?? this.textDirection,
      implicitFrom: implicitFrom ?? this.implicitFrom,
    );
  }
   /// Checks if this context has the same motion, reverse motion, and delays as another.
  bool hasSameMotion(ActContext? other) =>
      other != null &&
      motion == other.motion &&
      reverseMotion == other.reverseMotion &&
      delay == other.delay &&
      reverseDelay == other.reverseDelay;
}

/// A type identifier for an [Act].
///
/// Equality is based solely on [key] — two [ActKey]s with the same string are
/// considered the same type regardless of [desc]. [Actor] uses this to enforce
/// the one-act-per-key rule and to key its animation cache.
///
/// All instances of the same act class must return the same [ActKey]. Acts that
/// share a key (e.g. all slide variants) cannot be combined in one [Actor].
class ActKey {
  /// The string identifier for this act type.
  final String key;

  /// Optional human-readable description, shown in [toString] for debugging.
  final String? desc;

  /// Default constructor.
  const ActKey(this.key, [this.desc]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ActKey && runtimeType == other.runtimeType && key == other.key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => 'ActKey($key${desc != null ? ', $desc' : ''})';
}
