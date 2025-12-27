package com.example.flutter_ads_native.inter_reward

import android.app.Activity
import android.content.Context
import com.example.flutter_ads_native.AdsEventStreamHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Handles rewarded ads-related method calls from Flutter via MethodChannel.
 */
class RewardedAdHandler(
    private val activity: Activity,
    private val context: Context,
    private val eventHandler: AdsEventStreamHandler
) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "ads_init" -> {
                // Get rewarded ad unit IDs from arguments if provided
                @Suppress("UNCHECKED_CAST")
                val rewardedAdUnitIds = call.argument<List<String>>("rewardedAdUnitIds")
                
                // Set rewarded ad unit IDs for rotation if provided
                if (rewardedAdUnitIds != null && rewardedAdUnitIds.isNotEmpty()) {
                    MyCustomAdManager.setRewardedAdUnitIds(rewardedAdUnitIds)
                }
                
                // Preload rewarded ads with callbacks
                MyCustomAdManager.preloadRewarded(
                    context,
                    object : AdLoadCallback {
                        override fun onAdLoaded() {
                            eventHandler.sendEvent(AdsEventStreamHandler.EVENT_REWARDED_LOADED)
                        }

                        override fun onAdFailedToLoad(errorMessage: String?) {
                            eventHandler.sendEvent(
                                AdsEventStreamHandler.EVENT_REWARDED_FAILED,
                                mapOf("error" to (errorMessage ?: "Failed to load"))
                            )
                        }
                    }
                )
                result.success(true)
            }
            "ads_load_rewarded" -> {
                MyCustomAdManager.preloadRewarded(
                    context,
                    object : AdLoadCallback {
                        override fun onAdLoaded() {
                            eventHandler.sendEvent(AdsEventStreamHandler.EVENT_REWARDED_LOADED)
                        }

                        override fun onAdFailedToLoad(errorMessage: String?) {
                            eventHandler.sendEvent(
                                AdsEventStreamHandler.EVENT_REWARDED_FAILED,
                                mapOf("error" to (errorMessage ?: "Failed to load"))
                            )
                            // Try to load next ad unit ID in rotation
                            MyCustomAdManager.preloadRewarded(context, null)
                        }
                    }
                )
                result.success(true)
            }
            "ads_is_rewarded_ready" -> {
                result.success(MyCustomAdManager.isRewardedReady())
            }
            "ads_show_rewarded" -> {
                val isReady = MyCustomAdManager.isRewardedReady()
                if (!isReady) {
                    result.error("AD_NOT_READY", "Rewarded ad is not ready", null)
                    return
                }

                MyCustomAdManager.showRewarded(
                    activity,
                    object : RewardedAdCallback {
                        override fun onAdShown() {
                            eventHandler.sendEvent(AdsEventStreamHandler.EVENT_REWARDED_SHOWN)
                        }

                        override fun onAdClosed() {
                            eventHandler.sendEvent(AdsEventStreamHandler.EVENT_REWARDED_CLOSED)
                        }

                        override fun onUserEarnedReward(rewardType: String, rewardAmount: Int) {
                            eventHandler.sendEvent(
                                AdsEventStreamHandler.EVENT_REWARDED_EARNED,
                                mapOf(
                                    "rewardType" to rewardType,
                                    "rewardAmount" to rewardAmount
                                )
                            )
                        }

                        override fun onAdFailedToShow(errorMessage: String?) {
                            eventHandler.sendEvent(
                                AdsEventStreamHandler.EVENT_REWARDED_FAILED,
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
