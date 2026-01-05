package com.example.flutter_ads_native.inter_reward.admob

import android.app.Activity
import android.content.Context
import com.google.android.gms.ads.AdError
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.FullScreenContentCallback
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.rewarded.RewardItem
import com.google.android.gms.ads.rewardedinterstitial.RewardedInterstitialAd
import com.google.android.gms.ads.rewardedinterstitial.RewardedInterstitialAdLoadCallback
import com.example.flutter_ads_native.inter_reward.AdLoadCallback
import com.example.flutter_ads_native.inter_reward.AdsConfig
import com.example.flutter_ads_native.inter_reward.RewardedInterstitialAdCallback
import com.example.flutter_ads_native.inter_reward.RewardedInterstitialAdProvider
import com.example.flutter_ads_native.tracking.AdTypes
import com.example.flutter_ads_native.tracking.AdsAnalytics
import com.example.flutter_ads_native.tracking.AdsShowContext
import com.example.flutter_ads_native.tiktok_event.TikTokAdMobLogger
import com.example.flutter_ads_native.tiktok_event.TikTokAdTracker
import com.facebook.appevents.AppEventsLogger
import com.example.flutter_ads_native.facebook_event.FacebookROASTracker

/**
 * Rewarded Interstitial implementation using AdMob mediation.
 * Meta bidding is also handled under the hood via AdMob.
 */
class AdMobRewardedInterstitialProvider : RewardedInterstitialAdProvider {

    private var rewardedInterstitialAd: RewardedInterstitialAd? = null
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
            load(context, AdsConfig.REWARDED_INTERSTITIAL_ADMOB, callback)
            return
        }

        val adUnitId = adUnitIds[currentIndex]
        load(context, adUnitId, callback)
        
        // Rotate to next index for next load
        currentIndex = (currentIndex + 1) % adUnitIds.size
    }

    override fun load(context: Context, adUnitId: String, callback: AdLoadCallback?) {
        lastAdUnitId = adUnitId
        AdsAnalytics.logAdLoadStart(context, AdTypes.REWARDED_INTERSTITIAL, adUnitId)

        android.util.Log.d("AdMobRewardedInterstitial", "Loading rewarded interstitial ad with unit ID: $adUnitId")
        
        val adRequest = AdRequest.Builder().build()

        RewardedInterstitialAd.load(
            context,
            adUnitId,
            adRequest,
            object : RewardedInterstitialAdLoadCallback() {
                override fun onAdLoaded(ad: RewardedInterstitialAd) {
                    android.util.Log.d("AdMobRewardedInterstitial", "Rewarded interstitial ad loaded successfully")
                    rewardedInterstitialAd = ad
                    AdsAnalytics.logAdLoadSuccess(context, AdTypes.REWARDED_INTERSTITIAL, adUnitId)
                    callback?.onAdLoaded(adUnitId)
                    val facebookEventLogger = AppEventsLogger.newLogger(context)
                    TikTokAdMobLogger.bindRewardedInterstitialRevenue(context,ad, adUnitId, tracker)
                    FacebookROASTracker.bindRewardedInterstitialRevenue(context,ad, adUnitId, facebookEventLogger)
                }

                override fun onAdFailedToLoad(error: LoadAdError) {
                    android.util.Log.e("AdMobRewardedInterstitial", "Rewarded interstitial ad failed to load: ${error.code} - ${error.message}")
                    rewardedInterstitialAd = null
                    AdsAnalytics.logAdLoadFail(
                        context = context,
                        adType = AdTypes.REWARDED_INTERSTITIAL,
                        adUnitId = adUnitId,
                        errorCode = error.code,
                        errorMessage = error.message
                    )
                    callback?.onAdFailedToLoad(adUnitId, error.code, error.message)
                }
            }
        )
    }

    override fun show(activity: Activity, callback: RewardedInterstitialAdCallback?) {
        val ad = rewardedInterstitialAd
        if (ad == null) {
            callback?.onAdFailedToShow(lastAdUnitId, null, "Rewarded interstitial ad not ready")
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
                rewardedInterstitialAd = null
                // Preload next ad using rotation
                loadNext(activity.applicationContext, null)
            }

            override fun onAdFailedToShowFullScreenContent(error: AdError) {
                val ctx = AdsShowContext.getForAdType(AdTypes.REWARDED_INTERSTITIAL)
                AdsAnalytics.logAdShowFail(
                    context = activity,
                    adType = AdTypes.REWARDED_INTERSTITIAL,
                    adUnitId = lastAdUnitId,
                    screenClass = ctx?.screenClass,
                    callerFunction = ctx?.callerFunction,
                    errorCode = error.code,
                    errorMessage = error.message
                )
                callback?.onAdFailedToShow(lastAdUnitId, error.code, error.message)
                rewardedInterstitialAd = null
                // Try to preload next ad using rotation
                loadNext(activity.applicationContext, null)
            }

            override fun onAdImpression() {
                if(lastAdUnitId != null) {
                    val ctx = AdsShowContext.getForAdType(AdTypes.REWARDED_INTERSTITIAL)
                    AdsAnalytics.logAdImpression(
                        context = activity,
                        adType = AdTypes.REWARDED_INTERSTITIAL,
                        adUnitId = lastAdUnitId,
                        screenClass = ctx?.screenClass,
                        callerFunction = ctx?.callerFunction
                    )
                    val facebookEventLogger = AppEventsLogger.newLogger(activity)
                    TikTokAdMobLogger.logImpression(
                        activity,
                        tracker,
                        lastAdUnitId!!,
                        "INTERSTITIAL_REWARDED",
                        ad.responseInfo
                    )
                    FacebookROASTracker.logImpression(
                        activity,
                        facebookEventLogger,
                        lastAdUnitId!!,
                        "INTERSTITIAL_REWARDED",
                        ad.responseInfo
                    )
                }
            }
            override fun onAdClicked() {
                if(lastAdUnitId != null) {
                    val facebookEventLogger = AppEventsLogger.newLogger(activity)
                    TikTokAdMobLogger.logClick(
                        activity,
                        tracker,
                        lastAdUnitId!!,
                        "INTERSTITIAL_REWARDED",
                        ad.responseInfo
                    )
                    FacebookROASTracker.logClick(
                        activity,
                        facebookEventLogger,
                        lastAdUnitId!!,
                        "INTERSTITIAL_REWARDED",
                        ad.responseInfo
                    )
                }
            }
        }

        ad.show(activity) { rewardItem: RewardItem ->
            callback?.onUserEarnedReward(rewardItem.type, rewardItem.amount)
        }
    }

    override fun isReady(): Boolean {
        return rewardedInterstitialAd != null
    }

    fun getLastAdUnitId(): String? = lastAdUnitId
}
