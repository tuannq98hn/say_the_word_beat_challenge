package com.example.flutter_ads_native.tracking

import android.content.Context
import android.os.Bundle
import com.google.firebase.analytics.FirebaseAnalytics

/**
 * Single place to log analytics events for ads performance.
 */
object AdsAnalytics {

    private fun analytics(context: Context): FirebaseAnalytics {
        return FirebaseAnalytics.getInstance(context)
    }

    fun logAdLoadStart(context: Context, adType: String, adUnitId: String?) {
        logEvent(
            context = context,
            name = AnalyticsEventNames.AD_LOAD,
            params = mapOf(
                AnalyticsParamKeys.RESULT to "start",
                AnalyticsParamKeys.AD_TYPE to adType,
                AnalyticsParamKeys.AD_UNIT_ID to adUnitId
            )
        )
    }

    fun logAdLoadSuccess(context: Context, adType: String, adUnitId: String?) {
        logEvent(
            context = context,
            name = AnalyticsEventNames.AD_LOAD,
            params = mapOf(
                AnalyticsParamKeys.RESULT to "success",
                AnalyticsParamKeys.AD_TYPE to adType,
                AnalyticsParamKeys.AD_UNIT_ID to adUnitId
            )
        )
    }

    fun logAdLoadFail(
        context: Context,
        adType: String,
        adUnitId: String?,
        errorCode: Int?,
        errorMessage: String?
    ) {
        logEvent(
            context = context,
            name = AnalyticsEventNames.AD_LOAD,
            params = mapOf(
                AnalyticsParamKeys.RESULT to "fail",
                AnalyticsParamKeys.AD_TYPE to adType,
                AnalyticsParamKeys.AD_UNIT_ID to adUnitId,
                AnalyticsParamKeys.ERROR_CODE to errorCode,
                AnalyticsParamKeys.ERROR_MESSAGE to errorMessage
            )
        )
    }

    fun logAdShowCall(context: Context, adType: String, adUnitId: String?, screenClass: String?, callerFunction: String?) {
        logEvent(
            context = context,
            name = AnalyticsEventNames.AD_SHOW_CALL,
            params = mapOf(
                AnalyticsParamKeys.AD_TYPE to adType,
                AnalyticsParamKeys.AD_UNIT_ID to adUnitId,
                AnalyticsParamKeys.SCREEN_CLASS to screenClass,
                AnalyticsParamKeys.CALLER_FUNCTION to callerFunction
            )
        )
    }

    fun logAdImpression(context: Context, adType: String, adUnitId: String?, screenClass: String?, callerFunction: String?) {
        logEvent(
            context = context,
            name = AnalyticsEventNames.AD_IMPRESSION,
            params = mapOf(
                AnalyticsParamKeys.AD_TYPE to adType,
                AnalyticsParamKeys.AD_UNIT_ID to adUnitId,
                AnalyticsParamKeys.SCREEN_CLASS to screenClass,
                AnalyticsParamKeys.CALLER_FUNCTION to callerFunction
            )
        )
    }

    fun logAdShowFail(
        context: Context,
        adType: String,
        adUnitId: String?,
        screenClass: String?,
        callerFunction: String?,
        errorCode: Int?,
        errorMessage: String?
    ) {
        logEvent(
            context = context,
            name = AnalyticsEventNames.AD_SHOW_FAIL,
            params = mapOf(
                AnalyticsParamKeys.AD_TYPE to adType,
                AnalyticsParamKeys.AD_UNIT_ID to adUnitId,
                AnalyticsParamKeys.SCREEN_CLASS to screenClass,
                AnalyticsParamKeys.CALLER_FUNCTION to callerFunction,
                AnalyticsParamKeys.ERROR_CODE to errorCode,
                AnalyticsParamKeys.ERROR_MESSAGE to errorMessage
            )
        )
    }

    private fun logEvent(context: Context, name: String, params: Map<String, Any?>) {
        try {
            val bundle = Bundle()
            params.forEach { (k, v) ->
                when (v) {
                    null -> {
                        // skip null to keep payload clean
                    }
                    is String -> bundle.putString(k, v)
                    is Int -> bundle.putInt(k, v)
                    is Long -> bundle.putLong(k, v.toLong())
                    is Boolean -> bundle.putString(k, v.toString())
                    is Double -> bundle.putDouble(k, v)
                    else -> bundle.putString(k, v.toString())
                }
            }
            analytics(context).logEvent(name, bundle)
        } catch (_: Throwable) {
            // Never crash app because of analytics.
        }
    }
}


