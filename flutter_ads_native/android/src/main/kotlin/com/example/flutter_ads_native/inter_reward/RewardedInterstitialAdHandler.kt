package com.example.flutter_ads_native.inter_reward

import android.app.Activity
import android.content.Context
import com.example.flutter_ads_native.AdsEventStreamHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Handles rewarded interstitial ads-related method calls from Flutter via MethodChannel.
 */
class RewardedInterstitialAdHandler(
    private val activity: Activity,
    private val context: Context,
    private val eventHandler: AdsEventStreamHandler
) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "ads_init" -> {
                // Get rewarded interstitial ad unit IDs from arguments if provided
                @Suppress("UNCHECKED_CAST")
                val rewardedInterstitialAdUnitIds = call.argument<List<String>>("rewardedInterstitialAdUnitIds")
                
                // Set rewarded interstitial ad unit IDs for rotation if provided
                if (rewardedInterstitialAdUnitIds != null && rewardedInterstitialAdUnitIds.isNotEmpty()) {
                    MyCustomAdManager.setRewardedInterstitialAdUnitIds(rewardedInterstitialAdUnitIds)
                }
                
                // Preload rewarded interstitial ads with callbacks
                MyCustomAdManager.preloadRewardedInterstitial(
                    context,
                    object : AdLoadCallback {
                        override fun onAdLoaded() {
                            eventHandler.sendEvent(AdsEventStreamHandler.EVENT_REWARDED_INTERSTITIAL_LOADED)
                        }

                        override fun onAdFailedToLoad(errorMessage: String?) {
                            eventHandler.sendEvent(
                                AdsEventStreamHandler.EVENT_REWARDED_INTERSTITIAL_FAILED,
                                mapOf("error" to (errorMessage ?: "Failed to load"))
                            )
                        }
                    }
                )
                result.success(true)
            }
            "ads_load_rewarded_interstitial" -> {
                MyCustomAdManager.preloadRewardedInterstitial(
                    context,
                    object : AdLoadCallback {
                        override fun onAdLoaded() {
                            eventHandler.sendEvent(AdsEventStreamHandler.EVENT_REWARDED_INTERSTITIAL_LOADED)
                        }

                        override fun onAdFailedToLoad(errorMessage: String?) {
                            eventHandler.sendEvent(
                                AdsEventStreamHandler.EVENT_REWARDED_INTERSTITIAL_FAILED,
                                mapOf("error" to (errorMessage ?: "Failed to load"))
                            )
                            // Try to load next ad unit ID in rotation
                            MyCustomAdManager.preloadRewardedInterstitial(context, null)
                        }
                    }
                )
                result.success(true)
            }
            "ads_is_rewarded_interstitial_ready" -> {
                result.success(MyCustomAdManager.isRewardedInterstitialReady())
            }
            "ads_show_rewarded_interstitial" -> {
                val isReady = MyCustomAdManager.isRewardedInterstitialReady()
                if (!isReady) {
                    result.error("AD_NOT_READY", "Rewarded interstitial ad is not ready", null)
                    return
                }

                MyCustomAdManager.showRewardedInterstitial(
                    activity,
                    object : RewardedInterstitialAdCallback {
                        override fun onAdShown() {
                            eventHandler.sendEvent(AdsEventStreamHandler.EVENT_REWARDED_INTERSTITIAL_SHOWN)
                        }

                        override fun onAdClosed() {
                            eventHandler.sendEvent(AdsEventStreamHandler.EVENT_REWARDED_INTERSTITIAL_CLOSED)
                        }

                        override fun onUserEarnedReward(rewardType: String, rewardAmount: Int) {
                            eventHandler.sendEvent(
                                AdsEventStreamHandler.EVENT_REWARDED_INTERSTITIAL_EARNED,
                                mapOf(
                                    "rewardType" to rewardType,
                                    "rewardAmount" to rewardAmount
                                )
                            )
                        }

                        override fun onAdFailedToShow(errorMessage: String?) {
                            eventHandler.sendEvent(
                                AdsEventStreamHandler.EVENT_REWARDED_INTERSTITIAL_FAILED,
                                mapOf("error" to (errorMessage ?: "Unknown error"))
                            )
                        }
                    }
                )
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }
}
