package com.example.flutter_ads_native.banner_native.native

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.ProgressBar
import android.widget.RelativeLayout
import android.widget.TextView
import com.example.flutter_ads_native.AdsEventStreamHandler
import com.example.flutter_ads_native.R
import com.example.flutter_ads_native.tracking.AdTypes
import com.example.flutter_ads_native.tracking.AdsAnalytics
import com.example.flutter_ads_native.facebook_event.FacebookROASTracker
import com.example.flutter_ads_native.tiktok_event.TikTokAdMobLogger
import com.example.flutter_ads_native.tiktok_event.TikTokAdTracker
import com.facebook.appevents.AppEventsLogger
import com.google.android.gms.ads.AdListener
import com.google.android.gms.ads.AdLoader
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.VideoController
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class NativeCardView(
    context: Context,
    private val viewId: Int,
    private val params: Map<String, Any>?,
    private val channel: MethodChannel,
    private val eventHandler: AdsEventStreamHandler
) : PlatformView {
    lateinit var adLoader: AdLoader

    init {
        loadNativeAd(context, params)
    }

    val tracker = TikTokAdTracker()
    val facebookEventLogger = AppEventsLogger.newLogger(context)
    var nativeAds: NativeAd? = null
    var AD_UNIT_ID: String? = null

    private fun loadNativeAd(context: Context, params: Map<String, Any>?) {
        val adUnitId = params?.get("adUnitId")?.toString()
            ?: "ca-app-pub-3940256099942544/2247696110" // test id
        AdsAnalytics.logAdLoadStart(context, AdTypes.NATIVE, adUnitId)
        adLoader = AdLoader.Builder(context, adUnitId).forNativeAd { nativeAd ->
            val frmAdsLoading = root.findViewById<FrameLayout>(R.id.frmAdsNativeLoading)
            val frmAdsContent = root.findViewById<FrameLayout>(R.id.frmAdsContent)
            frmAdsLoading.visibility = View.GONE
            frmAdsContent.visibility = View.VISIBLE
            bindNativeAd(nativeAd)
            TikTokAdMobLogger.bindNativeRevenue(context = context, nativeAd, adUnitId, tracker)
            FacebookROASTracker.bindNativeRevenue(
                context = context, nativeAd, adUnitId, facebookEventLogger
            )
            nativeAds = nativeAd
            AD_UNIT_ID = adUnitId
        }.withAdListener(object : AdListener() {
            override fun onAdFailedToLoad(error: LoadAdError) {
                // Notify Flutter that ad failed to load
                eventHandler.sendEvent(
                    "ads_custom_view_failed",
                    mapOf(
                        "id" to viewId,
                        "adUnitId" to adUnitId,
                        "errorCode" to error.code,
                        "errorMessage" to error.message
                    )
                )
                AdsAnalytics.logAdLoadFail(
                    context = context,
                    adType = AdTypes.NATIVE,
                    adUnitId = adUnitId,
                    errorCode = error.code,
                    errorMessage = error.message
                )
            }

            override fun onAdImpression() {
                // Check null nativeAds and AD_UNIT_ID before logging impression
                if (nativeAds != null && AD_UNIT_ID != null) {
                    AdsAnalytics.logAdImpression(context, AdTypes.NATIVE, AD_UNIT_ID, null, null)
                    eventHandler.sendEvent(
                        "native_impression",
                        mapOf("id" to viewId, "adUnitId" to AD_UNIT_ID)
                    )
                    TikTokAdMobLogger.logNativeImpression(
                        context = context, tracker, AD_UNIT_ID!!, nativeAds!!
                    )
                    FacebookROASTracker.logNativeImpression(
                        context = context, facebookEventLogger, AD_UNIT_ID!!, nativeAds!!
                    )
                }
            }

            override fun onAdClicked() {
                if (nativeAds != null && AD_UNIT_ID != null) {
                    TikTokAdMobLogger.logNativeClick(
                        context = context, tracker, AD_UNIT_ID!!, nativeAds!!
                    )
                    FacebookROASTracker.logNativeClick(
                        context = context, facebookEventLogger, AD_UNIT_ID!!, nativeAds!!
                    )
                }
            }
        }).build()
        adLoader.loadAd(AdRequest.Builder().build())
    }

    private fun bindNativeAd(nativeAd: NativeAd) {

        // === GET ALL VIEWS ===
        // Find views - handle cases where views might not exist in some layouts
        try {
            val title = root.findViewById<TextView>(R.id.adTitle)
            val description = root.findViewById<TextView>(R.id.adDescription)
            val icon = root.findViewById<ImageView>(R.id.adIcon)
            val image = try {
                root.findViewById<ImageView>(R.id.adImage)
            } catch (ex: Exception) {
                null
            }
            val lnRating = try {
                root.findViewById<LinearLayout>(R.id.lnRating)
            } catch (ex: Exception) {
                null
            }
            val adView = root as NativeAdView
            val mediaView = try {
                root.findViewById<MediaView>(R.id.adMediaView)
            } catch (err: Exception) {
                null
            }
            val cta = root.findViewById<FrameLayout>(R.id.btnInstall)
            adView.callToActionView = cta
            adView.adChoicesView = root.findViewById(R.id.adChoicesView)
            adView.headlineView = title
            adView.bodyView = description
            adView.iconView = icon
            adView.starRatingView = lnRating
            val loadingMedia = try {
                root.findViewById<ProgressBar>(R.id.loadingMedia)
            } catch (err: Exception) {
                null
            }

            // Try to find Close button (may not exist in all layouts)
            val btnClose = try {
                root.findViewById<RelativeLayout>(R.id.btnClose)
            } catch (e: Exception) {
                null
            }
            btnClose?.setOnClickListener {
                // Notify Flutter that close button was clicked via EventChannel
                eventHandler.sendEvent("ads_custom_view_closed", mapOf("id" to viewId))
            }
            // === FILL DATA ===
            // Bind title
            title.text = nativeAd.headline ?: ""
            // Bind description

            if (nativeAd.body?.isNotEmpty() == true) {
                description.text = nativeAd.body ?: ""
            } else {
                description.visibility = View.GONE
            }
            // Bind icon/logo if available
            val iconDrawable = nativeAd.icon?.drawable
            if (icon != null) {
                if (iconDrawable != null) {
                    icon.setImageDrawable(iconDrawable)
                    icon.visibility = View.VISIBLE
                    // Make sure icon container is visible
                    val iconContainer = icon.parent as? View
                    iconContainer?.visibility = View.VISIBLE
                } else {
                    // Hide icon container if no icon available
                    val iconContainer = icon.parent as? View
                    iconContainer?.visibility = View.GONE
                }
            }
            adView.mediaView = null
            adView.imageView = null
            if (mediaView != null && nativeAd.mediaContent != null) {
                image?.visibility = View.GONE
                mediaView.visibility = View.VISIBLE

                adView.mediaView = mediaView
                mediaView.mediaContent = nativeAd.mediaContent!!
                if (nativeAd.mediaContent?.hasVideoContent() == true) {
                    nativeAd.mediaContent!!.videoController.videoLifecycleCallbacks =
                        object : VideoController.VideoLifecycleCallbacks() {
                            override fun onVideoPlay() {
                                super.onVideoPlay()
                                loadingMedia?.visibility = View.GONE
                            }

                            override fun onVideoStart() {
                                super.onVideoStart()
                                loadingMedia?.visibility = View.GONE
                            }
                        }
                } else {
                    loadingMedia?.visibility = View.GONE
                }
            } else if (image != null && nativeAd.images.isNotEmpty()) {
                adView.imageView = image
                image.setImageDrawable(nativeAd.images[0].drawable)

                image.visibility = View.VISIBLE
                mediaView?.visibility = View.GONE
                loadingMedia?.visibility = View.GONE
            } else if (image != null && iconDrawable != null) {
                image.setImageDrawable(iconDrawable)
                image.setPadding(0, 0, 0, 0)

                image.visibility = View.VISIBLE
                mediaView?.visibility = View.GONE
                loadingMedia?.visibility = View.GONE
            } else {
                image?.visibility = View.GONE
                mediaView?.visibility = View.GONE
                loadingMedia?.visibility = View.GONE
            }

            // CALL TO ACTION BUTTON
            val installText = root.findViewById<TextView>(R.id.install_text)
            installText?.text = nativeAd.callToAction ?: "Start now"

            if (lnRating != null) {
                val star1 = root.findViewById<ImageView>(R.id.star1)
                val star2 = root.findViewById<ImageView>(R.id.star2)
                val star3 = root.findViewById<ImageView>(R.id.star3)
                val star4 = root.findViewById<ImageView>(R.id.star4)
                val star5 = root.findViewById<ImageView>(R.id.star5)
                // --- Set rating stars ---
                // Update star rating if stars exist
                val stars = listOf(star1, star2, star3, star4, star5)
                if (nativeAd.starRating == null) {
                    lnRating.visibility = View.GONE
                    return
                }
                val rating = nativeAd.starRating ?: 0.0
                updateStarRating(rating, stars)
            }
            adView.setNativeAd(nativeAd)

        } catch (e: Exception) {
            // Handle any view binding errors gracefully
            e.printStackTrace()
        }
    }

    private fun updateStarRating(rating: Double, stars: List<ImageView>) {
        if (stars.isEmpty()) {
            return
        }

        for (i in stars.indices) {
            val starIndex = i + 1
            try {
                if (rating >= starIndex) {
                    stars[i].setImageResource(R.drawable.star_icon)   // sao sáng
                } else {
                    stars[i].setImageResource(R.drawable.star_icon_gray) // sao mờ
                }
            } catch (e: Exception) {
                // Handle case where drawable might not exist
                e.printStackTrace()
            }
        }
    }

    private fun getLayoutRes(params: Map<String, Any>?): Int {
        val adSize = params?.get("size") as? String ?: "BANNER"
        return when (adSize.uppercase()) {
            "FULL_SCREEN" -> R.layout.native_ad_full_screen
            "FULL_SCREEN_GUIDE" -> R.layout.native_ad_full_screen_guide
            "NATIVE_MEDIUM_RECTANGLE" -> R.layout.native_ad_card_medium_rectangle
            "NATIVE_MEDIUM_RECTANGLE_GUIDE" -> R.layout.native_ad_card_medium_rectangle_guide
            "NATIVE_FULL_BANNER" -> R.layout.native_ad_card_full_banner
            "NATIVE_LARGE" -> R.layout.native_ad_card_large
            else -> R.layout.native_ad_card
        }
    }

    private val root: View = LayoutInflater.from(context).inflate(getLayoutRes(params), null, false)

    override fun getView(): View = root

    override fun dispose() {
    }

    private fun isRootLargerThan120dp(root: View): Boolean {
        val density = root.resources.displayMetrics.density

        return root.measuredHeight / density >= 120f
    }

}
