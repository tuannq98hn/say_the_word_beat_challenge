package com.example.flutter_ads_native.tracking

/**
 * Centralized analytics event names for the local ads plugin.
 *
 * Keep names short, stable and snake_case to work well with Firebase/GA4.
 */
object AnalyticsEventNames {
    // Ads
    const val AD_LOAD = "swc_ad_load" // attempt/result of load
    const val AD_SHOW_CALL = "swc_ad_show_call" // show() invoked from Flutter
    const val AD_IMPRESSION = "swc_ad_impression" // ad actually displayed (impression)
    const val AD_SHOW_FAIL = "swc_ad_show_fail" // failed to show full screen ad
}


