import 'dart:async';

import 'package:flutter/services.dart';

/// Native ads service for interacting with Android ads module via MethodChannel and EventChannel.
///
/// This service provides a simple interface to:
/// - Initialize ads
/// - Load and show interstitial ads
/// - Load and show rewarded ads
/// - Listen to ad events (loaded, shown, closed, failed, earned reward)
///
/// The actual ad implementation (AdMob, MAX, etc.) is handled on the native side.
class NativeAds {
  static const _channel = MethodChannel('com.rbxmaster.callsanta/ads');
  static const _eventChannel =
      EventChannel('com.rbxmaster.callsanta/ads_events');

  static StreamSubscription<dynamic>? _eventSubscription;

  // Callbacks
  static Function()? onInterstitialLoaded;
  static Function()? onInterstitialShown;
  static Function()? onInterstitialClosed;
  static Function(String error)? onInterstitialFailed;

  static Function()? onRewardedLoaded;
  static Function()? onRewardedShown;
  static Function()? onRewardedClosed;
  static Function(String error)? onRewardedFailed;
  static Function(String rewardType, int rewardAmount)? onRewardedEarned;

  static Function()? onRewardedInterstitialLoaded;
  static Function()? onRewardedInterstitialShown;
  static Function()? onRewardedInterstitialClosed;
  static Function(String error)? onRewardedInterstitialFailed;
  static Function(String rewardType, int rewardAmount)? onRewardedInterstitialEarned;

  // Flag to track if rewarded ad is for unlocking wallpaper (not earning points)
  static bool _isUnlockingWallpaper = false;

  /// Set flag to indicate rewarded ad is for unlocking wallpaper (not earning points)
  static void setUnlockingWallpaper(bool value) {
    _isUnlockingWallpaper = value;
  }

  /// Check if rewarded ad is for unlocking wallpaper
  static bool isUnlockingWallpaper() {
    return _isUnlockingWallpaper;
  }

