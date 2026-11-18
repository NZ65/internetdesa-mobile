import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import 'customer_list_screen.dart';
import 'invoice_list_screen.dart';
import '../technician/quick_tools_screen.dart';
import '../sales/new_registration_screen.dart';

class AdminDashboardTab extends StatelessWidget {
  const AdminDashboardTab({super.key});

  String _formatCurrency(dynamic amount) {
    final num val = (amount is num) ? amount : (num.tryParse(amount.toString()) ?? 0);
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(val);
  }

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openWhatsApp(String phone, String name, dynamic amount) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final targetPhone = cleanPhone.startsWith('0')
        ? '62${cleanPhone.substring(1)}'
        : (cleanPhone.startsWith('8') ? '62$cleanPhone' : cleanPhone);
    final msg = Uri.encodeComponent(
      'Halo Kak $name, ini pengingat tagihan internet Sukorejo Net sebesar ${_formatCurrency(amount)}. Silakan lakukan pembayaran agar koneksi internet tetap lancar. Terima kasih! 🙏'
    );
    final url = Uri.parse('https://wa.me/$targetPhone?text=$msg');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final dash = Provider.of<DashboardProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final user = auth.user;
    final data = dash.dashboardData;
    final stats = data?.stats ?? {};
    final mt = data?.mikrotik ?? {};
    final olt = data?.olt ?? {};
    final unpaidInvoices = data?.unpaidInvoices ?? [];

