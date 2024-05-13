import 'package:ffx/src/x/x.dart';
import 'package:collection/collection.dart';
import 'package:weak_collections/weak_collections.dart' as weak;

class _XValues {
  final Map<XVKey, Object?> _values = {};
  final Map<XVKey, Object?> _dependentValues = {};
  final Map<XVKey, Object?> _localValues = {};
}

Map<X, _XValues> _xvs = weak.WeakMap();

class XVKey<T> {
  final Object? key;

  XVKey({required this.key}) : assert(key is! Map && key is! Set);

  @override
  int get hashCode =>
      key is List ? Object.hashAll([T, ...(key as List)]) : Object.hash(T, key);

  @override
  bool operator ==(Object other) {
    if (other is XVKey<T>) {
      final k = key;
      final ok = other.key;
      if (ok == k) {
        return true;
      }
      if (ok is List && k is List) {
        return const ListEquality().equals(ok, k);
      }
    }
    return false;
  }
}

extension XExt on X {
  _XValues get _vs => _xvs.putIfAbsent(this, () {
        final vs = _XValues();
        xState.addOnChangeDependenciesListener((_) {
          vs._dependentValues.clear();
        });

        mountable.onCancel.then((_) {
          vs._values.clear();
          vs._dependentValues.clear();
          vs._localValues.clear();
        });
        return vs;
      });

  T remember<T>(T Function() value, {Object? key}) {
    final vk = XVKey<T>(key: key);
    var f = _find<T>(vk, inDependentValues: false, inLocalValues: false);
    if (f != null) return f;
    f = value();
    _vs._values[vk] = f;
    return f as T;
  }

  T remember2Local<T>(T Function() value, {Object? key}) {
    final vk = XVKey<T>(key: key);
    var f = _find<T>(vk, inValues: false, inDependentValues: false);
    if (f != null) return f;
    f = parent?._find<T>(vk, inValues: false, inDependentValues: false);
    if (f != null) return f;
    f = value();
    _vs._localValues[vk] = f;
    return f as T;
  }

  T remember2Dependent<T>(T Function() value, {Object? key}) {
    final vk = XVKey<T>(key: key);
    var f = _find<T>(vk, inValues: false, inLocalValues: false);
    if (f != null) return f;
    f = value();
    _vs._dependentValues[vk] = f;
    return f as T;
  }

  T? _find<T>(XVKey<T> vk,
      {bool inValues = true,
      bool inDependentValues = true,
      bool inLocalValues = true}) {
    T? r;
    if (inValues) {
      r = _vs._values[vk] as T?;
    }
    if (r == null && inDependentValues) {
      r = _vs._dependentValues[vk] as T?;
    }
    if (r == null && inLocalValues) {
      r = _vs._localValues[vk] as T?;
      r ??= parent?._find(vk, inValues: false, inDependentValues: false);
    }
    return r;
  }

  T? find<T>(
      {Object? key,
      bool inValues = true,
      bool inDependentValues = true,
      bool inLocalValues = true}) {
    final vk = XVKey<T>(key: key);
    return _find(vk);
  }

  T get<T>({Object? key}) => find(key: key) as T;
}
