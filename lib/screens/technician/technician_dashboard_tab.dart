import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../models/ticket_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../widgets/anime_mascot_card.dart';
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
    final msg = Uri.encodeComponent('Halo Kak $name, saya teknisi Internet Desa Sukorejo. Terkait kendala internet Anda, saat ini kami sedang meluncur ke lokasi...');
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
                          'Pelanggan LOS / Putus (${losItems.length})',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        const Text(
                          'Kabel optik putus fisik atau modem mati daya (Dying Gasp)',
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
                    child: Text('🎉 Tidak ada kabel optik yang putus (LOS 0).'),
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
    final losCount = dash.losCount;

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
                    subtitle: losCount > 0 ? '$losCount Pelanggan Kabel Putus (LOS)' : 'Siaga Wilayah Sukorejo',
                    roleBadge: 'Teknisi Lapangan',
                    isConnected: losCount == 0,
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
                          label: 'Cek LOS',
                          icon: Icons.cell_tower_rounded,
                          iconColor: AppTheme.accentRed,
                          bgColor: AppTheme.pastelRed,
                          badgeText: losCount > 0 ? '$losCount' : null,
                          onTap: () => _showLosDetailDialog(context, dash.losItems),
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
                          label: 'ODP',
                          value: '$odpCount Titik',
                          color: const Color(0xFF00B074),
                          icon: Icons.inventory_2_outlined,
                        ),
                        if (losCount > 0) ...[
                          Container(height: 16, width: 1, color: const Color(0xFFE2E8F0)),
                          _buildMiniPill(
                            context,
                            label: 'LOS',
                            value: '$losCount',
                            color: AppTheme.accentRed,
                            icon: Icons.power_off_rounded,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ==========================================
              // 2. ANIME MASCOT COMPANION (Desa-chan)
              // ==========================================
              AnimeMascotCard(
                losCount: losCount,
                openTicketsCount: openTickets.length,
                isNocConnected: true,
                onTapLos: () => _showLosDetailDialog(context, dash.losItems),
                onTapTickets: () {},
                onTapPing: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QuickToolsScreen()),
                  );
                },
              ),

              // ==========================================
              // 3. DANA SERVICE GRID (Tools Diagnostik)
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
                        MaterialPageRoute(builder: (_) => const QuickToolsScreen(initialIndex: 0)),
                      );
                    },
                  ),
                  DanaServiceItem(
                    label: 'Cek LOS & Redaman',
                    icon: Icons.cell_tower_rounded,
                    iconColor: AppTheme.accentRed,
                    bgColor: AppTheme.pastelRed,
                    badgeText: losCount > 0 ? '$losCount LOS' : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QuickToolsScreen(initialIndex: 1)),
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
                        MaterialPageRoute(builder: (_) => const QuickToolsScreen(initialIndex: 2)),
                      );
                    },
                  ),
                  DanaServiceItem(
                    label: 'Kick PPPoE',
                    icon: Icons.flash_on_rounded,
                    iconColor: const Color(0xFFEF4444),
                    bgColor: const Color(0xFFFEE2E2),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QuickToolsScreen(initialIndex: 2)),
                      );
                    },
                  ),
                  DanaServiceItem(
                    label: 'Peta Jalur ODP',
                    icon: Icons.map_rounded,
                    iconColor: const Color(0xFF059669),
                    bgColor: const Color(0xFFD1FAE5),
                    onTap: () {
                      _showInfoDialog(
                        'Peta ODP & Fiber Sukorejo',
                        'Total 16 ODP terpasang. Tautan maps & koordinat presisi tersedia di web portal.',
                        Icons.map_rounded,
                      );
                    },
                  ),
                  DanaServiceItem(
                    label: 'Speedtest Lapangan',
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
                    label: 'Isolir / Un-isolir',
                    icon: Icons.lock_reset_rounded,
                    iconColor: const Color(0xFFD97706),
                    bgColor: const Color(0xFFFEF3C7),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QuickToolsScreen(initialIndex: 2)),
                      );
                    },
                  ),
                  DanaServiceItem(
                    label: 'Kontak NOC',
                    icon: Icons.support_agent_rounded,
                    iconColor: AppTheme.primaryBlue,
                    bgColor: AppTheme.primaryLight,
                    badgeText: '24 Jam',
                    onTap: () => _callPhone('085226118497'),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ==========================================
              // 4. BANNER CAROUSEL
              // ==========================================
              DanaBannerCarousel(
                banners: [
                  DanaBannerItem(
                    tag: 'SOP TEKNISI',
                    title: 'Standar Redaman Fiber Optik',
                    subtitle: 'Pastikan sinyal optik ONT di pelanggan berkisar antara -18 s/d -24 dBm.',
                    icon: Icons.engineering_rounded,
                    gradientColors: const [Color(0xFF118EEA), Color(0xFF0C75C2)],
                    onTap: () {},
                  ),
                  DanaBannerItem(
                    tag: 'NOTIFIKASI OTOMATIS',
                    title: 'Auto-Alert Pelanggan LOS',
                    subtitle: 'Aplikasi kini otomatis memunculkan notifikasi di HP jika kabel optik terputus.',
                    icon: Icons.notifications_active_rounded,
                    gradientColors: const [Color(0xFFF43F5E), Color(0xFFE11D48)],
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ==========================================
              // 5. DAFTAR TIKET GANGGUAN TERBARU
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
                                  color: AppTheme.accentOrange,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tiket Menunggu Penanganan (${openTickets.length})',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    if (ticketProvider.isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (openTickets.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 36),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.task_alt_rounded, size: 48, color: Color(0xFF00B074)),
                              SizedBox(height: 10),
                              Text(
                                'Semua Tiket Selesai!',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Tidak ada antrean gangguan warga saat ini.',
                                style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
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
                        separatorBuilder: (_, __) => const Divider(height: 1, indent: 70),
                        itemBuilder: (context, idx) {
                          final ticket = openTickets[idx];
                          final name = ticket.customerName ?? 'Pelanggan #${ticket.customerId}';

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.pastelOrange,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Center(
                                child: Icon(Icons.build_circle_rounded, color: AppTheme.accentOrange, size: 24),
                              ),
                            ),
                            title: Text(
                              name,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 2),
                                Text(
                                  ticket.issue,
                                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (ticket.customerPhone != null && ticket.customerPhone!.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.chat_rounded, color: Color(0xFF00B074), size: 20),
                                    onPressed: () => _openWhatsApp(ticket.customerPhone!, name),
                                    tooltip: 'Chat WhatsApp',
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF94A3B8), size: 14),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => TicketDetailScreen(ticket: ticket)),
                                    );
                                  },
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
