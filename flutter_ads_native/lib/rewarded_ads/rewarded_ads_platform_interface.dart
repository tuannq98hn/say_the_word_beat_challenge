import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'rewarded_ads_method_channel.dart';

abstract class RewardedAdsPlatform extends PlatformInterface {
  /// Constructs a RewardedAdsPlatform.
  RewardedAdsPlatform() : super(token: _token);

  static final Object _token = Object();

  static RewardedAdsPlatform _instance = MethodChannelRewardedAds();

  /// The default instance of [RewardedAdsPlatform] to use.
  ///
  /// Defaults to [MethodChannelRewardedAds].
  static RewardedAdsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [RewardedAdsPlatform] when
  /// they register themselves.
  static set instance(RewardedAdsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> initAds(List<String> rewardedAdUnitIds) {
    return _instance.initAds(rewardedAdUnitIds);
  }

  Future<void> loadRewarded() {
    return _instance.loadRewarded();
  }

  Future<bool> isRewardedReady() {
    return _instance.isRewardedReady();
  }

  Future<bool> showRewarded() {
    return _instance.showRewarded();
  }

  Future<bool> showRewardedWithContext({
    String? screenClass,
    String? callerFunction,
  }) {
    return _instance.showRewardedWithContext(
      screenClass: screenClass,
      callerFunction: callerFunction,
    );
  }
}
