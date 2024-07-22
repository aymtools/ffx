part of 'x.dart';

mixin XElementMixin on ComponentElement implements X {
  final Cancellable _cancellable = Cancellable();

  late final XDelegate<Widget> _xDelegate =
      XDelegate<Widget>(_cancellable.makeCancellable);

  bool _isFirstBuild = true;

  @override
  void rebuild({bool force = false}) {
    if (_isFirstBuild) {
      _isFirstBuild = false;
      _xDelegate.initState();
      _xDelegate.didChangeDependencies();
    }
    super.rebuild(force: force);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _xDelegate.didChangeDependencies();
  }

  @override
  void update(covariant Widget newWidget) {
    final oldWidget = widget;
    super.update(newWidget);
    _xDelegate.didUpdateWidget(oldWidget, newWidget);
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
  void unmount() {
    _xDelegate.dispose();
    super.unmount();
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

  void addOnUpdateWidgetListener(
          void Function(Widget widget, Widget oldWidget) listener,
          {Cancellable? removable}) =>
      _xDelegate.addOnUpdateWidgetListener(listener, removable: removable);

  @override
  Cancellable makeCancellable({Cancellable? father}) =>
      _xDelegate.makeCancellable(father: father);

  @override
  Cancellable get mountable => _xDelegate.mountable;
}

class _XCompanion {
  WeakReference<XLifecycle>? weakReferenceX;
}

abstract class XWidget extends Widget {
  final _XCompanion _xKitCompanion = _XCompanion();

  XWidget({super.key});

  @protected
  Widget build(BuildContext context);

  @override
  Element createElement() => XElement(this);
}

extension XWidgetEx<W extends XWidget> on W {
  XLifecycle get x {
    return _xKitCompanion.weakReferenceX?.target as XLifecycle;
  }

  void addOnUpdateWidgetListener(void Function(W widget, W oldWidget) listener,
      {Cancellable? removable}) {
    (x as XElement).addOnUpdateWidgetListener(
        (w, old) => listener(w as W, old as W),
        removable: removable);
  }
}

class XElement extends ComponentElement
    with XElementMixin, LifecycleObserverRegistryElementMixin
    implements XLifecycle {
  XElement(XWidget super.widget);

  @override
  XWidget get widget => super.widget as XWidget;

  @override
  void mount(Element? parent, Object? newSlot) {
    widget._xKitCompanion.weakReferenceX = WeakReference(this);
    super.mount(parent, newSlot);
  }

  @override
  void update(covariant XWidget newWidget) {
    newWidget._xKitCompanion.weakReferenceX = WeakReference(this);
    super.update(newWidget);
  }

  @override
  Widget build() {
    return widget.build(this);
  }

  @override
  BuildContext get context => this;
}
