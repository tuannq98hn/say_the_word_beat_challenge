package com.example.flutter_ads_native.banner_native.banner

import android.content.Context
import com.example.flutter_ads_native.AdsEventStreamHandler
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class BannerViewFactory(
    private val channel: MethodChannel,
    private val eventHandler: AdsEventStreamHandler
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, id: Int, args: Any?): PlatformView {
        val params = args as Map<String, Any>?
        return BannerView(context, id, params, channel, eventHandler)
    }
}
