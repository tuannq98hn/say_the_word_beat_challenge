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

    private fun loadNativeAd(context: Context, params: Map<String, Any>?) {
        val adUnitId = params?.get("adUnitId")?.toString()
            ?: "ca-app-pub-3940256099942544/2247696110" // test id
        adLoader = AdLoader.Builder(context, adUnitId).forNativeAd { nativeAd ->
            val frmAdsLoading = root.findViewById<FrameLayout>(R.id.frmAdsNativeLoading)
            val frmAdsContent = root.findViewById<FrameLayout>(R.id.frmAdsContent)
            frmAdsLoading.visibility = View.GONE
            frmAdsContent.visibility = View.VISIBLE
            bindNativeAd(nativeAd)
        }.withAdListener(object : AdListener() {
            override fun onAdFailedToLoad(error: LoadAdError) {
                val frmNativeRoot = root.findViewById<FrameLayout>(R.id.frmNativeRoot)
//                frmNativeRoot.removeAllViews()
                // Notify Flutter that ad failed to load
                eventHandler.sendEvent("ads_custom_view_failed", mapOf("id" to viewId))
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
            cta.isClickable = true
            cta.isFocusable = true
            cta.isEnabled = true
            adView.callToActionView = cta
            adView.adChoicesView = root.findViewById(R.id.adChoicesView)
            adView.headlineView = title
            adView.bodyView = description
            adView.iconView = icon
            if (mediaView != null && nativeAd.mediaContent != null) {
                adView.mediaView = mediaView
                adView.imageView = null
            } else {
                adView.mediaView = null
                adView.imageView = image
            }
            adView.starRatingView = lnRating
//            adView.advertiserView = adAdvertiser
//             Try to find MediaView (may not exist in all layouts)
//            adAdvertiser.apply {
//                text = "Ad"
//                visibility = View.VISIBLE
//            }
//            if(isRootLargerThan120dp(root)){
//                  adView.mediaView = mediaView
//            }else{
//                adView.mediaView = null
//            }
//            val btnInstall = root.findViewById<FrameLayout>(R.id.btnInstall)
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
            if (icon != null) {
                val iconDrawable =
                    nativeAd.icon?.drawable ?: nativeAd.images.firstOrNull()?.drawable
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
            if (mediaView != null && nativeAd.mediaContent?.hasVideoContent() == true) {
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
                image?.visibility = View.VISIBLE
                val images = nativeAd.images
                if (images.isNotEmpty()) {
                    val drawable = images[0].drawable
                    image?.setImageDrawable(drawable)
                }
            }
//            mediaView?.let { mediaView ->
//                nativeAd.mediaContent?.let {
//                    if (it.hasVideoContent()) {
//
//                    } else {
//
//                    }
//                }
//            }

//            image.visibility = View.VISIBLE
//            val images = nativeAd.images
//            if (images.isNotEmpty()) {
//                val drawable = images[0].drawable
//                image.setImageDrawable(drawable)
//            }
            // Bind MediaView or fallback to ImageView
//            if (mediaView != null && nativeAd.mediaContent != null) {
//                // Use MediaView for video/image content
//                mediaView.mediaContent = nativeAd.mediaContent!!
//                mediaView.visibility = View.VISIBLE
//                image.visibility = View.GONE
//            } else {
//                // Fallback to ImageView if MediaView not available or no media content
//                mediaView?.visibility = View.GONE
//                image.visibility = View.VISIBLE
//                val images = nativeAd.images
//                if (images.isNotEmpty()) {
//                    val drawable = images[0].drawable
//                    image.setImageDrawable(drawable)
//                }
//            }

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
            "NATIVE_MEDIUM_RECTANGLE" -> R.layout.native_ad_card_medium_rectangle
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