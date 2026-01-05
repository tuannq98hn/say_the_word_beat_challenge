import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'interstitial_ads_method_channel.dart';

abstract class InterstitialAdsPlatform extends PlatformInterface {
  /// Constructs a InterstitialAdsPlatform.
  InterstitialAdsPlatform() : super(token: _token);

  static final Object _token = Object();

  static InterstitialAdsPlatform _instance = MethodChannelInterstitialAds();

  /// The default instance of [InterstitialAdsPlatform] to use.
  ///
  /// Defaults to [MethodChannelInterstitialAds].
  static InterstitialAdsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [InterstitialAdsPlatform] when
  /// they register themselves.
  static set instance(InterstitialAdsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> initAds(List<String> interstitialAdUnitIds) {
    return _instance.initAds(interstitialAdUnitIds);
  }

  Future<void> loadInterstitial() {
    return _instance.loadInterstitial();
  }

  Future<bool> isInterstitialReady() {
    return _instance.isInterstitialReady();
  }

  Future<bool> showInterstitial() {
    return _instance.showInterstitial();
  }

  Future<bool> showInterstitialWithContext({
    String? screenClass,
    String? callerFunction,
  }) {
    return _instance.showInterstitialWithContext(
      screenClass: screenClass,
      callerFunction: callerFunction,
    );
  }
}
