part of 'f.dart';

abstract interface class Modifier {
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

class _PaddingModifier implements Modifier {
  final EdgeInsetsGeometry padding;

  _PaddingModifier(this.padding);

  _PaddingModifier.all(double value) : padding = EdgeInsets.all(value);

  @override
  Widget apply(X x, Widget child) {
    return Padding(padding: padding, child: child);
  }
}

extension $PaddingModifier on Modifier {
  Modifier padding(EdgeInsetsGeometry padding) =>
      CombinedModifier(inner: this, outer: _PaddingModifier(padding));

  Modifier paddingAll(double value) =>
      CombinedModifier(inner: this, outer: _PaddingModifier.all(value));
}

class _TextStyleModifier implements Modifier {
  final TextStyle style;

  _TextStyleModifier(this.style);

  @override
  Widget apply(X x, Widget child) {
    return DefaultTextStyle.merge(style: style, child: child);
  }
}

extension $TextStyleModifier on Modifier {
  Modifier textStyle(TextStyle style) =>
      CombinedModifier(inner: this, outer: _TextStyleModifier(style));
}
