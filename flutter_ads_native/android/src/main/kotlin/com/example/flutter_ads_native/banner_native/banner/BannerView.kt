package com.example.flutter_ads_native.banner_native.banner

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.FrameLayout
import com.example.flutter_ads_native.AdsEventStreamHandler
import com.example.flutter_ads_native.R
import com.example.flutter_ads_native.facebook_event.FacebookROASTracker
import com.example.flutter_ads_native.tracking.AdTypes
import com.example.flutter_ads_native.tracking.AdsAnalytics
import com.example.flutter_ads_native.tiktok_event.TikTokAdMobLogger
import com.example.flutter_ads_native.tiktok_event.TikTokAdTracker
import com.facebook.appevents.AppEventsLogger
import com.google.android.gms.ads.AdListener
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.AdSize
import com.google.android.gms.ads.AdView
import com.google.android.gms.ads.LoadAdError
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class BannerView(
    private val context: Context,
    private val viewId: Int,
    private val params: Map<String, Any>?,
    private val channel: MethodChannel,
    private val eventHandler: AdsEventStreamHandler
) : PlatformView {

    private val root: View =
        LayoutInflater.from(context).inflate(R.layout.banner_layout, null, false)
    private lateinit var adView: AdView
    private val frameAds = root.findViewById<FrameLayout>(R.id.frmAdsBanner).apply {
        val adBannerSize = getAdSize(params)
        layoutParams = FrameLayout.LayoutParams(
            adBannerSize.getWidthInPixels(context),
            adBannerSize.getHeightInPixels(context)
        )
    }

    val tracker = TikTokAdTracker()
    val facebookEventLogger = AppEventsLogger.newLogger(context)

    init {
        loadBanner()
    }

    private fun loadBanner() {
        val adBannerSize = getAdSize(params)
        adView = AdView(context).apply {
            setAdSize(adBannerSize)
            adUnitId = params?.get("adUnitId") as? String
                ?: "ca-app-pub-3940256099942544/6300978111"
        }

        val ad_unit_id = params?.get("adUnitId") as? String
            ?: "ca-app-pub-3940256099942544/6300978111"

        val request = AdRequest.Builder().build()
        AdsAnalytics.logAdLoadStart(context, AdTypes.BANNER, ad_unit_id)
        TikTokAdMobLogger.bindBannerRevenue(context = context, adView, ad_unit_id, tracker)
        FacebookROASTracker.bindBannerRevenue(
            context = context,
            adView,
            ad_unit_id,
            facebookEventLogger
        )
        adView.loadAd(request)
        adView.adListener = object : AdListener() {
            override fun onAdImpression() {
                AdsAnalytics.logAdImpression(context, AdTypes.BANNER, ad_unit_id, null, null)
                eventHandler.sendEvent(
                    "banner_impression",
                    mapOf("id" to viewId, "adUnitId" to ad_unit_id)
                )
                TikTokAdMobLogger.logImpression(
                    context = context,
                    tracker = tracker,
                    adUnitId = ad_unit_id,
                    format = "BANNER",
                    responseInfo = adView.responseInfo
                )

                FacebookROASTracker.logImpression(
                    context = context,
                    logger = facebookEventLogger,
                    adUnitId = ad_unit_id,
                    format = "BANNER",
                    responseInfo = adView.responseInfo
                )

            }

            override fun onAdClicked() {
                TikTokAdMobLogger.logClick(
                    context = context,
                    tracker = tracker,
                    adUnitId = ad_unit_id,
                    format = "BANNER",
                    responseInfo = adView.responseInfo
                )
                FacebookROASTracker.logClick(
                    context = context,
                    logger = facebookEventLogger,
                    adUnitId = ad_unit_id,
                    format = "BANNER",
                    responseInfo = adView.responseInfo
                )
            }

            override fun onAdFailedToLoad(p0: LoadAdError) {
                super.onAdFailedToLoad(p0)
                frameAds.removeAllViews()
                // Notify Flutter that ad failed to load
                channel.invokeMethod("ads_custom_view_failed", mapOf("id" to viewId))
                AdsAnalytics.logAdLoadFail(
                    context = context,
                    adType = AdTypes.BANNER,
                    adUnitId = ad_unit_id,
                    errorCode = p0.code,
                    errorMessage = p0.message
                )
                eventHandler.sendEvent(
                    "ads_custom_view_failed",
                    mapOf(
                        "id" to viewId,
                        "adUnitId" to ad_unit_id,
                        "errorCode" to p0.code,
                        "errorMessage" to p0.message
                    )
                )
            }

            override fun onAdLoaded() {
                super.onAdLoaded()
                frameAds.removeAllViews()
                frameAds.addView(adView)
                AdsAnalytics.logAdLoadSuccess(context, AdTypes.BANNER, ad_unit_id)
                eventHandler.sendEvent(
                    "banner_loaded",
                    mapOf("id" to viewId, "adUnitId" to ad_unit_id)
                )
            }
        }
    }

    private fun getAdSize(params: Map<String, Any>?): AdSize {
        val adSize = params?.get("size") as? String ?: "BANNER"
        return when (adSize.uppercase()) {
            "LARGE_BANNER" -> AdSize.LARGE_BANNER
            "MEDIUM_RECTANGLE" -> AdSize.MEDIUM_RECTANGLE
            "FULL_BANNER" -> AdSize.FULL_BANNER
            "LEADERBOARD" -> AdSize.LEADERBOARD
            else -> AdSize.BANNER
        }
    }

    override fun getView(): View = root

    override fun dispose() {
        adView.destroy()
    }
}