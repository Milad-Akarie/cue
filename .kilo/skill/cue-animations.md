# Cue Animation Library - AI Agent Skill

## Overview

Cue is a declarative Flutter animation library that provides smooth, spring-based and timed animations with minimal boilerplate. It uses an Act-based system where animations are composed and applied to widgets.

## Core Concepts

### 1. Cue Widget - Animation Trigger

The `Cue` widget wraps your UI and provides the animation trigger mechanism. There are several variants:

```dart
// Toggle-based animation (most common)
Cue.onToggle(
  toggled: bool,              // Animation state
  motion: CueMotion,          // Forward animation timing
  reverseMotion: CueMotion?,  // Optional reverse timing
  skipFirstAnimation: bool,   // Skip initial animation
  child: Widget,
  acts: [Act],               // Optional acts at Cue level
)

// On mount animation (plays when widget appears)
Cue.onMount(
  motion: CueMotion,
  reverseMotion: CueMotion?,
  loop: bool,                // Loop animation
  reverseOnLoop: bool,       // Reverse after each loop
  loopCount: int?,           // Number of loops
  child: Widget,
  acts: [Act],
)

// On hover animation
Cue.onHover(
  motion: CueMotion,
  cursor: MouseCursor,
  opaque: bool,
  child: Widget,
  acts: [Act],
)

// Value change animation
Cue.onChange(
  value: Object?,            // Animate when value changes
  motion: CueMotion,
  skipFirstAnimation: bool,
  fromCurrentValue: bool,
  child: Widget,
  acts: [Act],
)

// Progress-based animation (0.0 to 1.0)
Cue.onProgress(
  listenable: Listenable,
  progress: ValueGetter<double>,
  min: double,
  max: double,
  child: Widget,
  acts: [Act],
)

// Scroll-based animations
Cue.onScroll(              // Maps scroll position to 0-1
  child: Widget,
  acts: [Act],
)

Cue.onScrollVisible(       // Animates when visible
  enabled: bool,
  child: Widget,
  acts: [Act],
)

// Controlled animation (with CueTimeline)
Cue(
  timeline: CueTimeline,
  isBounded: bool,
  child: Widget,
  acts: [Act],
)
```

### 2. Actor Widget - Animation Applicator

The `Actor` widget applies Acts (animations) to its child. It inherits motion from parent Cue or defines its own:

```dart
Actor(
  acts: [Act],               // List of animations to apply
  motion: CueMotion?,        // Override forward motion
  reverseMotion: CueMotion?, // Override reverse motion
  delay: Duration,           // Delay before animation
  reverseDelay: Duration,    // Delay before reverse
  child: Widget,
)
```

**Key Rule**: Only one Act of each type can be applied per Actor. Multiple scale/rotate/etc Acts will conflict.

### 3. Acts - Animation Definitions

Acts define WHAT animates and HOW (from/to values). They are applied by Actor widgets.

### 4. CueMotion - Animation Timing

Defines animation curves and durations:

```dart
// Timed motions
CueMotion.linear(Duration)
CueMotion.curved(Duration, curve: Curve)

// Spring motions (physics-based)
Spring.smooth(damping: 23)       // Smooth, no bounce
Spring.gentle()                  // Subtle spring
Spring.bouncy()                  // Bouncy spring
Spring.wobbly()                  // Very bouncy
Spring.snappy()                   // Fast, responsive
Spring.iosDefault()              // iOS-style spring

// Custom spring
CueMotion.spring(
  duration: Duration,
  bounce: double,              // 0.0 = no bounce, 1.0 = max bounce
)

CueMotion.smooth(
  mass: double,
  stiffness: double,
  damping: double,
  tolerance: Tolerance,
  snapToEnd: bool,
)
```

## Complete Act Reference

### Transform Acts

#### Scale

```dart
// Basic scale
Act.scale(from: 1.0, to: 1.2, motion: CueMotion?, delay: Duration)

// Preset: Zoom in (0.0 → 1.0)
Act.zoomIn(from: 0.0, to: 1.0, motion: CueMotion?)

// Preset: Zoom out (1.0 → 0.0)
Act.zoomOut(from: 1.0, to: 0.0, motion: CueMotion?)

// Stretch (scale X and Y independently)
Act.stretch(
  from: Stretch(x: 1.0, y: 1.0),
  to: Stretch(x: 1.5, y: 0.8),
  motion: CueMotion?,
)
```

