import 'dart:async';
import 'package:flutter/services.dart';
import 'rewarded_interstitial_ads_platform_interface.dart';

class RewardedInterstitialAds {
  static const _eventChannel = EventChannel(
    'com.example.flutter_native_ad.rewarded_interstitial_event_channel',
  );
  static StreamSubscription<dynamic>? _eventSubscription;

  // Callbacks
  static Function()? onRewardedInterstitialLoaded;
  static Function()? onRewardedInterstitialShown;
  static Function()? onRewardedInterstitialClosed;
  static Function(String error)? onRewardedInterstitialFailed;
  static Function(String rewardType, int rewardAmount)?
  onRewardedInterstitialEarned;

  static Future<void> init({
    required List<String> rewardedInterstitialAdUnitIds,
    Function()? onRewardedInterstitialLoaded,
    Function()? onRewardedInterstitialShown,
    Function()? onRewardedInterstitialClosed,
    Function(String error)? onRewardedInterstitialFailed,
    Function(String rewardType, int rewardAmount)? onRewardedInterstitialEarned,
  }) async {
    // Setup callbacks
    RewardedInterstitialAds.onRewardedInterstitialLoaded =
        onRewardedInterstitialLoaded;
    RewardedInterstitialAds.onRewardedInterstitialShown =
        onRewardedInterstitialShown;
    RewardedInterstitialAds.onRewardedInterstitialClosed =
        onRewardedInterstitialClosed;
    RewardedInterstitialAds.onRewardedInterstitialFailed =
        onRewardedInterstitialFailed;
    RewardedInterstitialAds.onRewardedInterstitialEarned =
        onRewardedInterstitialEarned;
    RewardedInterstitialAdsPlatform.instance.initAds(
      rewardedInterstitialAdUnitIds,
    );
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
                'RewardedInterstitialAds: rewarded_interstitial_earned event received - rewardType=$rewardType, rewardAmount=$rewardAmount',
              );
              if (onRewardedInterstitialEarned != null) {
                onRewardedInterstitialEarned!.call(rewardType, rewardAmount);
                print(
                  'RewardedInterstitialAds: onRewardedInterstitialEarned callback called',
                );
              } else {
                print(
                  'RewardedInterstitialAds: ERROR - onRewardedInterstitialEarned callback is null!',
                );
              }
              break;
          }
        }
      },
      onError: (error) {
        print('RewardedInterstitialAds event stream error: $error');
      },
    );
  }

  /// Stop listening to ad events
  static void stopListening() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
  }

  /// Preload a rewarded interstitial ad.
  /// Call this before showing to ensure ad is ready.
  /// This is automatically called during init(), but you can call it manually
  /// to reload if needed (e.g., after showing an ad).
  static Future<void> loadRewardedInterstitial() async {
    try {
      await RewardedInterstitialAdsPlatform.instance.loadRewardedInterstitial();
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
      final result = await RewardedInterstitialAdsPlatform.instance
          .isRewardedInterstitialReady();
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
  static Future<bool> showRewardedInterstitial({
    String? screenClass,
    String? callerFunction,
  }) async {
    try {
      if (screenClass != null || callerFunction != null) {
        await RewardedInterstitialAdsPlatform.instance
            .showRewardedInterstitialWithContext(
          screenClass: screenClass,
          callerFunction: callerFunction,
        );
      } else {
        await RewardedInterstitialAdsPlatform.instance.showRewardedInterstitial();
      }
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
