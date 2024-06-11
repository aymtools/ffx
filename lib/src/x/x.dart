import 'package:anlifecycle/anlifecycle.dart';
import 'package:cancellable/cancellable.dart';
import 'package:collection/collection.dart';
import 'package:weak_collections/weak_collections.dart' as weak;
import 'package:flutter/material.dart';

part 'x_delegate.dart';

part 'x_ext.dart';

part 'x_state.dart';

part 'x_widget.dart';

abstract interface class X<W extends Widget> {
  W get widget;

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

  void addOnUpdateWidgetListener(void Function(W widget, W oldWidget) listener,
      {Cancellable? removable});
}

abstract interface class XLifecycle<W extends Widget>
    implements LifecycleObserverRegistry, X<W> {}
