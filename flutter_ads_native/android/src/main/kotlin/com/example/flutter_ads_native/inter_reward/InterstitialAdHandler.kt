package com.example.flutter_ads_native.inter_reward

import android.app.Activity
import android.content.Context
import com.example.flutter_ads_native.AdsEventStreamHandler
import com.example.flutter_ads_native.tracking.AdTypes
import com.example.flutter_ads_native.tracking.AdsAnalytics
import com.example.flutter_ads_native.tracking.AdsShowContext
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Handles interstitial ads-related method calls from Flutter via MethodChannel.
 */
class InterstitialAdHandler(
    private val activity: Activity,
    private val context: Context,
    private val eventHandler: AdsEventStreamHandler
) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "ads_init" -> {
                // Get interstitial ad unit IDs from arguments if provided
                @Suppress("UNCHECKED_CAST")
                val interstitialAdUnitIds = call.argument<List<String>>("interstitialAdUnitIds")
                
                // Set interstitial ad unit IDs for rotation if provided
                if (interstitialAdUnitIds != null && interstitialAdUnitIds.isNotEmpty()) {
                    MyCustomAdManager.setInterstitialAdUnitIds(interstitialAdUnitIds)
                }
                
                // Preload interstitial ads with callbacks
                MyCustomAdManager.preloadInterstitial(  
                    context,
                    object : AdLoadCallback {
                        override fun onAdLoaded(adUnitId: String) {
                            eventHandler.sendEvent(AdsEventStreamHandler.EVENT_INTERSTITIAL_LOADED)
                        }

                        override fun onAdFailedToLoad(adUnitId: String, errorCode: Int?, errorMessage: String?) {
                            eventHandler.sendEvent(
                                AdsEventStreamHandler.EVENT_INTERSTITIAL_FAILED,
                                mapOf(
                                    "error" to (errorMessage ?: "Failed to load"),
                                    "adUnitId" to adUnitId,
                                    "errorCode" to errorCode,
                                    "errorMessage" to errorMessage
                                )
                            )
                        }
                    }
                )
                result.success(true)
            }
            "ads_load_interstitial" -> {
                MyCustomAdManager.preloadInterstitial(
                    context,
                    object : AdLoadCallback {
                        override fun onAdLoaded(adUnitId: String) {
                            eventHandler.sendEvent(AdsEventStreamHandler.EVENT_INTERSTITIAL_LOADED)
                        }

                        override fun onAdFailedToLoad(adUnitId: String, errorCode: Int?, errorMessage: String?) {
                            eventHandler.sendEvent(
                                AdsEventStreamHandler.EVENT_INTERSTITIAL_FAILED,
                                mapOf(
                                    "error" to (errorMessage ?: "Failed to load"),
                                    "adUnitId" to adUnitId,
                                    "errorCode" to errorCode,
                                    "errorMessage" to errorMessage
                                )
                            )
                            // Try to load next ad unit ID in rotation
                            MyCustomAdManager.preloadInterstitial(context, null)
                        }
                    }
                )
                result.success(true)
            }
            "ads_is_interstitial_ready" -> {
                result.success(MyCustomAdManager.isInterstitialReady())
            }
            "ads_show_interstitial" -> {
                val screenClass = call.argument<String>("screenClass")
                val callerFunction = call.argument<String>("callerFunction")
                AdsShowContext.setForAdType(AdTypes.INTERSTITIAL, screenClass, callerFunction)
                AdsAnalytics.logAdShowCall(
                    context = context,
                    adType = AdTypes.INTERSTITIAL,
                    adUnitId = MyCustomAdManager.getLastInterstitialAdUnitId(),
                    screenClass = screenClass,
                    callerFunction = callerFunction
                )

                val isReady = MyCustomAdManager.isInterstitialReady()
                if (!isReady) {
                    AdsAnalytics.logAdShowFail(
                        context = context,
                        adType = AdTypes.INTERSTITIAL,
                        adUnitId = MyCustomAdManager.getLastInterstitialAdUnitId(),
                        screenClass = screenClass,
                        callerFunction = callerFunction,
                        errorCode = null,
                        errorMessage = "AD_NOT_READY"
                    )
                    result.error("AD_NOT_READY", "Interstitial ad is not ready", null)
                    return
                }

                MyCustomAdManager.showInterstitial(
                    activity,
                    object : InterstitialAdCallback {
                        override fun onAdShown() {
                            eventHandler.sendEvent(AdsEventStreamHandler.EVENT_INTERSTITIAL_SHOWN)
                        }

                        override fun onAdClosed() {
                            eventHandler.sendEvent(AdsEventStreamHandler.EVENT_INTERSTITIAL_CLOSED)
                        }

                        override fun onAdFailedToShow(adUnitId: String?, errorCode: Int?, errorMessage: String?) {
                            eventHandler.sendEvent(
                                AdsEventStreamHandler.EVENT_INTERSTITIAL_FAILED,
                                mapOf(
                                    "error" to (errorMessage ?: "Unknown error"),
                                    "adUnitId" to adUnitId,
                                    "errorCode" to errorCode,
                                    "errorMessage" to errorMessage
                                )
                            )
                        }
                    }
                )
                result.success(true)
            }
            "ads_record_action" -> {
                InterstitialConditions.recordAction(context)
                result.success(true)
            }
            "ads_can_show_interstitial" -> {
                result.success(InterstitialConditions.canShowInterstitial(context))
            }
            "ads_record_interstitial_shown" -> {
                InterstitialConditions.recordInterstitialShown(context)
                result.success(true)
            }
            "ads_reset_interstitial_session" -> {
                InterstitialConditions.resetSession(context)
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }
}
