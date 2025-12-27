package com.example.flutter_ads_native.inter_reward

import android.content.Context
import android.content.SharedPreferences
import java.util.Calendar

/**
 * Manages interstitial ad display conditions.
 * Config values are stored here in Kotlin as requested.
 */
object InterstitialConditions {
    // Configuration constants
    private const val MAX_INTER_PER_SESSION = 3
    private const val MAX_INTER_PER_DAY = 8
    private const val MIN_SECONDS_BETWEEN_INTER = 60
    private const val MIN_ACTIONS_BETWEEN_INTER = 3

    private const val PREFS_NAME = "interstitial_conditions"
    private const val KEY_SESSION_COUNT = "session_count"
    private const val KEY_LAST_INTER_TIME = "last_inter_time"
    private const val KEY_ACTIONS_SINCE_LAST_INTER = "actions_since_last_inter"
    private const val KEY_DAILY_COUNT = "daily_count"
    private const val KEY_DAILY_COUNT_DATE = "daily_count_date"

    private fun getPrefs(context: Context): SharedPreferences {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }

    /**
     * Records a meaningful action (e.g., set wallpaper, view detail).
     * Call this from Flutter when user performs actions.
     */
    fun recordAction(context: Context) {
        val prefs = getPrefs(context)
        val currentActions = prefs.getInt(KEY_ACTIONS_SINCE_LAST_INTER, 0)
        prefs.edit().putInt(KEY_ACTIONS_SINCE_LAST_INTER, currentActions + 1).apply()
    }

    /**
     * Checks if interstitial ad can be shown based on all conditions.
     * Returns true if all conditions are met, false otherwise.
     */
    fun canShowInterstitial(context: Context): Boolean {
        val prefs = getPrefs(context)
        val now = System.currentTimeMillis()

        // Check max per session
        val sessionCount = prefs.getInt(KEY_SESSION_COUNT, 0)
        if (sessionCount >= MAX_INTER_PER_SESSION) {
            return false
        }

        // Check max per day
        val dailyCount = prefs.getInt(KEY_DAILY_COUNT, 0)
        val dailyCountDate = prefs.getLong(KEY_DAILY_COUNT_DATE, 0)
        val calendar = Calendar.getInstance()
        val today = calendar.get(Calendar.DAY_OF_YEAR)
        calendar.timeInMillis = dailyCountDate
        val lastDate = calendar.get(Calendar.DAY_OF_YEAR)
        
        val currentDailyCount = if (today != lastDate) 0 else dailyCount
        if (currentDailyCount >= MAX_INTER_PER_DAY) {
            return false
        }

        // Check minimum interval
        val lastInterTime = prefs.getLong(KEY_LAST_INTER_TIME, 0)
        if (lastInterTime > 0) {
            val secondsSinceLast = (now - lastInterTime) / 1000
            if (secondsSinceLast < MIN_SECONDS_BETWEEN_INTER) {
                return false
            }
        }

        // Check minimum actions
        val actionsSinceLast = prefs.getInt(KEY_ACTIONS_SINCE_LAST_INTER, 0)
        if (actionsSinceLast < MIN_ACTIONS_BETWEEN_INTER) {
            return false
        }

        return true
    }

    /**
     * Records that an interstitial ad was shown.
     * Call this after successfully showing an ad.
     */
    fun recordInterstitialShown(context: Context) {
        val prefs = getPrefs(context)
        val now = System.currentTimeMillis()
        val editor = prefs.edit()

        // Update session count
        val sessionCount = prefs.getInt(KEY_SESSION_COUNT, 0)
        editor.putInt(KEY_SESSION_COUNT, sessionCount + 1)

        // Update daily count
        val dailyCount = prefs.getInt(KEY_DAILY_COUNT, 0)
        val dailyCountDate = prefs.getLong(KEY_DAILY_COUNT_DATE, 0)
        val calendar = Calendar.getInstance()
        val today = calendar.get(Calendar.DAY_OF_YEAR)
        calendar.timeInMillis = dailyCountDate
        val lastDate = calendar.get(Calendar.DAY_OF_YEAR)
        
        val currentDailyCount = if (today != lastDate) 0 else dailyCount
        editor.putInt(KEY_DAILY_COUNT, currentDailyCount + 1)
        editor.putLong(KEY_DAILY_COUNT_DATE, now)

        // Update last inter time
        editor.putLong(KEY_LAST_INTER_TIME, now)

        // Reset actions counter
        editor.putInt(KEY_ACTIONS_SINCE_LAST_INTER, 0)

        editor.apply()
    }

    /**
     * Resets session state (call on app start).
     */
    fun resetSession(context: Context) {
        val prefs = getPrefs(context)
        prefs.edit().putInt(KEY_SESSION_COUNT, 0).apply()
    }
}

