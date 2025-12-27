package com.example.flutter_ads_native

import io.flutter.plugin.common.EventChannel

/**
 * Handles EventChannel stream for ads events.
 * Sends events to Flutter when ads are loaded, shown, closed, or when user earns reward.
 */
class AdsEventStreamHandler : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    /**
     * Send event to Flutter.
     * @param eventType: "interstitial_loaded", "interstitial_shown", "interstitial_closed",
     *                   "interstitial_failed", "rewarded_loaded", "rewarded_shown",
     *                   "rewarded_closed", "rewarded_failed", "rewarded_earned"
     * @param data: Additional data (can be null)
     */
    fun sendEvent(eventType: String, data: Map<String, Any?>? = null) {
        eventSink?.success(
            mapOf(
                "event" to eventType,
                "data" to (data ?: emptyMap<String, Any?>())
            )
        )
    }

    companion object {
        const val EVENT_INTERSTITIAL_LOADED = "interstitial_loaded"
        const val EVENT_INTERSTITIAL_SHOWN = "interstitial_shown"
        const val EVENT_INTERSTITIAL_CLOSED = "interstitial_closed"
        const val EVENT_INTERSTITIAL_FAILED = "interstitial_failed"
        const val EVENT_REWARDED_LOADED = "rewarded_loaded"
        const val EVENT_REWARDED_SHOWN = "rewarded_shown"
        const val EVENT_REWARDED_CLOSED = "rewarded_closed"
        const val EVENT_REWARDED_FAILED = "rewarded_failed"
        const val EVENT_REWARDED_EARNED = "rewarded_earned"
        const val EVENT_REWARDED_INTERSTITIAL_LOADED = "rewarded_interstitial_loaded"
        const val EVENT_REWARDED_INTERSTITIAL_SHOWN = "rewarded_interstitial_shown"
        const val EVENT_REWARDED_INTERSTITIAL_CLOSED = "rewarded_interstitial_closed"
        const val EVENT_REWARDED_INTERSTITIAL_FAILED = "rewarded_interstitial_failed"
        const val EVENT_REWARDED_INTERSTITIAL_EARNED = "rewarded_interstitial_earned"
    }
}