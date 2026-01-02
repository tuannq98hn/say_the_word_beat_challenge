package com.example.flutter_ads_native.tiktok_event

import android.content.Context
import com.google.android.gms.ads.AdListener
import com.google.android.gms.ads.AdView
import com.google.android.gms.ads.ResponseInfo
import com.google.android.gms.ads.appopen.AppOpenAd
import com.google.android.gms.ads.interstitial.InterstitialAd
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.rewarded.RewardedAd
import com.google.android.gms.ads.rewardedinterstitial.RewardedInterstitialAd
object TikTokAdMobLogger {

    // ---------- Manual IMP / CLICK ----------

    fun logImpression(
        context: Context,
        tracker: TikTokAdTracker,
        adUnitId: String,
        format: String,
        responseInfo: ResponseInfo?
    ) {
        if (!TikTokConfigChecker.isEnabled(context)) return

        val meta = AdMobAdMeta.fromResponseInfo(adUnitId, format, responseInfo)
        tracker.trackImpression(meta)
    }

    fun logClick(
        context: Context,
        tracker: TikTokAdTracker,
        adUnitId: String,
        format: String,
        responseInfo: ResponseInfo?
    ) {
        if (!TikTokConfigChecker.isEnabled(context)) return

        val meta = AdMobAdMeta.fromResponseInfo(adUnitId, format, responseInfo)
        tracker.trackClick(meta)
    }

    fun logNativeImpression(
        context: Context,
        tracker: TikTokAdTracker,
        adUnitId: String,
        nativeAd: NativeAd
    ) {
        logImpression(
            context,
            tracker,
            adUnitId,
            "NATIVE",
            nativeAd.responseInfo
        )
    }

    fun logNativeClick(
        context: Context,
        tracker: TikTokAdTracker,
        adUnitId: String,
        nativeAd: NativeAd
    ) {
        logClick(
            context,
            tracker,
            adUnitId,
            "NATIVE",
            nativeAd.responseInfo
        )
    }

    // ---------- Bind ONLY Revenue (ILRD) ----------

    fun bindInterstitialRevenue(
        context: Context,
        ad: InterstitialAd,
        adUnitId: String,
        tracker: TikTokAdTracker
    ) {
        if (!TikTokConfigChecker.isEnabled(context)) return

        val meta = AdMobAdMeta.fromResponseInfo(adUnitId, "INTERSTITIAL", ad.responseInfo)
        ad.setOnPaidEventListener { adValue ->
            tracker.trackRevenue(meta, adValue)
        }
    }

    fun bindRewardedRevenue(
        context: Context,
        ad: RewardedAd,
        adUnitId: String,
        tracker: TikTokAdTracker
    ) {
        if (!TikTokConfigChecker.isEnabled(context)) return

        val meta = AdMobAdMeta.fromResponseInfo(adUnitId, "REWARDED", ad.responseInfo)
        ad.setOnPaidEventListener { adValue ->
            tracker.trackRevenue(meta, adValue)
        }
    }

    fun bindRewardedInterstitialRevenue(
        context: Context,
        ad: RewardedInterstitialAd,
        adUnitId: String,
        tracker: TikTokAdTracker
    ) {
        if (!TikTokConfigChecker.isEnabled(context)) return

        val meta = AdMobAdMeta.fromResponseInfo(
            adUnitId,
            "REWARDED_INTERSTITIAL",
            ad.responseInfo
        )
        ad.setOnPaidEventListener { adValue ->
            tracker.trackRevenue(meta, adValue)
        }
    }

    fun bindAppOpenRevenue(
        context: Context,
        ad: AppOpenAd,
        adUnitId: String,
        tracker: TikTokAdTracker
    ) {
        if (!TikTokConfigChecker.isEnabled(context)) return

        val meta = AdMobAdMeta.fromResponseInfo(adUnitId, "APP_OPEN", ad.responseInfo)
        ad.setOnPaidEventListener { adValue ->
            tracker.trackRevenue(meta, adValue)
        }
    }

    fun bindBannerRevenue(
        context: Context,
        adView: AdView,
        adUnitId: String,
        tracker: TikTokAdTracker
    ) {
        if (!TikTokConfigChecker.isEnabled(context)) return

        adView.setOnPaidEventListener { adValue ->
            val meta = AdMobAdMeta.fromResponseInfo(
                adUnitId,
                "BANNER",
                adView.responseInfo
            )
            tracker.trackRevenue(meta, adValue)
        }
    }

    fun bindNativeRevenue(
        context: Context,
        nativeAd: NativeAd,
        adUnitId: String,
        tracker: TikTokAdTracker
    ) {
        if (!TikTokConfigChecker.isEnabled(context)) return

        val meta = AdMobAdMeta.fromResponseInfo(adUnitId, "NATIVE", nativeAd.responseInfo)
        nativeAd.setOnPaidEventListener { adValue ->
            tracker.trackRevenue(meta, adValue)
        }
    }

    // ---------- Optional helpers for Banner listeners ----------

    fun attachBannerListenerForImpClick(
        context: Context,
        adView: AdView,
        adUnitId: String,
        tracker: TikTokAdTracker
    ) {
        if (!TikTokConfigChecker.isEnabled(context)) return

        adView.adListener = object : AdListener() {
            override fun onAdImpression() {
                logImpression(
                    context,
                    tracker,
                    adUnitId,
                    "BANNER",
                    adView.responseInfo
                )
            }

            override fun onAdClicked() {
                logClick(
                    context,
                    tracker,
                    adUnitId,
                    "BANNER",
                    adView.responseInfo
                )
            }
        }
    }
}
