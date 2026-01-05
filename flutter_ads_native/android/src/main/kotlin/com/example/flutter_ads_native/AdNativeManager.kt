package com.example.flutter_ads_native

import android.app.Activity
import android.content.Context
import com.example.flutter_ads_native.banner_native.banner.BannerViewFactory
import com.example.flutter_ads_native.banner_native.native.NativeCardViewFactory
import com.example.flutter_ads_native.inter_reward.BannerAdHandler
import com.example.flutter_ads_native.inter_reward.InterstitialAdHandler
import com.example.flutter_ads_native.inter_reward.NativeAdHandler
import com.example.flutter_ads_native.inter_reward.RewardedAdHandler
import com.example.flutter_ads_native.inter_reward.RewardedInterstitialAdHandler
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

object AdNativeManager {

    val adsMap: Map<AdNativeAdsType, AdNativeInterface> = mapOf(
        AdNativeAdsType.NATIVE to AdNativePlugin(
            "com.example.flutter_native_ad.native_method_channel",
            "com.example.flutter_native_ad.native_event_channel"
        ), AdNativeAdsType.BANNER to AdBannerPlugin(
            "com.example.flutter_native_ad.banner_method_channel",
            "com.example.flutter_native_ad.banner_event_channel"
        ), AdNativeAdsType.INTERSTITIAL to AdInterstitialPlugin(
            "com.example.flutter_native_ad.interstitial_method_channel",
            "com.example.flutter_native_ad.interstitial_event_channel"
        ), AdNativeAdsType.REWARDED to AdRewardPlugin(
            "com.example.flutter_native_ad.rewarded_method_channel",
            "com.example.flutter_native_ad.rewarded_event_channel"
        ), AdNativeAdsType.REWARDED_INTERSTITIAL to AdRewardInterstitialPlugin(
            "com.example.flutter_native_ad.rewarded_interstitial_method_channel",
            "com.example.flutter_native_ad.rewarded_interstitial_event_channel"
        )
    )

    fun getAdNativeInterface(adNativeAdsType: AdNativeAdsType): AdNativeInterface {
        return adsMap[adNativeAdsType]
            ?: throw IllegalArgumentException("AdNativeInterface not found for adNativeAdsType: $adNativeAdsType")
    }

    fun attachToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        adsMap.forEach { (adNativeAdsType, adNativeInterface) ->
            adNativeInterface.onAttachedToEngine(flutterPluginBinding)
        }
    }

    fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        adsMap.forEach { (adNativeAdsType, adNativeInterface) ->
            adNativeInterface.onDetachedFromEngine(binding)
        }
    }

    fun setActivity(activity: Activity?) {
        adsMap.forEach { (adNativeAdsType, adNativeInterface) ->
            adNativeInterface.onAttachedToActivity(activity)
        }
    }
}

abstract class AdNativeInterface(val methodChannelName: String, val eventChannelName: String) {
    var activity: Activity? = null
    abstract fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding)
    abstract fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding)
    open fun onAttachedToActivity(activity: Activity?) {
        this.activity = activity
    }

    open fun onDetachedFromActivity() {
        activity = null
    }
}

abstract class AdHandlerPlugin<T : MethodChannel.MethodCallHandler>(
    methodChannelName: String,
    eventChannelName: String,
    private val handlerFactory: (Activity, Context, AdsEventStreamHandler) -> T
) : AdNativeInterface(methodChannelName, eventChannelName) {

    var methodChannel: MethodChannel? = null
    var eventChannel: EventChannel? = null
    var eventHandler: AdsEventStreamHandler? = null
    var handler: T? = null
    var context: Context? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, methodChannelName)
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, eventChannelName)
        eventHandler = AdsEventStreamHandler()
        eventChannel?.setStreamHandler(eventHandler)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel?.setMethodCallHandler(null)
        eventChannel?.setStreamHandler(null)
        methodChannel = null
        eventChannel = null
        eventHandler = null
        handler = null
        context = null
    }

    override fun onAttachedToActivity(activity: Activity?) {
        super.onAttachedToActivity(activity)
        activity?.let { act ->
            val ctx = context ?: act.applicationContext
            eventHandler?.let { eventHandler ->
                handler = handlerFactory(act, ctx, eventHandler)
                methodChannel?.setMethodCallHandler(handler)
            }
        } ?: run {
            handler = null
            methodChannel?.setMethodCallHandler(null)
        }
    }
}

class AdNativePlugin(methodChannelName: String, eventChannelName: String) :
    AdHandlerPlugin<NativeAdHandler>(
        methodChannelName,
        eventChannelName,
        { activity, context, eventHandler -> NativeAdHandler(activity, context, eventHandler) }) {
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        super.onAttachedToEngine(flutterPluginBinding)
        methodChannel?.let { channel ->
            eventHandler?.let { handler ->
                flutterPluginBinding.platformViewRegistry.registerViewFactory(
                    "ads_native_view",
                    NativeCardViewFactory(channel, handler)
                )
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        super.onDetachedFromEngine(binding)
    }
}

class AdBannerPlugin(methodChannelName: String, eventChannelName: String) :
    AdHandlerPlugin<BannerAdHandler>(
        methodChannelName,
        eventChannelName,
        { activity, context, eventHandler -> BannerAdHandler(activity, context, eventHandler) }) {
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        super.onAttachedToEngine(flutterPluginBinding)
        methodChannel?.let { channel ->
            eventHandler?.let { handler ->
                flutterPluginBinding.platformViewRegistry.registerViewFactory(
                    "ads_banner_view",
                    BannerViewFactory(channel, handler)
                )
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        super.onDetachedFromEngine(binding)
    }
}

class AdInterstitialPlugin(methodChannelName: String, eventChannelName: String) :
    AdHandlerPlugin<InterstitialAdHandler>(
        methodChannelName, eventChannelName, { activity, context, eventHandler ->
            InterstitialAdHandler(
                activity, context, eventHandler
            )
        })

class AdRewardPlugin(methodChannelName: String, eventChannelName: String) :
    AdHandlerPlugin<RewardedAdHandler>(
        methodChannelName,
        eventChannelName,
        { activity, context, eventHandler -> RewardedAdHandler(activity, context, eventHandler) })

class AdRewardInterstitialPlugin(methodChannelName: String, eventChannelName: String) :
    AdHandlerPlugin<RewardedInterstitialAdHandler>(
        methodChannelName, eventChannelName, { activity, context, eventHandler ->
            RewardedInterstitialAdHandler(
                activity, context, eventHandler
            )
        })

enum class AdNativeAdsType {
    NATIVE, BANNER, INTERSTITIAL, REWARDED, REWARDED_INTERSTITIAL
}