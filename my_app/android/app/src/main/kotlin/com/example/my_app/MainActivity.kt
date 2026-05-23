package com.example.my_app

import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
  private val channelName = "tv_media_launcher"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
      when (call.method) {
        "checkVlcInstalled" -> result.success(isVlcInstalled())
        "openVideoWithVlc" -> {
          val path = call.argument<String>("path")
          result.success(openVideoWithVlc(path))
        }
        else -> result.notImplemented()
      }
    }
  }

  private fun isVlcInstalled(): Boolean {
    return try {
      packageManager.getPackageInfo("org.videolan.vlc", PackageManager.GET_ACTIVITIES)
      true
    } catch (exception: Exception) {
      false
    }
  }

  private fun openVideoWithVlc(path: String?): Boolean {
    if (path.isNullOrEmpty()) {
      return false
    }

    return try {
      val file = File(path)
      if (!file.exists()) {
        return false
      }

      val uri: Uri = FileProvider.getUriForFile(this, "$packageName.fileprovider", file)
      val intent = Intent(Intent.ACTION_VIEW).apply {
        setDataAndType(uri, "video/*")
        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_GRANT_READ_URI_PERMISSION)
        setPackage("org.videolan.vlc")
      }
      startActivity(intent)
      true
    } catch (exception: Exception) {
      false
    }
  }
}