  /// Initialize ads and automatically preload all ad types.
  /// Should be called early in app lifecycle (e.g., in main() or app initialization).
  ///
  /// This method will:
  /// - Initialize the ads SDK
  /// - Automatically preload both interstitial and rewarded ads
  /// - Set up event listeners for ad callbacks
  ///
  /// [interstitialAdUnitIds] - Optional list of interstitial ad unit IDs to rotate
  /// [rewardedAdUnitIds] - Optional list of rewarded ad unit IDs to rotate
  /// [rewardedInterstitialAdUnitIds] - Optional list of rewarded interstitial ad unit IDs to rotate
  /// [onInterstitialLoaded] - Called when interstitial ad finishes loading
  /// [onInterstitialShown] - Called when interstitial ad is shown
  /// [onInterstitialClosed] - Called when interstitial ad is closed
  /// [onInterstitialFailed] - Called when interstitial ad fails to load or show
  /// [onRewardedLoaded] - Called when rewarded ad finishes loading
  /// [onRewardedShown] - Called when rewarded ad is shown
  /// [onRewardedClosed] - Called when rewarded ad is closed
  /// [onRewardedFailed] - Called when rewarded ad fails to load or show
  /// [onRewardedEarned] - Called when user earns reward (with rewardType and rewardAmount)
  /// [onRewardedInterstitialLoaded] - Called when rewarded interstitial ad finishes loading
  /// [onRewardedInterstitialShown] - Called when rewarded interstitial ad is shown
  /// [onRewardedInterstitialClosed] - Called when rewarded interstitial ad is closed
  /// [onRewardedInterstitialFailed] - Called when rewarded interstitial ad fails to load or show
  /// [onRewardedInterstitialEarned] - Called when user earns reward from rewarded interstitial (with rewardType and rewardAmount)
  static Future<void> init({
    List<String>? interstitialAdUnitIds,
    List<String>? rewardedAdUnitIds,
    List<String>? rewardedInterstitialAdUnitIds,
    Function()? onInterstitialLoaded,
    Function()? onInterstitialShown,
    Function()? onInterstitialClosed,
    Function(String error)? onInterstitialFailed,
    Function()? onRewardedLoaded,
    Function()? onRewardedShown,
    Function()? onRewardedClosed,
    Function(String error)? onRewardedFailed,
    Function(String rewardType, int rewardAmount)? onRewardedEarned,
    Function()? onRewardedInterstitialLoaded,
    Function()? onRewardedInterstitialShown,
    Function()? onRewardedInterstitialClosed,
    Function(String error)? onRewardedInterstitialFailed,
    Function(String rewardType, int rewardAmount)? onRewardedInterstitialEarned,
  }) async {
    // Setup callbacks
    NativeAds.onInterstitialLoaded = onInterstitialLoaded;
    NativeAds.onInterstitialShown = onInterstitialShown;
    NativeAds.onInterstitialClosed = onInterstitialClosed;
    NativeAds.onInterstitialFailed = onInterstitialFailed;
    NativeAds.onRewardedLoaded = onRewardedLoaded;
    NativeAds.onRewardedShown = onRewardedShown;
    NativeAds.onRewardedClosed = onRewardedClosed;
    NativeAds.onRewardedFailed = onRewardedFailed;
    NativeAds.onRewardedEarned = onRewardedEarned;
    NativeAds.onRewardedInterstitialLoaded = onRewardedInterstitialLoaded;
    NativeAds.onRewardedInterstitialShown = onRewardedInterstitialShown;
    NativeAds.onRewardedInterstitialClosed = onRewardedInterstitialClosed;
    NativeAds.onRewardedInterstitialFailed = onRewardedInterstitialFailed;
    NativeAds.onRewardedInterstitialEarned = onRewardedInterstitialEarned;

    // Start listening to events
    _startListening();

    try {
      // Initialize and automatically preload all ads
      // Pass interstitial and rewarded ad unit IDs if provided
      final arguments = <String, dynamic>{};
      if (interstitialAdUnitIds != null && interstitialAdUnitIds.isNotEmpty) {
        arguments['interstitialAdUnitIds'] = interstitialAdUnitIds;
      }
      if (rewardedAdUnitIds != null && rewardedAdUnitIds.isNotEmpty) {
        arguments['rewardedAdUnitIds'] = rewardedAdUnitIds;
      }
      if (rewardedInterstitialAdUnitIds != null && rewardedInterstitialAdUnitIds.isNotEmpty) {
        arguments['rewardedInterstitialAdUnitIds'] = rewardedInterstitialAdUnitIds;
      }
      await _channel.invokeMethod(
          'ads_init', arguments.isEmpty ? null : arguments);
      final interInfo = interstitialAdUnitIds != null && interstitialAdUnitIds.isNotEmpty 
          ? " with ${interstitialAdUnitIds.length} interstitial ad unit IDs" 
          : "";
      final rewardInfo = rewardedAdUnitIds != null && rewardedAdUnitIds.isNotEmpty 
          ? " with ${rewardedAdUnitIds.length} rewarded ad unit IDs" 
          : "";
      final rewardInterInfo = rewardedInterstitialAdUnitIds != null && rewardedInterstitialAdUnitIds.isNotEmpty 
          ? " with ${rewardedInterstitialAdUnitIds.length} rewarded interstitial ad unit IDs" 
          : "";
      print('Ads initialized and preloading started$interInfo$rewardInfo$rewardInterInfo');
    } catch (e) {
      // Handle error - ads may not be available in debug mode
      print('Failed to initialize ads: $e');
    }
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
            case 'rewarded_loaded':
              onRewardedLoaded?.call();
              break;
            case 'rewarded_shown':
              onRewardedShown?.call();
              break;
            case 'rewarded_closed':
              onRewardedClosed?.call();
              break;
            case 'rewarded_failed':
              final error = data?['error'] as String? ?? 'Unknown error';
              onRewardedFailed?.call(error);
              break;
            case 'rewarded_earned':
              final rewardType = data?['rewardType'] as String? ?? '';
              final rewardAmount = data?['rewardAmount'] as int? ?? 0;
              print(
                  'NativeAds: rewarded_earned event received - rewardType=$rewardType, rewardAmount=$rewardAmount');
              print(
                  'NativeAds: onRewardedEarned callback is ${onRewardedEarned != null ? "set" : "null"}');
              if (onRewardedEarned != null) {
                onRewardedEarned!.call(rewardType, rewardAmount);
                print('NativeAds: onRewardedEarned callback called');
              } else {
                print('NativeAds: ERROR - onRewardedEarned callback is null!');
              }
              break;
            case 'rewarded_interstitial_loaded':
              onRewardedInterstitialLoaded?.call();
              break;
            case 'rewarded_interstitial_shown':
              onRewardedInterstitialShown?.call();
              break;
            case 'rewarded_interstitial_closed':
              onRewardedInterstitialClosed?.call();
              break;
            case 'rewarded_interstitial_failed':
              final error = data?['error'] as String? ?? 'Unknown error';
              onRewardedInterstitialFailed?.call(error);
              break;
            case 'rewarded_interstitial_earned':
              final rewardType = data?['rewardType'] as String? ?? '';
              final rewardAmount = data?['rewardAmount'] as int? ?? 0;
              print(
                  'NativeAds: rewarded_interstitial_earned event received - rewardType=$rewardType, rewardAmount=$rewardAmount');
              if (onRewardedInterstitialEarned != null) {
                onRewardedInterstitialEarned!.call(rewardType, rewardAmount);
                print('NativeAds: onRewardedInterstitialEarned callback called');
              } else {
                print('NativeAds: ERROR - onRewardedInterstitialEarned callback is null!');
              }
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
      await _channel.invokeMethod('ads_load_interstitial');
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
      final result = await _channel.invokeMethod('ads_is_interstitial_ready');
      return result as bool? ?? false;
    } catch (e) {
      print('Failed to check interstitial ad status: $e');
      return false;
    }
  }

  /// Show an interstitial ad if ready.
  /// Returns true if ad was shown, false if ad is not ready.
  /// Throws exception if there's an error.
  ///
  /// Note: After showing, the ad will be automatically reloaded in the background.
  static Future<bool> showInterstitial() async {
    try {
      await _channel.invokeMethod('ads_show_interstitial');
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

  /// Preload a rewarded ad.
  /// Call this before showing to ensure ad is ready.
  /// This is automatically called during init(), but you can call it manually
  /// to reload if needed (e.g., after showing an ad).
  static Future<void> loadRewarded() async {
    try {
      await _channel.invokeMethod('ads_load_rewarded');
    } catch (e) {
      print('Failed to load rewarded ad: $e');
    }
  }

  /// Reload rewarded ad if it's not ready.
  /// Useful for ensuring ad is available after showing.
  static Future<void> reloadRewardedIfNeeded() async {
    final isReady = await isRewardedReady();
    if (!isReady) {
      await loadRewarded();
    }
  }

  /// Check if rewarded ad is ready to show.
  static Future<bool> isRewardedReady() async {
    try {
      final result = await _channel.invokeMethod('ads_is_rewarded_ready');
      return result as bool? ?? false;
    } catch (e) {
      print('Failed to check rewarded ad status: $e');
      return false;
    }
  }

  /// Show a rewarded ad if ready.
  /// Returns true if ad was shown, false if ad is not ready.
  /// Throws exception if there's an error.
  ///
  /// Note: After showing, the ad will be automatically reloaded in the background.
  static Future<bool> showRewarded() async {
    try {
      await _channel.invokeMethod('ads_show_rewarded');
      return true;
    } on PlatformException catch (e) {
      if (e.code == 'AD_NOT_READY') {
        return false;
      }
      print('Failed to show rewarded ad: ${e.message}');
      rethrow;
    } catch (e) {
      print('Failed to show rewarded ad: $e');
      return false;
    }
  }

  /// Wait for ads to be ready (useful after init).
  /// [timeoutSeconds] - Maximum time to wait (default: 10 seconds)
  /// Returns true if both ads are ready, false if timeout
  static Future<bool> waitForAdsReady({
    int timeoutSeconds = 10,
  }) async {
    final timeout = Duration(seconds: timeoutSeconds);
    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < timeout) {
      final interstitialReady = await isInterstitialReady();
      final rewardedReady = await isRewardedReady();

      if (interstitialReady && rewardedReady) {
        return true;
      }

      // Wait a bit before checking again
      await Future.delayed(const Duration(milliseconds: 500));
    }

    return false;
  }

  /// Preload a rewarded interstitial ad.
  /// Call this before showing to ensure ad is ready.
  /// This is automatically called during init(), but you can call it manually
  /// to reload if needed (e.g., after showing an ad).
  static Future<void> loadRewardedInterstitial() async {
    try {
      await _channel.invokeMethod('ads_load_rewarded_interstitial');
    } catch (e) {
      print('Failed to load rewarded interstitial ad: $e');
    }
  }

  /// Reload rewarded interstitial ad if it's not ready.
  /// Useful for ensuring ad is available after showing.
  static Future<void> reloadRewardedInterstitialIfNeeded() async {
    final isReady = await isRewardedInterstitialReady();
    if (!isReady) {
      await loadRewardedInterstitial();
    }
  }

  /// Check if rewarded interstitial ad is ready to show.
  static Future<bool> isRewardedInterstitialReady() async {
    try {
      final result = await _channel.invokeMethod('ads_is_rewarded_interstitial_ready');
      return result as bool? ?? false;
    } catch (e) {
      print('Failed to check rewarded interstitial ad status: $e');
      return false;
    }
  }

  /// Show a rewarded interstitial ad if ready.
  /// Returns true if ad was shown, false if ad is not ready.
  /// Throws exception if there's an error.
  ///
  /// Note: After showing, the ad will be automatically reloaded in the background.
  static Future<bool> showRewardedInterstitial() async {
    try {
      await _channel.invokeMethod('ads_show_rewarded_interstitial');
      return true;
    } on PlatformException catch (e) {
      if (e.code == 'AD_NOT_READY') {
        return false;
      }
      print('Failed to show rewarded interstitial ad: ${e.message}');
      rethrow;
    } catch (e) {
      print('Failed to show rewarded interstitial ad: $e');
      return false;
    }
  }
}
