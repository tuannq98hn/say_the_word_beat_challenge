import 'package:firebase_analytics/firebase_analytics.dart';

import 'analytics_event_names.dart';
import 'analytics_param_keys.dart';

class AppAnalytics {
  AppAnalytics._();

  static final FirebaseAnalytics _fa = FirebaseAnalytics.instance;

  static Future<void> logScreenView({
    required String screenClass,
    String? screenName,
  }) async {
    // Also set GA4 screen context for better dashboards.
    await _fa.logScreenView(
      screenName: screenName ?? screenClass,
      screenClass: screenClass,
    );
    await _fa.logEvent(
      name: AnalyticsEventNames.screenView,
      parameters: {
        AnalyticsParamKeys.screenClass: screenClass,
        if (screenName != null) AnalyticsParamKeys.screenName: screenName,
      },
    );
  }

  static Future<void> logButtonClick({
    required String screenClass,
    required String buttonName,
    String? action,
  }) async {
    await _fa.logEvent(
      name: AnalyticsEventNames.buttonClick,
      parameters: {
        AnalyticsParamKeys.screenClass: screenClass,
        AnalyticsParamKeys.buttonName: buttonName,
        if (action != null) AnalyticsParamKeys.action: action,
      },
    );
  }

  static Future<void> logSessionAdsSummary({
    required String reason,
    required int interstitialCount,
    required int rewardedCount,
    required int rewardedInterstitialCount,
    required int bannerImpressionCount,
    required int nativeImpressionCount,
  }) async {
    await _fa.logEvent(
      name: AnalyticsEventNames.sessionAdsSummary,
      parameters: {
        AnalyticsParamKeys.reason: reason,
        AnalyticsParamKeys.interstitialCount: interstitialCount,
        AnalyticsParamKeys.rewardedCount: rewardedCount,
        AnalyticsParamKeys.rewardedInterstitialCount: rewardedInterstitialCount,
        AnalyticsParamKeys.bannerImpressionCount: bannerImpressionCount,
        AnalyticsParamKeys.nativeImpressionCount: nativeImpressionCount,
      },
    );
  }
}


