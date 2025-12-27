import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'interstitial_ads_platform_interface.dart';

/// An implementation of [InterstitialAdsPlatform] that uses method channels.
class MethodChannelInterstitialAds extends InterstitialAdsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel(
    'com.example.flutter_native_ad.interstitial_method_channel',
  );

  @override
  Future<void> initAds(List<String> interstitialAdUnitIds) async {
    await methodChannel.invokeMethod('ads_init', {
      "interstitialAdUnitIds": interstitialAdUnitIds,
    });
  }

  @override
  Future<void> loadInterstitial() async {
    await methodChannel.invokeMethod('ads_load_interstitial');
  }

  @override
  Future<bool> isInterstitialReady() async {
    final result = await methodChannel.invokeMethod<bool>(
      'ads_is_interstitial_ready',
    );
    return result ?? false;
  }

  @override
  Future<bool> showInterstitial() async {
    final result = await methodChannel.invokeMethod<bool>(
      'ads_show_interstitial',
    );
    return result ?? false;
  }
}
