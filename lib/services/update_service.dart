import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../config/theme.dart';
import 'api_service.dart';

class UpdateService {
  static bool _hasChecked = false;
  static const MethodChannel _channel = MethodChannel('id.my.internetdesaku.mobile/updater');

  /// Get guaranteed safe cache path for APK update download
  static Future<String> getInstallPath() async {
    try {
      final path = await _channel.invokeMethod<String>('getInstallPath');
      if (path != null && path.isNotEmpty) return path;
    } catch (_) {}
    return '${Directory.systemTemp.path}/internetdesa_update.apk';
  }

  /// Checks for application updates from the server and shows prompt if available
  static Future<void> checkForUpdates(BuildContext context, {bool silent = true}) async {
    if (silent && _hasChecked) return;
    _hasChecked = true;

    try {
      final api = ApiService();
      final response = await api.get(AppConfig.epVersion);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final latestVersion = data['latest_version']?.toString() ?? '1.0.0';
        final versionCode = data['version_code'] as int? ?? 1;
        final downloadUrl = data['download_url']?.toString() ?? '${AppConfig.defaultBaseUrl}/downloads/internetdesa.apk';
        final changelog = data['changelog']?.toString() ?? 'Pembaruan stabilitas dan fitur baru.';
        final forceUpdate = data['force_update'] as bool? ?? false;

        final isNewer = versionCode > AppConfig.appVersionCode || latestVersion != AppConfig.appVersion;

        if (isNewer && context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: !forceUpdate,
            builder: (ctx) => _UpdateDialog(
              currentVersion: AppConfig.appVersion,
              latestVersion: latestVersion,
              changelog: changelog,
              downloadUrl: downloadUrl,
              forceUpdate: forceUpdate,
            ),
          );
        } else if (!silent && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aplikasi sudah menggunakan versi terbaru (v${AppConfig.appVersion})'),
              backgroundColor: AppTheme.accentGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (!silent && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memeriksa pembaruan: $e'),
            backgroundColor: AppTheme.accentRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Installs downloaded APK via native MethodChannel
  static Future<Map<String, dynamic>> installApk(String filePath) async {
    try {
      final res = await _channel.invokeMethod<bool>('installApk', {'filePath': filePath});
      return {'success': res ?? false, 'message': 'Membuka pemasang paket Android'};
    } on PlatformException catch (pe) {
      debugPrint('Error invoking installApk: ${pe.code} - ${pe.message}');
      return {'success': false, 'code': pe.code, 'message': pe.message ?? 'Gagal membuka penginstal paket'};
    } catch (e) {
      debugPrint('Error invoking installApk: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}

class _UpdateDialog extends StatefulWidget {
  final String currentVersion;
  final String latestVersion;
  final String changelog;
  final String downloadUrl;
  final bool forceUpdate;

  const _UpdateDialog({
    required this.currentVersion,
    required this.latestVersion,
    required this.changelog,
    required this.downloadUrl,
    required this.forceUpdate,
  });

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  bool _isDownloading = false;
  bool _downloadComplete = false;
  String? _downloadedFilePath;
  double _progress = 0.0;
  String _statusText = '';
  String? _errorMessage;

  void _startInAppDownload() async {
    setState(() {
      _isDownloading = true;
      _downloadComplete = false;
      _progress = 0.0;
      _statusText = 'Menghubungkan ke server...';
      _errorMessage = null;
    });

    try {
      final savePath = await UpdateService.getInstallPath();
      final file = File(savePath);
      if (file.existsSync()) {
        try { file.deleteSync(); } catch (_) {}
      }

      final dio = Dio();
      await dio.download(
        widget.downloadUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            final p = received / total;
            final recMb = (received / (1024 * 1024)).toStringAsFixed(1);
            final totMb = (total / (1024 * 1024)).toStringAsFixed(1);
            setState(() {
              _progress = p;
              _statusText = '${(p * 100).toInt()}% ($recMb MB / $totMb MB)';
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadComplete = true;
          _downloadedFilePath = savePath;
          _statusText = 'Unduhan selesai! Membuka installer...';
        });
      }

      _installDownloadedApk(savePath);
    } catch (e) {
      debugPrint('Download error: $e');
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _errorMessage = 'Gagal mengunduh langsung: $e';
        });
      }
    }
  }

  void _installDownloadedApk(String path) async {
    final result = await UpdateService.installApk(path);
    if (!mounted) return;

    if (result['success'] == true) {
      // Installer launched successfully
    } else {
      final code = result['code'];
      final msg = result['message'] ?? 'Gagal memasang APK';
      setState(() {
        _errorMessage = (code == 'NEED_PERMISSION')
            ? 'Izin instalasi dari sumber ini diperlukan. Silakan aktifkan izin pada layar pengaturan, lalu tekan tombol "Pasang Sekarang" di bawah.'
            : msg;
      });
    }
  }

  void _openInBrowser() async {
    final uri = Uri.parse(widget.downloadUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (e2) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tidak dapat membuka browser: $e2'),
              backgroundColor: AppTheme.accentRed,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? const Color(0xFF131C2E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.system_update_rounded,
                    color: AppTheme.primaryBlue,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pembaruan Tersedia',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'v${widget.currentVersion} ➔ v${widget.latestVersion}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.accentGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Apa yang baru:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              ),
              child: Text(
                widget.changelog,
                style: const TextStyle(fontSize: 12.5, height: 1.45),
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentRed.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppTheme.accentRed, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(fontSize: 11.5, color: AppTheme.accentRed, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (_isDownloading) ...[
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                  minHeight: 8,
                  backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentGreen),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Mengunduh langsung di aplikasi...', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  Text(
                    _statusText,
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.accentGreen),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!widget.forceUpdate && !_isDownloading)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Nanti', style: TextStyle(color: Colors.grey)),
                  ),
                const SizedBox(width: 8),

                if (_downloadComplete && _downloadedFilePath != null)
                  ElevatedButton.icon(
                    onPressed: () => _installDownloadedApk(_downloadedFilePath!),
                    icon: const Icon(Icons.install_mobile_rounded, size: 18),
                    label: const Text('Pasang Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  )
                else if (!_isDownloading)
                  ElevatedButton.icon(
                    onPressed: _startInAppDownload,
                    icon: const Icon(Icons.download_for_offline_rounded, size: 18),
                    label: const Text('Update Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
              ],
            ),
            if (!_isDownloading && _errorMessage != null && !_downloadComplete) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: _openInBrowser,
                  icon: const Icon(Icons.open_in_browser_rounded, size: 14, color: AppTheme.primaryBlue),
                  label: const Text('Jika kendala berlanjut, unduh manual via Browser', style: TextStyle(fontSize: 11, color: AppTheme.primaryBlue)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
