import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/bouncing_button.dart';
import '../../widgets/dana_header.dart';
import '../../widgets/dana_hero_card.dart';
import '../../widgets/dana_service_grid.dart';
import '../../widgets/dana_banner_carousel.dart';
import '../../widgets/status_badge.dart';
import 'customer_list_screen.dart';
import 'invoice_list_screen.dart';
import 'invoice_pay_dialog.dart';
import '../technician/quick_tools_screen.dart';
import '../sales/new_registration_screen.dart';

class AdminDashboardTab extends StatelessWidget {
  const AdminDashboardTab({super.key});

  String _formatCurrency(dynamic amount) {
    final num val = (amount is num) ? amount : (num.tryParse(amount.toString()) ?? 0);
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(val);
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
    final revenue = stats['revenue_this_month'] ?? stats['monthly_revenue'] ?? 0;
    final activeCount = stats['active_customers'] ?? 0;
    final isolatedCount = stats['isolated_customers'] ?? 0;
    final unpaidCount = stats['unpaid_invoices_count'] ?? unpaidInvoices.length;

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
                          title: 'Halo, ${user?.username ?? "Admin"}',
                          subtitle: isMtOnline && isOltOnline ? 'NOC & OLT Normal' : 'Koneksi NOC Terhubung',
                          roleBadge: user?.role ?? 'Super Admin',
                          isConnected: isMtOnline,
                          isRefreshing: dash.isLoading,
                          onRefresh: () => dash.fetchDashboard(),
                        ),

