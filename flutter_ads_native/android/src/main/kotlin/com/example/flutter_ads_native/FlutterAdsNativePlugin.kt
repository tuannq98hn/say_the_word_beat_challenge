package com.example.flutter_ads_native

import android.app.Activity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** FlutterAdsNativePlugin */
class FlutterAdsNativePlugin : FlutterPlugin, ActivityAware {

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        AdNativeManager.attachToEngine(flutterPluginBinding)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        AdNativeManager.onDetachedFromEngine(binding)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        AdNativeManager.setActivity(binding.activity)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        AdNativeManager.setActivity(null)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        AdNativeManager.setActivity(binding.activity)
    }

    override fun onDetachedFromActivity() {
        AdNativeManager.setActivity(null)
    }
}
