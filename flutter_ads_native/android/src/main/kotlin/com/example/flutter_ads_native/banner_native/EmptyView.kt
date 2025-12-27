package com.example.flutter_ads_native.banner_native

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import com.example.flutter_ads_native.R
import io.flutter.plugin.platform.PlatformView

class EmptyView(
    context: Context,
    private val viewId: Int,
    params: Map<String, Any>?
) : PlatformView {

    private val root: View = LayoutInflater.from(context)
        .inflate(R.layout.empty_view, null, false)

    override fun getView(): View = root

    override fun dispose() {

    }
}