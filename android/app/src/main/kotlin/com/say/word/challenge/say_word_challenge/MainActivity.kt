package com.say.word.challenge.say_word_challenge

import androidx.annotation.NonNull
import com.google.android.play.core.appupdate.AppUpdateManager
import com.google.android.play.core.appupdate.AppUpdateManagerFactory
import com.google.android.play.core.appupdate.AppUpdateOptions
import com.google.android.play.core.install.InstallStateUpdatedListener
import com.google.android.play.core.install.model.AppUpdateType
import com.google.android.play.core.install.model.InstallStatus
import com.google.android.play.core.install.model.UpdateAvailability
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

//import com.say.word.challenge.say_word_challenge.BuildConfig

class MainActivity : FlutterActivity() {
    private val MY_REQUEST_CODE: Int = 123
    private lateinit var installStateUpdatedListener: InstallStateUpdatedListener
    private lateinit var appUpdateManager: AppUpdateManager
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // App Open Ad EventChannel for streaming events (riêng biệt)
        val appOpenAdEventChannelName = "com.say.word.challenge.say_word_challenge/app_events"
        val appOpenAdEventHandler = AppEventStreamHandler()
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            appOpenAdEventChannelName
        ).setStreamHandler(appOpenAdEventHandler)
        (application as? App)?.openAdManager?.setEventHandler(appOpenAdEventHandler)
    }

    override fun onResume() {
        super.onResume()
        initCheckUpdate()
    }

    private fun initCheckUpdate() {
        installStateUpdatedListener = InstallStateUpdatedListener {
//            if (BuildConfig.DEBUG) {
//                Log.e(
//                    "LoadActivity", "InstallStateUpdatedListener: state: " + it.installStatus()
//                )
//            }
            if (it.installStatus() == InstallStatus.DOWNLOADED) {
                appUpdateManager.completeUpdate()
            } else if (it.installStatus() == InstallStatus.INSTALLED) {
//                viewModel.setUpdateNotAvailableStatus(true)
                appUpdateManager.unregisterListener(installStateUpdatedListener)
            }
        }
        appUpdateManager = AppUpdateManagerFactory.create(this)
        appUpdateManager.registerListener(installStateUpdatedListener)
        checkUpdate()
    }

    private fun checkUpdate() {
        val appUpdateInfoTask = appUpdateManager.appUpdateInfo
        appUpdateInfoTask.addOnSuccessListener { appUpdateInfo ->
            if (appUpdateInfo.updateAvailability() == UpdateAvailability.UPDATE_NOT_AVAILABLE) {
//                viewModel.setUpdateNotAvailableStatus(true)
                return@addOnSuccessListener
            }
            if (appUpdateInfo.updateAvailability() == UpdateAvailability.UPDATE_AVAILABLE) {

                when {
                    // 🔸 Ưu tiên cập nhật ngay (immediate)
                    appUpdateInfo.isUpdateTypeAllowed(AppUpdateType.IMMEDIATE) -> {
//                        viewModel.setUpdateNotAvailableStatus(false)
                        appUpdateManager.startUpdateFlowForResult(
                            appUpdateInfo,
                            this,
                            AppUpdateOptions.newBuilder(AppUpdateType.IMMEDIATE)
                                .setAllowAssetPackDeletion(true).build(),
                            MY_REQUEST_CODE
                        )
                        return@addOnSuccessListener
                    }

                    appUpdateInfo.isUpdateTypeAllowed(AppUpdateType.FLEXIBLE) -> {
//                        viewModel.setUpdateNotAvailableStatus(false)
                        appUpdateManager.startUpdateFlowForResult(
                            appUpdateInfo,
                            this,
                            AppUpdateOptions.newBuilder(AppUpdateType.FLEXIBLE)
                                .setAllowAssetPackDeletion(true).build(),
                            MY_REQUEST_CODE
                        )
                        return@addOnSuccessListener
                    }

                    else -> {
//                        viewModel.setUpdateNotAvailableStatus(true)
                        return@addOnSuccessListener
                    }
                }
            }
        }.addOnFailureListener {
//            viewModel.setUpdateNotAvailableStatus(true)
        }
    }
}
