package com.example.flutter_ads_native.banner_native.banner

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.FrameLayout
import com.example.flutter_ads_native.R
import com.example.flutter_ads_native.tiktok_event.TikTokAdMobLogger
import com.example.flutter_ads_native.tiktok_event.TikTokAdTracker
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
    private val channel: MethodChannel
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
        TikTokAdMobLogger.bindBannerRevenue(adView, ad_unit_id, tracker)
        adView.loadAd(request)
        adView.adListener = object : AdListener() {
            override fun onAdImpression() {
                TikTokAdMobLogger.logImpression(
                    tracker = tracker,
                    adUnitId = ad_unit_id,
                    format = "BANNER",
                    responseInfo = adView.responseInfo
                )
            }

            override fun onAdClicked() {
                TikTokAdMobLogger.logClick(
                    tracker = tracker,
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
            }

            override fun onAdLoaded() {
                super.onAdLoaded()
                frameAds.removeAllViews()
                frameAds.addView(adView)
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