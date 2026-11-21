import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/native_updater.dart';

class InAppUpdateDialog extends StatefulWidget {
  final String latestVersion;
  final int versionCode;
  final String changelog;
  final String downloadUrl;

  const InAppUpdateDialog({
    super.key,
    required this.latestVersion,
    required this.versionCode,
    required this.changelog,
    required this.downloadUrl,
  });

  static Future<void> show(
    BuildContext context, {
    required String latestVersion,
    required int versionCode,
    required String changelog,
    required String downloadUrl,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => InAppUpdateDialog(
        latestVersion: latestVersion,
        versionCode: versionCode,
        changelog: changelog,
        downloadUrl: downloadUrl,
      ),
    );
  }

  @override
  State<InAppUpdateDialog> createState() => _InAppUpdateDialogState();
}

class _InAppUpdateDialogState extends State<InAppUpdateDialog> {
  bool _isDownloading = false;
  double _progress = 0.0;
  String _statusText = '';

  void _startUpdate() async {
    setState(() {
      _isDownloading = true;
      _statusText = 'Mengunduh paket APK sistem...';
    });

    final success = await NativeUpdater.downloadAndInstallApk(
      widget.downloadUrl,
      onProgress: (received, total) {
        if (total > 0 && mounted) {
          setState(() {
            _progress = received / total;
            _statusText = 'Mengunduh ${(received / (1024 * 1024)).toStringAsFixed(1)} MB / ${(total / (1024 * 1024)).toStringAsFixed(1)} MB';
          });
        }
      },
    );

    if (!success && mounted) {
      setState(() {
        _isDownloading = false;
        _statusText = 'Gagal mengunduh APK. Coba beberapa saat lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.bgCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppTheme.neonCyan, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.neonCyan.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.neonCyan.withOpacity(0.4)),
                  ),
                  child: const Icon(Icons.system_update_rounded, color: AppTheme.neonCyan, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PEMBARUAN SISTEM',
                        style: TextStyle(
                          color: AppTheme.neonCyan,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Versi ${widget.latestVersion} (Build ${widget.versionCode})',
                        style: const TextStyle(
                          color: AppTheme.textWhite,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.bgDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Catatan Pembaruan:',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.changelog,
                    style: const TextStyle(color: AppTheme.textSilver, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (_isDownloading) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: AppTheme.bgDark,
                color: AppTheme.neonCyan,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 8),
              Text(
                _statusText,
                style: const TextStyle(color: AppTheme.neonCyan, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!_isDownloading)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Nanti Saja', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _isDownloading ? null : _startUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonCyan,
                    foregroundColor: AppTheme.bgDark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: Text(_isDownloading ? 'Mengunduh...' : 'Update Langsung'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
