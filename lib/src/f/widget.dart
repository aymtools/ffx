part of 'f.dart';

class FXElement extends LifecycleXElement {
  FXElement(super.widget);

  @override
  FWidget get widget => super.widget as FWidget;

  @override
  Widget build() {
    return widget.builder(x);
  }
}

class FWidget extends Widget {
  final Widget Function(X x) builder;

  const FWidget({required FXKey super.key, required this.builder});

  @override
  FXElement createElement() => FXElement(this);
}

class FXKey extends Key {
  final String name;
  final List<Object?> parameters;

  const FXKey(this.name, this.parameters) : super.empty();

  const FXKey.empty(this.name)
      : parameters = const [],
        super.empty();
}
