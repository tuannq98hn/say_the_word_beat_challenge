package com.example.flutter_ads_native.tracking

/**
 * Centralized analytics parameter keys for the local ads plugin.
 */
object AnalyticsParamKeys {
    // Shared
    const val RESULT = "result" // success|fail|start

    // Ad context
    const val AD_TYPE = "ad_type" // interstitial|rewarded|rewarded_interstitial|banner|native
    const val AD_UNIT_ID = "ad_unit_id"

    // Flutter context (passed down on show())
    const val SCREEN_CLASS = "screen_class"
    const val CALLER_FUNCTION = "caller_function"

    // Error
    const val ERROR_CODE = "error_code"
    const val ERROR_MESSAGE = "error_message"
}


