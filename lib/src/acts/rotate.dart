part of 'act.dart';

class RotateAct extends TweenAct<double> {
  final AlignmentGeometry alignment;
  final bool _asQuarterTurns;
  final bool _inDegrees;

  @internal
  const RotateAct.internal({
    super.from = 0,
    super.to = 0,
    super.curve,
    super.timing,
    this.alignment = Alignment.center,
    bool asQuarterTurns = false,
    bool inDegrees = false,
  }) : _asQuarterTurns = asQuarterTurns,
       _inDegrees = inDegrees;

  const RotateAct({
    super.from = 0,
    super.to = 0,
    super.curve,
    super.timing,
    this.alignment = Alignment.center,
  }) : _asQuarterTurns = false,
       _inDegrees = false;

  const RotateAct.keyframes(
    super.keyframes, {
    super.curve,
    this.alignment = Alignment.center,
  }) : _asQuarterTurns = false,
       _inDegrees = false,
       super.keyframes();

  const RotateAct.degrees({
    super.from = 0,
    super.to = 0,
    super.curve,
    super.timing,
    this.alignment = Alignment.center,
  }) : _asQuarterTurns = false,
       _inDegrees = true;

  const RotateAct.turns({
    super.from = 0,
    super.to = 0,
    super.curve,
    super.timing,
    this.alignment = Alignment.center,
  }) : _asQuarterTurns = true,
       _inDegrees = false;

  @override
  double transform(double value) {
    if (_inDegrees) {
      return value * math.pi / 180;
    }
    if (_asQuarterTurns) {
      return value * math.pi / 2;
    }
    return value;
  }

  @override
  Widget apply(BuildContext context, Animation<double> animation, Widget child) {
    return MatrixTransition(
      animation: animation,
      onTransform: Matrix4.rotationZ,
      child: child,
    );
  }
}

class RotateLayout extends TweenAct<double> {
  final bool _asQuarterTurns;
  final bool _inDegrees;

  const RotateLayout({
    super.from = 0,
    super.to = 0,
    super.curve,
    super.timing,
  }) : _asQuarterTurns = false,
       _inDegrees = false;

  const RotateLayout.keyframes(
    super.keyframes, {
    super.curve,
  }) : _asQuarterTurns = false,
       _inDegrees = false,
       super.keyframes();

  const RotateLayout.degrees({
    super.from = 0,
    super.to = 0,
    super.curve,
    super.timing,
  }) : _asQuarterTurns = false,
       _inDegrees = true;

  const RotateLayout.turns({
    super.from = 0,
    super.to = 0,
    super.curve,
    super.timing,
  }) : _asQuarterTurns = true,
       _inDegrees = false;

  @override
  double transform(double value) {
    if (_inDegrees) {
      return value * math.pi / 180;
    }
    if (_asQuarterTurns) {
      return value * math.pi / 2;
    }
    return value;
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
  void updateRenderObject(BuildContext context, _RenderRotateLayout renderObject) {
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
