package com.example.flutter_ads_native.tiktok_event

import com.google.android.gms.ads.AdListener
import com.google.android.gms.ads.AdView
import com.google.android.gms.ads.ResponseInfo
import com.google.android.gms.ads.appopen.AppOpenAd
import com.google.android.gms.ads.interstitial.InterstitialAd
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.rewarded.RewardedAd
import com.google.android.gms.ads.rewardedinterstitial.RewardedInterstitialAd

object TikTokAdMobLogger {

    // ---------- Manual IMP / CLICK (you call yourself) ----------

    fun logImpression(tracker: TikTokAdTracker, adUnitId: String, format: String, responseInfo: ResponseInfo?) {
        val meta = AdMobAdMeta.fromResponseInfo(adUnitId, format, responseInfo)
        tracker.trackImpression(meta)
    }

    fun logClick(tracker: TikTokAdTracker, adUnitId: String, format: String, responseInfo: ResponseInfo?) {
        val meta = AdMobAdMeta.fromResponseInfo(adUnitId, format, responseInfo)
        tracker.trackClick(meta)
    }

    fun logNativeImpression(tracker: TikTokAdTracker, adUnitId: String, nativeAd: NativeAd) {
        val meta = AdMobAdMeta.fromResponseInfo(adUnitId, "NATIVE", nativeAd.responseInfo)
        tracker.trackImpression(meta)
    }

    fun logNativeClick(tracker: TikTokAdTracker, adUnitId: String, nativeAd: NativeAd) {
        val meta = AdMobAdMeta.fromResponseInfo(adUnitId, "NATIVE", nativeAd.responseInfo)
        tracker.trackClick(meta)
    }

    // ---------- Bind ONLY Revenue (ILRD) ----------

    fun bindInterstitialRevenue(ad: InterstitialAd, adUnitId: String, tracker: TikTokAdTracker) {
        val meta = AdMobAdMeta.fromResponseInfo(adUnitId, "INTERSTITIAL", ad.responseInfo)
        ad.setOnPaidEventListener { adValue -> tracker.trackRevenue(meta, adValue) }
    }

    fun bindRewardedRevenue(ad: RewardedAd, adUnitId: String, tracker: TikTokAdTracker) {
        val meta = AdMobAdMeta.fromResponseInfo(adUnitId, "REWARDED", ad.responseInfo)
        ad.setOnPaidEventListener { adValue -> tracker.trackRevenue(meta, adValue) }
    }

    fun bindRewardedInterstitialRevenue(ad: RewardedInterstitialAd, adUnitId: String, tracker: TikTokAdTracker) {
        val meta = AdMobAdMeta.fromResponseInfo(adUnitId, "REWARDED_INTERSTITIAL", ad.responseInfo)
        ad.setOnPaidEventListener { adValue -> tracker.trackRevenue(meta, adValue) }
    }

    fun bindAppOpenRevenue(ad: AppOpenAd, adUnitId: String, tracker: TikTokAdTracker) {
        val meta = AdMobAdMeta.fromResponseInfo(adUnitId, "APP_OPEN", ad.responseInfo)
        ad.setOnPaidEventListener { adValue -> tracker.trackRevenue(meta, adValue) }
    }

    fun bindBannerRevenue(adView: AdView, adUnitId: String, tracker: TikTokAdTracker) {
        // Revenue uses responseInfo at paid time
        adView.setOnPaidEventListener { adValue ->
            val meta = AdMobAdMeta.fromResponseInfo(adUnitId, "BANNER", adView.responseInfo)
            tracker.trackRevenue(meta, adValue)
        }
    }

    fun bindNativeRevenue(nativeAd: NativeAd, adUnitId: String, tracker: TikTokAdTracker) {
        val meta = AdMobAdMeta.fromResponseInfo(adUnitId, "NATIVE", nativeAd.responseInfo)
        nativeAd.setOnPaidEventListener { adValue -> tracker.trackRevenue(meta, adValue) }
    }

    // ---------- Optional helpers for Banner/Naitve listeners ----------

    fun attachBannerListenerForImpClick(adView: AdView, adUnitId: String, tracker: TikTokAdTracker) {
        adView.adListener = object : AdListener() {
            override fun onAdImpression() {
                logImpression(tracker, adUnitId, "BANNER", adView.responseInfo)
            }

            override fun onAdClicked() {
                logClick(tracker, adUnitId, "BANNER", adView.responseInfo)
            }
        }
    }
}
