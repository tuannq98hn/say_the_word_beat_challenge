package com.example.flutter_ads_native.inter_reward

import android.app.Activity
import android.content.Context

/**
 * Abstraction for a rewarded ad provider.
 * Same idea as InterstitialAdProvider but for rewarded video.
 */
interface RewardedAdProvider {
    fun load(context: Context, adUnitId: String, callback: AdLoadCallback? = null)
    fun show(activity: Activity, callback: RewardedAdCallback?)
    
    /**
     * Check if rewarded ad is ready to show.
     */
    fun isReady(): Boolean
}

