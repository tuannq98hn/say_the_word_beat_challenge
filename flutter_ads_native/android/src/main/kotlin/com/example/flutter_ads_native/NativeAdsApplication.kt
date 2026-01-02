package com.example.flutter_ads_native

import android.app.Application
import android.content.pm.PackageManager
import com.example.flutter_ads_native.inter_reward.admob.AdMobAdsInitializer
import com.facebook.FacebookSdk
import com.facebook.appevents.AppEventsLogger
import com.tiktok.TikTokBusinessSdk
import com.tiktok.TikTokBusinessSdk.TTConfig
import com.tiktok.appevents.base.EventName

open class NativeAdsApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        AdMobAdsInitializer.init(this)
        if (!FacebookSdk.isInitialized()) {
            FacebookSdk.fullyInitialize()
        }
        AppEventsLogger.activateApp(this)

        val appInfo = packageManager.getApplicationInfo(
            packageName, PackageManager.GET_META_DATA
        )
        val appId = applicationInfo.packageName

        val tiktokAppId = appInfo.metaData?.getString("com.tiktok.sdk.AppId")
        val tiktokAccessToken = appInfo.metaData?.getString("com.tiktok.sdk.AccessToken")

        val facebookAppId = appInfo.metaData?.getString("com.facebook.sdk.ApplicationId")
        val facebookClientToken = appInfo.metaData?.getString("com.facebook.sdk.ClientToken")

        if (tiktokAppId != null && tiktokAccessToken != null) {
            val ttConfig = TTConfig(applicationContext, tiktokAccessToken).setAppId(appId)
                .setTTAppId(tiktokAppId)

            TikTokBusinessSdk.initializeSdk(ttConfig, object : TikTokBusinessSdk.TTInitCallback {
                override fun success() {
                }

                override fun fail(code: Int, msg: String) {
                }
            })

            TikTokBusinessSdk.startTrack()

            TikTokBusinessSdk.trackTTEvent(EventName.LAUNCH_APP);
        }
    }
}