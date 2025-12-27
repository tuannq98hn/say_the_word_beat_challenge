import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'rewarded_ads_platform_interface.dart';

/// An implementation of [RewardedAdsPlatform] that uses method channels.
class MethodChannelRewardedAds extends RewardedAdsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel(
    'com.example.flutter_native_ad.rewarded_method_channel',
  );

  @override
  Future<void> initAds(List<String> rewardedAdUnitIds) async {
    await methodChannel.invokeMethod('ads_init', {
      "rewardedAdUnitIds": rewardedAdUnitIds,
    });
  }

  @override
  Future<void> loadRewarded() async {
    await methodChannel.invokeMethod('ads_load_rewarded');
  }

  @override
  Future<bool> isRewardedReady() async {
    final result = await methodChannel.invokeMethod<bool>(
      'ads_is_rewarded_ready',
    );
    return result ?? false;
  }

  @override
  Future<bool> showRewarded() async {
    final result = await methodChannel.invokeMethod<bool>('ads_show_rewarded');
    return result ?? false;
  }
}
