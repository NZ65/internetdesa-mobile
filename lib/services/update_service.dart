import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../config/theme.dart';
import 'api_service.dart';

class UpdateService {
  static bool _hasChecked = false;

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
}

class _UpdateDialog extends StatelessWidget {
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

  void _startUpdate() async {
    final uri = Uri.parse(downloadUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.system_update_rounded, color: AppTheme.primaryBlue, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pembaruan Tersedia',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'v$currentVersion ➔ v$latestVersion',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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
                color: Colors.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.15)),
              ),
              child: Text(
                changelog,
                style: const TextStyle(fontSize: 12.5, height: 1.45),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!forceUpdate)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Nanti Saja', style: TextStyle(color: Colors.grey)),
                  ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _startUpdate,
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Download & Update'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
