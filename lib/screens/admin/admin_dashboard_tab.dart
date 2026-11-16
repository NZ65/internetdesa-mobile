import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/stat_card.dart';

class AdminDashboardTab extends StatelessWidget {
  const AdminDashboardTab({super.key});

  String _formatCurrency(dynamic amount) {
    final num val = (amount is num) ? amount : (num.tryParse(amount.toString()) ?? 0);
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(val);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final dash = Provider.of<DashboardProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final user = auth.user;
    final data = dash.dashboardData;
    final stats = data?.stats ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'Dashboard ${user?.areaName ?? "ISP"}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              data?.dateNow ?? '',
              style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => dash.fetchDashboard(),
          ),
        ],
      ),
      body: dash.isLoading && data == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => dash.fetchDashboard(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Greeting Banner
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryBlue, Color(0xFF1E40AF)],
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
                          child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Halo, ${user?.name ?? user?.username}!',
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${user?.roleDisplayName} • Wilayah ${user?.areaName}',
                                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text('Ringkasan Layanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  // Grid Stat Cards
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.25,
                    children: [
                      StatCard(
                        title: 'Pelanggan Aktif',
                        value: '${stats['active_customers'] ?? 0}',
                        subtitle: 'Total: ${stats['total_customers'] ?? 0}',
                        icon: Icons.check_circle_outline,
                        color: AppTheme.accentGreen,
                      ),
                      StatCard(
                        title: 'Pelanggan Isolir',
                        value: '${stats['isolated_customers'] ?? 0}',
                        subtitle: 'Menunggak',
                        icon: Icons.block_outlined,
                        color: AppTheme.accentRed,
                      ),
                      StatCard(
                        title: 'Omzet Bulan Ini',
                        value: _formatCurrency(stats['month_revenue'] ?? 0),
                        subtitle: 'Kas Masuk',
                        icon: Icons.account_balance_wallet_outlined,
                        color: AppTheme.primaryBlue,
                      ),
                      StatCard(
                        title: 'Belum Lunas',
                        value: '${stats['unpaid_invoices_count'] ?? 0} Tagihan',
                        subtitle: _formatCurrency(stats['unpaid_invoices_amount'] ?? 0),
                        icon: Icons.receipt_long_outlined,
                        color: AppTheme.accentOrange,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Pembayaran Terkini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                        '5 Terakhir',
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Recent Payments List
                  if (data?.listItems.isEmpty ?? true)
                    const EmptyState(
                      icon: Icons.receipt_outlined,
                      title: 'Belum Ada Pembayaran',
                      message: 'Data riwayat pembayaran akan muncul di sini.',
                    )
                  else
                    ...data!.listItems.map((item) {
                      final amount = item['amount'] ?? 0;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.accentGreen.withOpacity(0.12),
                            child: const Icon(Icons.arrow_downward, color: AppTheme.accentGreen, size: 20),
                          ),
                          title: Text(
                            item['customer_name'] ?? 'Pelanggan',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            '${item['cust_id'] ?? ''} • ${item['payment_method'] ?? 'cash'} • ${item['payment_date'] ?? ''}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Text(
                            _formatCurrency(amount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.accentGreen,
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
