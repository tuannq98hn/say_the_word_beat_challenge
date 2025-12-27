import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_ads_native_platform_interface.dart';

/// An implementation of [FlutterAdsNativePlatform] that uses method channels.
class MethodChannelFlutterAdsNative extends FlutterAdsNativePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_ads_native');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
