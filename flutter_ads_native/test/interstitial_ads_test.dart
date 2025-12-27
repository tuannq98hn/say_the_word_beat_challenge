import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ads_native/interstitial_ads/interstitial_ads.dart';
import 'package:flutter_ads_native/interstitial_ads/interstitial_ads_platform_interface.dart';
import 'package:flutter_ads_native/interstitial_ads/interstitial_ads_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockInterstitialAdsPlatform
    with MockPlatformInterfaceMixin
    implements InterstitialAdsPlatform {
  bool initAdsCalled = false;
  bool loadInterstitialCalled = false;
  bool isInterstitialReadyCalled = false;
  bool showInterstitialCalled = false;

  List<String>? lastInitAdUnitIds;
  bool mockIsReady = true;
  bool mockShowSuccess = true;
  Exception? mockIsReadyException;

  @override
  Future<void> initAds(List<String> interstitialAdUnitIds) async {
    initAdsCalled = true;
    lastInitAdUnitIds = interstitialAdUnitIds;
  }

  @override
  Future<void> loadInterstitial() async {
    loadInterstitialCalled = true;
  }

  @override
  Future<bool> isInterstitialReady() {
    isInterstitialReadyCalled = true;
    if (mockIsReadyException != null) {
      return Future.error(mockIsReadyException!);
    }
    return Future.value(mockIsReady);
  }

  @override
  Future<bool> showInterstitial() {
    showInterstitialCalled = true;
    if (!mockShowSuccess) {
      return Future.error(
          PlatformException(code: 'AD_NOT_READY', message: 'Ad not ready'));
    }
    return Future.value(true);
  }
}

void main() {
  final InterstitialAdsPlatform initialPlatform =
      InterstitialAdsPlatform.instance;

  tearDown(() {
    // Reset platform instance after each test
    InterstitialAdsPlatform.instance = initialPlatform;
    // Clean up static callbacks
    InterstitialAds.onInterstitialLoaded = null;
    InterstitialAds.onInterstitialShown = null;
    InterstitialAds.onInterstitialClosed = null;
    InterstitialAds.onInterstitialFailed = null;
    InterstitialAds.stopListening();
  });

  test('$MethodChannelInterstitialAds is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelInterstitialAds>());
  });

  group('InterstitialAdsPlatform', () {
    test('initAds', () async {
      MockInterstitialAdsPlatform fakePlatform =
          MockInterstitialAdsPlatform();
      InterstitialAdsPlatform.instance = fakePlatform;

      await InterstitialAdsPlatform.instance.initAds(['test-id-1', 'test-id-2']);
      expect(fakePlatform.initAdsCalled, true);
      expect(fakePlatform.lastInitAdUnitIds, ['test-id-1', 'test-id-2']);
    });

    test('loadInterstitial', () async {
      MockInterstitialAdsPlatform fakePlatform =
          MockInterstitialAdsPlatform();
      InterstitialAdsPlatform.instance = fakePlatform;

      await InterstitialAdsPlatform.instance.loadInterstitial();
      expect(fakePlatform.loadInterstitialCalled, true);
    });

    test('isInterstitialReady', () async {
      MockInterstitialAdsPlatform fakePlatform =
          MockInterstitialAdsPlatform();
      InterstitialAdsPlatform.instance = fakePlatform;

      final result = await InterstitialAdsPlatform.instance.isInterstitialReady();
      expect(result, true);
      expect(fakePlatform.isInterstitialReadyCalled, true);
    });

    test('showInterstitial', () async {
      MockInterstitialAdsPlatform fakePlatform =
          MockInterstitialAdsPlatform();
      InterstitialAdsPlatform.instance = fakePlatform;

      final result = await InterstitialAdsPlatform.instance.showInterstitial();
      expect(result, true);
      expect(fakePlatform.showInterstitialCalled, true);
    });
  });

  group('InterstitialAds', () {
    test('isInterstitialReady returns true when platform returns true', () async {
      MockInterstitialAdsPlatform fakePlatform =
          MockInterstitialAdsPlatform();
      InterstitialAdsPlatform.instance = fakePlatform;

      final result = await InterstitialAds.isInterstitialReady();
      expect(result, true);
    });

    test('isInterstitialReady returns false when platform returns false',
        () async {
      MockInterstitialAdsPlatform fakePlatform = MockInterstitialAdsPlatform()
        ..mockIsReady = false;
      InterstitialAdsPlatform.instance = fakePlatform;

      final result = await InterstitialAds.isInterstitialReady();
      expect(result, false);
    });

    test('isInterstitialReady returns false on exception', () async {
      MockInterstitialAdsPlatform fakePlatform = MockInterstitialAdsPlatform()
        ..mockIsReadyException = Exception('Test error');
      InterstitialAdsPlatform.instance = fakePlatform;

      final result = await InterstitialAds.isInterstitialReady();
      expect(result, false);
    });

    test('showInterstitial returns true on success', () async {
      MockInterstitialAdsPlatform fakePlatform =
          MockInterstitialAdsPlatform();
      InterstitialAdsPlatform.instance = fakePlatform;

      final result = await InterstitialAds.showInterstitial();
      expect(result, true);
    });

    test('showInterstitial returns false on AD_NOT_READY exception', () async {
      MockInterstitialAdsPlatform fakePlatform = MockInterstitialAdsPlatform()
        ..mockShowSuccess = false;
      InterstitialAdsPlatform.instance = fakePlatform;

      final result = await InterstitialAds.showInterstitial();
      expect(result, false);
    });

    test('reloadInterstitialIfNeeded calls loadInterstitial when not ready',
        () async {
      MockInterstitialAdsPlatform fakePlatform = MockInterstitialAdsPlatform()
        ..mockIsReady = false;
      InterstitialAdsPlatform.instance = fakePlatform;

      await InterstitialAds.reloadInterstitialIfNeeded();
      expect(fakePlatform.loadInterstitialCalled, true);
    });

    test('reloadInterstitialIfNeeded does not call loadInterstitial when ready',
        () async {
      MockInterstitialAdsPlatform fakePlatform = MockInterstitialAdsPlatform()
        ..mockIsReady = true;
      InterstitialAdsPlatform.instance = fakePlatform;

      await InterstitialAds.reloadInterstitialIfNeeded();
      expect(fakePlatform.loadInterstitialCalled, false);
    });

    test('stopListening cancels event subscription', () {
      InterstitialAds.stopListening();
      // Should not throw, even if no subscription exists
      expect(() => InterstitialAds.stopListening(), returnsNormally);
    });
  });
}
