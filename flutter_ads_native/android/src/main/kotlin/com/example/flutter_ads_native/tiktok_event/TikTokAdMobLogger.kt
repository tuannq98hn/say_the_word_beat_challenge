package com.example.flutter_ads_native.tiktok_event

import com.google.android.gms.ads.*
import com.google.android.gms.ads.appopen.AppOpenAd
import com.google.android.gms.ads.interstitial.InterstitialAd
import com.google.android.gms.ads.rewarded.RewardedAd
import com.google.android.gms.ads.rewardedinterstitial.RewardedInterstitialAd
import com.google.android.gms.ads.nativead.NativeAd

object TikTokAdMobLogger {

    private const val E_IMP = "InAppADImpr"
    private const val E_CLICK = "InAppADClick"
    private const val E_REV = "ImpressionLevelAdRevenue"

    // -------- Full-screen formats --------

    fun bindInterstitial(ad: InterstitialAd, adUnitId: String, tracker: TikTokAdTracker) {
        val meta = AdMobMetaExtractor.fromResponseInfo(adUnitId, "INTERSTITIAL", ad.responseInfo)

        ad.fullScreenContentCallback = object : FullScreenContentCallback() {
            override fun onAdImpression() = tracker.track(E_IMP, meta)
            override fun onAdClicked() = tracker.track(E_CLICK, meta)
        }

        ad.setOnPaidEventListener { adValue ->
            val revenueProps = AdMobMetaExtractor.adValueToRevenueProps(adValue)
            tracker.track(E_REV, meta, revenueProps)
        }
    }

    fun bindRewarded(ad: RewardedAd, adUnitId: String, tracker: TikTokAdTracker) {
        val meta = AdMobMetaExtractor.fromResponseInfo(adUnitId, "REWARDED", ad.responseInfo)

        ad.fullScreenContentCallback = object : FullScreenContentCallback() {
            override fun onAdImpression() = tracker.track(E_IMP, meta)
            override fun onAdClicked() = tracker.track(E_CLICK, meta)
        }

        ad.setOnPaidEventListener { adValue ->
            val revenueProps = AdMobMetaExtractor.adValueToRevenueProps(adValue)
            tracker.track(E_REV, meta, revenueProps)
        }
    }

    fun bindRewardedInterstitial(ad: RewardedInterstitialAd, adUnitId: String, tracker: TikTokAdTracker) {
        val meta = AdMobMetaExtractor.fromResponseInfo(adUnitId, "INTERSTITIAL_REWARDED", ad.responseInfo)

        ad.fullScreenContentCallback = object : FullScreenContentCallback() {
            override fun onAdImpression() = tracker.track(E_IMP, meta)
            override fun onAdClicked() = tracker.track(E_CLICK, meta)
        }

        ad.setOnPaidEventListener { adValue ->
            val revenueProps = AdMobMetaExtractor.adValueToRevenueProps(adValue)
            tracker.track(E_REV, meta, revenueProps)
        }
    }

    fun bindAppOpen(ad: AppOpenAd, adUnitId: String, tracker: TikTokAdTracker) {
        val meta = AdMobMetaExtractor.fromResponseInfo(adUnitId, "APP_OPEN", ad.responseInfo)

        ad.fullScreenContentCallback = object : FullScreenContentCallback() {
            override fun onAdImpression() = tracker.track(E_IMP, meta)
            override fun onAdClicked() = tracker.track(E_CLICK, meta)
        }

        ad.setOnPaidEventListener { adValue ->
            val revenueProps = AdMobMetaExtractor.adValueToRevenueProps(adValue)
            tracker.track(E_REV, meta, revenueProps)
        }
    }

    // -------- Banner --------

    fun bindBanner(adView: AdView, adUnitId: String, tracker: TikTokAdTracker) {
        adView.adListener = object : AdListener() {
            override fun onAdImpression() {
                val meta = AdMobMetaExtractor.fromResponseInfo(adUnitId, "BANNER", adView.responseInfo)
                tracker.track(E_IMP, meta)
            }

            override fun onAdClicked() {
                val meta = AdMobMetaExtractor.fromResponseInfo(adUnitId, "BANNER", adView.responseInfo)
                tracker.track(E_CLICK, meta)
            }
        }

        adView.setOnPaidEventListener { adValue ->
            val meta = AdMobMetaExtractor.fromResponseInfo(adUnitId, "BANNER", adView.responseInfo)
            val revenueProps = AdMobMetaExtractor.adValueToRevenueProps(adValue)
            tracker.track(E_REV, meta, revenueProps)
        }
    }

    // -------- Native --------
    /**
     * Native thường lấy click/impression qua AdListener của AdLoader,
     * còn revenue lấy từ NativeAd.setOnPaidEventListener.
     */
    fun bindNative(nativeAd: NativeAd, adUnitId: String, tracker: TikTokAdTracker) {
        nativeAd.setOnPaidEventListener { adValue ->
            val meta = AdMobMetaExtractor.fromResponseInfo(adUnitId, "NATIVE", nativeAd.responseInfo)
            val revenueProps = AdMobMetaExtractor.adValueToRevenueProps(adValue)
            tracker.track(E_REV, meta, revenueProps)
        }
    }

    fun onNativeImpressionFromAdLoader(nativeAd: NativeAd, adUnitId: String, tracker: TikTokAdTracker) {
        val meta = AdMobMetaExtractor.fromResponseInfo(adUnitId, "NATIVE", nativeAd.responseInfo)
        tracker.track(E_IMP, meta)
    }

    fun onNativeClickFromAdLoader(nativeAd: NativeAd, adUnitId: String, tracker: TikTokAdTracker) {
        val meta = AdMobMetaExtractor.fromResponseInfo(adUnitId, "NATIVE", nativeAd.responseInfo)
        tracker.track(E_CLICK, meta)
    }
}

