import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ads_native/rewarded_ads/rewarded_ads.dart';
import 'package:flutter_ads_native/rewarded_ads/rewarded_ads_platform_interface.dart';
import 'package:flutter_ads_native/rewarded_ads/rewarded_ads_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockRewardedAdsPlatform
    with MockPlatformInterfaceMixin
    implements RewardedAdsPlatform {
  bool initAdsCalled = false;
  bool loadRewardedCalled = false;
  bool isRewardedReadyCalled = false;
  bool showRewardedCalled = false;

  List<String>? lastInitAdUnitIds;
  bool mockIsReady = true;
  bool mockShowSuccess = true;
  Exception? mockIsReadyException;

  @override
  Future<void> initAds(List<String> rewardedAdUnitIds) async {
    initAdsCalled = true;
    lastInitAdUnitIds = rewardedAdUnitIds;
  }

  @override
  Future<void> loadRewarded() async {
    loadRewardedCalled = true;
  }

  @override
  Future<bool> isRewardedReady() {
    isRewardedReadyCalled = true;
    if (mockIsReadyException != null) {
      return Future.error(mockIsReadyException!);
    }
    return Future.value(mockIsReady);
  }

  @override
  Future<bool> showRewarded() {
    showRewardedCalled = true;
    if (!mockShowSuccess) {
      return Future.error(
          PlatformException(code: 'AD_NOT_READY', message: 'Ad not ready'));
    }
    return Future.value(true);
  }
}

void main() {
  final RewardedAdsPlatform initialPlatform = RewardedAdsPlatform.instance;

  tearDown(() {
    // Reset platform instance after each test
    RewardedAdsPlatform.instance = initialPlatform;
    // Clean up static callbacks
    RewardedAds.onRewardedLoaded = null;
    RewardedAds.onRewardedShown = null;
    RewardedAds.onRewardedClosed = null;
    RewardedAds.onRewardedFailed = null;
    RewardedAds.onRewardedEarned = null;
    RewardedAds.stopListening();
    RewardedAds.setUnlockingWallpaper(false);
  });

  test('$MethodChannelRewardedAds is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelRewardedAds>());
  });

  group('RewardedAdsPlatform', () {
    test('initAds', () async {
      MockRewardedAdsPlatform fakePlatform = MockRewardedAdsPlatform();
      RewardedAdsPlatform.instance = fakePlatform;

      await RewardedAdsPlatform.instance.initAds(['test-id-1', 'test-id-2']);
      expect(fakePlatform.initAdsCalled, true);
      expect(fakePlatform.lastInitAdUnitIds, ['test-id-1', 'test-id-2']);
    });

    test('loadRewarded', () async {
      MockRewardedAdsPlatform fakePlatform = MockRewardedAdsPlatform();
      RewardedAdsPlatform.instance = fakePlatform;

      await RewardedAdsPlatform.instance.loadRewarded();
      expect(fakePlatform.loadRewardedCalled, true);
    });

    test('isRewardedReady', () async {
      MockRewardedAdsPlatform fakePlatform = MockRewardedAdsPlatform();
      RewardedAdsPlatform.instance = fakePlatform;

      final result = await RewardedAdsPlatform.instance.isRewardedReady();
      expect(result, true);
      expect(fakePlatform.isRewardedReadyCalled, true);
    });

    test('showRewarded', () async {
      MockRewardedAdsPlatform fakePlatform = MockRewardedAdsPlatform();
      RewardedAdsPlatform.instance = fakePlatform;

      final result = await RewardedAdsPlatform.instance.showRewarded();
      expect(result, true);
      expect(fakePlatform.showRewardedCalled, true);
    });
  });

  group('RewardedAds', () {
    test('isRewardedReady returns true when platform returns true', () async {
      MockRewardedAdsPlatform fakePlatform = MockRewardedAdsPlatform();
      RewardedAdsPlatform.instance = fakePlatform;

      final result = await RewardedAds.isRewardedReady();
      expect(result, true);
    });

    test('isRewardedReady returns false when platform returns false',
        () async {
      MockRewardedAdsPlatform fakePlatform = MockRewardedAdsPlatform()
        ..mockIsReady = false;
      RewardedAdsPlatform.instance = fakePlatform;

      final result = await RewardedAds.isRewardedReady();
      expect(result, false);
    });

    test('isRewardedReady returns false on exception', () async {
      MockRewardedAdsPlatform fakePlatform = MockRewardedAdsPlatform()
        ..mockIsReadyException = Exception('Test error');
      RewardedAdsPlatform.instance = fakePlatform;

      final result = await RewardedAds.isRewardedReady();
      expect(result, false);
    });

    test('showRewarded returns true on success', () async {
      MockRewardedAdsPlatform fakePlatform = MockRewardedAdsPlatform();
      RewardedAdsPlatform.instance = fakePlatform;

      final result = await RewardedAds.showRewarded();
      expect(result, true);
    });

    test('showRewarded returns false on AD_NOT_READY exception', () async {
      MockRewardedAdsPlatform fakePlatform = MockRewardedAdsPlatform()
        ..mockShowSuccess = false;
      RewardedAdsPlatform.instance = fakePlatform;

      final result = await RewardedAds.showRewarded();
      expect(result, false);
    });

    test('reloadRewardedIfNeeded calls loadRewarded when not ready', () async {
      MockRewardedAdsPlatform fakePlatform = MockRewardedAdsPlatform()
        ..mockIsReady = false;
      RewardedAdsPlatform.instance = fakePlatform;

      await RewardedAds.reloadRewardedIfNeeded();
      expect(fakePlatform.loadRewardedCalled, true);
    });

    test('reloadRewardedIfNeeded does not call loadRewarded when ready',
        () async {
      MockRewardedAdsPlatform fakePlatform = MockRewardedAdsPlatform()
        ..mockIsReady = true;
      RewardedAdsPlatform.instance = fakePlatform;

      await RewardedAds.reloadRewardedIfNeeded();
      expect(fakePlatform.loadRewardedCalled, false);
    });

    test('setUnlockingWallpaper and isUnlockingWallpaper', () {
      RewardedAds.setUnlockingWallpaper(true);
      expect(RewardedAds.isUnlockingWallpaper(), true);

      RewardedAds.setUnlockingWallpaper(false);
      expect(RewardedAds.isUnlockingWallpaper(), false);
    });

    test('stopListening cancels event subscription', () {
      RewardedAds.stopListening();
      // Should not throw, even if no subscription exists
      expect(() => RewardedAds.stopListening(), returnsNormally);
    });
  });
}