                        // Overlapping DANA Hero Card (Saldomu)
                        Padding(
                          padding: const EdgeInsets.only(top: 96),
                          child: DanaHeroCard(
                            title: 'PENDAPATAN BULAN INI',
                            primaryAmount: _formatCurrency(revenue),
                            secondaryText: '$activeCount Aktif',
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
                                    MaterialPageRoute(builder: (_) => const InvoiceListScreen()),
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
                                label: 'Pelanggan Aktif',
                                value: '$activeCount',
                                color: const Color(0xFF00B074),
                                icon: Icons.check_circle_outline,
                              ),
                              Container(height: 16, width: 1, color: const Color(0xFFE2E8F0)),
                              _buildMiniPill(
                                context,
                                label: 'Menunggak',
                                value: '$unpaidCount',
                                color: const Color(0xFFFF8B00),
                                icon: Icons.hourglass_empty_rounded,
                              ),
                              Container(height: 16, width: 1, color: const Color(0xFFE2E8F0)),
                              _buildMiniPill(
                                context,
                                label: 'Isolir',
                                value: '$isolatedCount',
                                color: const Color(0xFFF43F5E),
                                icon: Icons.block_rounded,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ==========================================
                    // 2. DANA 4x2 SERVICE GRID ("Layanan Internet")
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
                          badgeText: isOltOnline ? 'OK' : null,
                          onTap: () {
                            _showFeatureDialog(
                              context,
                              'OLT C-Data PON',
                              'Status: ${isOltOnline ? "Online & Normal" : "Offline"}\nModel: FD1608S-B0\nTotal ONT Terkoneksi: ${olt["active_onus"] ?? activeCount}',
                              Icons.hub_rounded,
                            );
                          },
                        ),
                        DanaServiceItem(
                          label: 'Reboot ONT',
                          icon: Icons.restart_alt_rounded,
                          iconColor: const Color(0xFFFF8B00),
                          bgColor: const Color(0xFFFEF5E7),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const QuickToolsScreen()),
                            );
                          },
                        ),
                        DanaServiceItem(
                          label: 'Ganti Wi-Fi',
                          icon: Icons.wifi_password_rounded,
                          iconColor: const Color(0xFF7C3AED),
                          bgColor: const Color(0xFFF3E8FF),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const QuickToolsScreen()),
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
                              'Modul pemetaan GIS ODP 8-Port dan redaman fiber optik aktif terintegrasi di web portal.',
                              Icons.map_rounded,
                            );
                          },
                        ),
                        DanaServiceItem(
                          label: 'Rekap Material',
                          icon: Icons.inventory_2_rounded,
                          iconColor: const Color(0xFFEC4899),
                          bgColor: const Color(0xFFFCE7F3),
                          onTap: () {
                            _showFeatureDialog(
                              context,
                              'Rekap Dropcore & ONT',
                              'Laporan pemakaian kabel dropcore dan unit ONT terpakai telah disinkronkan ke server.',
                              Icons.inventory_2_rounded,
                            );
                          },
                        ),
                        DanaServiceItem(
                          label: 'WhatsApp Gateway',
                          icon: Icons.chat_bubble_rounded,
                          iconColor: const Color(0xFF10B981),
                          bgColor: const Color(0xFFE8F5E9),
                          badgeText: 'BOT',
                          onTap: () {
                            _showFeatureDialog(
                              context,
                              'WhatsApp Gateway Baileys',
                              'Bot WhatsApp aktif melayani kirim kuitansi otomatis saat bayar dan reminder tagihan.',
                              Icons.chat_bubble_rounded,
                            );
                          },
                        ),
                        DanaServiceItem(
                          label: 'Auto-Update',
                          icon: Icons.system_update_rounded,
                          iconColor: AppTheme.primaryBlue,
                          bgColor: AppTheme.primaryLight,
                          badgeText: 'v1.3.2',
                          onTap: () {
                            _showFeatureDialog(
                              context,
                              'Pembaruan Aplikasi OTA',
                              'Versi Terbaru: v1.3.2 (DANA Style)\nIn-App Auto Downloader & Installer aktif.',
                              Icons.system_update_rounded,
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ==========================================
                    // 3. DANA PROMO & INFO BANNER CAROUSEL
                    // ==========================================
                    DanaBannerCarousel(
                      banners: [
                        DanaBannerItem(
                          tag: 'INFO NOC',
                          title: 'Internet Desa Sukorejo',
                          subtitle: 'Jaringan fiber optik dedicated 24 jam stabil tanpa batasan kuota FUP.',
                          icon: Icons.speed_rounded,
                          gradientColors: const [Color(0xFF118EEA), Color(0xFF0073C7)],
                          onTap: () {},
                        ),
                        DanaBannerItem(
                          tag: 'UPDATE v1.3.2',
                          title: 'Desain Baru DANA Style!',
                          subtitle: 'Tampilan bersih, animasi responsif, dan layout kartu modern ala dompet digital.',
                          icon: Icons.auto_awesome_rounded,
                          gradientColors: const [Color(0xFF00B074), Color(0xFF059669)],
                          onTap: () {},
                        ),
                        DanaBannerItem(
                          tag: 'OTOMASI',
                          title: 'Bayar & Auto-Buka Isolir',
                          subtitle: 'Pelanggan bayar langsung sinkron ke MikroTik dan kirim struk WhatsApp.',
                          icon: Icons.bolt_rounded,
                          gradientColors: const [Color(0xFFFF8B00), Color(0xFFEA580C)],
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ==========================================
                    // 4. DANA FEED / TAGIHAN UNPAID & RECENT
                    // ==========================================
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
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
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryBlue,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Tagihan Menunggak (${unpaidInvoices.length})',
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                                    'Lihat Semua >',
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
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: isDark ? AppTheme.borderDark : const Color(0xFFF1F5F9),
                          ),

                          if (unpaidInvoices.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(28.0),
                              child: Center(
                                child: Column(
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFE6F9F0),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.check_circle_rounded, color: Color(0xFF00B074), size: 30),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Semua Tagihan Lunas! 🎉',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tidak ada tagihan tertunda untuk saat ini.',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: unpaidInvoices.length > 5 ? 5 : unpaidInvoices.length,
                              separatorBuilder: (_, __) => Divider(
                                height: 1,
                                thickness: 1,
                                color: isDark ? AppTheme.borderDark : const Color(0xFFF8FAFD),
                              ),
                              itemBuilder: (context, idx) {
                                final inv = unpaidInvoices[idx];
                                final name = inv['customer_name'] ?? inv['nama'] ?? 'Pelanggan';
                                final phone = inv['customer_phone'] ?? inv['phone'] ?? '';
                                final amount = inv['amount'] ?? inv['total_amount'] ?? 0;
                                final dueDate = inv['due_date'] ?? inv['periode'] ?? '-';

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      // Avatar Circle with initial
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF5E7),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: const Color(0xFFFF8B00).withOpacity(0.3), width: 1),
                                        ),
                                        child: Center(
                                          child: Text(
                                            name.isNotEmpty ? name[0].toUpperCase() : 'P',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFFFF8B00),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w700,
                                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Jatuh Tempo: $dueDate',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Amount & Actions
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            _formatCurrency(amount),
                                            style: const TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFFF43F5E),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (phone.isNotEmpty) ...[
                                                BouncingButton(
                                                  onTap: () => _openWhatsApp(phone, name, amount),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFE8F5E9),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: const Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.chat_bubble_outline_rounded, size: 12, color: Color(0xFF00B074)),
                                                        SizedBox(width: 3),
                                                        Text('WA', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF00B074))),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                              ],
                                              BouncingButton(
                                                onTap: () {
                                                  // Open Pay Dialog
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) => InvoicePayDialog(
                                                      invoiceId: inv['id'] is int ? inv['id'] : int.tryParse(inv['id'].toString()) ?? 0,
                                                      customerName: name,
                                                      amount: (amount is num) ? amount.toDouble() : (double.tryParse(amount.toString()) ?? 0.0),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.primaryBlue,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: const Text(
                                                    'Bayar',
                                                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
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

  Widget _buildMiniPill(BuildContext context, {
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 10.5,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}
