package com.example.flutter_ads_native.inter_reward


import android.app.Activity

/**
 * Interface for rewarded interstitial ad providers.
 * Allows switching between different mediation platforms (AdMob, MAX, etc.)
 */
interface RewardedInterstitialAdProvider {
    fun load(context: android.content.Context, adUnitId: String, callback: AdLoadCallback?)
    fun show(activity: Activity, callback: RewardedInterstitialAdCallback?)
    fun isReady(): Boolean
}

/**
 * Callback interface for rewarded interstitial ad events.
 */
interface RewardedInterstitialAdCallback {
    fun onAdShown()
    fun onAdClosed()
    fun onUserEarnedReward(rewardType: String, rewardAmount: Int)
    fun onAdFailedToShow(adUnitId: String?, errorCode: Int?, errorMessage: String?)
}
