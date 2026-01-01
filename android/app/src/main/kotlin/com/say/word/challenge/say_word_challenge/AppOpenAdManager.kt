package com.say.word.challenge.say_word_challenge

import android.app.Activity
import android.app.Application
import android.util.Log
import com.example.flutter_ads_native.tiktok_event.TikTokAdMobLogger
import com.example.flutter_ads_native.tiktok_event.TikTokAdTracker
import com.google.android.gms.ads.AdError
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.FullScreenContentCallback
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.appopen.AppOpenAd
import com.say.word.challenge.say_word_challenge.AppEventStreamHandler

class AppOpenAdManager(
    private val application: Application
) {
    private var eventHandler: AppEventStreamHandler? = null


    companion object {
        private const val TAG = "AppOpenAd"
        private var isSatingApp = true
        private val AD_UNIT_ID = "ca-app-pub-3361561931511510/8320459592"// TEST ID
    }

    private var appOpenAd: AppOpenAd? = null
    private var isLoading = false
    private var isShowing = false
    private var loadTime = 0L

    val tracker = TikTokAdTracker(debugLog = true)

    fun setEventHandler(handler: AppEventStreamHandler) {
        eventHandler = handler
    }

    fun loadAd(onAdLoaded: (() -> Unit)?) {
        if (isLoading || isAdAvailable()) return
        isLoading = true

        val request = AdRequest.Builder().build()

        AppOpenAd.load(
            application,          // Context
            AD_UNIT_ID, request, object : AppOpenAd.AppOpenAdLoadCallback() {

                override fun onAdLoaded(ad: AppOpenAd) {
                    eventHandler?.sendEvent("app_open_ad_loaded", null)
                    Log.d(TAG, "OpenAd loaded")
                    appOpenAd = ad
                    isLoading = false
                    loadTime = System.currentTimeMillis()
                    onAdLoaded?.invoke()
                    TikTokAdMobLogger.bindAppOpen(ad, AD_UNIT_ID, tracker)
                }

                override fun onAdFailedToLoad(error: LoadAdError) {
                    eventHandler?.sendEvent("app_open_ad_load_failed", null)
                    Log.e(TAG, "Load failed: ${error.message}")
                    isLoading = false
                }
            })
    }

    fun showIfAvailable(activity: Activity) {
        if (isShowing || !isAdAvailable()) return

        appOpenAd?.fullScreenContentCallback = object : FullScreenContentCallback() {

            override fun onAdShowedFullScreenContent() {
                isShowing = true
            }

            override fun onAdDismissedFullScreenContent() {
                appOpenAd = null
                isShowing = false
                // Emit event khi người dùng close app open ad
                eventHandler?.sendEvent("app_open_ad_closed", null)
                loadAd(null)
            }

            override fun onAdFailedToShowFullScreenContent(adError: AdError) {
                appOpenAd = null
                isShowing = false
                loadAd(null)
            }
        }

        appOpenAd?.show(activity)
    }

    private fun isAdAvailable(): Boolean {
        val fourHours = 4 * 60 * 60 * 1000
        return appOpenAd != null && System.currentTimeMillis() - loadTime < fourHours
    }
}
