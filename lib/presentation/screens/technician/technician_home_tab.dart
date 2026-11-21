import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/sound_effects.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/technician_provider.dart';
import '../../widgets/zzz_card.dart';
import '../../widgets/zzz_badge.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';
import 'odp_map_screen.dart';
import 'quick_tools_screen.dart';
import 'ticket_detail_screen.dart';

class TechnicianHomeTab extends StatefulWidget {
  const TechnicianHomeTab({super.key});

  @override
  State<TechnicianHomeTab> createState() => _TechnicianHomeTabState();
}

class _TechnicianHomeTabState extends State<TechnicianHomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TechnicianProvider>().fetchTickets(status: 'open');
      context.read<TechnicianProvider>().fetchOdps();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dashProv = context.watch<DashboardProvider>();
    final techProv = context.watch<TechnicianProvider>();

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          dashProv.fetchDashboard(),
          techProv.fetchTickets(),
          techProv.fetchOdps(),
        ]);
      },
      color: AppTheme.neonCyan,
      backgroundColor: AppTheme.bgCard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 52, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Sector & Technician ID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.neonCyan,
                            boxShadow: [
                              BoxShadow(color: AppTheme.neonCyan, blurRadius: 6),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'FIELD ENGINEER // NOC SECTOR ${auth.user?.areaName?.toUpperCase() ?? "SUKOREJO"}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.4,
                            color: AppTheme.neonCyan,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      auth.user?.name ?? 'TEKNISI LAPANGAN',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textWhite,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                ZzzBadge(
                  text: 'TEKNISI NOC',
                  type: ZzzBadgeType.cyan,
                  icon: Icons.build_rounded,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Hero Telemetry Card for Field Operations
            ZzzCard(
              tag: 'FIELD SECTOR STATUS',
              borderColor: dashProv.hasAlert ? AppTheme.crimsonRed : AppTheme.neonCyan,
              hasGlow: dashProv.hasAlert,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'KONDISI FISIK JARINGAN',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textMuted,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dashProv.hasAlert
                                ? '${dashProv.losCount} PELANGGAN LOS'
                                : 'SEMUA LINK STABIL',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: dashProv.hasAlert ? AppTheme.crimsonRed : AppTheme.neonGreen,
                            ),
                          ),
                        ],
                      ),
                      ZzzBadge(
                        text: dashProv.hasAlert ? 'PERIKSA SEKARANG' : 'NORMAL',
                        type: dashProv.hasAlert ? ZzzBadgeType.red : ZzzBadgeType.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.borderDark, height: 1),
                  const SizedBox(height: 12),

                  // 3-Column stats: Online, LOS, Tiket Open
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetric('ONLINE', '${dashProv.dashboard?.activePppoe ?? 109}', AppTheme.neonGreen),
                      Container(width: 1, height: 28, color: AppTheme.borderDark),
                      _buildMetric('LOS FISIK', '${dashProv.losCount}', dashProv.losCount > 0 ? AppTheme.crimsonRed : AppTheme.textMuted),
                      Container(width: 1, height: 28, color: AppTheme.borderDark),
                      _buildMetric('TIKET OPEN', '${techProv.tickets.length}', techProv.tickets.isNotEmpty ? AppTheme.hazardYellow : AppTheme.textMuted),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick Diagnostic Actions
            Row(
              children: [
                Expanded(
                  child: ZzzCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const QuickToolsScreen()));
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.speed_rounded, color: AppTheme.neonCyan, size: 22),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('PING & DIAGNOSA', style: TextStyle(color: AppTheme.textWhite, fontSize: 11, fontWeight: FontWeight.w800)),
                              Text('Uji latensi real-time', style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ZzzCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const OdpMapScreen()));
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.alt_route_rounded, color: AppTheme.hazardYellow, size: 22),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('DIREKTORI ODP', style: TextStyle(color: AppTheme.textWhite, fontSize: 11, fontWeight: FontWeight.w800)),
                              Text('15 Box ODP Sukorejo', style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section: Active Field Tickets
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.assignment_rounded, size: 14, color: AppTheme.neonCyan),
                    SizedBox(width: 8),
                    Text(
                      'ACTIVE FIELD MISSIONS // TIKET GANGGUAN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textSilver,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${techProv.tickets.length} Tiket',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.neonCyan),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tickets List
            if (techProv.isLoading && techProv.tickets.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: AppTheme.neonCyan)))
            else if (techProv.tickets.isEmpty)
              const EmptyState(
                icon: Icons.check_circle_outline_rounded,
                title: 'Tidak Ada Gangguan Aktif',
                message: 'Seluruh koneksi pelanggan saat ini beroperasi normal.',
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: techProv.tickets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final ticket = techProv.tickets[index];
                  return ZzzCard(
                    padding: const EdgeInsets.all(14),
                    borderColor: ticket.isUrgent ? AppTheme.crimsonRed : AppTheme.borderDark,
                    onTap: () {
                      SoundEffects.playTap();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TicketDetailScreen(ticket: ticket)),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ticket.ticketNumber,
                              style: const TextStyle(
                                color: AppTheme.neonCyan,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                            StatusBadge(status: ticket.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ticket.customerName,
                          style: const TextStyle(
                            color: AppTheme.textWhite,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textMuted),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                ticket.customerAddress.isNotEmpty ? ticket.customerAddress : 'Alamat tidak tertera',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ticket.category.toUpperCase(),
                              style: const TextStyle(
                                color: AppTheme.hazardYellow,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Row(
                              children: [
                                Text(
                                  'DETAIL PENGERJAAN',
                                  style: TextStyle(
                                    color: AppTheme.neonCyan,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded, size: 16, color: AppTheme.neonCyan),
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
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
}
