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
  final T value;

  AsyncValue(this.value);
}

class AsyncWaiting<T> extends AsyncNotifier<T> {}

class AsyncError<T> extends AsyncNotifier<T> {
  final Object? error;
  final StackTrace? stackTrace;

  AsyncError({required this.error, this.stackTrace});
}

extension XAsyncExt on X {
  ValueNotifier<AsyncNotifier<T>> rememberAsyncNotifier<T>(
      Future<T> Function() value,
      {Object? key,
      bool toLocal = false}) {
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
      r = remember<ValueNotifier<AsyncNotifier<T>>>(init, key: vk);
    }

    addToListenableSingleMarkNeedsBuildListener(r);
    return r;
  }

  ValueNotifier<AsyncNotifier<T>> rememberAsyncNotifierStream<T>(
      Stream<T> Function() value,
      {Object? key,
      bool toLocal = false,
      bool? cancelOnError}) {
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
      r = remember<ValueNotifier<AsyncNotifier<T>>>(init, key: vk);
    }

    addToListenableSingleMarkNeedsBuildListener(r);
    return r;
  }

  ValueNotifier<AsyncNotifier<T>> rememberAsyncNotifierCollectOnLifecycle<T>(
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
      r = remember<ValueNotifier<AsyncNotifier<T>>>(init, key: vk);
    }

    addToListenableSingleMarkNeedsBuildListener(r);
    return r;
  }
}
