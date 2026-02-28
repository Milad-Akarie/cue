part of 'base/effect.dart';

class RotateLayoutEffect extends TweenEffect<double> {
  final RotateUnit unit;

  const RotateLayoutEffect({
    super.from = 0,
    super.to = 0,
    super.curve,
    super.timing,
  }) : unit = RotateUnit.radians;

  const RotateLayoutEffect.keyframes(
    super.keyframes, {
    super.curve,
    this.unit = RotateUnit.radians,
  }) : super.keyframes();

  const RotateLayoutEffect.degrees({
    super.from = 0,
    super.to = 0,
    super.curve,
    super.timing,
  }) : unit = RotateUnit.degrees;

  const RotateLayoutEffect.turns({
    super.from = 0,
    super.to = 0,
    super.curve,
    super.timing,
  }) : unit = RotateUnit.quarterTurns;

  @internal
  const RotateLayoutEffect.internal({
    super.from,
    super.to,
    super.keyframes,
    super.curve,
    super.timing,
    this.unit = RotateUnit.radians,
  }) : super.internal();

  @override
  double transform(double value) {
    switch (unit) {
      case RotateUnit.degrees:
        return value * math.pi / 180;
      case RotateUnit.quarterTurns:
        return value * math.pi / 2;
      case RotateUnit.radians:
        return value;
    }
  }

  @override
  Widget apply(BuildContext ctx, Animation<double> animation, Widget child) {
    return ListenableBuilder(
      listenable: animation,
      child: child,
      builder: (context, child) {
        return _RotateLayout(
          radians: animation.value,
          child: child,
        );
      },
    );
  }
}

class _RotateLayout extends SingleChildRenderObjectWidget {
  final double radians;

  const _RotateLayout({
    required this.radians,
    required super.child,
  });

  @override
  _RenderRotateLayout createRenderObject(BuildContext context) {
    return _RenderRotateLayout(radians);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderRotateLayout renderObject,
  ) {
    renderObject.radians = radians;
  }
}

class _RenderRotateLayout extends RenderProxyBox {
  double _radians;

  _RenderRotateLayout(this._radians);

  double get radians => _radians;
  set radians(double value) {
    if (_radians == value) return;
    _radians = value;
    markNeedsLayout();
  }

  Matrix4 _paintTransform = Matrix4.identity();

  @override
  void performLayout() {
    if (child == null) {
      size = constraints.smallest;
      return;
    }

    child!.layout(constraints.loosen(), parentUsesSize: true);

    final childSize = child!.size;
    final w = childSize.width;
    final h = childSize.height;

    final c = math.cos(radians).abs();
    final s = math.sin(radians).abs();

    // Calculate rotated bounding box size
    final rotatedW = w * c + h * s;
    final rotatedH = w * s + h * c;

    size = constraints.constrain(Size(rotatedW, rotatedH));

    final center = Offset(size.width / 2, size.height / 2);
    final childCenter = Offset(childSize.width / 2, childSize.height / 2);

    _paintTransform = Matrix4.identity()
      ..translateByDouble(center.dx, center.dy, 0, 1)
      ..rotateZ(radians)
      ..translateByDouble(-childCenter.dx, -childCenter.dy, 0, 1);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) {
      layer = null;
      return;
    }
    layer = context.pushTransform(
      needsCompositing,
      offset,
      _paintTransform,
      (context, offset) => context.paintChild(child!, offset),
      oldLayer: layer is TransformLayer ? layer as TransformLayer? : null,
    );
  }
}

class RotateLayoutActor extends SingleEffectBase<double> {
  final RotateUnit unit;

  const RotateLayoutActor({
    super.key,
    super.from = 0,
    super.to = 0,
    required super.child,
    super.role,
    super.curve,
    super.timing,
  }) : unit = RotateUnit.radians;

  const RotateLayoutActor.degrees({
    super.key,
    super.from = 0,
    super.to = 0,
    required super.child,
    super.role,
    super.curve,
    super.timing,
  }) : unit = RotateUnit.degrees;

  const RotateLayoutActor.turns({
    super.key,
    super.from = 0,
    super.to = 0,
    required super.child,
    super.role,
    super.curve,
    super.timing,
  }) : unit = RotateUnit.quarterTurns;

  const RotateLayoutActor.keyframes({
    required super.child,
    required super.frames,
    super.key,
    super.role,
    super.curve,
    this.unit = RotateUnit.radians,
  }) : super.keyframes();

  @override
  Effect get effect => RotateLayoutEffect.internal(
    from: from,
    to: to,
    keyframes: frames,
    curve: curve,
    timing: timing,
    unit: unit,
  );
}
