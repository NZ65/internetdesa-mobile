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
  }) async {
    await showDialog(
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
  String? _errorMessage;

  void _startDownload() {
    setState(() {
      _isDownloading = true;
      _progress = 0.0;
      _statusText = 'Menghubungkan ke server...';
      _errorMessage = null;
    });

    NativeUpdater.downloadAndInstall(
      downloadUrl: widget.downloadUrl,
      onProgress: (received, total) {
        if (total > 0) {
          final p = received / total;
          final mbReceived = (received / (1024 * 1024)).toStringAsFixed(1);
          final mbTotal = (total / (1024 * 1024)).toStringAsFixed(1);
          setState(() {
            _progress = p;
            _statusText = 'Mengunduh APK ($mbReceived MB / $mbTotal MB)... ${(p * 100).toInt()}%';
          });
        }
      },
      onError: (msg) {
        setState(() {
          _isDownloading = false;
          _errorMessage = msg;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                    color: AppTheme.primaryBlue.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.system_update_rounded, color: AppTheme.primaryBlue, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pembaruan Tersedia',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                      ),
                      Text(
                        'Versi ${widget.latestVersion} (Build ${widget.versionCode})',
                        style: const TextStyle(fontSize: 12, color: AppTheme.primaryBlue, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Catatan Pembaruan:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                widget.changelog,
                style: const TextStyle(fontSize: 12, color: AppTheme.textMain, height: 1.4),
              ),
            ),
            if (_isDownloading) ...[
              const SizedBox(height: 18),
              LinearProgressIndicator(
                value: _progress > 0 ? _progress : null,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Text(
                _statusText,
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                '⚠️ $_errorMessage',
                style: const TextStyle(fontSize: 11, color: AppTheme.accentRed),
              ),
            ],
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!_isDownloading)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Nanti Saja', style: TextStyle(color: AppTheme.textMuted)),
                  ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isDownloading ? null : _startDownload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text(_isDownloading ? 'Mengunduh...' : 'Perbarui Sekarang'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
