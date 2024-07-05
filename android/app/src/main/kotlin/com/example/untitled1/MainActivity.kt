package com.example.untitled1

import android.content.Intent
import android.media.projection.MediaProjectionConfig
import android.media.projection.MediaProjectionManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method.equals("startMediaProjectionService")) {
                    startMediaProjectionService()
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun startMediaProjectionService() {
        val serviceIntent = Intent(this, MediaProjectionService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager: MediaProjectionManager =
                getSystemService(MediaProjectionManager::class.java)
            if (Build.VERSION.SDK_INT >= 34) {
                val intent =
                    manager.createScreenCaptureIntent(MediaProjectionConfig.createConfigForDefaultDisplay())
                startActivityForResult(intent, REQUEST_CODE_MEDIA_PROJECTION)
            } else {
                startForegroundService(serviceIntent)
            }
        } else {
            startService(serviceIntent)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        val serviceIntent = Intent(this, MediaProjectionService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent)
        }
    }

    companion object {
        private const val CHANNEL = "com.example.untitled1/media_projection"
        const val REQUEST_CODE_MEDIA_PROJECTION = 100
    }
}
