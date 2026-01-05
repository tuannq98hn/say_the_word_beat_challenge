import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ads_native/rewarded_interstitial_ads/rewarded_interstitial_ads.dart';
import 'package:flutter_ads_native/rewarded_interstitial_ads/rewarded_interstitial_ads_platform_interface.dart';
import 'package:flutter_ads_native/rewarded_interstitial_ads/rewarded_interstitial_ads_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockRewardedInterstitialAdsPlatform
    with MockPlatformInterfaceMixin
    implements RewardedInterstitialAdsPlatform {
  bool initAdsCalled = false;
  bool loadRewardedInterstitialCalled = false;
  bool isRewardedInterstitialReadyCalled = false;
  bool showRewardedInterstitialCalled = false;

  List<String>? lastInitAdUnitIds;
  bool mockIsReady = true;
  bool mockShowSuccess = true;
  Exception? mockIsReadyException;

  @override
  Future<void> initAds(List<String> rewardedInterstitialAdUnitIds) async {
    initAdsCalled = true;
    lastInitAdUnitIds = rewardedInterstitialAdUnitIds;
  }

  @override
  Future<void> loadRewardedInterstitial() async {
    loadRewardedInterstitialCalled = true;
  }

  @override
  Future<bool> isRewardedInterstitialReady() {
    isRewardedInterstitialReadyCalled = true;
    if (mockIsReadyException != null) {
      return Future.error(mockIsReadyException!);
    }
    return Future.value(mockIsReady);
  }

  @override
  Future<bool> showRewardedInterstitial() {
    showRewardedInterstitialCalled = true;
    if (!mockShowSuccess) {
      return Future.error(
          PlatformException(code: 'AD_NOT_READY', message: 'Ad not ready'));
    }
    return Future.value(true);
  }

  @override
  Future<bool> showRewardedInterstitialWithContext({
    String? screenClass,
    String? callerFunction,
  }) {
    return showRewardedInterstitial();
  }
}

