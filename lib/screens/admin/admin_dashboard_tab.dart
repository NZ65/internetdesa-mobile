import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/anime_mascot_card.dart';
import '../../widgets/bouncing_button.dart';
import '../../widgets/dana_header.dart';
import '../../widgets/dana_hero_card.dart';
import '../../widgets/dana_service_grid.dart';
import '../../widgets/dana_banner_carousel.dart';
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

  String _formatCompactCurrency(dynamic amount) {
    final num val = (amount is num) ? amount : (num.tryParse(amount.toString()) ?? 0);
    if (val >= 1000000) {
      final jt = val / 1000000;
      return 'Rp ${jt.toStringAsFixed(1)} Jt';
    } else if (val >= 1000) {
      final rb = val / 1000;
      return 'Rp ${rb.toStringAsFixed(0)} Rb';
    }
    return 'Rp $val';
  }

  void _openWhatsApp(String phone, String name, dynamic amount) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final targetPhone = cleanPhone.startsWith('0')
        ? '62${cleanPhone.substring(1)}'
        : (cleanPhone.startsWith('8') ? '62$cleanPhone' : cleanPhone);
    final msg = Uri.encodeComponent(
      'Halo Kak $name, ini pengingat tagihan internet Sukorejo Net sebesar ${_formatCurrency(amount)}. Silakan lakukan pembayaran agar koneksi internet tetap lancar. Terima kasih! 🙏',
    );
    final url = Uri.parse('https://wa.me/$targetPhone?text=$msg');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showLosDetailDialog(BuildContext context, List<Map<String, dynamic>> losItems) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.pastelRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: AppTheme.accentRed, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daftar Pelanggan LOS (${losItems.length})',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        const Text(
                          'Kabel optik putus atau modem mati daya (Dying Gasp)',
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (losItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text('🎉 Luar biasa! Tidak ada pelanggan yang mengalami LOS saat ini.'),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.55),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: losItems.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, idx) {
                      final item = losItems[idx];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.pastelRed,
                          child: const Icon(Icons.power_off_rounded, color: AppTheme.accentRed, size: 18),
                        ),
                        title: Text(
                          item['name'] ?? 'Pelanggan #${item['onu_id']}',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                        ),
                        subtitle: Text(
                          'Port ${item['port'] ?? "-"} | Daya: ${item['rx_power'] ?? "LOS"} | ${item['down_reason'] ?? "Putus"}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.accentRed.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'LOS',
                            style: TextStyle(color: AppTheme.accentRed, fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showFeatureDialog(BuildContext context, String title, String message, IconData icon) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primaryBlue, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 13.5, height: 1.4)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(90, 42),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
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
    final saldoTersisa = stats['saldo_tersisa'] ?? 20211374;
    final revenue = stats['month_revenue'] ?? stats['revenue_this_month'] ?? stats['monthly_revenue'] ?? 0;
    final monthExpense = stats['month_expense'] ?? 0;
    final activeCount = stats['active_customers'] ?? 0;
    final isolatedCount = stats['isolated_customers'] ?? 0;
    final unpaidCount = stats['unpaid_invoices_count'] ?? unpaidInvoices.length;
    final unpaidAmount = stats['unpaid_invoices_amount'] ?? 0;
    final losCount = dash.losCount;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      body: dash.isLoading && data == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => dash.fetchDashboard(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // ==========================================
                    // 1. DANA HEADER & HERO SALDO CARD
                    // ==========================================
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // DANA Gradient Curved Header
                        DanaHeader(
                          title: 'Halo, ${user?.name ?? user?.username ?? "Admin"}',
                          subtitle: isMtOnline && isOltOnline
                              ? (losCount > 0 ? '$losCount Pelanggan LOS Terdeteksi' : 'NOC & OLT Normal')
                              : 'Koneksi NOC Terhubung',
                          roleBadge: user?.role ?? 'Super Admin',
                          isConnected: isMtOnline && losCount == 0,
                          isRefreshing: dash.isLoading,
                          onRefresh: () => dash.fetchDashboard(),
                        ),

                        // Overlapping DANA Hero Card (Saldomu)
                        Padding(
                          padding: const EdgeInsets.only(top: 96),
                          child: DanaHeroCard(
                            title: 'SALDO KAS TERSISA',
                            primaryAmount: _formatCurrency(saldoTersisa),
                            secondaryText: 'Kas Riil Sukorejo',
                            actions: [
                              DanaActionItem(
                                label: 'Catat Bayar',
                                icon: Icons.payments_rounded,
                                iconColor: const Color(0xFF00B074),
                                bgColor: const Color(0xFFE6F9F0),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const InvoiceListScreen()),
                                  );
                                },
                              ),
                              DanaActionItem(
                                label: 'Pelanggan',
                                icon: Icons.people_alt_rounded,
                                iconColor: AppTheme.primaryBlue,
                                bgColor: AppTheme.primaryLight,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const CustomerListScreen()),
                                  );
                                },
                              ),
                              DanaActionItem(
                                label: 'Tagihan Unpaid',
                                icon: Icons.receipt_long_rounded,
                                iconColor: const Color(0xFFFF8B00),
                                bgColor: const Color(0xFFFEF5E7),
                                badgeText: unpaidCount > 0 ? '$unpaidCount' : null,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const CustomerListScreen(initialStatus: 'unpaid'),
                                    ),
                                  );
                                },
                              ),
                              DanaActionItem(
                                label: 'Pasang Baru',
                                icon: Icons.person_add_alt_1_rounded,
                                iconColor: const Color(0xFF7C3AED),
                                bgColor: const Color(0xFFF3E8FF),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const NewRegistrationScreen()),
                                  );
                                },
                              ),
                            ],
                            footerPills: [
                              _buildMiniPill(
                                context,
                                label: 'Omset',
                                value: _formatCompactCurrency(revenue),
                                color: const Color(0xFF00B074),
                                icon: Icons.arrow_downward_rounded,
                              ),
                              Container(height: 16, width: 1, color: const Color(0xFFE2E8F0)),
                              _buildMiniPill(
                                context,
                                label: 'Pengeluaran',
                                value: _formatCompactCurrency(monthExpense),
                                color: AppTheme.accentRed,
                                icon: Icons.arrow_upward_rounded,
                              ),
                              Container(height: 16, width: 1, color: const Color(0xFFE2E8F0)),
                              _buildMiniPill(
                                context,
                                label: 'Unpaid',
                                value: '$unpaidCount Warga',
                                color: const Color(0xFFFF8B00),
                                icon: Icons.hourglass_empty_rounded,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ==========================================
                    // 2. ANIME MASCOT COMPANION CARD (Desa-chan)
                    // ==========================================
                    AnimeMascotCard(
                      losCount: losCount,
                      openTicketsCount: stats['open_tickets'] ?? 0,
                      isNocConnected: isMtOnline,
                      onTapLos: () => _showLosDetailDialog(context, dash.losItems),
                      onTapTickets: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const QuickToolsScreen()),
                        );
                      },
                      onTapPing: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const QuickToolsScreen()),
                        );
                      },
                    ),

                    // ==========================================
                    // 3. DANA 4x2 SERVICE GRID ("Layanan ISP")
                    // ==========================================
                    DanaServiceGrid(
                      title: 'Layanan & Diagnostik ISP',
                      items: [
                        DanaServiceItem(
                          label: 'Router MikroTik',
                          icon: Icons.router_rounded,
                          iconColor: const Color(0xFF0284C7),
                          bgColor: const Color(0xFFE0F2FE),
                          badgeText: isMtOnline ? 'LIVE' : 'OFF',
                          onTap: () {
                            _showFeatureDialog(
                              context,
                              'MikroTik Router RB',
                              'Status: ${isMtOnline ? "Online & Terhubung" : "Offline"}\nIP: ${mt["host"] ?? "192.168.1.1"}\nActive Sessions: ${mt["active_pppoe"] ?? activeCount}',
                              Icons.router_rounded,
                            );
                          },
                        ),
                        DanaServiceItem(
                          label: 'OLT C-Data',
                          icon: Icons.hub_rounded,
                          iconColor: const Color(0xFF00B074),
                          bgColor: const Color(0xFFE6F9F0),
                          badgeText: losCount > 0 ? '$losCount LOS' : (isOltOnline ? 'OK' : 'OFF'),
                          onTap: () => _showLosDetailDialog(context, dash.losItems),
                        ),
                        DanaServiceItem(
                          label: 'Diagnosa LOS',
                          icon: Icons.cell_tower_rounded,
                          iconColor: AppTheme.accentRed,
                          bgColor: AppTheme.pastelRed,
                          badgeText: losCount > 0 ? 'ALERT' : null,
                          onTap: () => _showLosDetailDialog(context, dash.losItems),
                        ),
                        DanaServiceItem(
                          label: 'Ganti Wi-Fi',
                          icon: Icons.wifi_password_rounded,
                          iconColor: const Color(0xFF7C3AED),
                          bgColor: const Color(0xFFF3E8FF),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const QuickToolsScreen(initialIndex: 2)),
                            );
                          },
                        ),
                        DanaServiceItem(
                          label: 'Peta ODP / GIS',
                          icon: Icons.map_rounded,
                          iconColor: const Color(0xFF0284C7),
                          bgColor: const Color(0xFFE0F2FE),
                          onTap: () {
                            _showFeatureDialog(
                              context,
                              'Peta ODP & Fiber Optik',
                              'Peta sebaran ODP 8-Port dan redaman fiber optik aktif Sukorejo & Mireng.',
                              Icons.map_rounded,
                            );
                          },
                        ),
                        DanaServiceItem(
                          label: 'Speedtest NOC',
                          icon: Icons.speed_rounded,
                          iconColor: AppTheme.accentCyan,
                          bgColor: AppTheme.pastelCyan,
                          onTap: () async {
                            final uri = Uri.parse('${AppConfig.defaultBaseUrl}/speedtest');
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          },
                        ),
                        DanaServiceItem(
                          label: 'WhatsApp Bot',
                          icon: Icons.chat_bubble_rounded,
                          iconColor: const Color(0xFF10B981),
                          bgColor: const Color(0xFFE8F5E9),
                          badgeText: 'AKTIF',
                          onTap: () {
                            _showFeatureDialog(
                              context,
                              'WhatsApp Gateway Baileys',
                              'Bot WhatsApp otomatis mengirim kuitansi saat pembayaran dan broadcast gangguan LOS.',
                              Icons.chat_bubble_rounded,
                            );
                          },
                        ),
                        DanaServiceItem(
                          label: 'Dusun Mireng',
                          icon: Icons.campaign_rounded,
                          iconColor: AppTheme.accentOrange,
                          bgColor: AppTheme.pastelOrange,
                          badgeText: '128 Port',
                          onTap: () {
                            _showFeatureDialog(
                              context,
                              'Perluasan Dk. Mireng',
                              'Target 128 Calon Pelanggan khusus Paket 50 Mbps. Pantau pendaftar di portal web /mireng.',
                              Icons.campaign_rounded,
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ==========================================
                    // 4. DANA PROMO & INFO BANNER CAROUSEL
                    // ==========================================
                    DanaBannerCarousel(
                      banners: [
                        DanaBannerItem(
                          tag: 'INFO NOC',
                          title: 'Internet Desa Sukorejo',
                          subtitle: 'Jaringan fiber optik dedicated 24 jam stabil tanpa batasan kuota FUP.',
                          icon: Icons.speed_rounded,
                          gradientColors: const [Color(0xFF118EEA), Color(0xFF0C75C2)],
                          onTap: () {},
                        ),
                        DanaBannerItem(
                          tag: 'PERLUASAN',
                          title: 'Ekspansi Dk. Mireng 128 Port',
                          subtitle: 'Pendaftaran mandiri warga dibuka, terisolasi aman di database komunitas.',
                          icon: Icons.share_location_rounded,
                          gradientColors: const [Color(0xFF00B074), Color(0xFF059669)],
                          onTap: () {},
                        ),
                        DanaBannerItem(
                          tag: 'ASISTEN PINTAR',
                          title: 'Kenalan dengan Desa-chan!',
                          subtitle: 'Asisten virtual anime yang selalu siap memberi notifikasi darurat saat kabel putus.',
                          icon: Icons.auto_awesome_rounded,
                          gradientColors: const [Color(0xFFFF8B00), Color(0xFFEA580C)],
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ==========================================
                    // 5. DANA FEED / RECENT PAYMENTS
                    // ==========================================
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentGreen,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Aktivitas Pembayaran Terbaru',
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? Colors.white : AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const InvoiceListScreen()),
                                    );
                                  },
                                  child: const Text(
                                    'Semua',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primaryBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),

                          // Feed Items
                          if (data?.listItems.isEmpty ?? true)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text('Belum ada transaksi pembayaran baru hari ini.'),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: data!.listItems.take(5).length,
                              separatorBuilder: (_, __) => const Divider(height: 1, indent: 70),
                              itemBuilder: (context, idx) {
                                final item = data.listItems[idx];
                                final name = item['customer_name'] ?? 'Pelanggan';
                                final amount = item['amount'] ?? 0;
                                final date = item['payment_date'] ?? '';

                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  leading: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppTheme.pastelGreen,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Center(
                                      child: Text(
                                        name.isNotEmpty ? name[0].toUpperCase() : 'P',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                          color: AppTheme.accentGreen,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    name,
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                                  ),
                                  subtitle: Text(
                                    date,
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '+ ${_formatCurrency(amount)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13,
                                          color: AppTheme.accentGreen,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentGreen.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'LUNAS',
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.accentGreen,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMiniPill(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
