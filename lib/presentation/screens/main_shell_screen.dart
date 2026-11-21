import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/sound_effects.dart';
import '../../core/utils/native_updater.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/in_app_update_dialog.dart';
import 'admin/admin_home_tab.dart';
import 'admin/customer_list_screen.dart';
import 'admin/expense_ledger_screen.dart';
import 'technician/technician_home_tab.dart';
import 'technician/odp_map_screen.dart';
import 'technician/quick_tools_screen.dart';
import 'sales/sales_home_tab.dart';
import 'sales/register_prospect_screen.dart';
import 'profile/profile_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkForOtaUpdate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboard();
    });
  }

  void _checkForOtaUpdate() async {
    final updateData = await NativeUpdater.checkUpdate();
    if (!mounted || updateData == null) return;

    final int remoteCode = updateData['version_code'] ?? 0;
    if (remoteCode > AppConfig.appVersionCode) {
      InAppUpdateDialog.show(
        context,
        latestVersion: updateData['latest_version'] ?? '1.7.0',
        versionCode: remoteCode,
        changelog: updateData['changelog'] ?? 'Pembaruan antarmuka Zenless Zone Zero (ZZZ) & optimasi performa.',
        downloadUrl: updateData['download_url'] ?? '${AppConfig.defaultBaseUrl}/downloads/internetdesa.apk',
      );
    }
  }

  void _showQuickToolsModal() {
    SoundEffects.playTap();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const QuickToolsScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final isTeknisi = user?.isTechnician == true;
    final isSales = user?.isSales == true;

    // Role-tailored view tabs
    final List<Widget> screens = isTeknisi
        ? [
            const TechnicianHomeTab(),
            const OdpMapScreen(),
            const QuickToolsScreen(asTab: true),
            const ProfileScreen(),
          ]
        : (isSales
            ? [
                const SalesHomeTab(),
                const RegisterProspectScreen(),
                const ProfileScreen(),
              ]
            : [
                const AdminHomeTab(),
                const CustomerListScreen(),
                const ExpenseLedgerScreen(),
                const ProfileScreen(),
              ]);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: IndexedStack(
        index: _currentIndex < screens.length ? _currentIndex : 0,
        children: screens,
      ),

      // Raised Center FAB (⚡) - ZZZ Neon Cyan Lightning Bolt
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: (!isSales)
          ? FloatingActionButton(
              onPressed: _showQuickToolsModal,
              backgroundColor: AppTheme.neonCyan,
              elevation: 8,
              shape: const CircleBorder(),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF80FFFF), AppTheme.neonCyan],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonCyan.withOpacity(0.5),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.bolt, color: AppTheme.bgDark, size: 30),
              ),
            )
          : null,

      // ZZZ Matte Carbon Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.bgSurface,
          border: Border(
            top: BorderSide(color: AppTheme.borderDark, width: 1.2),
          ),
        ),
        child: BottomAppBar(
          shape: (!isSales) ? const CircularNotchedRectangle() : null,
          notchMargin: 8,
          color: Colors.transparent,
          elevation: 0,
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.grid_view_rounded, 'BERANDA'),
              if (isTeknisi)
                _buildNavItem(1, Icons.alt_route_rounded, 'ODP MAP')
              else if (isSales)
                _buildNavItem(1, Icons.person_add_alt_1_rounded, 'DAFTAR')
              else
                _buildNavItem(1, Icons.group_rounded, 'PELANGGAN'),

              if (!isSales) const SizedBox(width: 48), // Center spacing for FAB

              if (isTeknisi)
                _buildNavItem(2, Icons.build_circle_rounded, 'TOOLS')
              else if (!isSales)
                _buildNavItem(2, Icons.account_balance_wallet_rounded, 'KAS'),

              _buildNavItem(isSales ? 2 : 3, Icons.person_rounded, 'PROFIL'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () {
        SoundEffects.playTap();
        setState(() => _currentIndex = index);
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? AppTheme.neonCyan : AppTheme.textMuted,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected ? AppTheme.neonCyan : AppTheme.textMuted,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
