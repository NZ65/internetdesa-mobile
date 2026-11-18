import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../models/ticket_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../widgets/bouncing_button.dart';
import '../../widgets/dana_header.dart';
import '../../widgets/dana_hero_card.dart';
import '../../widgets/dana_service_grid.dart';
import '../../widgets/dana_banner_carousel.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';
import 'ticket_detail_screen.dart';
import 'quick_tools_screen.dart';

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

  void _callPhone(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openWhatsApp(String phone, String name) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final target = clean.startsWith('0') ? '62${clean.substring(1)}' : (clean.startsWith('8') ? '62$clean' : clean);
    final msg = Uri.encodeComponent('Halo Kak $name, saya teknisi Internet Desa Sukorejo. Terkait tiket gangguan internet Anda, saat ini saya sedang menuju ke lokasi...');
    final uri = Uri.parse('https://wa.me/$target?text=$msg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openMapRoute(String? lat, String? lng, String? address) async {
    if (lat != null && lng != null && lat.isNotEmpty && lng.isNotEmpty) {
      final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }
    if (address != null && address.isNotEmpty) {
      final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  void _showInfoDialog(String title, String message, IconData icon) {
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
    final ticketProvider = Provider.of<TicketProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final user = auth.user;
    final stats = dash.dashboardData?.stats ?? {};
    final openTickets = ticketProvider.tickets;
    final odpCount = stats['total_odp_count'] ?? 16;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // ==========================================
              // 1. DANA HEADER & HERO TICKET CARD
              // ==========================================
              Stack(
                clipBehavior: Clip.none,
                children: [
                  DanaHeader(
                    title: 'Halo, ${user?.name ?? user?.username ?? "Teknisi"}',
                    subtitle: 'Area: ${user?.areaName ?? "W3 Sukorejo"}',
                    roleBadge: 'Teknisi Siaga',
                    isConnected: true,
                    isRefreshing: ticketProvider.isLoading,
                    onRefresh: _loadData,
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 96),
                    child: DanaHeroCard(
                      title: 'ANTREAN TIKET GANGGUAN',
                      primaryAmount: '${openTickets.length} Tiket Aktif',
                      secondaryText: openTickets.isNotEmpty ? 'Prioritas' : 'Aman',
                      actions: [
                        DanaActionItem(
                          label: 'Tiket Masuk',
                          icon: Icons.assignment_late_rounded,
                          iconColor: const Color(0xFFF43F5E),
                          bgColor: const Color(0xFFFFF1F2),
                          badgeText: openTickets.isNotEmpty ? '${openTickets.length}' : null,
                          onTap: () {},
                        ),
                        DanaActionItem(
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
                        DanaActionItem(
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
                        DanaActionItem(
                          label: 'Peta ODP',
                          icon: Icons.map_rounded,
                          iconColor: AppTheme.primaryBlue,
                          bgColor: AppTheme.primaryLight,
                          onTap: () {
                            _showInfoDialog(
                              'Peta Jalur Fiber & ODP',
                              'Total 16 ODP aktif terpetakan di area Sukorejo. Cek jalur kabel via Google Maps atau web dashboard.',
                              Icons.map_rounded,
                            );
                          },
                        ),
                      ],
                      footerPills: [
                        _buildMiniPill(
                          context,
                          label: 'Tiket Open',
                          value: '${openTickets.length}',
                          color: openTickets.isNotEmpty ? const Color(0xFFF43F5E) : const Color(0xFF00B074),
                          icon: Icons.confirmation_number_outlined,
                        ),
                        Container(height: 16, width: 1, color: const Color(0xFFE2E8F0)),
                        _buildMiniPill(
                          context,
                          label: 'ODP Sukorejo',
                          value: '$odpCount Titik',
                          color: const Color(0xFF00B074),
                          icon: Icons.inventory_2_outlined,
                        ),
                        Container(height: 16, width: 1, color: const Color(0xFFE2E8F0)),
                        _buildMiniPill(
                          context,
                          label: 'Status Tim',
                          value: 'Siaga',
                          color: AppTheme.primaryBlue,
                          icon: Icons.verified_user_outlined,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ==========================================
              // 2. DANA SERVICE GRID (Tools Diagnostik)
              // ==========================================
              DanaServiceGrid(
                title: 'Alat Cepat & Diagnostik Lapangan',
                items: [
                  DanaServiceItem(
                    label: 'Ping Test IP',
                    icon: Icons.network_ping_rounded,
                    iconColor: const Color(0xFF0284C7),
                    bgColor: const Color(0xFFE0F2FE),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QuickToolsScreen()),
                      );
                    },
                  ),
                  DanaServiceItem(
                    label: 'Cek Redaman',
                    icon: Icons.speed_rounded,
                    iconColor: const Color(0xFF00B074),
                    bgColor: const Color(0xFFE6F9F0),
                    badgeText: 'dBm',
                    onTap: () {
                      _showInfoDialog(
                        'Standar Redaman Fiber',
                        'Standar normal redaman ONT di rumah pelanggan adalah antara -18 dBm s/d -24 dBm. Redaman di atas -27 dBm perlu perbaikan sambungan / fast connector.',
                        Icons.speed_rounded,
                      );
                    },
                  ),
                  DanaServiceItem(
                    label: 'Remote ONT',
                    icon: Icons.settings_remote_rounded,
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
                    label: 'Ganti Sandi',
                    icon: Icons.wifi_lock_rounded,
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
                    label: 'ODP 8-Port',
                    icon: Icons.grid_view_rounded,
                    iconColor: const Color(0xFFEC4899),
                    bgColor: const Color(0xFFFCE7F3),
                    onTap: () {
                      _showInfoDialog(
                        'Manajemen Port ODP',
                        'Setiap ODP memiliki 8 slot dropcore. Pastikan nomor port dicatat saat pasang baru agar memudahkan maintenance.',
                        Icons.grid_view_rounded,
                      );
                    },
                  ),
                  DanaServiceItem(
                    label: 'Sisa Dropcore',
                    icon: Icons.cable_rounded,
                    iconColor: const Color(0xFF0D9488),
                    bgColor: const Color(0xFFCCFBF1),
                    onTap: () {
                      _showInfoDialog(
                        'Stok Material Dropcore',
                        'Rekap kabel dropcore dan fast connector tercatat di server. Ajukan penambahan jika sisa haspel di bawah 100m.',
                        Icons.cable_rounded,
                      );
                    },
                  ),
                  DanaServiceItem(
                    label: 'Grup Telegram',
                    icon: Icons.send_rounded,
                    iconColor: const Color(0xFF0284C7),
                    bgColor: const Color(0xFFE0F2FE),
                    onTap: () {
                      _showInfoDialog(
                        'Notifikasi Bot Telegram',
                        'Setiap pendaftaran baru dan tiket darurat otomatis dikirim ke grup Telegram teknisi & admin.',
                        Icons.send_rounded,
                      );
                    },
                  ),
                  DanaServiceItem(
                    label: 'Bantuan SOP',
                    icon: Icons.menu_book_rounded,
                    iconColor: const Color(0xFF64748B),
                    bgColor: const Color(0xFFF1F5F9),
                    onTap: () {
                      _showInfoDialog(
                        'SOP Teknisi Lapangan',
                        '1. Utamakan K3 & keselamatan tiang listrik.\n2. Verifikasi redaman optik sebelum serah terima.\n3. Uji kecepatan internet minimal 3x.\n4. Ambil foto bukti instalasi selesai.',
                        Icons.menu_book_rounded,
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ==========================================
              // 3. DANA BANNER CAROUSEL
              // ==========================================
              DanaBannerCarousel(
                banners: [
                  DanaBannerItem(
                    tag: 'K3 LAPANGAN',
                    title: 'Keselamatan Kerja Nomor 1',
                    subtitle: 'Gunakan sabuk pengaman, helm proyek, dan periksa tegangan kabel saat naik ke tiang.',
                    icon: Icons.health_and_safety_rounded,
                    gradientColors: const [Color(0xFF0F766E), Color(0xFF14B8A6)],
                    onTap: () {},
                  ),
                  DanaBannerItem(
                    tag: 'STANDAR REDAMAN',
                    title: 'Target Sinyal Optik',
                    subtitle: 'Pastikan sinyal di bawah -24 dBm agar pelanggan tidak mengalami loss paket atau RTO.',
                    icon: Icons.network_check_rounded,
                    gradientColors: const [Color(0xFF118EEA), Color(0xFF0073C7)],
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ==========================================
              // 4. DAFTAR TIKET GANGGUAN FEED
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
                                  color: AppTheme.accentRed,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Daftar Tiket Gangguan (${openTickets.length})',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            openTickets.isNotEmpty ? 'Perlu Ditangani' : 'Aman',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: openTickets.isNotEmpty ? AppTheme.accentRed : const Color(0xFF00B074),
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

                    if (ticketProvider.isLoading)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (openTickets.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(28.0),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.verified_rounded, color: Color(0xFF00B074), size: 48),
                              SizedBox(height: 12),
                              Text(
                                'Semua Jalur Aman & Normal! 🎉',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Tidak ada antrean gangguan saat ini. Kerja bagus!',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: openTickets.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          thickness: 1,
                          color: isDark ? AppTheme.borderDark : const Color(0xFFF8FAFD),
                        ),
                        itemBuilder: (context, idx) {
                          final t = openTickets[idx];
                          final isCritical = t.priority == 'critical';

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: isCritical
                                            ? const Color(0xFFFFF1F2)
                                            : const Color(0xFFFEF5E7),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: (isCritical ? AppTheme.accentRed : const Color(0xFFFF8B00)).withOpacity(0.3),
                                        ),
                                      ),
                                      child: Icon(
                                        isCritical ? Icons.error_rounded : Icons.warning_amber_rounded,
                                        color: isCritical ? AppTheme.accentRed : const Color(0xFFFF8B00),
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t.title,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Pelanggan: ${t.customerName ?? "Umum"}',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    StatusBadge(status: t.status),
                                  ],
                                ),
                                if (t.customerAddress != null && t.customerAddress!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    t.customerAddress!,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: isDark ? Colors.grey[400] : const Color(0xFF475569),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (t.customerPhone != null && t.customerPhone!.isNotEmpty) ...[
                                      BouncingButton(
                                        onTap: () => _openWhatsApp(t.customerPhone!, t.customerName ?? 'Pelanggan'),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE8F5E9),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.chat_bubble_outline_rounded, size: 13, color: Color(0xFF00B074)),
                                              SizedBox(width: 4),
                                              Text('WA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00B074))),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    BouncingButton(
                                      onTap: () => _openMapRoute(t.latitude, t.longitude, t.customerAddress),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE0F2FE),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.navigation_rounded, size: 13, color: Color(0xFF0284C7)),
                                            SizedBox(width: 4),
                                            Text('Rute', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    BouncingButton(
                                      onTap: () async {
                                        final updated = await Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => TicketDetailScreen(ticket: t)),
                                        );
                                        if (updated == true) _loadData();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryBlue,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'Tangani',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                      ),
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
