package com.example.flutter_ads_native.inter_reward.admob

import android.content.Context
import com.google.android.gms.ads.MobileAds

/**
 * Thin wrapper to initialize Google Mobile Ads SDK (AdMob).
 * This should be called once from Application.onCreate().
 *
 * Meta Audience Network bidding is configured via:
 *  - AdMob UI (Mediation -> Bidding partners)
 *  - Meta adapter dependency in build.gradle.
 */
object AdMobAdsInitializer {
    private var initialized = false

    fun init(context: Context) {
        if (initialized) return

        android.util.Log.d("AdMobInit", "Initializing AdMob SDK...")
        MobileAds.initialize(context) { initializationStatus ->
            android.util.Log.d("AdMobInit", "AdMob initialization status: ${initializationStatus.adapterStatusMap}")
            // Optional: you can log adapter status here
        }

        initialized = true
        android.util.Log.d("AdMobInit", "AdMob SDK initialized")
    }
}

