package com.example.flutter_ads_native.tiktok_event

import android.os.Bundle
import com.google.android.gms.ads.AdValue
import com.google.android.gms.ads.ResponseInfo
import com.google.android.gms.ads.AdapterResponseInfo

data class AdMobAdMeta(
    val adUnitId: String,
    val format: String,                 // INTERSTITIAL, REWARDED, BANNER, ...
    val mediationPlatform: String = "AdMob",

    // From ResponseInfo
    val responseId: String? = null,
    val mediationGroupName: String? = null,    // responseExtras["mediation_group_name"]
    val mediationAdapterClassName: String? = null,

    // From loaded AdapterResponseInfo
    val adSourceName: String? = null,
    val adSourceId: String? = null,
    val adSourceInstanceName: String? = null,
    val adSourceInstanceId: String? = null,
)

object AdMobMetaExtractor {

    fun fromResponseInfo(
        adUnitId: String,
        format: String,
        responseInfo: ResponseInfo?
    ): AdMobAdMeta {
        val extras: Bundle? = responseInfo?.responseExtras
        val loaded: AdapterResponseInfo? = responseInfo?.loadedAdapterResponseInfo

        return AdMobAdMeta(
            adUnitId = adUnitId,
            format = format,
            responseId = responseInfo?.responseId,
            mediationGroupName = extras?.getString("mediation_group_name"),
            mediationAdapterClassName = responseInfo?.mediationAdapterClassName,
            adSourceName = loaded?.adSourceName,
            adSourceId = loaded?.adSourceId,
            adSourceInstanceName = loaded?.adSourceInstanceName,
            adSourceInstanceId = loaded?.adSourceInstanceId,
        )
    }

    fun adValueToRevenueProps(adValue: AdValue): Map<String, Any> {
        val revenue = adValue.valueMicros / 1_000_000.0 // micros -> currency unit
        return mapOf(
            "revenue" to revenue,
            "currency" to adValue.currencyCode,
            "precision" to adValue.precisionType
        )
    }
}
