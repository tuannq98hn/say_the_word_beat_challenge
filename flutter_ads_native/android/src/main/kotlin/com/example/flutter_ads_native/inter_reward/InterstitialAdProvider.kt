package com.example.flutter_ads_native.inter_reward

import android.app.Activity
import android.content.Context

/**
 * Abstraction for an interstitial ad provider.
 * This allows you to swap out AdMob with another mediation later
 * (e.g., MAX) without changing Flutter or MyCustomAdManager.
 */
interface InterstitialAdProvider {
    /**
     * Preload / load an interstitial ad.
     * Should be called early (e.g., app start or before showing).
     */
    fun load(context: Context, adUnitId: String, callback: AdLoadCallback? = null)

    /**
     * Show the interstitial ad if ready.
     * If not ready, callback.onAdFailedToShow should be invoked.
     */
    fun show(activity: Activity, callback: InterstitialAdCallback?)

    /**
     * Check if interstitial ad is ready to show.
     */
    fun isReady(): Boolean
}

