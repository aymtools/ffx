part of 'x.dart';

abstract class IXState<W extends Widget> implements IX {
  void addOnUpdateWidgetListener(void Function(W widget, W oldWidget) listener,
      {Cancellable? removable});
}

class XStateDelegate<W extends Widget> extends XDelegate implements IXState<W> {
  XStateDelegate(super.cancellableProvider);

  Set<void Function(W widget, W oldWidget)>? _onUpdateWidget;

  @override
  void addOnUpdateWidgetListener(void Function(W widget, W oldWidget) listener,
      {Cancellable? removable}) {
    if (removable?.isAvailable != true) return;
    if (_onUpdateWidget == null) {
      _onUpdateWidget = {};
      makeCancellable().onCancel.then((value) {
        _onUpdateWidget?.clear();
        _onUpdateWidget = null;
      });
    }
    _onUpdateWidget!.add(listener);
    removable?.onCancel.then((_) => _onUpdateWidget?.remove(listener));
  }

  void didUpdateWidget(covariant W oldWidget, covariant W widget) {
    if (_onUpdateWidget != null && _onUpdateWidget!.isNotEmpty) {
      final listeners = List.of(_onUpdateWidget!, growable: false);
      for (var l in listeners) {
        l(widget, oldWidget);
      }
    }
  }
}

mixin XStateMixin<W extends StatefulWidget> on State<W> implements IXState<W> {
  late final Cancellable _base = () {
    return this is LifecycleObserverRegistry
        ? (this as LifecycleObserverRegistry).makeLiveCancellable()
        : Cancellable();
  }();
  late final XStateDelegate<W> _delegate =
      XStateDelegate(_base.makeCancellable);

  @override
  void addOnActivateListener(void Function(Cancellable cancellable) listener,
          {Cancellable? removable}) =>
      _delegate.addOnActivateListener(listener, removable: removable);

  @override
  void addOnChangeDependenciesListener(
          void Function(Cancellable cancellable) listener,
          {Cancellable? removable}) =>
      _delegate.addOnChangeDependenciesListener(listener, removable: removable);

  @override
  void addOnDeactivateListener(void Function(Cancellable cancellable) listener,
          {Cancellable? removable}) =>
      _delegate.addOnDeactivateListener(listener, removable: removable);

  @override
  void addOnUpdateWidgetListener(void Function(W widget, W oldWidget) listener,
          {Cancellable? removable}) =>
      _delegate.addOnUpdateWidgetListener(listener, removable: removable);

  @override
  Cancellable makeCancellable({Cancellable? father}) =>
      _delegate.makeCancellable(father: father);

  @override
  void initState() {
    super.initState();
    _x._context = context;
    _x._mockState = _delegate;
    makeCancellable().onCancel.then(_x._mountedCancellable.cancel);
    _x._parent = () => _findParent(context as Element);
    _delegate.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _delegate.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant oldWidget) {
    super.didUpdateWidget(oldWidget);
    _delegate.didUpdateWidget(oldWidget, widget);
  }

  @override
  void activate() {
    super.activate();
    _delegate.activate();
  }

  @override
  void deactivate() {
    super.deactivate();
    _delegate.deactivate();
  }

  @override
  void dispose() {
    _delegate.dispose();
    // _x._depValues.clear();
    _base.cancel();
    super.dispose();
  }

  late final X _x = X._();

  @protected
  X get x => _x;
}

mixin XLifecycleStateMixin<W extends StatefulWidget> on State<W>
    implements IXState<W>, LifecycleObserverRegistryMixin<W> {
  late final LifecycleObserverRegistryDelegate _delegateLifecycle =
      LifecycleObserverRegistryDelegate(
          target: this,
          parentElementProvider: () {
            late Element parent;
            context.visitAncestorElements((element) {
              parent = element;
              return false;
            });
            return parent;
          });

  @override
  LifecycleState get currentLifecycleState =>
      _delegateLifecycle.currentLifecycleState;

  @override
  Lifecycle get lifecycle => _delegateLifecycle.lifecycle;

  @override
  void addLifecycleObserver(LifecycleObserver observer,
      {LifecycleState? startWith, bool fullCycle = true}) {
    _delegateLifecycle.addLifecycleObserver(observer,
        startWith: startWith, fullCycle: fullCycle);
  }

  @override
  void removeLifecycleObserver(LifecycleObserver observer, {bool? fullCycle}) =>
      _delegateLifecycle.removeLifecycleObserver(observer,
          fullCycle: fullCycle);

  @override
  LO? findLifecycleObserver<LO extends LifecycleObserver>() =>
      _delegateLifecycle.findLifecycleObserver<LO>();

  late final XStateDelegate<W> _delegate = XStateDelegate(makeLiveCancellable);

  @override
  void addOnActivateListener(void Function(Cancellable cancellable) listener,
          {Cancellable? removable}) =>
      _delegate.addOnActivateListener(listener, removable: removable);

  @override
  void addOnChangeDependenciesListener(
          void Function(Cancellable cancellable) listener,
          {Cancellable? removable}) =>
      _delegate.addOnChangeDependenciesListener(listener, removable: removable);

  @override
  void addOnDeactivateListener(void Function(Cancellable cancellable) listener,
          {Cancellable? removable}) =>
      _delegate.addOnDeactivateListener(listener, removable: removable);

  @override
  void addOnUpdateWidgetListener(void Function(W widget, W oldWidget) listener,
          {Cancellable? removable}) =>
      _delegate.addOnUpdateWidgetListener(listener, removable: removable);

  @override
  void addOnDidUpdateWidget(void Function(W widget, W oldWidget) listener) =>
      addOnUpdateWidgetListener(listener);

  @override
  Cancellable makeCancellable({Cancellable? father}) =>
      _delegate.makeCancellable(father: father);

  @override
  void initState() {
    super.initState();
    _x._context = context;
    _x._mockState = _delegate;
    _x._lifecycleORegistry = _delegateLifecycle;
    makeCancellable().onCancel.then(_x._mountedCancellable.cancel);
    _x._parent = () => _findParent(context as Element);
    _delegateLifecycle.initState();
    _delegate.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _delegateLifecycle.didChangeDependencies();
    _delegate.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant oldWidget) {
    super.didUpdateWidget(oldWidget);
    _delegate.didUpdateWidget(oldWidget, widget);
  }

  @override
  void activate() {
    super.activate();
    _delegate.activate();
  }

  @override
  void deactivate() {
    super.deactivate();
    _delegate.deactivate();
  }

  @override
  void dispose() {
    _delegateLifecycle.dispose();
    _delegate.dispose();
    super.dispose();
  }

  late final X _x = X._();

  @protected
  X get x => _x;
}
