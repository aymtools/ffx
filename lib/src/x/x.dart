import 'package:an_lifecycle_cancellable/an_lifecycle_cancellable.dart';
import 'package:anlifecycle/anlifecycle.dart';
import 'package:cancellable/cancellable.dart';
import 'package:flutter/material.dart';
import 'package:weak_collections/weak_collections.dart' as weak;

part 'x_element.dart';
part 'x_kit.dart';

class X {
  X._();

  BuildContext? _context;

  IX? _mockState;
  LifecycleObserverRegistry? _lifecycleORegistry;

  BuildContext get context => _context!;

  IX get mockState => _mockState!;

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
  XElement createElement() => XElement(this);
}

extension XWidgetExt<W extends XWidget> on W {
  @protected
  X get x => _xs[this] as X;
}
