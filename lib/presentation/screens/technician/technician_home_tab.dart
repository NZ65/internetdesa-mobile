import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/sound_effects.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/technician_provider.dart';
import '../../widgets/blue_archive_stage.dart';
import '../../widgets/cyber_card.dart';
import '../../widgets/dana_curved_header.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/squircle_action_button.dart';
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
      color: AppTheme.primaryBlue,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Curved DANA & Blue Archive Header
            DanaCurvedHeader(
              userName: auth.user?.name ?? 'Teknisi',
              role: 'TEKNISI LAPANGAN',
              areaName: auth.user?.areaName ?? 'Sukorejo',
              saldoKas: dashProv.dashboard?.saldoKas ?? 0,
              sisaModal: dashProv.dashboard?.sisaModal,
              sisaKasOps: dashProv.dashboard?.sisaKasOps,
              wanRx: dashProv.dashboard?.wanRx ?? '0 bps',
              wanTx: dashProv.dashboard?.wanTx ?? '0 bps',
              activePppoe: dashProv.dashboard?.activePppoe ?? 0,
            ),

            // Blue Archive SCHALE Tactical Terminal & MomoTalk
            BlueArchiveStage(
              hasAlert: dashProv.hasAlert,
              losCount: dashProv.losCount,
              userName: auth.user?.name ?? 'Teknisi',
              onAlertTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const QuickToolsScreen(initialTab: 1)),
                );
              },
            ),

            // Quick Technician Actions Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: CyberCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SquircleActionButton(
                      code: '01',
                      icon: Icons.alt_route_rounded,
                      label: 'ODP Map',
                      iconColor: AppTheme.accentPurple,
                      backgroundColor: AppTheme.pastelPurple,
                      badgeText: '${techProv.odps.length}',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const OdpMapScreen()),
                        );
                      },
                    ),
                    SquircleActionButton(
                      code: '02',
                      icon: Icons.warning_amber_rounded,
                      label: 'Pelanggan LOS',
                      iconColor: AppTheme.accentRed,
                      backgroundColor: AppTheme.pastelRed,
                      badgeText: (dashProv.dashboard?.losOnus ?? 0) > 0 ? '${dashProv.dashboard!.losOnus}' : null,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const QuickToolsScreen(initialTab: 1)),
                        );
                      },
                    ),
                    SquircleActionButton(
                      code: '03',
                      icon: Icons.wifi_tethering_rounded,
                      label: 'Ping Test',
                      iconColor: AppTheme.primaryBlue,
                      backgroundColor: const Color(0xFFE0F2FE),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const QuickToolsScreen(initialTab: 0)),
                        );
                      },
                    ),
                    SquircleActionButton(
                      code: '04',
                      icon: Icons.restart_alt_rounded,
                      label: 'Reboot ONT',
                      iconColor: AppTheme.accentGreen,
                      backgroundColor: AppTheme.pastelGreen,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const QuickToolsScreen(initialTab: 2)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Trouble Tickets Section Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TIKET GANGGUAN AKTIF',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textMain,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    '${techProv.tickets.length} Tiket',
                    style: const TextStyle(fontSize: 12, color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Tickets List
            if (techProv.isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (techProv.tickets.isEmpty)
              const EmptyState(
                icon: Icons.check_circle_outline_rounded,
                title: 'Tidak Ada Gangguan Aktif',
                message: 'Semua tiket gangguan pelanggan telah terselesaikan!',
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: techProv.tickets.length,
                itemBuilder: (ctx, idx) {
                  final t = techProv.tickets[idx];
                  return CyberCard(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(14),
                    onTap: () {
                      SoundEffects.playTap();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => TicketDetailScreen(ticket: t)),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              t.customerName,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                            ),
                            StatusBadge(status: t.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t.title,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t.customerAddress ?? 'Alamat belum diatur',
                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
