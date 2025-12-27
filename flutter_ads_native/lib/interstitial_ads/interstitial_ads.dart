import 'dart:async';
import 'package:flutter/services.dart';
import 'interstitial_ads_platform_interface.dart';

class InterstitialAds {
  static const _eventChannel = EventChannel(
    'com.example.flutter_native_ad.interstitial_event_channel',
  );
  static StreamSubscription<dynamic>? _eventSubscription;

  // Callbacks
  static Function()? onInterstitialLoaded;
  static Function()? onInterstitialShown;
  static Function()? onInterstitialClosed;
  static Function(String error)? onInterstitialFailed;
  static Future<void> init({
    required List<String> interstitialAdUnitIds,
    Function()? onInterstitialLoaded,
    Function()? onInterstitialShown,
    Function()? onInterstitialClosed,
    Function(String error)? onInterstitialFailed,
  }) async {
    // Setup callbacks
    InterstitialAds.onInterstitialLoaded = onInterstitialLoaded;
    InterstitialAds.onInterstitialShown = onInterstitialShown;
    InterstitialAds.onInterstitialClosed = onInterstitialClosed;
    InterstitialAds.onInterstitialFailed = onInterstitialFailed;
    InterstitialAdsPlatform.instance.initAds(interstitialAdUnitIds);
    _startListening();
  }

  /// Start listening to ad events from native side
  static void _startListening() {
    _eventSubscription?.cancel();
    _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        if (event is Map) {
          final eventType = event['event'] as String?;
          final data = event['data'] as Map<dynamic, dynamic>?;

          switch (eventType) {
            case 'interstitial_loaded':
              onInterstitialLoaded?.call();
              break;
            case 'interstitial_shown':
              onInterstitialShown?.call();
              break;
            case 'interstitial_closed':
              onInterstitialClosed?.call();
              break;
            case 'interstitial_failed':
              final error = data?['error'] as String? ?? 'Unknown error';
              onInterstitialFailed?.call(error);
              break;
          }
        }
      },
      onError: (error) {
        print('Ads event stream error: $error');
      },
    );
  }

  /// Stop listening to ad events
  static void stopListening() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
  }

  /// Preload an interstitial ad.
  /// Call this before showing to ensure ad is ready.
  /// This is automatically called during init(), but you can call it manually
  /// to reload if needed (e.g., after showing an ad).
  static Future<void> loadInterstitial() async {
    try {
      await InterstitialAdsPlatform.instance.loadInterstitial();
    } catch (e) {
      print('Failed to load interstitial ad: $e');
    }
  }

  /// Reload interstitial ad if it's not ready.
  /// Useful for ensuring ad is available after showing.
  static Future<void> reloadInterstitialIfNeeded() async {
    final isReady = await isInterstitialReady();
    if (!isReady) {
      await loadInterstitial();
    }
  }

  /// Check if interstitial ad is ready to show.
  static Future<bool> isInterstitialReady() async {
    try {
      final result = await InterstitialAdsPlatform.instance
          .isInterstitialReady();
      return result as bool? ?? false;
    } catch (e) {
      print('Failed to check interstitial ad status: $e');
      return false;
    }
  }

  static Future<bool> showInterstitial() async {
    try {
      await InterstitialAdsPlatform.instance.showInterstitial();
      return true;
    } on PlatformException catch (e) {
      if (e.code == 'AD_NOT_READY') {
        return false;
      }
      print('Failed to show interstitial ad: ${e.message}');
      rethrow;
    } catch (e) {
      print('Failed to show interstitial ad: $e');
      return false;
    }
  }
}
