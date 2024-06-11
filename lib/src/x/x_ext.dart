part of 'x.dart';

class TypedKey<T> {
  final Object? key;

  TypedKey([this.key]);

  @override
  int get hashCode => _equality.hash(this);

  @override
  bool operator ==(Object other) {
    return _equality.equals(this, other);
  }

  Type _typed() => T;
}

class TypedKeyEquality implements Equality<Object?> {
  final Equality _base;

  const TypedKeyEquality() : _base = const DefaultEquality();

  @override
  bool equals(Object? e1, Object? e2) {
    if (identical(e1, e2)) return true;
    if (e1 is TypedKey && e2 is TypedKey) {
      return e1._typed() == e2._typed() && _equality.equals(e1.key, e2.key);
    }
    return _base.equals(e1, e2);
  }

  @override
  int hash(Object? e) {
    if (e is TypedKey) {
      return Object.hash(e._typed(), _equality.hash(e.key));
    }
    return _base.hash(e);
  }

  @override
  bool isValidKey(Object? o) {
    if (o is TypedKey) {
      return true;
    }
    return _base.isValidKey(o);
  }
}

const Equality _equality = DeepCollectionEquality(TypedKeyEquality());

final Map<Lifecycle, Map<Object, Object>> _map = {};

weak.WeakMap<X, X> _parent = weak.WeakMap();

extension XExtKit<W extends Widget> on X<W> {
  void markNeedsBuild() {
    final element = (context as Element);
    if (element.dirty) return;
    element.markNeedsBuild();
  }

  void onDispose(void Function() block) {
    mountable.onCancel.then((_) => block());
  }

  X? get parent {
    X? find = _parent[this];
    if (find != null) return find;
    context.visitAncestorElements((element) {
      if (element is XElement) {
        find = element;
        return false;
      } else if (element is StatefulElement && element.state is X) {
        find = element.state as X;
        return false;
      }
      return true;
    });
    if (find != null) {
      _parent[this] = find;
    }
    return find;
  }
}
