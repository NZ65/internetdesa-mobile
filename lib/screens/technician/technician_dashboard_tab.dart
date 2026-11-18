import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../models/ticket_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/stat_card.dart';
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
    final msg = Uri.encodeComponent('Halo Kak $name, saya teknisi dari Internet Desa Sukorejo. Terkait tiket gangguan internet Anda, saat ini saya sedang menuju ke lokasi...');
    final uri = Uri.parse('https://wa.me/$target?text=$msg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final dash = Provider.of<DashboardProvider>(context);
    final ticketProvider = Provider.of<TicketProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final user = auth.user;
    final stats = dash.dashboardData?.stats ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF0D9488),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Teknisi Lapangan (${user?.areaName ?? "W3"})',
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
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // ==========================================
            // 1. TECHNICIAN HERO BANNER
            // ==========================================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F766E).withOpacity(0.35),
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
                        Icons.engineering_rounded,
                        color: Color(0xFF0F766E),
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
                          'Teknisi: ${user?.name ?? user?.username}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Siaga Perbaikan & Pemeliharaan ODP',
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
                        const Icon(Icons.circle, color: Color(0xFF5EEAD4), size: 7),
                        const SizedBox(width: 5),
                        Text(
                          '${ticketProvider.tickets.length} TUGAS',
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
                    title: 'Tiket Terbuka',
                    value: '${ticketProvider.tickets.length}',
                    subtitle: 'Menunggu penanganan teknisi',
                    icon: Icons.assignment_late_rounded,
                    color: AppTheme.accentRed,
                    badgeText: 'PRIORITAS',
                    badgeColor: AppTheme.accentRed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Kotak ODP Sukorejo',
                    value: '${stats['total_odp_count'] ?? 16}',
                    subtitle: 'Terpetakan dalam jaringan',
                    icon: Icons.inventory_2_rounded,
                    color: const Color(0xFF0D9488),
                    badgeText: 'INFRASTRUKTUR',
                    badgeColor: const Color(0xFF0D9488),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ==========================================
            // 3. QUICK TOOLS STRIP
            // ==========================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Alat Troubleshoot Mandiri',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const QuickToolsScreen()),
                    );
                  },
                  child: const Text(
                    'Buka Semua Tools →',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D9488),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildToolChip(
                    context,
                    label: 'Ping Test IP',
                    icon: Icons.network_ping_rounded,
                    color: const Color(0xFF0284C7),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QuickToolsScreen()),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildToolChip(
                    context,
                    label: 'Reboot Modem ONT',
                    icon: Icons.restart_alt_rounded,
                    color: AppTheme.accentRed,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QuickToolsScreen()),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildToolChip(
                    context,
                    label: 'Ganti Sandi WiFi',
                    icon: Icons.wifi_password_rounded,
                    color: AppTheme.accentGreen,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QuickToolsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ==========================================
            // 4. DAFTAR TIKET GANGGUAN AKTIF
            // ==========================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Tiket Gangguan Aktif',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                ),
                Text(
                  '${ticketProvider.tickets.length} Tiket',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentRed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (ticketProvider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (ticketProvider.tickets.isEmpty)
              const EmptyState(
                icon: Icons.verified_rounded,
                title: 'Jaringan Kondusif & Normal',
                message: 'Semua jalur dan ODP aman! Tidak ada antrean tiket gangguan saat ini.',
              )
            else
              ...ticketProvider.tickets.map((t) {
                final isCritical = t.priority == 'critical';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF131C2E) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isCritical
                          ? AppTheme.accentRed.withOpacity(0.4)
                          : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                      width: isCritical ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.3)
                            : (isCritical ? AppTheme.accentRed.withOpacity(0.08) : Colors.black.withOpacity(0.04)),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TicketDetailScreen(ticket: t)),
                      );
                      if (updated == true) _loadData();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isCritical
                                      ? AppTheme.accentRed.withOpacity(0.15)
                                      : AppTheme.accentOrange.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  isCritical ? Icons.error_rounded : Icons.warning_amber_rounded,
                                  color: isCritical ? AppTheme.accentRed : AppTheme.accentOrange,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'ID: #${t.id} • Prioritas: ${t.priority.toUpperCase()}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isCritical ? AppTheme.accentRed : (isDark ? Colors.grey[400] : const Color(0xFF64748B)),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              StatusBadge(status: t.status),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.person_rounded, size: 15, color: Color(0xFF64748B)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Pelanggan: ${t.customerName ?? "Umum / Area"}',
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (t.customerAddress != null && t.customerAddress!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded, size: 15, color: Color(0xFF64748B)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    t.customerAddress!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (t.customerPhone != null && t.customerPhone!.isNotEmpty) ...[
                                OutlinedButton.icon(
                                  onPressed: () => _callPhone(t.customerPhone!),
                                  icon: const Icon(Icons.call_rounded, size: 14),
                                  label: const Text('Telepon', style: TextStyle(fontSize: 11.5)),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    minimumSize: Size.zero,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  onPressed: () => _openWhatsApp(t.customerPhone!, t.customerName ?? 'Pelanggan'),
                                  icon: const Icon(Icons.chat_rounded, size: 14, color: Color(0xFF25D366)),
                                  label: const Text('WhatsApp', style: TextStyle(fontSize: 11.5, color: Color(0xFF25D366))),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    minimumSize: Size.zero,
                                    side: const BorderSide(color: Color(0xFF25D366)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              ElevatedButton(
                                onPressed: () async {
                                  final updated = await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => TicketDetailScreen(ticket: t)),
                                  );
                                  if (updated == true) _loadData();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0F766E),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  minimumSize: Size.zero,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('Detail Tiket →', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildToolChip(
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
