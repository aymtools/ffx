import 'package:ffx/src/ext/ext.dart';
import 'package:ffx/src/x/x.dart';
import 'package:flutter/material.dart';
import 'package:weak_collections/weak_collections.dart' as weak;

ValueNotifier<T> mutableStateOf<T>(T value) => ValueNotifier(value);

ValueNotifier<int> mutableIntStateOf(int value) => mutableStateOf(value);

ValueNotifier<bool> mutableBoolStateOf(bool value) => mutableStateOf(value);

ValueNotifier<double> mutableDoubleStateOf(double value) =>
    mutableStateOf(value);

Map<Listenable, void Function()> _singleMarkNeedsBuild = weak.WeakMap();

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

  void addToListenableSingleMarkNeedsBuildListener(Listenable listenable) {
    _singleMarkNeedsBuild.putIfAbsent(listenable, () {
      final l = markNeedsBuild;
      listenable.addListener(l);
      mountable.onCancel.then((value) => listenable.removeListener(l));
      return l;
    });
  }

  ValueNotifier<T> rememberValueNotifier<T>(T Function() value,
      {Object? key, bool toLocal = false}) {
    ValueNotifier<T> init() => mutableStateOf(value());

    final vk = XVKey<ValueNotifier<T>>(key: key);

    ValueNotifier<T> r;
    if (toLocal) {
      r = remember2Local(init, key: vk);
    } else {
      r = remember<ValueNotifier<T>>(init, key: vk);
    }
    addToListenableSingleMarkNeedsBuildListener(r);
    return r;
  }

  ValueNotifier<T> findValueNotifier<T>({Object? key, bool inLocal = false}) {
    ValueNotifier<T> r = find(
        key: key,
        inDependentValues: false,
        inLocalValues: inLocal,
        inValues: !inLocal);
    addToListenableSingleMarkNeedsBuildListener(r);
    return r;
  }

  T getValue<T>({Object? key}) => find<ValueNotifier<T>>(key: key)!.value;
}
