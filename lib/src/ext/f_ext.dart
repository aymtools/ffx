import 'package:anlifecycle/anlifecycle.dart';
import 'package:ffx/src/ext/ext.dart';
import 'package:ffx/src/x/x.dart';
import 'package:flutter/material.dart';

ValueNotifier<T> mutableStateWith<T>(T value) => ValueNotifier(value);

ValueNotifier<T> Function() mutableStateOf<T>(T value) =>
    () => ValueNotifier(value);

ValueNotifier<int> Function() mutableIntStateOf(int value) =>
    mutableStateOf<int>(value);

ValueNotifier<bool> Function() mutableBoolStateOf(bool value) =>
    mutableStateOf(value);

ValueNotifier<double> Function() mutableDoubleStateOf(double value) =>
    mutableStateOf(value);

extension XFExt on X {
  ThemeData get theme => remember2Dependent(() => Theme.of(context));

  NavigatorState get navigator => remember2Dependent(
        () => Navigator.of(context),
        key: 'Navigator',
      );

  NavigatorState get navigatorRoot => remember2Dependent(
        () => Navigator.of(context, rootNavigator: true),
        key: 'rootNavigator',
      );

  ValueNotifier<T> rememberValue<T>(T Function() value, {bool listen = true}) {
    return rememberValueNotifier(mutableStateOf(value()), listen: listen);
  }

  ValueNotifier<T> rememberValueNotifier<T>(ValueNotifier<T> Function() value,
      {Object? key, bool toLocal = false, bool listen = true}) {
    final vk = XTypedKey<ValueNotifier<T>>(key);

    ValueNotifier<T> r;
    if (toLocal) {
      r = remember2Local(value, key: vk, listen: listen);
    } else {
      r = remember<ValueNotifier<T>>(value, key: vk, listen: listen);
    }
    return r;
  }

  ValueNotifier<T> findValueNotifier<T>(
      {Object? key, bool inLocal = false, bool listen = true}) {
    ValueNotifier<T> r = find(
        key: key,
        inDependentValues: false,
        inLocalValues: inLocal,
        inValues: !inLocal,
        listen: listen);
    return r;
  }

  T getValue<T>({Object? key}) => find<ValueNotifier<T>>(key: key)!.value;

  T getByRouteArguments<T>() {
    final settings = remember2Dependent(() => ModalRoute.of(context)!.settings);
    return settings.arguments as T;
  }

  T getByRoute<T, I>({required T Function(I arguments) block}) {
    final settings = remember2Dependent(() => ModalRoute.of(context)!.settings);
    return block(settings.arguments as I);
  }

  T getByRouteMap<T>({required String key}) {
    return getByRoute<T, Map>(block: (a) => a[key]);
  }
}

final Map<Lifecycle, Map<Object, Object>> _map = {};

extension LifecycleProvider on LifecycleObserverRegistry {
  T rememberToLifecycle<T extends Object>(
      {Object? key, required T Function() creator}) {
    assert(currentLifecycleState >= LifecycleState.created);
    late T f;
    final values = _map.putIfAbsent(lifecycle, () {
      lifecycle.addObserver(LifecycleObserver.onEventDestroy(
          (owner) => _map.remove(owner.lifecycle)));
      return {};
    });
    f = values.putIfAbsent(XTypedKey<T>(key), () => creator()) as T;
    return f;
  }
}
