package com.example.flutter_ads_native.banner_native.native

import android.content.Context
import com.example.flutter_ads_native.AdsEventStreamHandler
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class NativeCardViewFactory(
    private val channel: MethodChannel,
    private val eventHandler: AdsEventStreamHandler
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, id: Int, args: Any?): PlatformView {
        val params = args as Map<String, Any>?
        return NativeCardView(context, id, params, channel, eventHandler)
    }
}
