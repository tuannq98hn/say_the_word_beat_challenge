import 'package:flutter/services.dart';
import 'package:flutter_ads_native/rewarded_ads/rewarded_ads_method_channel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelRewardedAds platform = MethodChannelRewardedAds();
  const MethodChannel channel = MethodChannel(
    'com.example.flutter_native_ad.rewarded_method_channel',
  );

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'ads_init':
              return null;
            case 'ads_load_rewarded':
              return null;
            case 'ads_is_rewarded_ready':
              return true;
            case 'ads_show_rewarded':
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

  group('MethodChannelRewardedAds', () {
    test('initAds', () async {
      await platform.initAds(['test-id-1', 'test-id-2']);
      // Should complete without error
      expect(platform.initAds(['test-id-1']), completes);
    });

    test('loadRewarded', () async {
      await platform.loadRewarded();
      // Should complete without error
      expect(platform.loadRewarded(), completes);
    });

    test('isRewardedReady returns true', () async {
      final result = await platform.isRewardedReady();
      expect(result, true);
    });

    test('isRewardedReady returns false when native returns false', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'ads_is_rewarded_ready') {
              return false;
            }
            return null;
          });

      final result = await platform.isRewardedReady();
      expect(result, false);
    });

    test('isRewardedReady returns false when native returns null', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'ads_is_rewarded_ready') {
              return null;
            }
            return null;
          });

      final result = await platform.isRewardedReady();
      expect(result, false);
    });

    test('showRewarded returns true', () async {
      final result = await platform.showRewarded();
      expect(result, true);
    });

    test('showRewarded returns false when native returns false', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'ads_show_rewarded') {
              return false;
            }
            return null;
          });

      final result = await platform.showRewarded();
      expect(result, false);
    });

    test('showRewarded returns false when native returns null', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'ads_show_rewarded') {
              return null;
            }
            return null;
          });

      final result = await platform.showRewarded();
      expect(result, false);
    });
  });
}
