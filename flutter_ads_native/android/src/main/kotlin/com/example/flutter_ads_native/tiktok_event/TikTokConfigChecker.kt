package com.example.flutter_ads_native.tiktok_event

import android.content.Context
import android.content.pm.PackageManager

object TikTokConfigChecker {

    private var checked = false
    private var enabled = false

    fun isEnabled(context: Context): Boolean {
        if (checked) return enabled

        enabled = try {
            val appInfo = context.packageManager.getApplicationInfo(
                context.packageName,
                PackageManager.GET_META_DATA
            )

            val accessToken =
                appInfo.metaData?.getString("com.tiktok.sdk.AccessToken")
            val appId =
                appInfo.metaData?.getString("com.tiktok.sdk.AppId")

            !accessToken.isNullOrBlank() && !appId.isNullOrBlank()
        } catch (e: Exception) {
            false
        }

        checked = true
        return enabled
    }
}
