part of 'x.dart';

class _XCompanion {
  WeakReference<XLifecycle>? weakReferenceX;
}

abstract class XWidget extends Widget {
  final _XCompanion _xKitCompanion = _XCompanion();

  XWidget({super.key});

  @protected
  Widget build(BuildContext context);

  @override
  Element createElement() => _makeTypedElement();
}

extension XWidgetEx<W extends XWidget> on W {
  XElement _makeTypedElement() => XElement<W>(this);

  XLifecycle<W> get x => _xKitCompanion.weakReferenceX?.target as XLifecycle<W>;
}

mixin XElementMixin<W extends Widget> on ComponentElement implements X<W> {
  final Cancellable _cancellable = Cancellable();

  late final XDelegate<W> _xDelegate =
      XDelegate<W>(_cancellable.makeCancellable);

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
  void update(covariant W newWidget) {
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

class XElement<XW extends XWidget> extends ComponentElement
    with XElementMixin<XW>, LifecycleObserverRegistryElementMixin
    implements XLifecycle<XW> {
  XElement(XW super.widget);

  @override
  XW get widget => super.widget as XW;

  @override
  void mount(Element? parent, Object? newSlot) {
    widget._xKitCompanion.weakReferenceX = WeakReference(this);
    super.mount(parent, newSlot);
  }

  @override
  void update(covariant XW newWidget) {
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
