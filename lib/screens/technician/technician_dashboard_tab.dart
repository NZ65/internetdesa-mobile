import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/ticket_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import 'ticket_detail_screen.dart';

class TechnicianDashboardTab extends StatefulWidget {
  const TechnicianDashboardTab({super.key});

  @override
  State<TechnicianDashboardTab> createState() => _TechnicianDashboardTabState();
}

class _TechnicianDashboardTabState extends State<TechnicianDashboardTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    Provider.of<TicketProvider>(context, listen: false).fetchTickets(status: 'open');
    Provider.of<DashboardProvider>(context, listen: false).fetchDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final dash = Provider.of<DashboardProvider>(context);
    final ticketProvider = Provider.of<TicketProvider>(context);

    final user = auth.user;
    final stats = dash.dashboardData?.stats ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text('Teknisi Lapangan (${user?.areaName ?? "W3"})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Technician Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(Icons.engineering, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Teknisi: ${user?.name ?? user?.username}',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Siaga Gangguan & Perbaikan Lapangan',
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
                    title: 'Tiket Terbuka',
                    value: '${ticketProvider.tickets.length}',
                    subtitle: 'Perlu Penanganan',
                    icon: Icons.assignment_late_outlined,
                    color: AppTheme.accentRed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Kotak ODP',
                    value: '${stats['total_odp_count'] ?? 16}',
                    subtitle: 'Terpasang',
                    icon: Icons.inventory_2_outlined,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Daftar Tiket Gangguan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  '${ticketProvider.tickets.length} Tiket',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentRed),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (ticketProvider.isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (ticketProvider.tickets.isEmpty)
              const EmptyState(
                icon: Icons.verified_outlined,
                title: 'Tidak Ada Gangguan',
                message: 'Semua jaringan aman! Tidak ada tiket aktif saat ini.',
              )
            else
              ...ticketProvider.tickets.map((t) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: t.priority == 'critical'
                          ? AppTheme.accentRed.withOpacity(0.12)
                          : AppTheme.accentOrange.withOpacity(0.12),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: t.priority == 'critical' ? AppTheme.accentRed : AppTheme.accentOrange,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        StatusBadge(status: t.status),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          'Pelanggan: ${t.customerName ?? "Umum"}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        if (t.customerAddress != null && t.customerAddress!.isNotEmpty)
                          Text(
                            t.customerAddress!,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TicketDetailScreen(ticket: t)),
                      );
                      if (updated == true) _loadData();
                    },
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
