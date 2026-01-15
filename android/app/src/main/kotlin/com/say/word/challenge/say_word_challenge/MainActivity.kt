package com.say.word.challenge.say_word_challenge

import android.content.IntentSender
import androidx.annotation.NonNull
import androidx.lifecycle.Lifecycle
import com.google.android.play.core.appupdate.AppUpdateManager
import com.google.android.play.core.appupdate.AppUpdateManagerFactory
import com.google.android.play.core.appupdate.AppUpdateOptions
import com.google.android.play.core.install.InstallStateUpdatedListener
import com.google.android.play.core.install.model.AppUpdateType
import com.google.android.play.core.install.model.InstallStatus
import com.google.android.play.core.install.model.UpdateAvailability
import com.google.firebase.crashlytics.FirebaseCrashlytics
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

//import com.say.word.challenge.say_word_challenge.BuildConfig

class MainActivity : FlutterActivity() {
    private val MY_REQUEST_CODE: Int = 123
    private lateinit var installStateUpdatedListener: InstallStateUpdatedListener
    private lateinit var appUpdateManager: AppUpdateManager
    private var isUpdateFlowStarted = false
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // App Open Ad EventChannel for streaming events (riêng biệt)
        val appOpenAdEventChannelName = "com.say.word.challenge.say_word_challenge/app_events"
        val methodChannelName = "com.say.word.challenge.say_word_challenge/app_method"
        val appOpenAdEventHandler = AppEventStreamHandler()
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            appOpenAdEventChannelName
        ).setStreamHandler(appOpenAdEventHandler)
        (application as? App)?.openAdManager?.setEventHandler(appOpenAdEventHandler)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, methodChannelName)
        channel.setMethodCallHandler { method, result ->
            if (method.method == "canShowOpenAd") {
                App.canShowOpenAd = method.arguments as Boolean
                result.success(true)
            }
        }
    }

    override fun onResume() {
        super.onResume()
        initCheckUpdate()
    }

    private fun initCheckUpdate() {
        installStateUpdatedListener = InstallStateUpdatedListener {state->
                when (state.installStatus()) {
                InstallStatus.DOWNLOADED -> {
                    appUpdateManager.completeUpdate()
                }

                InstallStatus.INSTALLED,
                InstallStatus.CANCELED,
                InstallStatus.FAILED -> {
                    appUpdateManager.unregisterListener(installStateUpdatedListener)
                    isUpdateFlowStarted = false
                }

                else -> {}
            }
            appUpdateManager = AppUpdateManagerFactory.create(this)
            appUpdateManager.registerListener(installStateUpdatedListener)
            checkUpdate()
        }
    }

    private fun checkUpdate() {
        val appUpdateInfoTask = appUpdateManager.appUpdateInfo
        appUpdateInfoTask.addOnSuccessListener { appUpdateInfo ->
            // 🔒 Activity phải RESUMED
            if (!lifecycle.currentState.isAtLeast(Lifecycle.State.RESUMED)) {
                return@addOnSuccessListener
            }

            if (appUpdateInfo.updateAvailability() == UpdateAvailability.UPDATE_NOT_AVAILABLE) {
                return@addOnSuccessListener
            }
            if (isUpdateFlowStarted) return@addOnSuccessListener

            if (appUpdateInfo.updateAvailability() == UpdateAvailability.UPDATE_AVAILABLE) {

                      val updateType = when {
                    appUpdateInfo.isUpdateTypeAllowed(AppUpdateType.IMMEDIATE) ->
                        AppUpdateType.IMMEDIATE

                    appUpdateInfo.isUpdateTypeAllowed(AppUpdateType.FLEXIBLE) ->
                        AppUpdateType.FLEXIBLE

                    else -> null
                }

                if (updateType != null) {
                    try {
                        isUpdateFlowStarted = true
                        appUpdateManager.startUpdateFlowForResult(
                            appUpdateInfo,
                            this,
                            AppUpdateOptions.newBuilder(updateType)
                                .setAllowAssetPackDeletion(true)
                                .build(),
                            MY_REQUEST_CODE
                        )
                    } catch (e: IntentSender.SendIntentException) {
                        isUpdateFlowStarted = false
                        FirebaseCrashlytics.getInstance().recordException(e)
                    }
                }
            }
        }.addOnFailureListener {
            isUpdateFlowStarted = false
        }
    }
}
