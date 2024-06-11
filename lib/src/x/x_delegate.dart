part of 'x.dart';

class XDelegate<W extends Widget> implements X<W> {
  final Cancellable Function() cancellableProvider;
  late final Cancellable _mountable;

  XDelegate(this.cancellableProvider);

  @override
  Cancellable makeCancellable({Cancellable? father}) =>
      cancellableProvider().makeCancellable(father: father);

  void initState() {
    _mountable = cancellableProvider();
  }

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

  @override
  Cancellable get mountable => _mountable;

  @override
  BuildContext get context => throw UnimplementedError();

  @override
  W get widget => throw UnimplementedError();
}
