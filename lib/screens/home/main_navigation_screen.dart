import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../admin/admin_dashboard_tab.dart';
import '../admin/customer_list_screen.dart';
import '../admin/invoice_list_screen.dart';
import '../technician/technician_dashboard_tab.dart';
import '../technician/quick_tools_screen.dart';
import '../sales/sales_dashboard_tab.dart';
import '../sales/new_registration_screen.dart';
import '../profile/profile_screen.dart';
import '../../services/update_service.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).fetchDashboard();
      UpdateService.checkForUpdates(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Role-tailored tabs
    List<Widget> screens = [];
    List<BottomNavigationBarItem> navItems = [];

    if (user.isAdmin) {
      screens = [
        const AdminDashboardTab(),
        const CustomerListScreen(),
        const InvoiceListScreen(),
        const QuickToolsScreen(),
        const ProfileScreen(),
      ];
      navItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard_rounded),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_alt_outlined),
          activeIcon: Icon(Icons.people_alt_rounded),
          label: 'Pelanggan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long_rounded),
          label: 'Billing',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.build_circle_outlined),
          activeIcon: Icon(Icons.build_circle_rounded),
          label: 'Tools',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Profil',
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
        BottomNavigationBarItem(
          icon: Icon(Icons.engineering_outlined),
          activeIcon: Icon(Icons.engineering_rounded),
          label: 'Tugas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.build_circle_outlined),
          activeIcon: Icon(Icons.build_circle_rounded),
          label: 'Tools',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_alt_outlined),
          activeIcon: Icon(Icons.people_alt_rounded),
          label: 'Pelanggan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Profil',
        ),
      ];
    } else {
      // Sales
      screens = [
        const SalesDashboardTab(),
        const NewRegistrationScreen(),
        const ProfileScreen(),
      ];
      navItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.trending_up_rounded),
          activeIcon: Icon(Icons.trending_up_rounded),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_add_alt_outlined),
          activeIcon: Icon(Icons.person_add_alt_1_rounded),
          label: 'Pasang Baru',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Profil',
        ),
      ];
    }

    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131C2E) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.45 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (idx) => setState(() => _currentIndex = idx),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: isDark ? AppTheme.accentCyan : AppTheme.primaryBlue,
              unselectedItemColor: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              selectedFontSize: 11.5,
              unselectedFontSize: 11,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
              items: navItems,
            ),
          ),
        ),
      ),
    );
  }
}