void main() {
  final RewardedInterstitialAdsPlatform initialPlatform =
      RewardedInterstitialAdsPlatform.instance;

  tearDown(() {
    // Reset platform instance after each test
    RewardedInterstitialAdsPlatform.instance = initialPlatform;
    // Clean up static callbacks
    RewardedInterstitialAds.onRewardedInterstitialLoaded = null;
    RewardedInterstitialAds.onRewardedInterstitialShown = null;
    RewardedInterstitialAds.onRewardedInterstitialClosed = null;
    RewardedInterstitialAds.onRewardedInterstitialFailed = null;
    RewardedInterstitialAds.onRewardedInterstitialEarned = null;
    RewardedInterstitialAds.stopListening();
  });

  test('$MethodChannelRewardedInterstitialAds is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelRewardedInterstitialAds>());
  });

  group('RewardedInterstitialAdsPlatform', () {
    test('initAds', () async {
      MockRewardedInterstitialAdsPlatform fakePlatform =
          MockRewardedInterstitialAdsPlatform();
      RewardedInterstitialAdsPlatform.instance = fakePlatform;

      await RewardedInterstitialAdsPlatform.instance
          .initAds(['test-id-1', 'test-id-2']);
      expect(fakePlatform.initAdsCalled, true);
      expect(fakePlatform.lastInitAdUnitIds, ['test-id-1', 'test-id-2']);
    });

    test('loadRewardedInterstitial', () async {
      MockRewardedInterstitialAdsPlatform fakePlatform =
          MockRewardedInterstitialAdsPlatform();
      RewardedInterstitialAdsPlatform.instance = fakePlatform;

      await RewardedInterstitialAdsPlatform.instance.loadRewardedInterstitial();
      expect(fakePlatform.loadRewardedInterstitialCalled, true);
    });

    test('isRewardedInterstitialReady', () async {
      MockRewardedInterstitialAdsPlatform fakePlatform =
          MockRewardedInterstitialAdsPlatform();
      RewardedInterstitialAdsPlatform.instance = fakePlatform;

      final result = await RewardedInterstitialAdsPlatform.instance
          .isRewardedInterstitialReady();
      expect(result, true);
      expect(fakePlatform.isRewardedInterstitialReadyCalled, true);
    });

    test('showRewardedInterstitial', () async {
      MockRewardedInterstitialAdsPlatform fakePlatform =
          MockRewardedInterstitialAdsPlatform();
      RewardedInterstitialAdsPlatform.instance = fakePlatform;

      final result = await RewardedInterstitialAdsPlatform.instance
          .showRewardedInterstitial();
      expect(result, true);
      expect(fakePlatform.showRewardedInterstitialCalled, true);
    });
  });

  group('RewardedInterstitialAds', () {
    test('isRewardedInterstitialReady returns true when platform returns true',
        () async {
      MockRewardedInterstitialAdsPlatform fakePlatform =
          MockRewardedInterstitialAdsPlatform();
      RewardedInterstitialAdsPlatform.instance = fakePlatform;

      final result = await RewardedInterstitialAds.isRewardedInterstitialReady();
      expect(result, true);
    });

    test('isRewardedInterstitialReady returns false when platform returns false',
        () async {
      MockRewardedInterstitialAdsPlatform fakePlatform =
          MockRewardedInterstitialAdsPlatform()..mockIsReady = false;
      RewardedInterstitialAdsPlatform.instance = fakePlatform;

      final result = await RewardedInterstitialAds.isRewardedInterstitialReady();
      expect(result, false);
    });

    test('isRewardedInterstitialReady returns false on exception', () async {
      MockRewardedInterstitialAdsPlatform fakePlatform =
          MockRewardedInterstitialAdsPlatform()
            ..mockIsReadyException = Exception('Test error');
      RewardedInterstitialAdsPlatform.instance = fakePlatform;

      final result = await RewardedInterstitialAds.isRewardedInterstitialReady();
      expect(result, false);
    });

    test('showRewardedInterstitial returns true on success', () async {
      MockRewardedInterstitialAdsPlatform fakePlatform =
          MockRewardedInterstitialAdsPlatform();
      RewardedInterstitialAdsPlatform.instance = fakePlatform;

      final result = await RewardedInterstitialAds.showRewardedInterstitial();
      expect(result, true);
    });

    test('showRewardedInterstitial returns false on AD_NOT_READY exception',
        () async {
      MockRewardedInterstitialAdsPlatform fakePlatform =
          MockRewardedInterstitialAdsPlatform()..mockShowSuccess = false;
      RewardedInterstitialAdsPlatform.instance = fakePlatform;

      final result = await RewardedInterstitialAds.showRewardedInterstitial();
      expect(result, false);
    });

    test('reloadRewardedInterstitialIfNeeded calls loadRewardedInterstitial when not ready',
        () async {
      MockRewardedInterstitialAdsPlatform fakePlatform =
          MockRewardedInterstitialAdsPlatform()..mockIsReady = false;
      RewardedInterstitialAdsPlatform.instance = fakePlatform;

      await RewardedInterstitialAds.reloadRewardedInterstitialIfNeeded();
      expect(fakePlatform.loadRewardedInterstitialCalled, true);
    });

    test('reloadRewardedInterstitialIfNeeded does not call loadRewardedInterstitial when ready',
        () async {
      MockRewardedInterstitialAdsPlatform fakePlatform =
          MockRewardedInterstitialAdsPlatform()..mockIsReady = true;
      RewardedInterstitialAdsPlatform.instance = fakePlatform;

      await RewardedInterstitialAds.reloadRewardedInterstitialIfNeeded();
      expect(fakePlatform.loadRewardedInterstitialCalled, false);
    });

    test('stopListening cancels event subscription', () {
      RewardedInterstitialAds.stopListening();
      // Should not throw, even if no subscription exists
      expect(() => RewardedInterstitialAds.stopListening(), returnsNormally);
    });
  });
}
