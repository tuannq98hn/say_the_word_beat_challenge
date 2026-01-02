package com.say.word.challenge.say_word_challenge

import android.app.Activity
import android.app.Application
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.ProcessLifecycleOwner
import com.example.flutter_ads_native.NativeAdsApplication
//import com.facebook.FacebookSdk
//import com.facebook.appevents.AppEventsLogger
import com.google.android.gms.ads.MobileAds
//import com.tiktok.TikTokBusinessSdk
//import com.tiktok.TikTokBusinessSdk.TTConfig
//import com.rbxmaster.callsanta.R
//import com.tiktok.appevents.base.EventName


class App : NativeAdsApplication(), Application.ActivityLifecycleCallbacks, DefaultLifecycleObserver {

    lateinit var openAdManager: AppOpenAdManager
    private var currentActivity: Activity? = null
    private var isAppInBackground = true
    private var hasShownAdOnStartup = false

    override fun onCreate() {
        super<NativeAdsApplication>.onCreate()
        MobileAds.initialize(this)
//        AdMobAdsInitializer.init(this)
//        FacebookSdk.sdkInitialize(applicationContext)
//        AppEventsLogger.activateApp(this)
        openAdManager = AppOpenAdManager(this)
        openAdManager.loadAd {
            Handler(Looper.getMainLooper()).postDelayed({
                if (!hasShownAdOnStartup) {
                    hasShownAdOnStartup = true
                    currentActivity?.let {
                        openAdManager.showIfAvailable(it)
                    }
                }
            }, 300)
        }

        registerActivityLifecycleCallbacks(this)
        ProcessLifecycleOwner.get().lifecycle.addObserver(this)

//        val accessToken = getString(R.string.tiktok_app)
//        val appId = applicationContext.packageName
//        val tiktokAppId = getString(R.string.tiktok_app_id)
//
//        val ttConfig = TTConfig(applicationContext, accessToken)
//            .setAppId(appId)
//            .setTTAppId(tiktokAppId)
//
//        TikTokBusinessSdk.initializeSdk(ttConfig, object : TikTokBusinessSdk.TTInitCallback {
//            override fun success() {
//            }
//
//            override fun fail(code: Int, msg: String) {
//            }
//        })
//
//        TikTokBusinessSdk.startTrack()
//
//        TikTokBusinessSdk.trackTTEvent(EventName.LAUNCH_APP);

    }

    override fun onActivityResumed(activity: Activity) {
        currentActivity = activity

        // Show OpenAd lần đầu khi app khởi động
        if (!hasShownAdOnStartup) {
            isAppInBackground = false
            // Delay để đảm bảo activity đã sẵn sàng
            Handler(Looper.getMainLooper()).postDelayed({
                currentActivity?.let {
                    openAdManager.showIfAvailable(it)
                }
            }, 500)
        }
    }

    override fun onActivityPaused(activity: Activity) {
        // Đánh dấu app đang ở background
        isAppInBackground = true
    }

    // ===== Empty lifecycle =====
    override fun onActivityCreated(a: Activity, b: Bundle?) {}
    override fun onActivityStarted(activity: Activity) {
    }

    override fun onActivityStopped(a: Activity) {}
    override fun onActivitySaveInstanceState(a: Activity, b: Bundle) {}
    override fun onActivityDestroyed(a: Activity) {}

    override fun onStart(owner: LifecycleOwner) {
        // Show OpenAd khi app quay lại từ background (không phải lần đầu khởi động)
        if (hasShownAdOnStartup && isAppInBackground) {
            Handler(Looper.getMainLooper()).postDelayed({
                currentActivity?.let {
                    openAdManager.showIfAvailable(it)
                }
            }, 500)
        }
    }
}
