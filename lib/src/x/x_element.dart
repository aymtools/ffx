part of 'x.dart';

abstract class IX {
  Cancellable makeCancellable({Cancellable? father});

  void addOnChangeDependenciesListener(
      void Function(Cancellable cancellable) listener,
      {Cancellable? removable});

  void addOnActivateListener(void Function(Cancellable cancellable) listener,
      {Cancellable? removable});

  void addOnDeactivateListener(void Function(Cancellable cancellable) listener,
      {Cancellable? removable});
}

class XDelegate implements IX {
  final Cancellable Function() cancellableProvider;

  XDelegate(this.cancellableProvider);

  @override
  Cancellable makeCancellable({Cancellable? father}) =>
      cancellableProvider().makeCancellable(father: father);

  void initState() {}

  Cancellable? _changeDependenciesCancellable;
  Set<void Function(Cancellable cancellable)>? _onChangeDependencies;

  @override
  void addOnChangeDependenciesListener(
      void Function(Cancellable cancellable) listener,
      {Cancellable? removable}) {
    if (removable?.isAvailable != true) return;
    if (_onChangeDependencies == null) {
      _onChangeDependencies = {};
      makeCancellable().onCancel.then((value) {
        _onChangeDependencies?.clear();
        _onChangeDependencies = null;
      });
    }
    if (_changeDependenciesCancellable?.isAvailable == true) {
      listener(_changeDependenciesCancellable!.makeCancellable());
    }
    _onChangeDependencies!.add(listener);
    removable?.onCancel.then((_) => _onChangeDependencies?.remove(listener));
  }

  void didChangeDependencies() {
    _changeDependenciesCancellable?.cancel();
    _changeDependenciesCancellable = makeCancellable();
    if (_onChangeDependencies != null) {
      final listeners = List.of(_onChangeDependencies!, growable: false);
      for (var l in listeners) {
        l(_changeDependenciesCancellable!.makeCancellable());
      }
    }
  }

  Cancellable? _activateCancellable;
  Set<void Function(Cancellable cancellable)>? _activates;

  @override
  void addOnActivateListener(void Function(Cancellable cancellable) listener,
      {Cancellable? removable}) {
    if (removable?.isAvailable != true) return;
    if (_activates == null) {
      _activates = {};
      makeCancellable().onCancel.then((value) {
        _activates?.clear();
        _activates = null;
      });
    }
    if (_activateCancellable?.isAvailable == true) {
      listener(_activateCancellable!.makeCancellable());
    }
    _activates!.add(listener);
    removable?.onCancel.then((_) => _activates?.remove(listener));
  }

  void activate() {
    _deactivateCancellable?.cancel();
    if (_activateCancellable?.isAvailable != true) {
      _activateCancellable?.cancel();
      _activateCancellable = makeCancellable();
    }
    if (_activates != null) {
      final listeners = List.of(_activates!, growable: false);
      for (var l in listeners) {
        l(_activateCancellable!.makeCancellable());
      }
    }
  }

  Cancellable? _deactivateCancellable;
  Set<void Function(Cancellable cancellable)>? _deactivates;

  @override
  void addOnDeactivateListener(void Function(Cancellable cancellable) listener,
      {Cancellable? removable}) {
    if (removable?.isAvailable != true) return;
    if (_deactivates == null) {
      _deactivates = {};
      makeCancellable().onCancel.then((value) {
        _deactivates?.clear();
        _deactivates = null;
      });
    }
    if (_deactivateCancellable?.isAvailable == true) {
      listener(_deactivateCancellable!.makeCancellable());
    }
    _deactivates!.add(listener);
    removable?.onCancel.then((_) => _deactivates?.remove(listener));
  }

  void deactivate() {
    _activateCancellable?.cancel();
    if (_deactivateCancellable?.isAvailable != true) {
      _deactivateCancellable?.cancel();
      _deactivateCancellable = makeCancellable();
    }
    if (_deactivates != null) {
      final listeners = List.of(_deactivates!, growable: false);
      for (var l in listeners) {
        l(_deactivateCancellable!.makeCancellable());
      }
    }
  }

  void dispose() {}
}

mixin XElementMixin on ComponentElement implements IX {
  final X _x = X._();

  X get x => _x;

  Cancellable Function() get cancellableProvider;

  bool _isFirstBuild = true;

  @override
  void mount(Element? parent, Object? newSlot) {
    assert(() {
      final e = this;
      if (e is StatefulElement && (e as StatefulElement).state is IXState) {
        return false;
      }
      return true;
    }(), 'XElementMixin cannot be used with IXState');

    _x._context = this;
    _x._parent = () => _findParent(this);
    _x._mockState = this;
    super.mount(parent, newSlot);
  }

  late final XDelegate _delegate = XDelegate(cancellableProvider);

  @override
  void rebuild({bool force = false}) {
    if (_isFirstBuild) {
      _isFirstBuild = false;
      _delegate.initState();
      _delegate.didChangeDependencies();
    }
    super.rebuild(force: force);
  }

  @override
  void unmount() {
    _delegate.dispose();
    _x._mockState = null;
    super.unmount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _delegate.didChangeDependencies();
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
  Cancellable makeCancellable({Cancellable? father}) =>
      _delegate.makeCancellable(father: father);
}

abstract class LifecycleXElement extends ComponentElement
    with LifecycleObserverRegistryElementMixin, XElementMixin {
  LifecycleXElement(super.widget);

  @override
  void mount(Element? parent, Object? newSlot) {
    _x._lifecycleORegistry = this;
    super.mount(parent, newSlot);
  }

  @override
  void unmount() {
    _x._lifecycleORegistry = null;
    super.unmount();
  }

  @override
  Cancellable Function() get cancellableProvider => makeLiveCancellable;
}

class XElement extends LifecycleXElement {
  XElement(super.widget);

  @override
  XWidget get widget => super.widget as XWidget;

  @override
  Widget build() {
    return widget.build(this);
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    _xs[widget] = _x;
    super.mount(parent, newSlot);
  }

  @override
  void update(covariant Widget newWidget) {
    final oldWidget = widget;
    _xs.remove(oldWidget);
    _xs[newWidget as XWidget] = _x;
    super.update(newWidget);
  }

  @override
  void unmount() {
    super.unmount();
    _xs.remove(widget);
  }
}

X? _findParent(Element element) {
  X? find;
  element.visitAncestorElements((element) {
    if (element is XElement) {
      find = element._x;
      return false;
    } else if (element is StatefulElement &&
        element.state is XLifecycleStateMixin) {
      find = (element.state as XLifecycleStateMixin)._x;
      return false;
    } else if (element is StatefulElement && element.state is XStateMixin) {
      find = (element.state as XStateMixin)._x;
      return false;
    }
    return true;
  });
  return find;
}

final Map<Widget, X> _xs = weak.WeakMap<Widget, X>();
