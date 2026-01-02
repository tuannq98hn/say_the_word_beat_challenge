package com.example.flutter_ads_native.inter_reward.admob

import android.app.Activity
import android.content.Context
import com.example.flutter_ads_native.facebook_event.FacebookROASTracker
import com.example.flutter_ads_native.inter_reward.AdLoadCallback
import com.example.flutter_ads_native.inter_reward.AdsConfig
import com.example.flutter_ads_native.inter_reward.InterstitialAdCallback
import com.example.flutter_ads_native.inter_reward.InterstitialAdProvider
import com.example.flutter_ads_native.tiktok_event.TikTokAdMobLogger
import com.example.flutter_ads_native.tiktok_event.TikTokAdTracker
import com.facebook.appevents.AppEventsLogger
import com.google.android.gms.ads.AdError
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.FullScreenContentCallback
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.interstitial.InterstitialAd
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback

/**
 * Interstitial implementation using AdMob mediation.
 * NOTE:
 *  - Meta Audience Network bidding is handled automatically via
 *    AdMob mediation + Meta adapter + config in AdMob console.
 *  - This code does NOT call Meta SDK directly.
 */
class AdMobInterstitialProvider : InterstitialAdProvider {

    private var interstitialAd: InterstitialAd? = null
    private var lastAdUnitId: String? = null

    // List of ad unit IDs for rotation
    private var adUnitIds: MutableList<String> = mutableListOf()
    private var currentIndex: Int = 0

    val tracker = TikTokAdTracker()

    /**
     * Set list of ad unit IDs for rotation
     */
    fun setAdUnitIds(ids: List<String>) {
        if (ids.isNotEmpty()) {
            adUnitIds.clear()
            adUnitIds.addAll(ids)
            currentIndex = 0
        }
    }

    /**
     * Load next ad unit ID in rotation
     */
    fun loadNext(context: Context, callback: AdLoadCallback?) {
        if (adUnitIds.isEmpty()) {
            // Fallback to default if no rotation IDs set
            load(context, AdsConfig.INTERSTITIAL_ADMOB, callback)
            return
        }

        val adUnitId = adUnitIds[currentIndex]
        load(context, adUnitId, callback)

        // Rotate to next index for next load
        currentIndex = (currentIndex + 1) % adUnitIds.size
    }

    override fun load(context: Context, adUnitId: String, callback: AdLoadCallback?) {
        lastAdUnitId = adUnitId
        val facebookEventLogger = AppEventsLogger.newLogger(context)
        val adRequest = AdRequest.Builder().build()

        InterstitialAd.load(
            context,
            adUnitId,
            adRequest,
            object : InterstitialAdLoadCallback() {
                override fun onAdLoaded(ad: InterstitialAd) {
                    interstitialAd = ad
                    callback?.onAdLoaded()
                    TikTokAdMobLogger.bindInterstitialRevenue(
                        context = context,
                        ad,
                        adUnitId,
                        tracker
                    )
                    FacebookROASTracker.bindInterstitialRevenue(
                        context = context,
                        ad,
                        adUnitId,
                        facebookEventLogger
                    )
                }

                override fun onAdFailedToLoad(error: LoadAdError) {
                    interstitialAd = null
                    callback?.onAdFailedToLoad(error.message)
                }
            }
        )
    }

    override fun show(activity: Activity, callback: InterstitialAdCallback?) {
        val ad = interstitialAd
        if (ad == null) {
            callback?.onAdFailedToShow("Interstitial ad not ready")
            // Optionally trigger a new load using rotation
            loadNext(activity.applicationContext, null)
            return
        }

        ad.fullScreenContentCallback = object : FullScreenContentCallback() {
            override fun onAdShowedFullScreenContent() {
                callback?.onAdShown()
            }

            override fun onAdDismissedFullScreenContent() {
                callback?.onAdClosed()
                interstitialAd = null
                // Preload next ad using rotation
                loadNext(activity.applicationContext, null)
            }

            override fun onAdFailedToShowFullScreenContent(error: AdError) {
                callback?.onAdFailedToShow(error.message)
                interstitialAd = null
                // Try to preload next ad using rotation
                loadNext(activity.applicationContext, null)
            }

            override fun onAdImpression() {
                if (lastAdUnitId != null) {
                    val facebookEventLogger = AppEventsLogger.newLogger(activity)
                    TikTokAdMobLogger.logImpression(
                        context = activity,
                        tracker,
                        lastAdUnitId!!,
                        "INTERSTITIAL",
                        ad.responseInfo
                    )

                    FacebookROASTracker.logImpression(
                        context = activity,
                        facebookEventLogger,
                        lastAdUnitId!!,
                        "INTERSTITIAL",
                        ad.responseInfo
                    )

                }
            }

            override fun onAdClicked() {
                if (lastAdUnitId != null) {
                    val facebookEventLogger = AppEventsLogger.newLogger(activity)
                    TikTokAdMobLogger.logClick(
                        context = activity,
                        tracker,
                        lastAdUnitId!!,
                        "INTERSTITIAL",
                        ad.responseInfo
                    )
                    FacebookROASTracker.logClick(
                        context = activity,
                        facebookEventLogger,
                        lastAdUnitId!!,
                        "INTERSTITIAL",
                        ad.responseInfo
                    )
                }
            }
        }

        ad.show(activity)
    }

    override fun isReady(): Boolean {
        return interstitialAd != null
    }
}

