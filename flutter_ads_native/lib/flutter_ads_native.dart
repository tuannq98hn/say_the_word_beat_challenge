import 'flutter_ads_native_platform_interface.dart';

class FlutterAdsNative {
  Future<String?> getPlatformVersion() {
    return FlutterAdsNativePlatform.instance.getPlatformVersion();
  }
}
