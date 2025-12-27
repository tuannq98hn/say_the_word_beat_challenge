import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ads_native/flutter_ads_native.dart';
import 'package:flutter_ads_native/flutter_ads_native_platform_interface.dart';
import 'package:flutter_ads_native/flutter_ads_native_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterAdsNativePlatform
    with MockPlatformInterfaceMixin
    implements FlutterAdsNativePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterAdsNativePlatform initialPlatform = FlutterAdsNativePlatform.instance;

  test('$MethodChannelFlutterAdsNative is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterAdsNative>());
  });

  test('getPlatformVersion', () async {
    FlutterAdsNative flutterAdsNativePlugin = FlutterAdsNative();
    MockFlutterAdsNativePlatform fakePlatform = MockFlutterAdsNativePlatform();
    FlutterAdsNativePlatform.instance = fakePlatform;

  });
}
