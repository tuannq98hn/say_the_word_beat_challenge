package com.example.flutter_ads_native.tiktok_event

import com.tiktok.TikTokBusinessSdk
import com.tiktok.appevents.base.TTBaseEvent
import java.util.UUID

class TikTokAdTracker(
    private val defaultMediationPlatform: String = "AdMob",
    private val debugLog: Boolean = false
) {

    /**
     * Gửi event sang TikTok SDK.
     * Event names khuyến nghị cho ads:
     *  - InAppADImpr
     *  - InAppADClick
     *  - ImpressionLevelAdRevenue
     */
    fun track(eventName: String, meta: AdMobAdMeta, extraProps: Map<String, Any> = emptyMap()) {
        val eventId = meta.responseId ?: UUID.randomUUID().toString()

        val props = buildMap<String, Any> {
            put("ad_platform", meta.mediationPlatform.ifBlank { defaultMediationPlatform })
            put("ad_unit_id", meta.adUnitId)
            put("ad_format", meta.format)

            meta.mediationGroupName?.let { put("mediation_group_name", it) }
            meta.mediationAdapterClassName?.let { put("mediation_adapter_class", it) }

            meta.adSourceName?.let { put("ad_source_name", it) }
            meta.adSourceId?.let { put("ad_source_id", it) }
            meta.adSourceInstanceName?.let { put("ad_source_instance_name", it) }
            meta.adSourceInstanceId?.let { put("ad_source_instance_id", it) }

            // merge thêm props (revenue, currency, precision, ...)
            putAll(extraProps)
        }

        sendToTikTokSdk(eventName = eventName, eventId = eventId, properties = props)
    }

    /**
     * Code “core” để đảm bảo gọi đúng TikTok SDK.
     * Vì tài liệu TikTok portal đôi khi thay đổi theo version, đoạn dưới đây dùng TTCustomEvent
     * (cách an toàn nhất để nhét đủ properties từ AdMob).
     */
    private fun sendToTikTokSdk(eventName: String, eventId: String, properties: Map<String, Any>) {
        try {
            val builder = TTBaseEvent.newBuilder(eventName, eventId)
            properties.forEach { (k, v) -> builder.addProperty(k, v) }

            val event = builder.build()
            TikTokBusinessSdk.trackTTEvent(event)

        } catch (t: Throwable) {
            if (debugLog) {
                android.util.Log.e("TikTokAdTracker", "sendToTikTokSdk failed: ${t.message}", t)
            }
        }
    }
}
