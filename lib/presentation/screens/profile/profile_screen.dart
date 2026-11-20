import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/sound_effects.dart';
import '../../../core/utils/native_updater.dart';
import '../../../data/services/storage_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/cyber_card.dart';
import '../../widgets/in_app_update_dialog.dart';
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ganti Kata Sandi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password Saat Ini', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password Baru (min. 6 karakter)', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await context.read<AuthProvider>().changePassword(
                oldCtrl.text.trim(),
                newCtrl.text.trim(),
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ok ? 'Password berhasil diperbarui!' : 'Gagal memperbarui password.')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _checkManualUpdate() async {
    SoundEffects.playTap();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Memeriksa ketersediaan pembaruan...')),
    );

    final updateData = await NativeUpdater.checkUpdate();
    if (!mounted) return;

    if (updateData != null && (updateData['version_code'] ?? 0) > AppConfig.appVersionCode) {
      InAppUpdateDialog.show(
        context,
        latestVersion: updateData['latest_version'] ?? '1.5.8',
        versionCode: updateData['version_code'] ?? 15,
        changelog: updateData['changelog'] ?? 'Pembaruan aplikasi.',
        downloadUrl: updateData['download_url'] ?? '${AppConfig.defaultBaseUrl}/downloads/internetdesa.apk',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aplikasi sudah dalam versi terbaru (v1.5.8).')),
      );
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Konfirmasi Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
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
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed, foregroundColor: Colors.white),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppTheme.iceBackground,
      appBar: AppBar(
        title: const Text('Profil Pengguna', style: TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppTheme.textMain),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Card
            CyberCard(
              margin: EdgeInsets.zero,
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryBlue, AppTheme.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.cyberGlow,
                    ),
                    child: Center(
                      child: Text(
                        user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'A',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Pengguna',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@${user?.username ?? "-"} • Wilayah ${user?.areaName ?? "Sukorejo"}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            (user?.role ?? 'admin').toUpperCase(),
                            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Settings & Controls
            CyberCard(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Efek Suara & Haptik (Blue Archive)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Feedback suara audio chime saat interaksi', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                    value: _soundEnabled,
                    activeColor: AppTheme.primaryBlue,
                    onChanged: (val) {
                      setState(() => _soundEnabled = val);
                      StorageService.setSoundEnabled(val);
                      if (val) SoundEffects.playTap();
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.key_rounded, color: AppTheme.primaryBlue, size: 20),
                    title: const Text('Ganti Password Akun', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textLight),
                    onTap: _showChangePasswordDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.system_update_rounded, color: AppTheme.accentGreen, size: 20),
                    title: const Text('Periksa Pembaruan APK (OTA)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Versi saat ini: v1.5.8 (Build 15)', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textLight),
                    onTap: _checkManualUpdate,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Logout Button
            OutlinedButton.icon(
              onPressed: _confirmLogout,
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Keluar dari Akun'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.accentRed,
                side: const BorderSide(color: AppTheme.accentRed),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
