package com.example.flutter_ads_native

import android.app.Application
import com.facebook.FacebookSdk
import com.facebook.appevents.AppEventsLogger

open class NativeAdsApplication: Application() {
    override fun onCreate() {
        super.onCreate()
//        FacebookSdk.sdkInitialize(this)
//        AppEventsLogger.activateApp(this)
    }
}