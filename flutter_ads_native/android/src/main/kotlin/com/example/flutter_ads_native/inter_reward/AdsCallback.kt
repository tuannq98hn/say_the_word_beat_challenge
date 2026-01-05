package com.example.flutter_ads_native.inter_reward

/**
 * Generic callback interfaces for ad events that Flutter may care about.
 * These are used inside native code. Flutter will receive a summarized result
 * through MethodChannel responses.
 */
interface InterstitialAdCallback {
    fun onAdShown()
    fun onAdClosed()
    fun onAdFailedToShow(adUnitId: String?, errorCode: Int?, errorMessage: String?)
}

interface RewardedAdCallback {
    fun onAdShown()
    fun onAdClosed()
    fun onUserEarnedReward(rewardType: String, rewardAmount: Int)
    fun onAdFailedToShow(adUnitId: String?, errorCode: Int?, errorMessage: String?)
}

interface AdLoadCallback {
    fun onAdLoaded(adUnitId: String)
    fun onAdFailedToLoad(adUnitId: String, errorCode: Int?, errorMessage: String?)
}

