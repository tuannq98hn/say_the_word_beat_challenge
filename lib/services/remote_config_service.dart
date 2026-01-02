import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_ads_native/ad_data.dart';
import 'package:flutter_ads_native/index.dart';
import 'package:say_word_challenge/data/model/ads_model.dart';

class RemoteConfigService {
  RemoteConfigService._internal();

  static final RemoteConfigService _instance = RemoteConfigService._internal();

  static RemoteConfigService get instance => _instance;

  late final FirebaseRemoteConfig _remoteConfig;

  Future<void> init() async {
    _remoteConfig = FirebaseRemoteConfig.instance;
    await _remoteConfig.setDefaults({"ads": jsonEncode(_defaultAdsConfig)});

    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero, // 30 phút mới cho fetch lại
      ),
    );
    await _remoteConfig.fetchAndActivate();
  }

  AdsModel get adsModel {
    String? adsString;
    try {
      adsString = _remoteConfig.getString('ads');
    } catch (err) {
      adsString = jsonEncode(_defaultAdsConfig);
    }
    // return AdsModel.fromJson(_defaultAdsConfig);
    return AdsModel.fromJson(jsonDecode(adsString));
  }

  /// Get list of interstitial ad unit IDs from remote config
  List<String> getInterstitialAdUnitIds() {
    try {
      final adUnitIds = adsModel.inter?.adUnitIds;
      if (adUnitIds != null && adUnitIds.isNotEmpty) {
        return adUnitIds;
      }
    } catch (e) {
      debugPrint('Error getting interstitial ad unit IDs: $e');
    }
    // Fallback to default
    final defaultInter = _defaultAdsConfig['inter'] as Map<String, dynamic>;
    final defaultIds = defaultInter['adUnitIds'] as List;
    return defaultIds.map((id) => id.toString()).toList();
  }

  /// Get list of rewarded ad unit IDs from remote config
  List<String> getRewardedAdUnitIds() {
    try {
      final adUnitIds = adsModel.reward?.adUnitIds;
      if (adUnitIds != null && adUnitIds.isNotEmpty) {
        return adUnitIds;
      }
    } catch (e) {
      debugPrint('Error getting rewarded ad unit IDs: $e');
    }
    // Fallback to default
    final defaultReward = _defaultAdsConfig['reward'] as Map<String, dynamic>;
    final defaultIds = defaultReward['adUnitIds'] as List;
    return defaultIds.map((id) => id.toString()).toList();
  }

  /// Get list of rewarded interstitial ad unit IDs from remote config
  List<String> getRewardedInterstitialAdUnitIds() {
    try {
      final adUnitIds = adsModel.rewardInter?.adUnitIds;
      if (adUnitIds != null && adUnitIds.isNotEmpty) {
        return adUnitIds;
      }
    } catch (e) {
      debugPrint('Error getting rewarded interstitial ad unit IDs: $e');
    }
    // Fallback to default
    final defaultRewardInter =
        _defaultAdsConfig['rewardInter'] as Map<String, dynamic>;
    final defaultIds = defaultRewardInter['adUnitIds'] as List;
    return defaultIds.map((id) => id.toString()).toList();
  }

  Map<String, RemoteConfigValue> get all => _remoteConfig.getAll();

  dynamic get _defaultAdsConfig => {
    "banner": [
      {
        "screenName": "SplashPage",
        "adUnitId": "ca-app-pub-3940256099942544/6300978111",
        "size": "LARGE_BANNER",
        "isShow": true,
      },
      {
        "screenName": "BottomNav",
        "adUnitId": "ca-app-pub-3940256099942544/6300978111",
        "size": "SMART_BANNER",
        "isShow": true,
      },
    ],
    "native": [
      {
        "screenName": "BottomNav",
        "adUnitId": "ca-app-pub-3940256099942544/2247696110",
        "size": "NATIVE_BANNER",
        "isShow": true,
      },
      {
        "screenName": "SplashPageFull",
        "adUnitId": "ca-app-pub-3940256099942544/2247696110",
        "size": "FULL_SCREEN",
        "isShow": true,
      },
      {
        "screenName": "GameOverPage",
        "adUnitId": "ca-app-pub-3940256099942544/2247696110",
        "size": "NATIVE_MEDIUM_RECTANGLE",
        "isShow": true,
      },
      {
        "screenName": "SettingsPage",
        "adUnitId": "ca-app-pub-3940256099942544/2247696110",
        "size": "NATIVE_LARGE",
        "isShow": true,
      },
      {
        "screenName": "PreGameSettingsPage",
        "adUnitId": "ca-app-pub-3940256099942544/2247696110",
        "size": "NATIVE_MEDIUM_RECTANGLE",
        "isShow": true,
      },
      {
        "screenName": "VideoPlayerPage",
        "adUnitId": "ca-app-pub-3940256099942544/2247696110",
        "size": "NATIVE_LARGE",
        "isShow": true,
      },
      {
        "screenName": "CreateWizardPageUpload",
        "adUnitId": "ca-app-pub-3940256099942544/2247696110",
        "size": "NATIVE_LARGE",
        "isShow": true,
      },
      {
        "screenName": "CreateWizardPageMode",
        "adUnitId": "ca-app-pub-3940256099942544/2247696110",
        "size": "NATIVE_LARGE",
        "isShow": true,
      },
      {
        "screenName": "CreateWizardPageManual",
        "adUnitId": "ca-app-pub-3940256099942544/2247696110",
        "size": "NATIVE_LARGE",
        "isShow": true,
      },
    ],
    "inter": {
      "adUnitIds": [
        "ca-app-pub-3940256099942544/1033173712",
        "ca-app-pub-3940256099942544/1033173712",
        "ca-app-pub-3940256099942544/1033173712",
        "ca-app-pub-3940256099942544/1033173712",
      ],
      "showRateTime": 15,
      "interMaxPerSession": 100,
      "interMinSecondsBetween": 10,
      "interMaxPerDay": 20,
      "interMinActionBetween": 3,
    },
    "reward": {
      "adUnitIds": [
        "ca-app-pub-3940256099942544/5224354917",
        "ca-app-pub-3940256099942544/5224354917",
        "ca-app-pub-3940256099942544/5224354917",
        "ca-app-pub-3940256099942544/5224354917",
      ],
      "rewardMaxPerSession": 10,
      "rewardMaxPerDay": 30,
    },
    "rewardInter": {
      "adUnitIds": [
        "ca-app-pub-3940256099942544/5354046379",
        "ca-app-pub-3940256099942544/5354046379",
        "ca-app-pub-3940256099942544/5354046379",
        "ca-app-pub-3940256099942544/5354046379",
        "ca-app-pub-3940256099942544/5354046379",
      ],
      "rewardInterMaxPerSession": 10,
      "rewardInterMaxPerDay": 30,
    },
    "shouldShowRewardInter": true,
  };

  int get maxInterShowInSession => adsModel.inter?.interMaxPerSession ?? 0;

  int get interMinSecondsBetween => adsModel.inter?.interMinSecondsBetween ?? 0;

  int get interMaxPerDay => adsModel.inter?.interMaxPerDay ?? 0;

  int get interMinActionBetween => adsModel.inter?.interMinActionBetween ?? 0;

  int get rewardMaxPerSession => adsModel.reward?.rewardMaxPerSession ?? 0;

  int get rewardMaxPerDay => adsModel.reward?.rewardMaxPerDay ?? 0;

  int get rewardInterMaxPerSession =>
      adsModel.rewardInter?.rewardInterMaxPerSession ?? 0;

  int get rewardInterMaxPerDay =>
      adsModel.rewardInter?.rewardInterMaxPerDay ?? 0;

  /// Check if should show rewarded interstitial instead of rewarded ad
  /// Returns true if showRewardInter is true in Remote Config, false otherwise
  bool get shouldShowRewardInter => adsModel.shouldShowRewardInter ?? false;

  Widget? configAdsByScreen(
    String screenName, {
    AdBannerSize? size,
    void Function()? onNativeClose,
  }) {
    final banner = adsModel.banner?.firstWhereOrNull(
      (test) => test.screenName == screenName && test.isShow == true,
    );
    final native = adsModel.native?.firstWhereOrNull(
      (test) => test.screenName == screenName && test.isShow == true,
    );
    final bannerNative = native ?? banner;
    if (bannerNative != null) {
      if (bannerNative is NativeModel) {
        return NativeAdWidget(
          data: AdNativeData(
            adUnitId: bannerNative.adUnitId!,
            size: bannerNative.size!,
          ),
          onCloseAd: onNativeClose,
        );
      }
      if (bannerNative is BannerModel) {
        return BannerAdWidget(
          data: AdBannerData(
            adUnitId: bannerNative.adUnitId!,
            size: bannerNative.size!,
          ),
        );
      }
    }
    return SizedBox.shrink();
  }

  BannerNativeModel? configAdsDataByScreen(String screenName) {
    final banner = adsModel.banner?.firstWhereOrNull(
      (test) => test.screenName == screenName && test.isShow == true,
    );
    final native = adsModel.native?.firstWhereOrNull(
      (test) => test.screenName == screenName && test.isShow == true,
    );
    return native ?? banner;
  }

  // ===== OPTIONAL: HÀM GENERIC NẾU MUỐN DÙNG THEO ID =====

  int getFeatureFreeUses(String featureKey) {
    // ví dụ featureKey = 'video_call', 'audio_call',...
    return _remoteConfig.getInt('${featureKey}_free_uses');
  }

  bool getFeatureIsFree(String featureKey) {
    return _remoteConfig.getBool('${featureKey}_is_free');
  }
}
