import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'rewarded_interstitial_ads_method_channel.dart';

abstract class RewardedInterstitialAdsPlatform extends PlatformInterface {
  /// Constructs a RewardedInterstitialAdsPlatform.
  RewardedInterstitialAdsPlatform() : super(token: _token);

  static final Object _token = Object();

  static RewardedInterstitialAdsPlatform _instance =
      MethodChannelRewardedInterstitialAds();

  /// The default instance of [RewardedInterstitialAdsPlatform] to use.
  ///
  /// Defaults to [MethodChannelRewardedInterstitialAds].
  static RewardedInterstitialAdsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [RewardedInterstitialAdsPlatform] when
  /// they register themselves.
  static set instance(RewardedInterstitialAdsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> initAds(List<String> rewardedInterstitialAdUnitIds) {
    return _instance.initAds(rewardedInterstitialAdUnitIds);
  }

  Future<void> loadRewardedInterstitial() {
    return _instance.loadRewardedInterstitial();
  }

  Future<bool> isRewardedInterstitialReady() {
    return _instance.isRewardedInterstitialReady();
  }

  Future<bool> showRewardedInterstitial() {
    return _instance.showRewardedInterstitial();
  }

  Future<bool> showRewardedInterstitialWithContext({
    String? screenClass,
    String? callerFunction,
  }) {
    return _instance.showRewardedInterstitialWithContext(
      screenClass: screenClass,
      callerFunction: callerFunction,
    );
  }
}
