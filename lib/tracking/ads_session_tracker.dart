import 'dart:async';

import 'app_analytics.dart';

class AdsSessionTracker {
  AdsSessionTracker._();

  static int _interstitialShown = 0;
  static int _rewardedShown = 0;
  static int _rewardedInterstitialShown = 0;
  static int _bannerImpression = 0;
  static int _nativeImpression = 0;

  static void onInterstitialShown() => _interstitialShown++;
  static void onRewardedShown() => _rewardedShown++;
  static void onRewardedInterstitialShown() => _rewardedInterstitialShown++;
  static void onBannerImpression() => _bannerImpression++;
  static void onNativeImpression() => _nativeImpression++;

  static Future<void> flush({required String reason}) async {
    // Best-effort: never block app lifecycle.
    unawaited(
      AppAnalytics.logSessionAdsSummary(
        reason: reason,
        interstitialCount: _interstitialShown,
        rewardedCount: _rewardedShown,
        rewardedInterstitialCount: _rewardedInterstitialShown,
        bannerImpressionCount: _bannerImpression,
        nativeImpressionCount: _nativeImpression,
      ),
    );
  }
}


