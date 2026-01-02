package com.example.flutter_ads_native.tiktok_event

import android.os.Bundle
import com.google.android.gms.ads.AdapterResponseInfo
import com.google.android.gms.ads.ResponseInfo

data class AdMobAdMeta(
    val adUnitId: String,
    val format: String, // banner/interstitial/rewarded/rewarded_interstitial/native/app_open...
    val mediationPlatform: String = "admob_sdk",

    // ResponseInfo
    val responseId: String? = null,

    // Loaded adapter
    val adSourceName: String? = null,
    val adSourceId: String? = null,
    val adSourceInstanceName: String? = null,
    val adSourceInstanceId: String? = null,
    val mediationAdapterClassName: String? = null,

    // Response extras
    val mediationGroupName: String? = null,
    val mediationAbTestName: String? = null,
    val mediationAbTestVariant: String? = null,
) {
    companion object {
        fun fromResponseInfo(
            adUnitId: String,
            format: String,
            responseInfo: ResponseInfo?,
            mediationPlatform: String = "admob_sdk",
        ): AdMobAdMeta {
            val loaded: AdapterResponseInfo? = responseInfo?.loadedAdapterResponseInfo
            val extras: Bundle? = responseInfo?.responseExtras

            return AdMobAdMeta(
                adUnitId = adUnitId,
                format = format,
                mediationPlatform = mediationPlatform,
                responseId = responseInfo?.responseId,

                adSourceName = loaded?.adSourceName,
                adSourceId = loaded?.adSourceId,
                adSourceInstanceName = loaded?.adSourceInstanceName,
                adSourceInstanceId = loaded?.adSourceInstanceId,
                mediationAdapterClassName = loaded?.adapterClassName,

                mediationGroupName = extras?.getString("mediation_group_name"),
                mediationAbTestName = extras?.getString("mediation_ab_test_name"),
                mediationAbTestVariant = extras?.getString("mediation_ab_test_variant"),
            )
        }
    }
}
