import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/sales_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import 'new_registration_screen.dart';

class SalesDashboardTab extends StatefulWidget {
  const SalesDashboardTab({super.key});

  @override
  State<SalesDashboardTab> createState() => _SalesDashboardTabState();
}

class _SalesDashboardTabState extends State<SalesDashboardTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    Provider.of<SalesProvider>(context, listen: false).fetchRegistrations();
    Provider.of<SalesProvider>(context, listen: false).fetchPackages();
    Provider.of<DashboardProvider>(context, listen: false).fetchDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final dash = Provider.of<DashboardProvider>(context);
    final sales = Provider.of<SalesProvider>(context);

    final user = auth.user;
    final stats = dash.dashboardData?.stats ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text('Sales & Pemasaran (${user?.areaName ?? "W3"})'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewRegistrationScreen()),
          );
          if (res == true) _loadData();
        },
        icon: const Icon(Icons.add),
        label: const Text('Pasang Baru'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Sales Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4338CA), Color(0xFF6366F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.campaign,
                        color: Color(0xFF4338CA),
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sales: ${user?.name ?? user?.username}',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pendaftaran Pelanggan & Pasang Baru',
                          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            // Stat Cards
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Total Input',
                    value: '${stats['total_registrations'] ?? sales.registrations.length}',
                    subtitle: 'Pendaftaran',
                    icon: Icons.assignment_outlined,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Terpasang',
                    value: '${stats['installed_count'] ?? 0}',
                    subtitle: 'Sukses Aktif',
                    icon: Icons.check_circle_outline,
                    color: AppTheme.accentGreen,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Riwayat Pendaftaran Anda', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  '${sales.registrations.length} Data',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (sales.isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (sales.registrations.isEmpty)
              const EmptyState(
                icon: Icons.person_add_disabled_outlined,
                title: 'Belum Ada Pendaftaran',
                message: 'Tekan tombol "Pasang Baru" untuk mendaftarkan calon pelanggan di lapangan.',
              )
            else
              ...sales.registrations.map((r) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: r.isInstalled
                          ? AppTheme.accentGreen.withOpacity(0.12)
                          : AppTheme.accentOrange.withOpacity(0.12),
                      child: Icon(
                        r.isInstalled ? Icons.check : Icons.hourglass_top,
                        color: r.isInstalled ? AppTheme.accentGreen : AppTheme.accentOrange,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            r.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        StatusBadge(status: r.status),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('WhatsApp: ${r.phone} • ${r.packageName ?? "Paket"}', style: const TextStyle(fontSize: 12)),
                        if (r.address != null && r.address!.isNotEmpty)
                          Text(
                            r.address!,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 60), // padding for FAB
          ],
        ),
      ),
    );
  }
}
