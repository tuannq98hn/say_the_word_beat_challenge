package com.example.flutter_ads_native.facebook_event

import android.content.Context
import android.os.Bundle
import com.facebook.appevents.AppEventsLogger
import com.google.android.gms.ads.AdListener
import com.google.android.gms.ads.AdView
import com.google.android.gms.ads.ResponseInfo
import com.google.android.gms.ads.appopen.AppOpenAd
import com.google.android.gms.ads.interstitial.InterstitialAd
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.rewarded.RewardedAd
import com.google.android.gms.ads.rewardedinterstitial.RewardedInterstitialAd
import java.math.BigDecimal
import java.util.Currency

object FacebookROASTracker {

    private const val EVENT_AD_IMPRESSION = "ad_impression"
    private const val EVENT_AD_CLICK = "ad_click"

    // ---------------- IMP / CLICK ----------------

    fun logImpression(
        context: Context,
        logger: AppEventsLogger,
        adUnitId: String,
        format: String,
        responseInfo: ResponseInfo?
    ) {
        if (!FacebookConfigChecker.isEnabled(context)) return

        logger.logEvent(
            EVENT_AD_IMPRESSION,
            buildParams(adUnitId, format, responseInfo)
        )
    }

    fun logClick(
        context: Context,
        logger: AppEventsLogger,
        adUnitId: String,
        format: String,
        responseInfo: ResponseInfo?
    ) {
        if (!FacebookConfigChecker.isEnabled(context)) return

        logger.logEvent(
            EVENT_AD_CLICK,
            buildParams(adUnitId, format, responseInfo)
        )
    }

    fun logNativeImpression(
        context: Context,
        logger: AppEventsLogger,
        adUnitId: String,
        nativeAd: NativeAd
    ) {
        logImpression(context, logger, adUnitId, "NATIVE", nativeAd.responseInfo)
    }

    fun logNativeClick(
        context: Context,
        logger: AppEventsLogger,
        adUnitId: String,
        nativeAd: NativeAd
    ) {
        logClick(context, logger, adUnitId, "NATIVE", nativeAd.responseInfo)
    }

    // ---------------- ILRD (Revenue) ----------------

    fun bindInterstitialRevenue(
        context: Context,
        ad: InterstitialAd,
        adUnitId: String,
        logger: AppEventsLogger
    ) {
        if (!FacebookConfigChecker.isEnabled(context)) return

        ad.setOnPaidEventListener { adValue ->
            val revenue = BigDecimal(adValue.valueMicros)
                .divide(BigDecimal(1_000_000))

            logger.logPurchase(
                revenue,
                Currency.getInstance("USD"),
                buildRevenueParams(adUnitId, "INTERSTITIAL", ad.responseInfo)
            )
        }
    }

    fun bindRewardedRevenue(
        context: Context,
        ad: RewardedAd,
        adUnitId: String,
        logger: AppEventsLogger
    ) {
        if (!FacebookConfigChecker.isEnabled(context)) return

        ad.setOnPaidEventListener { adValue ->
            val revenue = BigDecimal(adValue.valueMicros)
                .divide(BigDecimal(1_000_000))

            logger.logPurchase(
                revenue,
                Currency.getInstance("USD"),
                buildRevenueParams(adUnitId, "REWARDED", ad.responseInfo)
            )
        }
    }

    fun bindRewardedInterstitialRevenue(
        context: Context,
        ad: RewardedInterstitialAd,
        adUnitId: String,
        logger: AppEventsLogger
    ) {
        if (!FacebookConfigChecker.isEnabled(context)) return

        ad.setOnPaidEventListener { adValue ->
            val revenue = BigDecimal(adValue.valueMicros)
                .divide(BigDecimal(1_000_000))

            logger.logPurchase(
                revenue,
                Currency.getInstance("USD"),
                buildRevenueParams(adUnitId, "REWARDED_INTERSTITIAL", ad.responseInfo)
            )
        }
    }

    fun bindAppOpenRevenue(
        context: Context,
        ad: AppOpenAd,
        adUnitId: String,
        logger: AppEventsLogger
    ) {
        if (!FacebookConfigChecker.isEnabled(context)) return

        ad.setOnPaidEventListener { adValue ->
            val revenue = BigDecimal(adValue.valueMicros)
                .divide(BigDecimal(1_000_000))

            logger.logPurchase(
                revenue,
                Currency.getInstance("USD"),
                buildRevenueParams(adUnitId, "APP_OPEN", ad.responseInfo)
            )
        }
    }

    fun bindBannerRevenue(
        context: Context,
        adView: AdView,
        adUnitId: String,
        logger: AppEventsLogger
    ) {
        if (!FacebookConfigChecker.isEnabled(context)) return

        adView.setOnPaidEventListener { adValue ->
            val revenue = BigDecimal(adValue.valueMicros)
                .divide(BigDecimal(1_000_000))

            logger.logPurchase(
                revenue,
                Currency.getInstance("USD"),
                buildRevenueParams(adUnitId, "BANNER", adView.responseInfo)
            )
        }
    }

    fun bindNativeRevenue(
        context: Context,
        nativeAd: NativeAd,
        adUnitId: String,
        logger: AppEventsLogger
    ) {
        if (!FacebookConfigChecker.isEnabled(context)) return

        nativeAd.setOnPaidEventListener { adValue ->
            val revenue = BigDecimal(adValue.valueMicros)
                .divide(BigDecimal(1_000_000))

            logger.logPurchase(
                revenue,
                Currency.getInstance("USD"),
                buildRevenueParams(adUnitId, "NATIVE", nativeAd.responseInfo)
            )
        }
    }

    // ---------------- Banner Listener ----------------

    fun attachBannerListenerForImpClick(
        context: Context,
        adView: AdView,
        adUnitId: String,
        logger: AppEventsLogger
    ) {
        if (!FacebookConfigChecker.isEnabled(context)) return

        adView.adListener = object : AdListener() {
            override fun onAdImpression() {
                logImpression(context, logger, adUnitId, "BANNER", adView.responseInfo)
            }

            override fun onAdClicked() {
                logClick(context, logger, adUnitId, "BANNER", adView.responseInfo)
            }
        }
    }

    // ---------------- Helpers ----------------

    private fun buildParams(
        adUnitId: String,
        format: String,
        responseInfo: ResponseInfo?
    ): Bundle = Bundle().apply {
        putString("ad_platform", "admob")
        putString("ad_unit_id", adUnitId)
        putString("ad_format", format)
        responseInfo?.mediationAdapterClassName?.let {
            putString("mediation_adapter", it)
        }
    }

    private fun buildRevenueParams(
        adUnitId: String,
        format: String,
        responseInfo: ResponseInfo?
    ): Bundle = buildParams(adUnitId, format, responseInfo).apply {
        putString("currency", "USD")
    }
}