#### Rotate

```dart
// Basic rotation (Z-axis)
Act.rotate(
  from: 0,
  to: 180,
  unit: RotateUnit,          // .degrees, .radians, .quarterTurns
  axis: RotateAxis,          // .x, .y, .z
  alignment: AlignmentGeometry,
  motion: CueMotion?,
)

// Presets
Act.flipX(motion: CueMotion?)   // Flip horizontally
Act.flipY(motion: CueMotion?)   // Flip vertically

// 3D rotation
Act.rotate3D(
  from: Rotation3D.zero,
  to: Rotation3D(x: 45, y: 90, z: 0),
  unit: Rotate3DUnit,        // .degrees or .radians
  perspective: 0.001,        // 3D perspective depth
  alignment: AlignmentGeometry,
  motion: CueMotion?,
)

// Layout rotation (rotates the widget's layout, not just visual)
Act.rotateLayout(
  from: 0,
  to: -1,
  unit: RotateUnit.quarterTurns,
  motion: CueMotion?,
)
```

#### Translate

```dart
// Offset-based translation
Act.translate(
  from: Offset.zero,
  to: Offset(100, 50),
  motion: CueMotion?,
)

// Axis-specific
Act.translateX(from: 0, to: 100, motion: CueMotion?)
Act.translateY(from: 0, to: -50, motion: CueMotion?)

// Translate from global position
Act.translateFromGlobal(
  offset: Offset,            // Global screen position
  toLocal: Offset.zero,      // Target local position
  motion: CueMotion?,
)

Act.translateFromGlobalRect(
  rect: Rect,
  alignment: AlignmentGeometry,
  toLocal: Offset.zero,
  motion: CueMotion?,
)

Act.translateFromGlobalKey(
  key: GlobalKey,
  alignment: AlignmentGeometry,
  toLocal: Offset.zero,
  motion: CueMotion?,
)
```

#### Slide (fractional offset based on widget size)

```dart
// Slide with fractional offsets (1.0 = full width/height)
Act.slide(from: Offset(1, 0), to: Offset.zero, motion: CueMotion?)

// Axis-specific fractional
Act.slideX(from: 1.0, to: 0.0, motion: CueMotion?)
Act.slideY(from: 1.0, to: 0.0, motion: CueMotion?)

// Presets
Act.slideUp(motion: CueMotion?)           // Slide from bottom
Act.slideDown(motion: CueMotion?)         // Slide from top
Act.slideFromLeading(motion: CueMotion?)  // Slide from start (RTL-aware)
Act.slideFromTrailing(motion: CueMotion?) // Slide from end (RTL-aware)
```

#### Parallax

```dart
Act.parallax(
  slide: double,             // Amount to slide
  axis: Axis,                // .horizontal or .vertical
  motion: CueMotion?,
)
```

#### Skew

```dart
Act.skew(
  from: Skew(x: 0, y: 0),
  to: Skew(x: 0.2, y: 0),
  alignment: AlignmentGeometry?,
  origin: Offset?,
  motion: CueMotion?,
)
```

#### Transform (raw matrix)

```dart
Act.transform(
  from: Matrix4?,
  to: Matrix4,
  motion: CueMotion?,
)
```

### Visual Effect Acts

#### Opacity

```dart
// Basic opacity
Act.opacity(from: 1.0, to: 0.0, motion: CueMotion?)

// Presets
Act.fadeIn(from: 0.0, to: 1.0, motion: CueMotion?)
Act.fadeOut(from: 1.0, to: 0.0, motion: CueMotion?)
```

#### Blur

```dart
// Image/widget blur
Act.blur(from: 0, to: 10, motion: CueMotion?)

// Presets
Act.focus(from: 10, to: 0, motion: CueMotion?)
Act.unfocus(from: 0, to: 10, motion: CueMotion?)

// Backdrop blur (background blur)
Act.backdropBlur(
  from: 0,
  to: 20,
  blendMode: BlendMode,
  motion: CueMotion?,
)
```

#### Color Tint

```dart
Act.colorTint(
  from: Colors.transparent,
  to: Colors.blue.withOpacity(0.5),
  motion: CueMotion?,
)
```

