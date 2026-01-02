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
import com.example.flutter_ads_native.tiktok_event.TikTokAdMobLogger
import com.example.flutter_ads_native.tiktok_event.TikTokAdTracker

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
                    callback?.onAdLoaded()
                    TikTokAdMobLogger.bindRewardedInterstitialRevenue(ad, adUnitId, tracker)
                }

                override fun onAdFailedToLoad(error: LoadAdError) {
                    android.util.Log.e("AdMobRewardedInterstitial", "Rewarded interstitial ad failed to load: ${error.code} - ${error.message}")
                    rewardedInterstitialAd = null
                    val errorMessage = "Error ${error.code}: ${error.message}"
                    callback?.onAdFailedToLoad(errorMessage)
                }
            }
        )
    }

    override fun show(activity: Activity, callback: RewardedInterstitialAdCallback?) {
        val ad = rewardedInterstitialAd
        if (ad == null) {
            callback?.onAdFailedToShow("Rewarded interstitial ad not ready")
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
                callback?.onAdFailedToShow(error.message)
                rewardedInterstitialAd = null
                // Try to preload next ad using rotation
                loadNext(activity.applicationContext, null)
            }

            override fun onAdImpression() {
                if(lastAdUnitId != null) TikTokAdMobLogger.logImpression(tracker, lastAdUnitId!!, "INTERSTITIAL_REWARDED", ad.responseInfo)
            }
            override fun onAdClicked() {
                if(lastAdUnitId != null) TikTokAdMobLogger.logClick(tracker, lastAdUnitId!!, "INTERSTITIAL_REWARDED", ad.responseInfo)
            }
        }

        ad.show(activity) { rewardItem: RewardItem ->
            callback?.onUserEarnedReward(rewardItem.type, rewardItem.amount)
        }
    }

    override fun isReady(): Boolean {
        return rewardedInterstitialAd != null
    }
}
