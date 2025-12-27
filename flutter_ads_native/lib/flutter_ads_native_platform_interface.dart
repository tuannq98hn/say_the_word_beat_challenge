import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_ads_native_method_channel.dart';

abstract class FlutterAdsNativePlatform extends PlatformInterface {
  /// Constructs a FlutterAdsNativePlatform.
  FlutterAdsNativePlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterAdsNativePlatform _instance = MethodChannelFlutterAdsNative();

  /// The default instance of [FlutterAdsNativePlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterAdsNative].
  static FlutterAdsNativePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterAdsNativePlatform] when
  /// they register themselves.
  static set instance(FlutterAdsNativePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    return _instance.getPlatformVersion();
  }
}