### Layout Acts

#### SizedBox

```dart
Act.sizedBox(
  width: AnimatableValue<double>?,
  height: AnimatableValue<double>?,
  alignment: AlignmentGeometry,
  motion: CueMotion?,
)

// AnimatableValue can be:
// .tween(from: 100, to: 200)
// .constant(150)
```

#### SizedClip

```dart
// Animate size while clipping overflow
Act.sizedClip(
  from: NSize?,              // Nullable size
  to: NSize?,
  alignment: AlignmentGeometry,
  clipGeometry: ClipGeometry,
  clipBehavior: Clip,
  motion: CueMotion?,
)

// NSize allows null axes to use child size
NSize(w: 200, h: 100)        // Fixed size
NSize.width(200)             // Fixed width, child height
NSize.height(100)            // Fixed height, child width
NSize.childSize              // Both axes follow child
NSize.infinity               // Use max constraints
NSize.square(100)            // Square size

// ClipGeometry types
ClipGeometry.rect()
ClipGeometry.rrect(BorderRadius.circular(12))
ClipGeometry.superEllipse(BorderRadius.circular(12))
```

#### FractionalSize

```dart
Act.fractionalSize(
  widthFactor: AnimatableValue<double>?,
  heightFactor: AnimatableValue<double>?,
  alignment: AnimatableValue<AlignmentGeometry>?,
  motion: CueMotion?,
)
```

#### Clip

```dart
// Animated clip with border radius
Act.clip(
  borderRadius: BorderRadius,
  alignment: AlignmentGeometry,
  useSuperellipse: bool,
  motion: CueMotion?,
)

// Axis-specific clipping
Act.clipHeight(
  fromFactor: 0.0,           // 0.0 = hidden, 1.0 = full height
  toFactor: 1.0,
  alignment: AlignmentGeometry,
  motion: CueMotion?,
)

Act.clipWidth(
  fromFactor: 0.0,
  toFactor: 1.0,
  alignment: AlignmentGeometry,
  motion: CueMotion?,
)

// Circular clip
Act.circularClip(
  alignment: AlignmentGeometry,
  motion: CueMotion?,
)
```

#### Align

```dart
Act.align(
  from: Alignment.topLeft,
  to: Alignment.center,
  motion: CueMotion?,
)
```

#### Padding

```dart
Act.padding(
  from: EdgeInsets.zero,
  to: EdgeInsets.all(16),
  motion: CueMotion?,
)
```

### Decoration Acts

#### Decorate

```dart
Act.decorate(
  color: AnimatableValue<Color>?,
  borderRadius: AnimatableValue<BorderRadiusGeometry>?,
  border: AnimatableValue<BoxBorder>?,
  boxShadow: AnimatableValue<List<BoxShadow>>?,
  gradient: AnimatableValue<Gradient>?,
  shape: BoxShape,           // .rectangle or .circle
  position: DecorationPosition,
  motion: CueMotion?,
)

// AnimatableValue examples:
// color: .tween(from: Colors.red, to: Colors.blue)
// borderRadius: .tween(from: .circular(0), to: .circular(20))
```

### Style Acts

#### TextStyle

```dart
Act.textStyle(
  from: TextStyle,
  to: TextStyle,
  motion: CueMotion?,
)
```

#### IconTheme

```dart
Act.iconTheme(
  from: IconThemeData,
  to: IconThemeData,
  motion: CueMotion?,
)
```

## AnimatableValue Pattern

Many Acts accept `AnimatableValue<T>` for properties that can be constant or animated:

```dart
AnimatableValue.tween(from: value1, to: value2)
AnimatableValue.constant(value)
```

## Keyframe Animations

Acts support keyframe-based animations for complex sequences:

```dart
ScaleAct.keyframed(
  frames: Keyframes.fractional([
    KeyframeEntry.key(1.0, at: 0.0),   // Scale 1.0 at start
    KeyframeEntry.key(1.2, at: 0.5),   // Scale 1.2 at midpoint
    KeyframeEntry.key(1.0, at: 1.0),   // Scale 1.0 at end
  ]),
  delay: Duration,
)

// Using shorthand:
frames: .fractional([
  .key(1.0, at: 0.0),
  .key(1.2, at: 0.5),
  .key(1.0, at: 1.0),
])
```

