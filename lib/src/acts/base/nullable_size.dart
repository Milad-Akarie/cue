import 'dart:ui';

/// A size specification where each axis can be `null` to mean
/// "use the child's natural size for that axis" (no constraint applied).
///
/// `double.infinity` is still supported and means "use the maximum available
/// constraint for that axis".
///
/// Examples:
/// ```dart
/// // Both axes fixed
/// NSize(width: 200, height: 100)
///
/// // Animate width, let height follow child
/// NSize(width: 200, height: null)
///
/// // Both axes follow child (no constraint)
/// NSize.childSize
///
/// // From a Flutter Size (no nulls)
/// NSize.fromSize(Size(200, 100))
/// ```
class NSize {
  /// The width. `null` means use the child's natural width.
  /// `double.infinity` means use the maximum available width constraint.
  final double? w;

  /// The height. `null` means use the child's natural height.
  /// `double.infinity` means use the maximum available height constraint.
  final double? h;

  const NSize({this.w, this.h});

  /// Both axes follow the child's natural size (no constraint on either axis).
  static const NSize childSize = NSize();
  static const NSize infinity = NSize(w: double.infinity, h: double.infinity);
  static const NSize zero = NSize(w: 0, h: 0);

  /// Creates an [NSize] from a Flutter [Size] (no nulls).
  NSize.size(Size size) : w = size.width, h = size.height;

  /// Both axes set to [size] (square).
  const NSize.square(double size) : w = size, h = size;

  /// Fixed [w], child's natural height
  const NSize.width(double this.w) : h = null;

  /// Fixed [h], child's natural width
  const NSize.height(double this.h) : w = null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NSize && runtimeType == other.runtimeType && w == other.w && h == other.h;

  @override
  int get hashCode => Object.hash(w, h);

  @override
  String toString() => 'NSize(width: $w, height: $h)';
}
