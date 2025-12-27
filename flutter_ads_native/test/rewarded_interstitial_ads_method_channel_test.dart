import 'package:flutter/services.dart';
import 'package:flutter_ads_native/rewarded_interstitial_ads/rewarded_interstitial_ads_method_channel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelRewardedInterstitialAds platform =
      MethodChannelRewardedInterstitialAds();
  const MethodChannel channel = MethodChannel(
    'com.example.flutter_native_ad.rewarded_interstitial_method_channel',
  );

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'ads_init':
              return null;
            case 'ads_load_rewarded_interstitial':
              return null;
            case 'ads_is_rewarded_interstitial_ready':
              return true;
            case 'ads_show_rewarded_interstitial':
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

  group('MethodChannelRewardedInterstitialAds', () {
    test('initAds', () async {
      await platform.initAds(['test-id-1', 'test-id-2']);
      // Should complete without error
      expect(platform.initAds(['test-id-1']), completes);
    });

    test('loadRewardedInterstitial', () async {
      await platform.loadRewardedInterstitial();
      // Should complete without error
      expect(platform.loadRewardedInterstitial(), completes);
    });

    test('isRewardedInterstitialReady returns true', () async {
      final result = await platform.isRewardedInterstitialReady();
      expect(result, true);
    });

    test(
      'isRewardedInterstitialReady returns false when native returns false',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'ads_is_rewarded_interstitial_ready') {
                return false;
              }
              return null;
            });

        final result = await platform.isRewardedInterstitialReady();
        expect(result, false);
      },
    );

    test(
      'isRewardedInterstitialReady returns false when native returns null',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'ads_is_rewarded_interstitial_ready') {
                return null;
              }
              return null;
            });

        final result = await platform.isRewardedInterstitialReady();
        expect(result, false);
      },
    );

    test('showRewardedInterstitial returns true', () async {
      final result = await platform.showRewardedInterstitial();
      expect(result, true);
    });

    test(
      'showRewardedInterstitial returns false when native returns false',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'ads_show_rewarded_interstitial') {
                return false;
              }
              return null;
            });

        final result = await platform.showRewardedInterstitial();
        expect(result, false);
      },
    );

    test(
      'showRewardedInterstitial returns false when native returns null',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'ads_show_rewarded_interstitial') {
                return null;
              }
              return null;
            });

        final result = await platform.showRewardedInterstitial();
        expect(result, false);
      },
    );
  });
}
