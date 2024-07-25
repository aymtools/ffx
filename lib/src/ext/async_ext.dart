import 'dart:async';

import 'package:an_lifecycle_cancellable/an_lifecycle_cancellable.dart';
import 'package:anlifecycle/anlifecycle.dart';
import 'package:cancellable/cancellable.dart';
import 'package:ffx/src/ext/ext.dart';
import 'package:ffx/src/ext/f_ext.dart';
import 'package:ffx/src/x/x.dart';
import 'package:flutter/widgets.dart';

sealed class AsyncValue<T> {
  AsyncValue();

  factory AsyncValue.loading() => AsyncWaiting<T>();

  factory AsyncValue.waiting() => AsyncWaiting<T>();

  factory AsyncValue.error({required Object error, StackTrace? stackTrace}) =>
      AsyncError<T>(error: error, stackTrace: stackTrace);

  factory AsyncValue.value(T value) => AsyncData(value);

  R when<R>(
    R Function(T data) onData,
    R Function() onWaiting,
    R Function(Object error, StackTrace? stackTrace) onError,
  ) {
    return switch (this) {
      AsyncData<T>(:final data) => onData(data),
      AsyncWaiting<T>() => onWaiting(),
      AsyncError<T>(:final error, :final stackTrace) =>
        onError(error, stackTrace),
    };
  }
}

class AsyncData<T> extends AsyncValue<T> {
  final T data;

  AsyncData(this.data);
}

class AsyncWaiting<T> extends AsyncValue<T> {}

class AsyncError<T> extends AsyncValue<T> {
  final Object error;
  final StackTrace? stackTrace;

  AsyncError({required this.error, this.stackTrace});
}

class _AsyncValueStream<T, A> {
  final StreamController<T> controller = StreamController();

  Stream<T> get stream => controller.stream;
  FutureOr<T> Function(A) value;

  Cancellable? lastArgs;
  A _agrs;

  set args(A args) {
    if (args == _agrs) return;
    _agrs = args;
    _listenArg();
    reload();
  }

  Cancellable cancellable;

  _AsyncValueStream(this.value, this._agrs, this.cancellable) {
    controller.bindCancellable(cancellable);
    _listenArg();
    reload();
  }

  _listenArg() {
    lastArgs?.cancel();
    final a = _agrs;
    if (a is Listenable) {
      a.addListener(reload);
      lastArgs = cancellable.makeCancellable();
      lastArgs?.onCancel.then((_) => a.removeListener(reload));
    }
  }

  Cancellable? _loading;

  void reload() {
    _loading?.cancel();
    _loading = (lastArgs ?? cancellable).makeCancellable();
    loading(_loading!);
  }

  void loading(Cancellable loading) async {
    await Future.delayed(Duration.zero);
    if (loading.isUnavailable) return;
    var v = value(_agrs);
    if (loading.isUnavailable) return;
    if (v is Future<T>) {
      v = await v;
      if (loading.isUnavailable) return;
    }
    controller.add(v as T);
  }
}

extension XAsyncExt on X {
  AsyncValue<T> rememberAsyncValue<T>(Future<T> Function() value,
      {Object? key, bool toLocal = false}) {
    ValueNotifier<AsyncValue<T>> init() {
      final result = mutableStateWith<AsyncValue<T>>(AsyncValue<T>.waiting());
      final future = value();
      future
          .bindCancellable(mountable)
          .then((v) => result.value = AsyncValue.value(v))
          .onError<Object>((error, stackTrace) => result.value =
              AsyncValue.error(error: error, stackTrace: stackTrace))
          .ignore();
      return result;
    }

    final vk = XKey<ValueNotifier<T>>(key);

    ValueNotifier<AsyncValue<T>> r;
    if (toLocal) {
      r = remember2Local(init, key: vk);
    } else {
      r = remember(init, key: vk);
    }

    addToListenableSingleMarkNeedsBuildListener(r);
    return r.value;
  }

  AsyncValue<T> rememberAsyncValueAndArg<T, Args>(
      FutureOr<T> Function(Args) value, Args args,
      {Object? key, bool toLocal = false}) {
    final ans = remember(
        () => _AsyncValueStream<T, Args>(value, args, mountable),
        listen: false,
        key: key);
    ans.args = args;
    return rememberAsyncValueStream(() => ans.stream,
        key: XKey<T>([key, Args]));
  }

  AsyncValue<T> rememberAsyncValueStream<T>(Stream<T> Function() value,
      {Object? key, bool toLocal = false, bool? cancelOnError}) {
    ValueNotifier<AsyncValue<T>> init() {
      final result = mutableStateWith<AsyncValue<T>>(AsyncValue<T>.waiting());
      final stream = value();
      stream.bindCancellable(mountable).listen(
            (event) {
              result.value = AsyncValue.value(event);
            },
            cancelOnError: cancelOnError,
            onError: (error, stackTrace) {
              result.value =
                  AsyncValue.error(error: error, stackTrace: stackTrace);
            },
          );
      return result;
    }

    final vk = XKey<ValueNotifier<T>>(key);

    ValueNotifier<AsyncValue<T>> r;
    if (toLocal) {
      r = remember2Local(init, key: vk);
    } else {
      r = remember(init, key: vk);
    }

    addToListenableSingleMarkNeedsBuildListener(r);
    return r.value;
  }
}

extension XLifecycleAsyncExt on XLifecycle {
  AsyncValue<T> rememberAsyncValueCollectOnLifecycle<T>(
      Future<T> Function() value,
      {Object? key,
      bool toLocal = false,
      bool? cancelOnError,
      LifecycleState targetState = LifecycleState.started}) {
    ValueNotifier<AsyncValue<T>> init() {
      final result = mutableStateWith<AsyncValue<T>>(AsyncValue<T>.waiting());
      final stream = collectOnLifecycle<T>(
        block: (Cancellable cancellable) =>
            value().bindCancellable(cancellable),
        runWithDelayed: true,
        targetState: targetState,
      );
      stream.bindCancellable(mountable).listen(
            (event) {
              result.value = AsyncValue.value(event);
            },
            cancelOnError: cancelOnError,
            onError: (error, stackTrace) {
              result.value =
                  AsyncValue.error(error: error, stackTrace: stackTrace);
            },
          );
      return result;
    }

    final vk = XKey<ValueNotifier<T>>(key);

    ValueNotifier<AsyncValue<T>> r;
    if (toLocal) {
      r = remember2Local(init, key: vk);
    } else {
      r = remember(init, key: vk);
    }

    addToListenableSingleMarkNeedsBuildListener(r);
    return r.value;
  }
}