    final isMtOnline = mt['connected'] == true;
    final isOltOnline = olt['connected'] == true;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppTheme.accentGreen,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'NOC ${user?.areaName ?? "Sukorejo Net"}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan Data',
            onPressed: () => dash.fetchDashboard(),
          ),
        ],
      ),
      body: dash.isLoading && data == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => dash.fetchDashboard(),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // ==========================================
                  // 1. HERO BRAND & LIVE STATUS BANNER
                  // ==========================================
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF0C4A6E), const Color(0xFF0369A1)]
                            : [const Color(0xFF0284C7), const Color(0xFF0EA5E9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withOpacity(0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => const Icon(
                                  Icons.wifi,
                                  color: Color(0xFF0284C7),
                                  size: 28,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Halo, ${user?.name ?? user?.username}!',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${user?.roleDisplayName} • Sukorejo Wilayah 3',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.3)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.circle, color: Color(0xFF4ADE80), size: 7),
                                  SizedBox(width: 5),
                                  Text(
                                    'LIVE NOC',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Mini stats ribbon inside hero
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildHeroStat('PPPoE Aktif', '${mt['active_pppoe'] ?? stats['active_customers'] ?? 0} Sesi', Icons.speed_rounded),
                              Container(height: 24, width: 1, color: Colors.white.withOpacity(0.2)),
                              _buildHeroStat('Kapasitas ODP', '${stats['total_odp_count'] ?? 16} Box', Icons.lan_rounded),
                              Container(height: 24, width: 1, color: Colors.white.withOpacity(0.2)),
                              _buildHeroStat('Tanggal', data?.dateNow ?? 'Hari ini', Icons.calendar_today_rounded),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ==========================================
                  // 2. STATUS PERANGKAT CORE & OLT (INTERAKTIF)
                  // ==========================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Infrastruktur Jaringan Core',
                        style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'MikroTik & OLT',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      // MikroTik Card
                      Expanded(
                        child: _buildDeviceCard(
                          context,
                          title: mt['name']?.toString() ?? 'MikroTik Core',
                          subtitle: 'IP: ${mt['host'] ?? "10.10.10.4"}',
                          isOnline: isMtOnline,
                          icon: Icons.router_rounded,
                          accentColor: AppTheme.accentGreen,
                          metric1Label: 'CPU Load',
                          metric1Value: '${mt['cpu_load'] ?? 0}%',
                          metric2Label: 'PPPoE',
                          metric2Value: '${mt['active_pppoe'] ?? stats['active_customers'] ?? 0}',
                          btnLabel: 'Buka WebFig',
                          onBtnTap: () => _openUrl(mt['webfig_url'] ?? 'http://10.10.10.4'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // OLT Card
                      Expanded(
                        child: _buildDeviceCard(
                          context,
                          title: olt['name']?.toString() ?? 'C-Data OLT EPON',
                          subtitle: 'IP: ${olt['host'] ?? "10.10.10.3"}',
                          isOnline: isOltOnline,
                          icon: Icons.hub_rounded,
                          accentColor: AppTheme.primaryBlue,
                          metric1Label: 'Status PON',
                          metric1Value: isOltOnline ? 'Active' : 'Offline',
                          metric2Label: 'Uptime',
                          metric2Value: olt['uptime']?.toString() ?? '-',
                          btnLabel: 'Buka OLT Web',
                          onBtnTap: () => _openUrl(olt['web_url'] ?? 'http://10.10.10.3'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ==========================================
                  // 3. STATISTIK OPERASIONAL (4-GRID MODERN)
                  // ==========================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ringkasan Bisnis & Pelanggan',
                        style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CustomerListScreen()),
                          );
                        },
                        child: const Text(
                          'Lihat Semua →',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Grid 1: Pelanggan Aktif & Pendapatan Bulan Ini
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Pelanggan Aktif',
                          value: '${stats['active_customers'] ?? 0}',
                          subtitle: 'Dari ${stats['total_customers'] ?? 0} total pelanggan',
                          icon: Icons.people_alt_rounded,
                          color: const Color(0xFF0284C7),
                          badgeText: 'ONLINE',
                          badgeColor: const Color(0xFF0284C7),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CustomerListScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: 'Pendapatan Bulan Ini',
                          value: _formatCurrency(stats['paid_income'] ?? stats['monthly_income'] ?? 0),
                          subtitle: '${stats['paid_invoices_count'] ?? 0} invoice lunas',
                          icon: Icons.account_balance_wallet_rounded,
                          color: AppTheme.accentGreen,
                          badgeText: 'LUNAS',
                          badgeColor: AppTheme.accentGreen,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const InvoiceListScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Grid 2: Tunggakan Belum Bayar & Antrean Pasang Baru
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Belum Lunas / Isolir',
                          value: _formatCurrency(stats['unpaid_amount'] ?? 0),
                          subtitle: '${stats['unpaid_invoices_count'] ?? stats['isolated_customers'] ?? 0} pelanggan tertunggak',
                          icon: Icons.warning_amber_rounded,
                          color: AppTheme.accentRed,
                          badgeText: 'PERLU DITAGIH',
                          badgeColor: AppTheme.accentRed,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const InvoiceListScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: 'Pasang Baru',
                          value: '${stats['pending_registrations'] ?? 0}',
                          subtitle: 'Menunggu penarikan kabel',
                          icon: Icons.person_add_alt_1_rounded,
                          color: AppTheme.accentOrange,
                          badgeText: 'ANTREAN',
                          badgeColor: AppTheme.accentOrange,
                          onTap: () {
                            Provider.of<CustomerProvider>(context, listen: false)
                                .fetchCustomers(status: 'pasang_baru');
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CustomerListScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // ==========================================
                  // 4. MENU AKSI CEPAT (TACTILE CHIPS)
                  // ==========================================
                  const Text(
                    'Aksi Cepat Manajemen',
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildActionPill(
                          context,
                          label: 'Trouble Tools',
                          icon: Icons.build_circle_rounded,
                          color: AppTheme.accentCyan,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const QuickToolsScreen()),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildActionPill(
                          context,
                          label: 'Pasang Baru',
                          icon: Icons.person_add_rounded,
                          color: AppTheme.accentOrange,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const NewRegistrationScreen()),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildActionPill(
                          context,
                          label: 'Tagihan & Invoice',
                          icon: Icons.receipt_long_rounded,
                          color: AppTheme.accentGreen,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const InvoiceListScreen()),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildActionPill(
                          context,
                          label: 'Peta ODP Jaringan',
                          icon: Icons.map_rounded,
                          color: AppTheme.accentPurple,
                          onTap: () => _openUrl('https://internetdesaku.my.id/portal/'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ==========================================
                  // 5. DAFTAR TAGIHAN PERLU PERHATIAN
                  // ==========================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tagihan Menunggu Konfirmasi',
                        style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '${unpaidInvoices.length} Data',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (unpaidInvoices.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF131C2E) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: AppTheme.accentGreen, size: 28),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Semua Tagihan Tertata!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text('Tidak ada tunggakan jatuh tempo mendesak saat ini.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...unpaidInvoices.take(5).map((inv) {
                      final custName = inv['customer_name'] ?? inv['cust_name'] ?? 'Pelanggan';
                      final custPhone = inv['customer_phone'] ?? inv['phone'] ?? '';
                      final amount = inv['amount'] ?? inv['total_amount'] ?? 0;
                      final dueDate = inv['due_date'] ?? '-';
                      final isIsolated = inv['status'] == 'isolated' || inv['customer_status'] == 'isolated';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF131C2E) : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isIsolated
                                ? AppTheme.accentRed.withOpacity(0.3)
                                : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: isIsolated
                                  ? AppTheme.accentRed.withOpacity(0.15)
                                  : AppTheme.accentOrange.withOpacity(0.15),
                              radius: 20,
                              child: Icon(
                                isIsolated ? Icons.lock_clock_rounded : Icons.receipt_rounded,
                                color: isIsolated ? AppTheme.accentRed : AppTheme.accentOrange,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    custName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Jatuh tempo: $dueDate',
                                    style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : const Color(0xFF64748B)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatCurrency(amount),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.accentRed,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (custPhone.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.chat_bubble_rounded, color: Color(0xFF25D366)),
                                tooltip: 'Kirim Pengingat WA',
                                onPressed: () => _openWhatsApp(custPhone, custName, amount),
                              ),
                            StatusBadge(status: isIsolated ? 'isolated' : 'unpaid'),
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildHeroStat(String title, String val, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 16),
        const SizedBox(height: 4),
        Text(
          val,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900),
        ),
        Text(
          title,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildDeviceCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool isOnline,
    required IconData icon,
    required Color accentColor,
    required String metric1Label,
    required String metric1Value,
    required String metric2Label,
    required String metric2Value,
    required String btnLabel,
    required VoidCallback onBtnTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131C2E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOnline ? accentColor.withOpacity(0.3) : AppTheme.accentRed.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: isOnline ? accentColor.withOpacity(0.12) : AppTheme.accentRed.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: isOnline ? accentColor : AppTheme.accentRed, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: isOnline ? const Color(0xFF10B981).withOpacity(0.15) : AppTheme.accentRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isOnline ? 'ONLINE' : 'OFFLINE',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: isOnline ? const Color(0xFF10B981) : AppTheme.accentRed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10.5,
              color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(metric1Label, style: TextStyle(fontSize: 10.5, color: isDark ? Colors.grey[400] : Colors.grey[600])),
              Text(metric1Value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(metric2Label, style: TextStyle(fontSize: 10.5, color: isDark ? Colors.grey[400] : Colors.grey[600])),
              Text(metric2Value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 30,
            child: OutlinedButton(
              onPressed: onBtnTap,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                side: BorderSide(color: accentColor.withOpacity(0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                btnLabel,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: accentColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionPill(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131C2E) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withOpacity(isDark ? 0.3 : 0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
