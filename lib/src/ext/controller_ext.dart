import 'package:ffx/ffx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class _WidgetTicker extends Ticker {
  _WidgetTicker(super.onTick, this._creator, {super.debugLabel});

  final _Maker _creator;

  @override
  void dispose() {
    _creator._removeTicker(this);
    super.dispose();
  }
}

class _Maker implements TickerProvider {
  Set<Ticker>? _tickers;
  WeakReference<BuildContext>? context;

  @override
  Ticker createTicker(TickerCallback onTick) {
    if (_tickerModeNotifier == null) {
      // Setup TickerMode notifier before we vend the first ticker.
      _updateTickerModeNotifier();
    }
    assert(_tickerModeNotifier != null);
    _tickers ??= <_WidgetTicker>{};
    final _WidgetTicker result = _WidgetTicker(onTick, this,
        debugLabel: kDebugMode ? 'created by ${describeIdentity(this)}' : null)
      ..muted = !_tickerModeNotifier!.value;
    _tickers!.add(result);
    return result;
  }

  void _removeTicker(_WidgetTicker ticker) {
    assert(_tickers != null);
    assert(_tickers!.contains(ticker));
    _tickers!.remove(ticker);
  }

  ValueListenable<bool>? _tickerModeNotifier;

  void activate() {
    // We may have a new TickerMode ancestor, get its Notifier.
    _updateTickerModeNotifier();
    _updateTickers();
  }

  void _updateTickers() {
    if (_tickers != null) {
      final bool muted = !_tickerModeNotifier!.value;
      for (final Ticker ticker in _tickers!) {
        ticker.muted = muted;
      }
    }
  }

  void _updateTickerModeNotifier() {
    final ctx = context?.target;
    if (ctx == null) return;
    final ValueListenable<bool> newNotifier = TickerMode.getNotifier(ctx);
    if (newNotifier == _tickerModeNotifier) {
      return;
    }
    _tickerModeNotifier?.removeListener(_updateTickers);
    newNotifier.addListener(_updateTickers);
    _tickerModeNotifier = newNotifier;
  }

  void dispose() {
    assert(() {
      if (_tickers != null) {
        for (final Ticker ticker in _tickers!) {
          if (ticker.isActive) {
            throw FlutterError.fromParts(<DiagnosticsNode>[
              ErrorSummary('$this was disposed with an active Ticker.'),
              ErrorDescription(
                '$runtimeType created a Ticker via its CancellableState, but at the time '
                'dispose() was called on the mixin, that Ticker was still active. All Tickers must '
                'be disposed before calling super.dispose().',
              ),
              ErrorHint(
                'Tickers used by AnimationControllers '
                'should be disposed by calling dispose() on the AnimationController itself. '
                'Otherwise, the ticker will leak.',
              ),
              ticker.describeForError('The offending ticker was'),
            ]);
          }
        }
      }
      return true;
    }());
    _tickerModeNotifier?.removeListener(_updateTickers);
    _tickerModeNotifier = null;
  }
}

// Map<X, _Maker> _makers = {};
// Map<X, KeepAliveHandle> _keepAlive = {};

extension CancellableStateExt on X {
  TickerProvider rememberTickerProvider() {
    final factoryTickerProvider = remember(() {
      _Maker maker = _Maker();
      onDispose(maker.dispose);
      // mountable.onCancel.then((value) => maker.dispose());
      addOnActivateListener((_) {
        maker.context = WeakReference(context);
        maker.activate();
      });
      return maker;
    }, key: 'TickerProvider');
    return factoryTickerProvider;
  }

  bool rememberKeepAlive(bool wantKeepAlive) {
    final wantKeepAliveHandle =
        rememberValue(() => KeepAliveHandle(), listen: false);
    final handle = wantKeepAliveHandle.value;
    if (wantKeepAlive) {
      KeepAliveNotification(handle).dispatch(context);
    } else {
      handle.dispose();
      wantKeepAliveHandle.value = KeepAliveHandle();
    }
    return wantKeepAlive;
  }

  AnimationController rememberAnimationController({
    double? value,
    Duration? duration,
    Duration? reverseDuration,
    String? debugLabel,
    double lowerBound = 0.0,
    double upperBound = 1.0,
    AnimationBehavior animationBehavior = AnimationBehavior.normal,
    Object? key,
  }) {
    return remember(() {
      final result = AnimationController(
          value: value,
          duration: duration,
          reverseDuration: reverseDuration,
          debugLabel: debugLabel,
          lowerBound: lowerBound,
          upperBound: upperBound,
          animationBehavior: animationBehavior,
          vsync: rememberTickerProvider());
      mountable.onCancel.then((value) => result.dispose());
      return result;
    }, key: [
      value,
      duration,
      reverseDuration,
      lowerBound,
      upperBound,
      animationBehavior,
      key,
    ], listen: false);
  }

  AnimationController rememberAnimationControllerUnbounded({
    double value = 0.0,
    Duration? duration,
    Duration? reverseDuration,
    String? debugLabel,
    AnimationBehavior animationBehavior = AnimationBehavior.normal,
    Object? key,
  }) {
    return remember(() {
      final result = AnimationController.unbounded(
          value: value,
          duration: duration,
          reverseDuration: reverseDuration,
          debugLabel: debugLabel,
          animationBehavior: animationBehavior,
          vsync: rememberTickerProvider());
      mountable.onCancel.then((value) => result.dispose());
      return result;
    }, key: [
      'Unbounded',
      value,
      duration,
      reverseDuration,
      animationBehavior,
      key
    ], listen: false);
  }

  TabController rememberTabController({
    int initialIndex = 0,
    Duration? animationDuration,
    required int length,
    Object? key,
  }) {
    return remember(() {
      final result = TabController(
          initialIndex: initialIndex,
          animationDuration: animationDuration,
          length: length,
          vsync: rememberTickerProvider());
      mountable.onCancel.then((value) => result.dispose());
      return result;
    }, key: [initialIndex, animationDuration, length, key], listen: false);
  }
}