## ReverseBehavior

Controls how animations behave when reversing:

```dart
// Mirror: Animate from 'to' back to 'from'
ReverseBehavior.mirror()

// Mirror with delay
ReverseBehavior.mirror(delay: Duration(milliseconds: 200))

// Custom reverse values
ReverseBehavior(to: customValue, delay: Duration)

// For keyframes
KFReverseBehavior.mirror()
KFReverseBehavior(frames: Keyframes, delay: Duration)
```

## Common Patterns

### Pattern 1: Toggle Animation

```dart
Cue.onToggle(
  toggled: isExpanded,
  motion: Spring.smooth(damping: 23),
  child: Actor(
    acts: [
      .scale(from: 1.0, to: 1.1),
      .rotate(from: 0, to: 180),
      .fadeIn(),
    ],
    child: MyWidget(),
  ),
)
```

### Pattern 2: Entrance Animation

```dart
Cue.onMount(
  motion: Spring.smooth(damping: 23),
  child: Actor(
    acts: [
      .slideY(from: 0.5, to: 0),
      .fadeIn(from: 0, to: 1),
      .blur(from: 8, to: 0),
    ],
    child: MyWidget(),
  ),
)
```

### Pattern 3: Size Animation with Clip

```dart
Actor(
  acts: [
    .sizedClip(
      from: NSize.width(80),
      to: NSize.width(200),
      clipGeometry: ClipGeometry.rrect(BorderRadius.circular(20)),
    ),
  ],
  child: MyWidget(),
)
```

### Pattern 4: Complex Toggle with Multiple Actors

```dart
Cue.onToggle(
  toggled: isActive,
  motion: .linear(Duration(milliseconds: 300)),
  child: Column(
    children: [
      Actor(
        acts: [.rotate(to: 180)],
        child: Icon(Icons.expand_more),
      ),
      Actor(
        acts: [
          .clipHeight(fromFactor: 0.3),
          .fadeIn(),
          .slideY(from: 0.5),
        ],
        child: Text('Details'),
      ),
    ],
  ),
)
```

### Pattern 5: Keyframe Animation

```dart
Actor(
  acts: [
    ScaleAct.keyframed(
      frames: .fractional([
        .key(1.0, at: 0.0),
        .key(1.1, at: 0.4),
        .key(1.1, at: 0.6),
        .key(1.0, at: 1.0),
      ]),
    ),
  ],
  child: MyWidget(),
)
```

### Pattern 6: Delayed/Staggered Animations

```dart
Column(
  children: [
    Actor(
      acts: [.fadeIn(), .slideY(from: 0.3, to: 0)],
      delay: Duration.zero,
      child: Item1(),
    ),
    Actor(
      acts: [.fadeIn(), .slideY(from: 0.3, to: 0)],
      delay: Duration(milliseconds: 100),
      child: Item2(),
    ),
    Actor(
      acts: [.fadeIn(), .slideY(from: 0.3, to: 0)],
      delay: Duration(milliseconds: 200),
      child: Item3(),
    ),
  ],
)
```

### Pattern 7: Position-based Animation (Stack)

```dart
Cue.onToggle(
  toggled: isExpanded,
  child: Stack(
    children: [
      PositionActor.keyframed(
        frames: .fractional([
          .key(Position.fill(end: 0.5), at: 0.0),
          .key(Position.fill(end: 0, top: 0.15, bottom: 0.15), at: 0.45),
          .key(Position.fill(start: 0.5), at: 1.0),
        ]),
        relativeTo: Size(width, height),
        child: Widget1(),
      ),
      Widget2(),
    ],
  ),
)
```

### Pattern 8: Scroll-based Animation

```dart
Cue.onScrollVisible(
  enabled: true,
  child: Actor(
    acts: [
      .fadeIn(),
      .slideY(from: 0.2, to: 0),
      .scale(from: 0.8, to: 1.0),
    ],
    child: MyWidget(),
  ),
)
```

## Extension Shorthand Syntax

Cue provides extensions for concise syntax:

```dart
// EdgeInsets
.symmetric(horizontal: 16, vertical: 8)
.all(16)
.only(top: 10)
.fromLTRB(10, 20, 10, 20)
.zero

// BorderRadius
.circular(12)
.vertical(top: Radius.circular(12), bottom: Radius.circular(12))

// Alignment
.center
.topLeft
.bottomRight
// etc.

// BoxFit
.cover
.contain
.fill

// Clip
.antiAlias
.hardEdge
.none

// MainAxisAlignment
.center
.start
.end
.spaceBetween
.spaceAround
.spaceEvenly

// CrossAxisAlignment
.start
.center
.end
.stretch

// FontWeight
.bold
.w600
.w700

// BlendMode
.color
.multiply
.screen
// etc.
```

## Best Practices

### 1. Motion Selection

- Use **Spring.smooth()** for natural, responsive UI interactions
- Use **linear()** with short durations for simple state changes
- Use **curved()** with custom curves for specific easing effects
- Use **spring()** with bounce parameter for playful animations

### 2. Performance

- Avoid animating expensive properties (like filters) on large widgets
- Use `clipBehavior: Clip.none` when clipping isn't needed
- Combine multiple Acts in one Actor instead of nesting multiple Actors
- Use `sizedClip` instead of `sizedBox` when you need overflow clipping

### 3. Act Composition

- Only one Act of each type per Actor (no duplicate scale, rotate, etc.)
- Order matters: Acts are applied in reverse order (last Act wraps first)
- Group related animations in the same Actor for synchronized timing
- Use separate Actors for different timing/delays

### 4. Responsive Design

- Use `NSize` with null axes to respect child sizes
- Use `slideX/slideY` for size-relative movement
- Use `AlignmentDirectional` for RTL support
- Use `fractionalSize` for percentage-based sizing

### 5. Common Mistakes to Avoid

- ❌ Don't put two scale Acts in one Actor
- ❌ Don't forget `toggled` parameter in `Cue.onToggle`
- ❌ Don't use `skipFirstAnimation: true` without understanding the behavior
- ✅ Do use `reverseMotion` for different forward/reverse timings
- ✅ Do use `delay` for staggered animations
- ✅ Do use Spring motions for interactive UI elements

## Debugging

Enable debug mode to visualize animations:

```dart
CueDebugProvider(
  child: MaterialApp(...),
)
```

## Type Reference

### CueMotion Types
- `TimedMotion` - Duration-based with optional curve
- `Spring` - Physics-based spring motion

### RotateUnit
- `.degrees` - 0-360
- `.radians` - 0-2π
- `.quarterTurns` - 0-4 (90° increments)

### RotateAxis
- `.x` - Horizontal axis
- `.y` - Vertical axis  
- `.z` - Depth axis (default 2D rotation)

### Axis
- `.horizontal`
- `.vertical`

### ReverseBehaviorType
- `.mirror` - Reverse from 'to' to 'from'
- `.custom` - Use custom reverse values

## Complete Example

```dart
class ExpandingCard extends StatefulWidget {
  @override
  State<ExpandingCard> createState() => _ExpandingCardState();
}

class _ExpandingCardState extends State<ExpandingCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Cue.onToggle(
      toggled: _isExpanded,
      motion: Spring.smooth(damping: 23),
      child: GestureDetector(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Actor(
          acts: [
            .scale(from: 1.0, to: 1.05),
            .padding(
              from: EdgeInsets.symmetric(vertical: 0),
              to: EdgeInsets.symmetric(vertical: 12),
            ),
          ],
          child: Card(
            child: Column(
              children: [
                // Header - always visible
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text('Card Title'),
                      Spacer(),
                      Actor(
                        acts: [.rotate(from: 0, to: 180)],
                        child: Icon(Icons.expand_more),
                      ),
                    ],
                  ),
                ),
                // Content - clips in
                Actor(
                  acts: [
                    .clipHeight(fromFactor: 0.3),
                    .fadeIn(),
                    .slideY(from: 0.5, to: 0),
                  ],
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Expanded content here'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

## Summary

Cue provides a declarative, composable animation system with:
- **Cue widgets** for triggers (toggle, hover, mount, scroll)
- **Actor widgets** for applying animations
- **Acts** for defining transformations
- **CueMotion** for timing (spring or timed)
- **AnimatableValue** for property animations
- **Keyframes** for complex sequences
- **ReverseBehavior** for custom reverse animations

The library emphasizes spring physics for natural motion and provides extensive presets for common animation patterns.
