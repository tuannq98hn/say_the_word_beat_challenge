package com.say.word.challenge.say_word_challenge

//import com.facebook.FacebookSdk
//import com.facebook.appevents.AppEventsLogger
import android.app.Activity
import android.app.Application
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.ProcessLifecycleOwner
import com.example.flutter_ads_native.NativeAdsApplication


class App : NativeAdsApplication(), Application.ActivityLifecycleCallbacks,
    DefaultLifecycleObserver {

    lateinit var openAdManager: AppOpenAdManager
    private var currentActivity: Activity? = null
    private var isAppInBackground = true
    private var hasShownAdOnStartup = false

    override fun onCreate() {
        super<NativeAdsApplication>.onCreate()
        openAdManager = AppOpenAdManager(this)
        openAdManager.loadAd { }

        registerActivityLifecycleCallbacks(this)
        ProcessLifecycleOwner.get().lifecycle.addObserver(this)
    }

    override fun onActivityResumed(activity: Activity) {
        currentActivity = activity
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
        if (isAppInBackground) {
            Handler(Looper.getMainLooper()).postDelayed({
                currentActivity?.let {
                    openAdManager.showIfAvailable(it)
                }
            }, 500)
        }
    }
}
