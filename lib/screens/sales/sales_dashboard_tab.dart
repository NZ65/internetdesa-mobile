import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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

  String _formatCurrency(dynamic amount) {
    final num val = (amount is num) ? amount : (num.tryParse(amount.toString()) ?? 0);
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(val);
  }

  void _openWhatsApp(String phone, String name) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final target = clean.startsWith('0') ? '62${clean.substring(1)}' : (clean.startsWith('8') ? '62$clean' : clean);
    final msg = Uri.encodeComponent('Halo Kak $name, terima kasih telah mendaftar pasang baru Internet Desa Sukorejo. Mengenai jadwal survey dan pemasangan kabel kami...');
    final uri = Uri.parse('https://wa.me/$target?text=$msg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final dash = Provider.of<DashboardProvider>(context);
    final sales = Provider.of<SalesProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final user = auth.user;
    final stats = dash.dashboardData?.stats ?? {};
    final packages = sales.packages;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF6366F1),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Sales & Pemasaran (${user?.areaName ?? "W3"})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan',
            onPressed: _loadData,
          ),
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
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Pasang Baru', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4338CA),
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // ==========================================
            // 1. SALES HERO BANNER
            // ==========================================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4338CA), Color(0xFF6366F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4338CA).withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
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
                        Icons.campaign_rounded,
                        color: Color(0xFF4338CA),
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sales: ${user?.name ?? user?.username}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pendaftaran Pelanggan & Ekspansi Fiber',
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.circle, color: Color(0xFFA5B4FC), size: 7),
                        const SizedBox(width: 5),
                        Text(
                          '${sales.registrations.length} INPUT',
                          style: const TextStyle(
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
            ),

            const SizedBox(height: 18),

            // ==========================================
            // 2. STATS OVERVIEW
            // ==========================================
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Total Input Sales',
                    value: '${stats['total_registrations'] ?? sales.registrations.length}',
                    subtitle: 'Calon pelanggan terdata',
                    icon: Icons.assignment_turned_in_rounded,
                    color: const Color(0xFF6366F1),
                    badgeText: 'LEADS',
                    badgeColor: const Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Sukses Terpasang',
                    value: '${stats['installed_count'] ?? 0}',
                    subtitle: 'Kabel & ONT aktif di rumah',
                    icon: Icons.verified_user_rounded,
                    color: AppTheme.accentGreen,
                    badgeText: 'AKTIF',
                    badgeColor: AppTheme.accentGreen,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // ==========================================
            // 3. PAKET INTERNET TERSEDIA
            // ==========================================
            if (packages.isNotEmpty) ...[
              const Text(
                'Katalog Paket Broadband Sukorejo',
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: packages.length,
                  itemBuilder: (context, idx) {
                    final p = packages[idx];
                    return Container(
                      width: 220,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF131C2E) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF6366F1).withOpacity(0.25),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  p.name,
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  p.speedText,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF6366F1)),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _formatCurrency(p.price),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.accentGreen),
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 28,
                            child: ElevatedButton(
                              onPressed: () async {
                                final res = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const NewRegistrationScreen(),
                                  ),
                                );
                                if (res == true) _loadData();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4338CA),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Pilih Paket Ini →', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 22),
            ],

            // ==========================================
            // 4. DAFTAR ANTREAN PASANG BARU
            // ==========================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Riwayat Calon Pelanggan Anda',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                ),
                Text(
                  '${sales.registrations.length} Data',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (sales.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (sales.registrations.isEmpty)
              const EmptyState(
                icon: Icons.person_add_disabled_rounded,
                title: 'Belum Ada Pendaftaran',
                message: 'Tekan tombol "+ Pasang Baru" untuk mendaftarkan warga baru yang ingin berlangganan WiFi.',
              )
            else
              ...sales.registrations.map((r) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF131C2E) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: r.isInstalled
                          ? AppTheme.accentGreen.withOpacity(0.3)
                          : const Color(0xFF6366F1).withOpacity(0.25),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: r.isInstalled
                                  ? AppTheme.accentGreen.withOpacity(0.15)
                                  : const Color(0xFF6366F1).withOpacity(0.15),
                              radius: 20,
                              child: Icon(
                                r.isInstalled ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                                color: r.isInstalled ? AppTheme.accentGreen : const Color(0xFF6366F1),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r.name,
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Paket: ${r.packageName ?? "-"}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            StatusBadge(status: r.status),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1),
                        const SizedBox(height: 10),
                        if (r.address != null && r.address!.isNotEmpty) ...[
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF64748B)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  r.address!,
                                  style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : const Color(0xFF64748B)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'WhatsApp: ${r.phone}',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                                fontFamily: 'monospace',
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _openWhatsApp(r.phone, r.name),
                              icon: const Icon(Icons.chat_rounded, size: 14, color: Color(0xFF25D366)),
                              label: const Text('Hubungi WA', style: TextStyle(fontSize: 11.5, color: Color(0xFF25D366))),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                minimumSize: Size.zero,
                                side: const BorderSide(color: Color(0xFF25D366)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 70), // padding for FAB
          ],
        ),
      ),
    );
  }
}
