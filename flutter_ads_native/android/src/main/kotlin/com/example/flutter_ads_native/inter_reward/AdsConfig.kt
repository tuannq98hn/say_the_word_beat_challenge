package com.example.flutter_ads_native.inter_reward

/**
 * Centralized ad configuration.
 * - Define all Ad Unit IDs here (per environment / flavor if needed).
 * - Define which mediation platform is currently active.
 *
 * NOTE:
 *  - Meta Audience Network is configured as a *bidding* ad source inside AdMob console.
 *  - There is no direct Meta-specific code here.
 */
object AdsConfig {
    // Active mediation platform (for future extension: MAX, LevelPlay, etc.)
    val currentMediationPlatform: AdsMediationPlatform = AdsMediationPlatform.ADMOB

    // AdMob Ad Unit IDs - Production IDs
    // Meta Audience Network bidding is configured via AdMob console
    const val INTERSTITIAL_ADMOB = "ca-app-pub-3940256099942544/1033173712"
    const val REWARDED_ADMOB    = "ca-app-pub-3940256099942544/5224354917"
    const val REWARDED_INTERSTITIAL_ADMOB = "ca-app-pub-3940256099942544/5354046379"

    // If you have different IDs for UAT/DEV, you can:
    // - Add more constants, or
    // - Use BuildConfig.FLAVOR / BuildConfig.BUILD_TYPE to switch at runtime.
}

