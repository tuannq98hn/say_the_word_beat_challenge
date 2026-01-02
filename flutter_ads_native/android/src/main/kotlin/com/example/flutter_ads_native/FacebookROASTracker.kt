package com.example.flutter_ads_native

import android.content.Context
import android.os.Bundle
import com.facebook.appevents.AppEventsLogger
import com.google.android.gms.ads.AdValue

object FacebookROASTracker {

    private const val EVENT_AD_IMPRESSION = "fb_mobile_ad_impression"
    private const val EVENT_AD_CLICK = "fb_mobile_ad_click"

    fun trackAdRevenue(
        context: Context,
        adUnitId: String,
        adType: String,
        adValue: AdValue
    ) {
        val revenueUsd = adValue.valueMicros / 1_000_000.0
        if (revenueUsd <= 0) return

        val params = Bundle().apply {
            putString("ad_unit_id", adUnitId)
            putString("ad_type", adType)
            putString("currency", "USD")
            putDouble("value", revenueUsd)
        }

          AppEventsLogger.newLogger(context)
            .logEvent(EVENT_AD_IMPRESSION, revenueUsd, params)
    }

    fun trackAdClick(
        context: Context,
        adUnitId: String,
        adType: String
    ) {
        val params = Bundle().apply {
            putString("ad_unit_id", adUnitId)
            putString("ad_type", adType)
        }

        AppEventsLogger.newLogger(context)
            .logEvent(EVENT_AD_CLICK, params)
    }
}