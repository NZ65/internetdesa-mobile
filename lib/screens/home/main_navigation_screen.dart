import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../services/update_service.dart';
import '../../widgets/dana_bottom_nav.dart';
import '../../widgets/bouncing_button.dart';
import '../admin/admin_dashboard_tab.dart';
import '../admin/customer_list_screen.dart';
import '../admin/invoice_list_screen.dart';
import '../profile/profile_screen.dart';
import '../sales/new_registration_screen.dart';
import '../sales/sales_dashboard_tab.dart';
import '../technician/quick_tools_screen.dart';
import '../technician/technician_dashboard_tab.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _welcomeController;
  late Animation<Offset> _welcomeSlideAnimation;
  late Animation<double> _welcomeFadeAnimation;
  bool _showWelcomeBanner = true;

  @override
  void initState() {
    super.initState();
    // Launch Welcome Animation
    _welcomeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _welcomeSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _welcomeController,
      curve: Curves.easeOutBack,
    ));

    _welcomeFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _welcomeController, curve: Curves.easeIn),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).fetchDashboard();
      UpdateService.checkForUpdates(context);

      // Play opening animation
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) {
          _welcomeController.forward();
        }
      });

      // Auto dismiss welcome banner after 4.5 seconds
      Future.delayed(const Duration(milliseconds: 4800), () {
        if (mounted && _showWelcomeBanner) {
          _dismissWelcomeBanner();
        }
      });
    });
  }

  void _dismissWelcomeBanner() {
    _welcomeController.reverse().then((_) {
      if (mounted) {
        setState(() => _showWelcomeBanner = false);
      }
    });
  }

  @override
  void dispose() {
    _welcomeController.dispose();
    super.dispose();
  }

  void _showDanaActionSheet(BuildContext context, dynamic user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bottom sheet drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF118EEA), Color(0xFF0C75C2)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Aksi Kilat Internet Desa',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Pilih jalan pintas operasi cepat untuk ${user.name ?? user.username}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Quick Action Tiles
              _buildActionTile(
                icon: Icons.payments_rounded,
                iconColor: AppTheme.accentGreen,
                bgColor: AppTheme.pastelGreen,
                title: 'Catat Pembayaran Tagihan',
                subtitle: 'Konfirmasi bayar pelanggan langsung & buat kwitansi WA',
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _currentIndex = 1);
                },
              ),
              const SizedBox(height: 10),

              _buildActionTile(
                icon: Icons.person_add_alt_1_rounded,
                iconColor: AppTheme.primaryBlue,
                bgColor: AppTheme.pastelBlue,
                title: 'Tambah Calon Pelanggan Baru',
                subtitle: 'Input registrasi pemasangan warga & tandai GPS',
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NewRegistrationScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),

              _buildActionTile(
                icon: Icons.cell_tower_rounded,
                iconColor: AppTheme.accentRed,
                bgColor: AppTheme.pastelRed,
                title: 'Periksa Pelanggan LOS & Redaman',
                subtitle: 'Diagnosa kabel optik putus, port OLT, & daya redaman',
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QuickToolsScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),

              _buildActionTile(
                icon: Icons.speed_rounded,
                iconColor: AppTheme.accentPurple,
                bgColor: AppTheme.pastelPurple,
                title: 'Speedtest & Ping Server NOC',
                subtitle: 'Analisa latensi MikroTik, DNS, & stabilitas koneksi',
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QuickToolsScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return BouncingButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: iconColor.withOpacity(0.18), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Role-tailored screens and tabs
    List<Widget> screens = [];
    List<DanaNavItem> navItems = [];

    if (user.isAdmin) {
      screens = [
        const AdminDashboardTab(),
        const InvoiceListScreen(),
        const CustomerListScreen(),
        const ProfileScreen(),
      ];
      navItems = const [
        DanaNavItem(
          label: 'Beranda',
          icon: Icons.home_outlined,
          activeIcon: Icons.home_rounded,
        ),
        DanaNavItem(
          label: 'Billing',
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long_rounded,
        ),
        DanaNavItem(
          label: 'Pelanggan',
          icon: Icons.people_alt_outlined,
          activeIcon: Icons.people_alt_rounded,
        ),
        DanaNavItem(
          label: 'Saya',
          icon: Icons.account_circle_outlined,
          activeIcon: Icons.account_circle_rounded,
        ),
      ];
    } else if (user.role == 'teknisi') {
      screens = [
        const TechnicianDashboardTab(),
        const QuickToolsScreen(),
        const CustomerListScreen(),
        const ProfileScreen(),
      ];
      navItems = const [
        DanaNavItem(
          label: 'Tugas',
          icon: Icons.home_outlined,
          activeIcon: Icons.home_rounded,
        ),
        DanaNavItem(
          label: 'Tools NOC',
          icon: Icons.build_circle_outlined,
          activeIcon: Icons.build_circle_rounded,
        ),
        DanaNavItem(
          label: 'Pelanggan',
          icon: Icons.people_alt_outlined,
          activeIcon: Icons.people_alt_rounded,
        ),
        DanaNavItem(
          label: 'Saya',
          icon: Icons.account_circle_outlined,
          activeIcon: Icons.account_circle_rounded,
        ),
      ];
    } else {
      // Sales
      screens = [
        const SalesDashboardTab(),
        const NewRegistrationScreen(),
        const CustomerListScreen(),
        const ProfileScreen(),
      ];
      navItems = const [
        DanaNavItem(
          label: 'Beranda',
          icon: Icons.home_outlined,
          activeIcon: Icons.home_rounded,
        ),
        DanaNavItem(
          label: 'Pasang Baru',
          icon: Icons.person_add_alt_outlined,
          activeIcon: Icons.person_add_alt_1_rounded,
        ),
        DanaNavItem(
          label: 'Warga',
          icon: Icons.people_alt_outlined,
          activeIcon: Icons.people_alt_rounded,
        ),
        DanaNavItem(
          label: 'Saya',
          icon: Icons.account_circle_outlined,
          activeIcon: Icons.account_circle_rounded,
        ),
      ];
    }

    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: screens,
          ),

          // Animated Opening Mascot Welcome Banner
          if (_showWelcomeBanner)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 14,
              right: 14,
              child: SlideTransition(
                position: _welcomeSlideAnimation,
                child: FadeTransition(
                  opacity: _welcomeFadeAnimation,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.35), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0xFFE0F2FE),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset(
                              'assets/images/mascot_interactive_happy.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.asset(
                                'assets/images/mascot_happy.png',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.face_rounded, color: AppTheme.primaryBlue),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '✨ Desa-chan siap membantu!',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? Colors.white : AppTheme.primaryDark,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Selamat bertugas ${user?.name ?? user?.username ?? "Tim"}! Operasional Sukorejo aktif lancar.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                                    height: 1.25,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: _dismissWelcomeBanner,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white12 : const Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: isDark ? Colors.white70 : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: DanaBottomNav(
        currentIndex: _currentIndex,
        items: navItems,
        onTabSelected: (idx) => setState(() => _currentIndex = idx),
        onCenterActionTap: () => _showDanaActionSheet(context, user),
      ),
    );
  }
}
