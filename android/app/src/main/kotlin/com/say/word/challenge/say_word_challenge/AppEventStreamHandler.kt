package com.say.word.challenge.say_word_challenge

import io.flutter.plugin.common.EventChannel

class AppEventStreamHandler : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null
    override fun onListen(
        arguments: Any?,
        events: EventChannel.EventSink?
    ) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun sendEvent(eventType: String, data: Map<String, Any?>? = null) {
        eventSink?.success(
            mapOf(
                "event" to eventType,
                "data" to (data ?: emptyMap<String, Any?>())
            )
        )
    }
}
