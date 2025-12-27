import 'package:flutter/services.dart';
import 'package:flutter_ads_native/interstitial_ads/interstitial_ads_method_channel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelInterstitialAds platform = MethodChannelInterstitialAds();
  const MethodChannel channel = MethodChannel(
    'com.example.flutter_native_ad.interstitial_method_channel',
  );

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'ads_init':
              return null;
            case 'ads_load_interstitial':
              return null;
            case 'ads_is_interstitial_ready':
              return true;
            case 'ads_show_interstitial':
              return true;
            default:
              return null;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('MethodChannelInterstitialAds', () {
    test('initAds', () async {
      await platform.initAds(['test-id-1', 'test-id-2']);
      // Should complete without error
      expect(platform.initAds(['test-id-1']), completes);
    });

    test('loadInterstitial', () async {
      await platform.loadInterstitial();
      // Should complete without error
      expect(platform.loadInterstitial(), completes);
    });

    test('isInterstitialReady returns true', () async {
      final result = await platform.isInterstitialReady();
      expect(result, true);
    });

    test(
      'isInterstitialReady returns false when native returns false',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'ads_is_interstitial_ready') {
                return false;
              }
              return null;
            });

        final result = await platform.isInterstitialReady();
        expect(result, false);
      },
    );

    test(
      'isInterstitialReady returns false when native returns null',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'ads_is_interstitial_ready') {
                return null;
              }
              return null;
            });

        final result = await platform.isInterstitialReady();
        expect(result, false);
      },
    );

    test('showInterstitial returns true', () async {
      final result = await platform.showInterstitial();
      expect(result, true);
    });

    test('showInterstitial returns false when native returns false', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'ads_show_interstitial') {
              return false;
            }
            return null;
          });

      final result = await platform.showInterstitial();
      expect(result, false);
    });

    test('showInterstitial returns false when native returns null', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'ads_show_interstitial') {
              return null;
            }
            return null;
          });

      final result = await platform.showInterstitial();
      expect(result, false);
    });
  });
}
