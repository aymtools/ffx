import 'package:an_lifecycle_cancellable/an_lifecycle_cancellable.dart';
import 'package:anlifecycle/anlifecycle.dart';
import 'package:cancellable/cancellable.dart';
import 'package:flutter/material.dart';
import 'package:weak_collections/weak_collections.dart' as weak;

part 'x_kit.dart';

class X<W extends Widget> {
  X._();

  BuildContext? _context;

  IXState<W>? _xState;
  LifecycleObserverRegistry? _lifecycleORegistry;

  BuildContext get context => _context!;

  IXState<W> get xState => _xState!;

  LifecycleObserverRegistry get lifecycleORegistry => _lifecycleORegistry!;

  late final Cancellable _mountedCancellable =
      _lifecycleORegistry?.makeLiveCancellable() ?? Cancellable();

  X? Function()? _parent;

  Cancellable get mountable => _mountedCancellable;

  X? get parent => _parent?.call();

  void markNeedsBuild() {
    Element element = context as Element;
    element.markNeedsBuild();
  }
}

abstract class XWidget extends Widget {
  const XWidget({super.key});

  @protected
  Widget build(BuildContext context);

  @override
  XElement createElement() => _createElement();
}

extension XWidgetExt<W extends XWidget> on W {
  @protected
  X<W> get x => _xs[this] as X<W>;

  XElement<W> _createElement() => XElement<W>(this);
}
