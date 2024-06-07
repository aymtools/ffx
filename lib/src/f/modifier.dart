part of 'f.dart';

abstract interface class Modifier {
  @protected
  Widget apply(X x, Widget child);
}

class _Modifier implements Modifier {
  const _Modifier();

  @override
  Widget apply(X x, Widget child) => child;
}

const Modifier Modifior = _Modifier();

class CombinedModifier implements Modifier {
  final Modifier inner;
  final Modifier outer;

  CombinedModifier({required this.inner, required this.outer});

  @override
  Widget apply(X x, Widget child) {
    return outer.apply(x, inner.apply(x, child));
  }
}

extension ModifierThenExt on Modifier {
  @protected
  Modifier then(Modifier other) => CombinedModifier(inner: this, outer: other);
}

class _ModifierFx implements Modifier {
  final Widget Function(X x, Widget child) fx;

  _ModifierFx(this.fx);

  @override
  Widget apply(X x, Widget child) {
    return fx(x, child);
  }
}

extension $ModifierFxExt on Modifier {
  Modifier fx(Widget Function(X x, Widget child) fx) => then(_ModifierFx(fx));
}

extension $PaddingModifier on Modifier {
  Modifier padding(EdgeInsetsGeometry padding) =>
      fx((_, child) => Padding(padding: padding));

  Modifier paddingAll(double value) =>
      fx((_, child) => Padding(padding: EdgeInsets.all(value)));

  Modifier paddingOnly(
          {double left = 0,
          double top = 0,
          double right = 0,
          double bottom = 0}) =>
      fx((_, child) => Padding(
          padding: EdgeInsets.only(
              left: left, top: top, right: right, bottom: bottom)));
}

extension $TextStyleModifier on Modifier {
  Modifier textStyle(TextStyle style) =>
      fx((_, child) => DefaultTextStyle.merge(style: style, child: child));
}
