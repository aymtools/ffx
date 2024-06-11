part of 'x.dart';

mixin XStateMixin<W extends StatefulWidget> on State<W> implements X<W> {
  final Cancellable _cancellable = Cancellable();

  late final XDelegate<W> _xDelegate =
      XDelegate<W>(_cancellable.makeCancellable);

  @override
  void initState() {
    super.initState();
    _xDelegate.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _xDelegate.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant oldWidget) {
    super.didUpdateWidget(oldWidget);
    _xDelegate.didUpdateWidget(oldWidget, widget);
  }

  @override
  void activate() {
    super.activate();
    _xDelegate.activate();
  }

  @override
  void deactivate() {
    super.deactivate();
    _xDelegate.deactivate();
  }

  @override
  void dispose() {
    _xDelegate.dispose();
    super.dispose();
  }

  @override
  void addOnActivateListener(void Function(Cancellable cancellable) listener,
          {Cancellable? removable}) =>
      _xDelegate.addOnActivateListener(listener, removable: removable);

  @override
  void addOnChangeDependenciesListener(
          void Function(Cancellable cancellable) listener,
          {Cancellable? removable}) =>
      _xDelegate.addOnChangeDependenciesListener(listener,
          removable: removable);

  @override
  void addOnDeactivateListener(void Function(Cancellable cancellable) listener,
          {Cancellable? removable}) =>
      _xDelegate.addOnDeactivateListener(listener, removable: removable);

  @override
  void addOnUpdateWidgetListener(void Function(W widget, W oldWidget) listener,
          {Cancellable? removable}) =>
      _xDelegate.addOnUpdateWidgetListener(listener, removable: removable);

  @override
  Cancellable makeCancellable({Cancellable? father}) =>
      _xDelegate.makeCancellable(father: father);

  @override
  Cancellable get mountable => _xDelegate.mountable;
}

mixin XLifecycleStateMixin<W extends StatefulWidget> on State<W>
    implements XLifecycle<W> {
  late final LifecycleObserverRegistryDelegate _lifecycleDelegate =
      LifecycleObserverRegistryDelegate(
          target: this, parentElementProvider: () => context as Element);

  final Cancellable _cancellable = Cancellable();

  late final XDelegate<W> _xDelegate =
      XDelegate<W>(_cancellable.makeCancellable);

  @override
  void initState() {
    _lifecycleDelegate.initState();
    super.initState();
    _xDelegate.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lifecycleDelegate.didChangeDependencies();
    _xDelegate.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant oldWidget) {
    super.didUpdateWidget(oldWidget);
    _xDelegate.didUpdateWidget(oldWidget, widget);
  }

  @override
  void activate() {
    super.activate();
    _xDelegate.activate();
  }

  @override
  void deactivate() {
    super.deactivate();
    _xDelegate.deactivate();
  }

  @override
  void dispose() {
    _xDelegate.dispose();
    _lifecycleDelegate.dispose();
    super.dispose();
  }

  @override
  void addOnActivateListener(void Function(Cancellable cancellable) listener,
          {Cancellable? removable}) =>
      _xDelegate.addOnActivateListener(listener, removable: removable);

  @override
  void addOnChangeDependenciesListener(
          void Function(Cancellable cancellable) listener,
          {Cancellable? removable}) =>
      _xDelegate.addOnChangeDependenciesListener(listener,
          removable: removable);

  @override
  void addOnDeactivateListener(void Function(Cancellable cancellable) listener,
          {Cancellable? removable}) =>
      _xDelegate.addOnDeactivateListener(listener, removable: removable);

  @override
  void addOnUpdateWidgetListener(void Function(W widget, W oldWidget) listener,
          {Cancellable? removable}) =>
      _xDelegate.addOnUpdateWidgetListener(listener, removable: removable);

  @override
  Cancellable makeCancellable({Cancellable? father}) =>
      _xDelegate.makeCancellable(father: father);

  @override
  Cancellable get mountable => _xDelegate.mountable;

  @override
  void addLifecycleObserver(LifecycleObserver observer,
          {LifecycleState? startWith, bool fullCycle = true}) =>
      _lifecycleDelegate.addLifecycleObserver(observer,
          startWith: startWith, fullCycle: fullCycle);

  @override
  LifecycleState get currentLifecycleState =>
      _lifecycleDelegate.currentLifecycleState;

  @override
  LO? findLifecycleObserver<LO extends LifecycleObserver>() =>
      _lifecycleDelegate.findLifecycleObserver<LO>();

  @override
  Lifecycle get lifecycle => _lifecycleDelegate.lifecycle;

  @override
  void removeLifecycleObserver(LifecycleObserver observer, {bool? fullCycle}) =>
      _lifecycleDelegate.removeLifecycleObserver(observer,
          fullCycle: fullCycle);
}
