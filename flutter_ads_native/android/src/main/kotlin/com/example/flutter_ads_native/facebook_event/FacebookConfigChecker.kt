package com.example.flutter_ads_native.facebook_event

import android.content.Context
import android.content.pm.PackageManager

object FacebookConfigChecker {

    private var checked = false
    private var enabled = false

    fun isEnabled(context: Context): Boolean {
        if (checked) return enabled

        enabled = try {
            val appInfo = context.packageManager.getApplicationInfo(
                context.packageName,
                PackageManager.GET_META_DATA
            )

            val appId = appInfo.metaData?.getString("com.facebook.sdk.ApplicationId")
            val clientToken = appInfo.metaData?.getString("com.facebook.sdk.ClientToken")

            !appId.isNullOrBlank() && !clientToken.isNullOrBlank()
        } catch (e: Exception) {
            false
        }

        checked = true
        return enabled
    }
}
