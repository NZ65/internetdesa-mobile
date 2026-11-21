import 'dart:io';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import '../config/app_config.dart';

class NativeUpdater {
  static const MethodChannel _channel = MethodChannel('id.my.internetdesaku.mobile/updater');

  /// Check version from backend
  static Future<Map<String, dynamic>?> checkUpdate() async {
    try {
      final dio = Dio();
      final res = await dio.get('${AppConfig.defaultBaseUrl}${AppConfig.epVersion}');
      if (res.data != null && res.data['success'] == true) {
        return res.data;
      }
    } catch (_) {}
    return null;
  }

  /// Download APK with progress callback and execute in-app installation
  static Future<void> downloadAndInstall({
    required String downloadUrl,
    required void Function(int received, int total) onProgress,
    required void Function(String message) onError,
  }) async {
    try {
      // 1. Get cache file path from Android MainActivity
      final String? apkPath = await _channel.invokeMethod<String>('getInstallPath');
      if (apkPath == null || apkPath.isEmpty) {
        onError('Gagal mendapatkan lokasi penyimpanan cache APK.');
        return;
      }

      // 2. Download APK file directly
      final dio = Dio();
      await dio.download(
        downloadUrl,
        apkPath,
        onReceiveProgress: onProgress,
      );

      final file = File(apkPath);
      if (!await file.exists() || await file.length() < 1000) {
        onError('File APK yang diunduh tidak valid atau korup.');
        return;
      }

      // 3. Trigger native package installer via FileProvider
      await _channel.invokeMethod('installApk', {'filePath': apkPath});
    } on PlatformException catch (pe) {
      onError(pe.message ?? 'Gagal membuka penginstal paket Android.');
    } catch (e) {
      onError('Gagal mengunduh pembaruan: $e');
    }
  }

  /// Convenience wrapper returning Future<bool>
  static Future<bool> downloadAndInstallApk(
    String downloadUrl, {
    required void Function(int received, int total) onProgress,
  }) async {
    bool ok = true;
    await downloadAndInstall(
      downloadUrl: downloadUrl,
      onProgress: onProgress,
      onError: (_) {
        ok = false;
      },
    );
    return ok;
  }
}
