import 'package:anlifecycle/anlifecycle.dart';
import 'package:cancellable/cancellable.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:weak_collections/weak_collections.dart' as weak;

part 'x_delegate.dart';
part 'x_ext.dart';
part 'x_state.dart';
part 'x_widget.dart';

abstract interface class X {
  BuildContext get context;

  Cancellable get mountable;

  Cancellable makeCancellable({Cancellable? father});

  void addOnChangeDependenciesListener(
      void Function(Cancellable cancellable) listener,
      {Cancellable? removable});

  void addOnActivateListener(void Function(Cancellable cancellable) listener,
      {Cancellable? removable});

  void addOnDeactivateListener(void Function(Cancellable cancellable) listener,
      {Cancellable? removable});
}

abstract interface class XState<W extends Widget> implements X {
  W get widget;

  void addOnUpdateWidgetListener(void Function(W widget, W oldWidget) listener,
      {Cancellable? removable});
}

abstract interface class XLifecycle implements LifecycleObserverRegistry, X {}
