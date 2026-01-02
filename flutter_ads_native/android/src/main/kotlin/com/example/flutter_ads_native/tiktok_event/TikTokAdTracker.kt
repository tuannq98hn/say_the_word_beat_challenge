package com.example.flutter_ads_native.tiktok_event

import com.google.android.gms.ads.AdValue
import com.tiktok.TikTokBusinessSdk
import com.tiktok.appevents.base.TTBaseEvent
import com.tiktok.appevents.base.EventName
import com.tiktok.appevents.base.TTAdRevenueEvent
import org.json.JSONObject
import java.util.UUID

/**
 * Track:
 * - IMP/CLICK => TTBaseEvent (addProperty)
 * - ILRD (Revenue) => TTAdRevenueEvent (JSONObject) giống snippet AdMob doc
 */
class TikTokAdTracker(
    private val defaultMediationPlatform: String = "admob_sdk",
) {
    private val E_IMP = EventName.IN_APP_AD_IMPR.toString()
    private val E_CLICK = EventName.IN_APP_AD_CLICK.toString()
    private val E_REV = EventName.IMPRESSION_LEVEL_AD_REVENUE.toString()

    fun trackImpression(meta: AdMobAdMeta, extraProps: Map<String, Any> = emptyMap()) {
        trackBase(E_IMP, meta, extraProps)
    }

    fun trackClick(meta: AdMobAdMeta, extraProps: Map<String, Any> = emptyMap()) {
        trackBase(E_CLICK, meta, extraProps)
    }

    /**
     * ILRD: dùng TTAdRevenueEvent theo schema:
     * value, currency_code, precision, ad_unit_id, ad_source_*, mediation_*, device_ad_mediation_platform, ad_format
     */
    fun trackRevenue(meta: AdMobAdMeta, adValue: AdValue) {
        val json = buildAdRevenueJson(meta, adValue)

        // TTAdRevenueEvent class name/package phụ thuộc SDK; nếu IDE không resolve,
        // dùng "TTAdRevenueEvent" đúng như trong doc bạn trích.
        val evt = TTAdRevenueEvent.newBuilder(json).build()
        TikTokBusinessSdk.trackTTEvent(evt)
    }

    /**
     * Base events (IMP/CLICK): TTBaseEvent + properties
     */
    private fun trackBase(eventName: String, meta: AdMobAdMeta, extraProps: Map<String, Any>) {
        val eventId = meta.responseId ?: UUID.randomUUID().toString()

        val props = buildMap<String, Any> {
            // ---- Ads context ----
            put("device_ad_mediation_platform", meta.mediationPlatform.ifBlank { defaultMediationPlatform })
            put("ad_format", meta.format)
            put("ad_unit_id", meta.adUnitId)

            // TikTok "content_*" mapping for ads
            put("content_id", meta.adUnitId)
            put("content_type", "ad")

            // ---- Mediation + source (if available) ----
            meta.mediationGroupName?.takeIf { it.isNotBlank() }?.let { put("mediation_group_name", it) }
            meta.mediationAbTestName?.takeIf { it.isNotBlank() }?.let { put("mediation_ab_test_name", it) }
            meta.mediationAbTestVariant?.takeIf { it.isNotBlank() }?.let { put("mediation_ab_test_variant", it) }

            meta.mediationAdapterClassName?.takeIf { it.isNotBlank() }?.let { put("mediation_adapter_class", it) }

            meta.adSourceName?.takeIf { it.isNotBlank() }?.let { put("ad_source_name", it) }
            meta.adSourceId?.takeIf { it.isNotBlank() }?.let { put("ad_source_id", it) }
            meta.adSourceInstanceName?.takeIf { it.isNotBlank() }?.let { put("ad_source_instance_name", it) }
            meta.adSourceInstanceId?.takeIf { it.isNotBlank() }?.let { put("ad_source_instance_id", it) }

            // merge thêm props tùy bạn (nếu muốn thêm debug fields)
            putAll(extraProps)
        }

        sendToTikTokBaseEvent(eventName = eventName, eventId = eventId, properties = props)
    }

    private fun sendToTikTokBaseEvent(eventName: String, eventId: String, properties: Map<String, Any>) {
        val builder = TTBaseEvent.newBuilder(eventName, eventId)

        properties.forEach { (k, v) ->
            // TTBaseEvent.addProperty thường nhận Object; giữ Any
            builder.addProperty(k, v)
        }

        TikTokBusinessSdk.trackTTEvent(builder.build())
    }

    private fun buildAdRevenueJson(meta: AdMobAdMeta, adValue: AdValue): JSONObject {
        // Theo snippet bạn đưa: value là micros, currency_code ISO-4217, precision int
        val valueMicros = adValue.valueMicros
        val currencyCode = adValue.currencyCode
        val precisionType = adValue.precisionType

        val platform = meta.mediationPlatform.ifBlank { defaultMediationPlatform }

        // Theo snippet: vẫn put các key, nếu thiếu thì để ""
        return JSONObject().apply {
            put("value", valueMicros)
            put("currency_code", currencyCode)
            put("precision", precisionType)

            put("ad_unit_id", meta.adUnitId)
            put("ad_source_name", meta.adSourceName.orEmpty())
            put("ad_source_id", meta.adSourceId.orEmpty())
            put("ad_source_instance_name", meta.adSourceInstanceName.orEmpty())
            put("ad_source_instance_id", meta.adSourceInstanceId.orEmpty())

            put("mediation_group_name", meta.mediationGroupName.orEmpty())
            put("mediation_ab_test_name", meta.mediationAbTestName.orEmpty())
            put("mediation_ab_test_variant", meta.mediationAbTestVariant.orEmpty())

            put("device_ad_mediation_platform", platform)
            put("ad_format", meta.format)
        }
    }
}
