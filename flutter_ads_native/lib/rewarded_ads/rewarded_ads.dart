import 'dart:async';
import 'package:flutter/services.dart';
import 'rewarded_ads_platform_interface.dart';

class RewardedAds {
  static const _eventChannel = EventChannel(
    'com.example.flutter_native_ad.rewarded_event_channel',
  );
  static StreamSubscription<dynamic>? _eventSubscription;

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

  // Callbacks
  static Function()? onRewardedLoaded;
  static Function()? onRewardedShown;
  static Function()? onRewardedClosed;
  static Function(String error)? onRewardedFailed;
  static Function(String rewardType, int rewardAmount)? onRewardedEarned;

  static Future<void> init({
    required List<String> rewardedAdUnitIds,
    Function()? onRewardedLoaded,
    Function()? onRewardedShown,
    Function()? onRewardedClosed,
    Function(String error)? onRewardedFailed,
    Function(String rewardType, int rewardAmount)? onRewardedEarned,
  }) async {
    // Setup callbacks
    RewardedAds.onRewardedLoaded = onRewardedLoaded;
    RewardedAds.onRewardedShown = onRewardedShown;
    RewardedAds.onRewardedClosed = onRewardedClosed;
    RewardedAds.onRewardedFailed = onRewardedFailed;
    RewardedAds.onRewardedEarned = onRewardedEarned;
    RewardedAdsPlatform.instance.initAds(rewardedAdUnitIds);
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
                'RewardedAds: rewarded_earned event received - rewardType=$rewardType, rewardAmount=$rewardAmount',
              );
              print(
                'RewardedAds: onRewardedEarned callback is ${onRewardedEarned != null ? "set" : "null"}',
              );
              if (onRewardedEarned != null) {
                onRewardedEarned!.call(rewardType, rewardAmount);
                print('RewardedAds: onRewardedEarned callback called');
              } else {
                print(
                  'RewardedAds: ERROR - onRewardedEarned callback is null!',
                );
              }
              break;
          }
        }
      },
      onError: (error) {
        print('RewardedAds event stream error: $error');
      },
    );
  }

  /// Stop listening to ad events
  static void stopListening() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
  }

  /// Preload a rewarded ad.
  /// Call this before showing to ensure ad is ready.
  /// This is automatically called during init(), but you can call it manually
  /// to reload if needed (e.g., after showing an ad).
  static Future<void> loadRewarded() async {
    try {
      await RewardedAdsPlatform.instance.loadRewarded();
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
      final result = await RewardedAdsPlatform.instance.isRewardedReady();
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
  static Future<bool> showRewarded({
    String? screenClass,
    String? callerFunction,
  }) async {
    try {
      if (screenClass != null || callerFunction != null) {
        await RewardedAdsPlatform.instance.showRewardedWithContext(
          screenClass: screenClass,
          callerFunction: callerFunction,
        );
      } else {
        await RewardedAdsPlatform.instance.showRewarded();
      }
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
}
