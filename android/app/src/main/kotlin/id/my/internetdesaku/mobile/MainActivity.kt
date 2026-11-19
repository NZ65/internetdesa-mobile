package id.my.internetdesaku.mobile

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "id.my.internetdesaku.mobile/updater"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstallPath" -> {
                    try {
                        val cacheFile = File(applicationContext.cacheDir, "internetdesa_update.apk")
                        result.success(cacheFile.absolutePath)
                    } catch (e: Exception) {
                        result.error("PATH_ERROR", e.message, null)
                    }
                }
                "installApk" -> {
                    val filePath = call.argument<String>("filePath")
                    if (filePath != null) {
                        val file = File(filePath)
                        if (file.exists()) {
                            try {
                                // Check Android 8.0+ unknown sources permission
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && !packageManager.canRequestPackageInstalls()) {
                                    val settingsIntent = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES).apply {
                                        data = Uri.parse("package:$packageName")
                                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                    }
                                    startActivity(settingsIntent)
                                    result.error("NEED_PERMISSION", "Izin instalasi aplikasi pihak ketiga diperlukan. Silakan aktifkan izin pada layar pengaturan.", null)
                                    return@setMethodCallHandler
                                }

                                val intent = Intent(Intent.ACTION_VIEW).apply {
                                    val uri: Uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                        FileProvider.getUriForFile(applicationContext, "$packageName.fileprovider", file)
                                    } else {
                                        Uri.fromFile(file)
                                    }
                                    setDataAndType(uri, "application/vnd.android.package-archive")
                                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                                }
                                startActivity(intent)
                                result.success(true)
                            } catch (e: Exception) {
                                result.error("INSTALL_ERROR", e.message, null)
                            }
                        } else {
                            result.error("FILE_NOT_FOUND", "File update tidak ditemukan: $filePath", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "filePath bernilai null", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
