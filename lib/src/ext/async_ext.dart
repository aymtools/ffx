import 'dart:async';

import 'package:an_lifecycle_cancellable/an_lifecycle_cancellable.dart';
import 'package:anlifecycle/anlifecycle.dart';
import 'package:cancellable/cancellable.dart';
import 'package:ffx/src/ext/ext.dart';
import 'package:ffx/src/ext/f_ext.dart';
import 'package:ffx/src/x/x.dart';
import 'package:flutter/widgets.dart';

sealed class AsyncNotifier<T> {
  AsyncNotifier();

  factory AsyncNotifier.loading() => AsyncWaiting<T>();

  factory AsyncNotifier.waiting() => AsyncWaiting<T>();

  factory AsyncNotifier.error(
          {required Object? error, StackTrace? stackTrace}) =>
      AsyncError<T>(error: error, stackTrace: stackTrace);

  factory AsyncNotifier.value(T value) => AsyncValue(value);
}

class AsyncValue<T> extends AsyncNotifier<T> {
  final T data;

  AsyncValue(this.data);
}

class AsyncWaiting<T> extends AsyncNotifier<T> {}

class AsyncError<T> extends AsyncNotifier<T> {
  final Object? error;
  final StackTrace? stackTrace;

  AsyncError({required this.error, this.stackTrace});
}

class _AsyncNotifierStream<T, A> {
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

  _AsyncNotifierStream(this.value, this._agrs, this.cancellable) {
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
  AsyncNotifier<T> rememberAsyncNotifier<T>(Future<T> Function() value,
      {Object? key, bool toLocal = false}) {
    ValueNotifier<AsyncNotifier<T>> init() {
      final result =
          mutableStateOf<AsyncNotifier<T>>(AsyncNotifier<T>.waiting());
      final future = value();
      future
          .bindCancellable(mountable)
          .then((v) => result.value = AsyncNotifier.value(v))
          .onError((error, stackTrace) => result.value =
              AsyncNotifier.error(error: error, stackTrace: stackTrace))
          .ignore();
      return result;
    }

    final vk = XVKey<ValueNotifier<T>>(key: key);

    ValueNotifier<AsyncNotifier<T>> r;
    if (toLocal) {
      r = remember2Local(init, key: vk);
    } else {
      r = remember(init, key: vk);
    }

    addToListenableSingleMarkNeedsBuildListener(r);
    return r.value;
  }

  AsyncNotifier<T> rememberAsyncNotifierArgs<T, Args>(
      FutureOr<T> Function(Args) value, Args args,
      {Object? key, bool toLocal = false}) {
    final ans = remember(
        () => _AsyncNotifierStream<T, Args>(value, args, mountable),
        listen: false,
        key: key);
    ans.args = args;
    return rememberAsyncNotifierStream(() => ans.stream,
        key: XVKey<T>(key: [key, Args]));
  }

  AsyncNotifier<T> rememberAsyncNotifierStream<T>(Stream<T> Function() value,
      {Object? key, bool toLocal = false, bool? cancelOnError}) {
    ValueNotifier<AsyncNotifier<T>> init() {
      final result =
          mutableStateOf<AsyncNotifier<T>>(AsyncNotifier<T>.waiting());
      final stream = value();
      stream.bindCancellable(mountable).listen(
            (event) {
              result.value = AsyncNotifier.value(event);
            },
            cancelOnError: cancelOnError,
            onError: (error, stackTrace) {
              result.value =
                  AsyncNotifier.error(error: error, stackTrace: stackTrace);
            },
          );
      return result;
    }

    final vk = XVKey<ValueNotifier<T>>(key: key);

    ValueNotifier<AsyncNotifier<T>> r;
    if (toLocal) {
      r = remember2Local(init, key: vk);
    } else {
      r = remember(init, key: vk);
    }

    addToListenableSingleMarkNeedsBuildListener(r);
    return r.value;
  }

  AsyncNotifier<T> rememberAsyncNotifierCollectOnLifecycle<T>(
      Future<T> Function() value,
      {Object? key,
      bool toLocal = false,
      bool? cancelOnError,
      LifecycleState targetState = LifecycleState.started}) {
    ValueNotifier<AsyncNotifier<T>> init() {
      final result =
          mutableStateOf<AsyncNotifier<T>>(AsyncNotifier<T>.waiting());
      final stream = lifecycleORegistry.collectOnLifecycle<T>(
        block: (Cancellable cancellable) =>
            value().bindCancellable(cancellable),
        runWithDelayed: true,
        targetState: targetState,
      );
      stream.bindCancellable(mountable).listen(
            (event) {
              result.value = AsyncNotifier.value(event);
            },
            cancelOnError: cancelOnError,
            onError: (error, stackTrace) {
              result.value =
                  AsyncNotifier.error(error: error, stackTrace: stackTrace);
            },
          );
      return result;
    }

    final vk = XVKey<ValueNotifier<T>>(key: key);

    ValueNotifier<AsyncNotifier<T>> r;
    if (toLocal) {
      r = remember2Local(init, key: vk);
    } else {
      r = remember(init, key: vk);
    }

    addToListenableSingleMarkNeedsBuildListener(r);
    return r.value;
  }
}
