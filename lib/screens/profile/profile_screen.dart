import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/storage_service.dart';
import '../../services/update_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showChangePasswordDialog(BuildContext context) {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ganti Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password Lama'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password Baru (min 6 karakter)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Konfirmasi Password Baru'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final oldP = oldController.text.trim();
              final newP = newController.text.trim();
              final confP = confirmController.text.trim();

              if (newP.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password baru minimal 6 karakter.')),
                );
                return;
              }
              if (newP != confP) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Konfirmasi password tidak cocok.')),
                );
                return;
              }

              Navigator.pop(ctx);
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final ok = await auth.changePassword(oldP, newP);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok ? 'Password berhasil diperbarui!' : (auth.errorMessage ?? 'Gagal ganti password.')),
                    backgroundColor: ok ? AppTheme.accentGreen : AppTheme.accentRed,
                  ),
                );
              }
            },
            child: const Text('Perbarui'),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await Provider.of<AuthProvider>(context, listen: false).logout();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Avatar & Identity Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.15),
                    child: Text(
                      user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? user?.username ?? 'Pengguna',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user?.roleDisplayName ?? 'Staff',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Wilayah Operasional: ${user?.areaName ?? "W3"}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Text('Pengaturan & Keamanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dns_outlined),
                  title: const Text('Alamat Server VPS'),
                  subtitle: Text(StorageService.getBaseUrl()),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_reset),
                  title: const Text('Ganti Password'),
                  subtitle: const Text('Ubah kata sandi akun mobile Anda'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showChangePasswordDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.system_update_rounded, color: AppTheme.primaryBlue),
                  title: const Text('Periksa Pembaruan Aplikasi'),
                  subtitle: const Text('Versi ${AppConfig.appVersion} • Update Otomatis'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => UpdateService.checkForUpdates(context, silent: false),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Logout Button
          ElevatedButton.icon(
            onPressed: () => _handleLogout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Keluar dari Akun (Logout)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRed,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          Center(
            child: Text(
              'InternetDesa Mobile v${AppConfig.appVersion} • All-in-One Suite',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ),
        ],
      ),
    );
  }
}
