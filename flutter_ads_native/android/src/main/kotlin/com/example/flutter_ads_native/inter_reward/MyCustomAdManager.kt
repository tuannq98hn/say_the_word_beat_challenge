package com.example.flutter_ads_native.inter_reward

import android.app.Activity
import android.content.Context
import com.example.flutter_ads_native.inter_reward.admob.AdMobInterstitialProvider
import com.example.flutter_ads_native.inter_reward.admob.AdMobRewardedProvider
import com.example.flutter_ads_native.inter_reward.admob.AdMobRewardedInterstitialProvider

/**
 * MyCustomAdManager is the single entry point for Flutter (via MethodChannel).
 *
 * It hides:
 *  - Which mediation platform is used (AdMob, MAX, etc.)
 *  - How each ad type is implemented.
 *
 * Future:
 *  - To switch to MAX, create MaxInterstitialProvider / MaxRewardedProvider
 *    and change the provider creation below.
 */
object MyCustomAdManager {
    // Providers will be chosen based on AdsConfig.currentMediationPlatform.
    private val interstitialProvider: InterstitialAdProvider by lazy {
        when (AdsConfig.currentMediationPlatform) {
            AdsMediationPlatform.ADMOB -> AdMobInterstitialProvider()
            // AdsMediationPlatform.MAX -> MaxInterstitialProvider()
        }
    }

    private val rewardedProvider: RewardedAdProvider by lazy {
        when (AdsConfig.currentMediationPlatform) {
            AdsMediationPlatform.ADMOB -> AdMobRewardedProvider()
            // AdsMediationPlatform.MAX -> MaxRewardedProvider()
        }
    }

    private val rewardedInterstitialProvider: RewardedInterstitialAdProvider by lazy {
        when (AdsConfig.currentMediationPlatform) {
            AdsMediationPlatform.ADMOB -> AdMobRewardedInterstitialProvider()
            // AdsMediationPlatform.MAX -> MaxRewardedInterstitialProvider()
        }
    }

    fun setInterstitialAdUnitIds(adUnitIds: List<String>) {
        if (interstitialProvider is AdMobInterstitialProvider) {
            (interstitialProvider as AdMobInterstitialProvider).setAdUnitIds(adUnitIds)
        }
    }

    fun setRewardedAdUnitIds(adUnitIds: List<String>) {
        if (rewardedProvider is AdMobRewardedProvider) {
            (rewardedProvider as AdMobRewardedProvider).setAdUnitIds(adUnitIds)
        }
    }

    fun setRewardedInterstitialAdUnitIds(adUnitIds: List<String>) {
        if (rewardedInterstitialProvider is AdMobRewardedInterstitialProvider) {
            (rewardedInterstitialProvider as AdMobRewardedInterstitialProvider).setAdUnitIds(adUnitIds)
        }
    }

    fun preloadAll(context: Context) {
        preloadInterstitial(context)
        preloadRewarded(context)
        preloadRewardedInterstitial(context)
    }

    fun preloadInterstitial(context: Context, callback: AdLoadCallback? = null) {
        if (interstitialProvider is AdMobInterstitialProvider) {
            (interstitialProvider as AdMobInterstitialProvider).loadNext(context, callback)
        } else {
            // Fallback to default behavior
            interstitialProvider.load(context, AdsConfig.INTERSTITIAL_ADMOB, callback)
        }
    }

    fun preloadRewarded(context: Context, callback: AdLoadCallback? = null) {
        if (rewardedProvider is AdMobRewardedProvider) {
            (rewardedProvider as AdMobRewardedProvider).loadNext(context, callback)
        } else {
            // Fallback to default behavior
            rewardedProvider.load(context, AdsConfig.REWARDED_ADMOB, callback)
        }
    }

    fun showInterstitial(activity: Activity, callback: InterstitialAdCallback?) {
        interstitialProvider.show(activity, callback)
    }

    fun showRewarded(activity: Activity, callback: RewardedAdCallback?) {
        rewardedProvider.show(activity, callback)
    }

    fun isInterstitialReady(): Boolean {
        return interstitialProvider.isReady()
    }

    fun isRewardedReady(): Boolean {
        return rewardedProvider.isReady()
    }

    fun preloadRewardedInterstitial(context: Context, callback: AdLoadCallback? = null) {
        if (rewardedInterstitialProvider is AdMobRewardedInterstitialProvider) {
            (rewardedInterstitialProvider as AdMobRewardedInterstitialProvider).loadNext(context, callback)
        } else {
            // Fallback to default behavior
            rewardedInterstitialProvider.load(context, AdsConfig.REWARDED_INTERSTITIAL_ADMOB, callback)
        }
    }

    fun showRewardedInterstitial(activity: Activity, callback: RewardedInterstitialAdCallback?) {
        rewardedInterstitialProvider.show(activity, callback)
    }

    fun isRewardedInterstitialReady(): Boolean {
        return rewardedInterstitialProvider.isReady()
    }

    fun getLastInterstitialAdUnitId(): String? {
        return if (interstitialProvider is AdMobInterstitialProvider) {
            (interstitialProvider as AdMobInterstitialProvider).getLastAdUnitId()
        } else {
            null
        }
    }

    fun getLastRewardedAdUnitId(): String? {
        return if (rewardedProvider is AdMobRewardedProvider) {
            (rewardedProvider as AdMobRewardedProvider).getLastAdUnitId()
        } else {
            null
        }
    }

    fun getLastRewardedInterstitialAdUnitId(): String? {
        return if (rewardedInterstitialProvider is AdMobRewardedInterstitialProvider) {
            (rewardedInterstitialProvider as AdMobRewardedInterstitialProvider).getLastAdUnitId()
        } else {
            null
        }
    }
}

