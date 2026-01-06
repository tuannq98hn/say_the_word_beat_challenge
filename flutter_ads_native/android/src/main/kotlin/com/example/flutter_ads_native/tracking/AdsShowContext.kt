package com.example.flutter_ads_native.tracking

/**
 * Stores the latest "show request" context coming from Flutter so native impression/callback
 * can attribute events to a screen/caller.
 *
 * This is best-effort only; it may be overwritten if multiple show calls happen quickly.
 */
object AdsShowContext {
    @Volatile
    private var interstitial: ShowContext? = null
    @Volatile
    private var rewarded: ShowContext? = null
    @Volatile
    private var rewardedInterstitial: ShowContext? = null

    data class ShowContext(
        val screenClass: String?,
        val callerFunction: String?
    )

    fun setForAdType(adType: String, screenClass: String?, callerFunction: String?) {
        val ctx = ShowContext(screenClass = screenClass, callerFunction = callerFunction)
        when (adType) {
            AdTypes.INTERSTITIAL -> interstitial = ctx
            AdTypes.REWARDED -> rewarded = ctx
            AdTypes.REWARDED_INTERSTITIAL -> rewardedInterstitial = ctx
        }
    }

    fun getForAdType(adType: String): ShowContext? {
        return when (adType) {
            AdTypes.INTERSTITIAL -> interstitial
            AdTypes.REWARDED -> rewarded
            AdTypes.REWARDED_INTERSTITIAL -> rewardedInterstitial
            else -> null
        }
    }
}


