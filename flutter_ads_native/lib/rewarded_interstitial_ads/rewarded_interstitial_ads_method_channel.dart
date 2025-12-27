import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'rewarded_interstitial_ads_platform_interface.dart';

/// An implementation of [RewardedInterstitialAdsPlatform] that uses method channels.
class MethodChannelRewardedInterstitialAds
    extends RewardedInterstitialAdsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel(
    'com.example.flutter_native_ad.rewarded_interstitial_method_channel',
  );

  @override
  Future<void> initAds(List<String> rewardedInterstitialAdUnitIds) async {
    await methodChannel.invokeMethod('ads_init', {
      "rewardedInterstitialAdUnitIds": rewardedInterstitialAdUnitIds,
    });
  }

  @override
  Future<void> loadRewardedInterstitial() async {
    await methodChannel.invokeMethod('ads_load_rewarded_interstitial');
  }

  @override
  Future<bool> isRewardedInterstitialReady() async {
    final result = await methodChannel.invokeMethod<bool>(
      'ads_is_rewarded_interstitial_ready',
    );
    return result ?? false;
  }

  @override
  Future<bool> showRewardedInterstitial() async {
    final result = await methodChannel.invokeMethod<bool>(
      'ads_show_rewarded_interstitial',
    );
    return result ?? false;
  }
}
