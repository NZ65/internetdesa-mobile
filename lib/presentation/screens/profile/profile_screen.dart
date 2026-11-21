import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/sound_effects.dart';
import '../../../core/utils/native_updater.dart';
import '../../../data/services/storage_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/in_app_update_dialog.dart';
import '../../widgets/zzz_badge.dart';
import '../../widgets/zzz_button.dart';
import '../../widgets/zzz_card.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _soundEnabled = StorageService.isSoundEnabled();

  void _showChangePasswordDialog() {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCardElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.borderSubtle),
        ),
        title: Row(
          children: const [
            Icon(Icons.key_rounded, color: AppTheme.primaryCyan, size: 20),
            SizedBox(width: 8),
            Text(
              'GANTI KATA SANDI',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppTheme.textMain,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldCtrl,
              obscureText: true,
              style: const TextStyle(color: AppTheme.textMain),
              decoration: InputDecoration(
                labelText: 'Password Saat Ini',
                labelStyle: const TextStyle(color: AppTheme.textMuted),
                filled: true,
                fillColor: AppTheme.bgCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.borderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.primaryCyan),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newCtrl,
              obscureText: true,
              style: const TextStyle(color: AppTheme.textMain),
              decoration: InputDecoration(
                labelText: 'Password Baru (min. 6 karakter)',
                labelStyle: const TextStyle(color: AppTheme.textMuted),
                filled: true,
                fillColor: AppTheme.bgCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.borderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.primaryCyan),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('BATAL', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await context.read<AuthProvider>().changePassword(
                oldCtrl.text.trim(),
                newCtrl.text.trim(),
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: ok ? AppTheme.accentGreen : AppTheme.accentRed,
                    content: Text(ok ? 'Password berhasil diperbarui!' : 'Gagal memperbarui password.'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryCyan,
              foregroundColor: Colors.black,
            ),
            child: const Text('SIMPAN', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _checkManualUpdate() async {
    SoundEffects.playTap();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppTheme.bgCardElevated,
        content: Text('Memeriksa ketersediaan pembaruan OTA...'),
      ),
    );

    final updateData = await NativeUpdater.checkUpdate();
    if (!mounted) return;

    if (updateData != null && (updateData['version_code'] ?? 0) > AppConfig.appVersionCode) {
      InAppUpdateDialog.show(
        context,
        latestVersion: updateData['latest_version'] ?? AppConfig.appVersion,
        versionCode: updateData['version_code'] ?? AppConfig.appVersionCode,
        changelog: updateData['changelog'] ?? 'Pembaruan aplikasi.',
        downloadUrl: updateData['download_url'] ?? '${AppConfig.defaultBaseUrl}/downloads/internetdesa.apk',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.bgCardElevated,
          content: Text('Aplikasi sudah dalam versi terbaru (v${AppConfig.appVersion}).'),
        ),
      );
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCardElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.borderSubtle),
        ),
        title: const Text(
          'KONFIRMASI TERMINASI SESI',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            color: AppTheme.accentRed,
            letterSpacing: 1.0,
          ),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari sesi operator ini?',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('BATAL', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('TERMINATE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.terminal_rounded, color: AppTheme.primaryCyan, size: 20),
            SizedBox(width: 8),
            Text(
              'OPERATOR PROFILE',
              style: TextStyle(
                color: AppTheme.textMain,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: AppTheme.textMain),
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Tactical Profile Card
            ZzzCard(
              tag: 'ID-CREDENTIALS',
              isAccent: true,
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.bgDark,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.primaryCyan.withOpacity(0.6), width: 1.5),
                      boxShadow: AppTheme.cyanGlow,
                    ),
                    child: Center(
                      child: Text(
                        user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'O',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryCyan,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Operator',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textMain,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@${user?.username ?? "-"} // ${user?.areaName ?? "SUKOREJO"}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ZzzBadge(
                          label: (user?.role ?? 'ADMIN').toUpperCase(),
                          type: user?.role == 'admin'
                              ? ZzzBadgeType.cyan
                              : (user?.role == 'technician' ? ZzzBadgeType.yellow : ZzzBadgeType.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // System Configurations Card
            ZzzCard(
              tag: 'SYSTEM CONFIG',
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Haptic & Audio FX',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textMain),
                    ),
                    subtitle: const Text(
                      'Tactical chime & vibration feedback',
                      style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                    value: _soundEnabled,
                    activeColor: AppTheme.primaryCyan,
                    onChanged: (val) {
                      setState(() => _soundEnabled = val);
                      StorageService.setSoundEnabled(val);
                      if (val) SoundEffects.playTap();
                    },
                  ),
                  const Divider(color: AppTheme.borderSubtle, height: 1),
                  ListTile(
                    leading: const Icon(Icons.key_rounded, color: AppTheme.primaryCyan, size: 20),
                    title: const Text(
                      'Ganti Password Akun',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textMain),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
                    onTap: _showChangePasswordDialog,
                  ),
                  const Divider(color: AppTheme.borderSubtle, height: 1),
                  ListTile(
                    leading: const Icon(Icons.system_update_alt_rounded, color: AppTheme.accentGreen, size: 20),
                    title: const Text(
                      'Periksa Pembaruan APK (OTA)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textMain),
                    ),
                    subtitle: Text(
                      'Versi saat ini: v${AppConfig.appVersion} (Build ${AppConfig.appVersionCode})',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontFamily: 'monospace'),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
                    onTap: _checkManualUpdate,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            ZzzButton(
              label: 'TERMINASI SESI // LOGOUT',
              icon: Icons.logout_rounded,
              type: ZzzButtonType.danger,
              onPressed: _confirmLogout,
            ),
          ],
        ),
      ),
    );
  }
}
