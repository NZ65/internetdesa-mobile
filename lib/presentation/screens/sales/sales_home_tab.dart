import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/sound_effects.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/sales_provider.dart';
import '../../widgets/blue_archive_stage.dart';
import '../../widgets/cyber_card.dart';
import '../../widgets/dana_curved_header.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/squircle_action_button.dart';
import '../../widgets/status_badge.dart';
import 'register_prospect_screen.dart';

class SalesHomeTab extends StatefulWidget {
  const SalesHomeTab({super.key});

  @override
  State<SalesHomeTab> createState() => _SalesHomeTabState();
}

class _SalesHomeTabState extends State<SalesHomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesProvider>().fetchRegistrations();
      context.read<SalesProvider>().fetchPackages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dashProv = context.watch<DashboardProvider>();
    final salesProv = context.watch<SalesProvider>();

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          dashProv.fetchDashboard(),
          salesProv.fetchRegistrations(),
        ]);
      },
      color: AppTheme.primaryBlue,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Curved DANA Header
            DanaCurvedHeader(
              userName: auth.user?.name ?? 'Sales',
              role: 'TIM SALES LAPANGAN',
              areaName: auth.user?.areaName ?? 'Sukorejo',
              saldoKas: dashProv.dashboard?.saldoKas ?? 0,
            ),

            // Interactive Mascot Airi
            BlueArchiveStage(
              hasAlert: dashProv.hasAlert,
              losCount: dashProv.losCount,
              userName: auth.user?.name ?? 'Sales',
            ),

            // Quick Actions & Registrations Summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: CyberCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SquircleActionButton(
                      icon: Icons.person_add_alt_1_rounded,
                      label: 'Daftar Baru',
                      iconColor: AppTheme.primaryBlue,
                      backgroundColor: const Color(0xFFE0F2FE),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RegisterProspectScreen()),
                        );
                      },
                    ),
                    SquircleActionButton(
                      icon: Icons.inventory_2_rounded,
                      label: 'Paket Internet',
                      iconColor: AppTheme.accentOrange,
                      backgroundColor: AppTheme.pastelOrange,
                      badgeText: '${salesProv.packages.length}',
                      onTap: () {
                        // View packages
                      },
                    ),
                    SquircleActionButton(
                      icon: Icons.task_alt_rounded,
                      label: 'Terpasang',
                      iconColor: AppTheme.accentGreen,
                      backgroundColor: AppTheme.pastelGreen,
                      badgeText: '${salesProv.registrations.where((r) => r.status == "installed").length}',
                      onTap: () {},
                    ),
                    SquircleActionButton(
                      icon: Icons.hourglass_top_rounded,
                      label: 'Antrean',
                      iconColor: AppTheme.accentPurple,
                      backgroundColor: AppTheme.pastelPurple,
                      badgeText: '${salesProv.registrations.where((r) => r.status == "pending").length}',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),

            // Header Antrean Pasang Baru
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'RIWAYAT PENDAFTARAN SAYA',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textMain,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    '${salesProv.registrations.length} Pengajuan',
                    style: const TextStyle(fontSize: 12, color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Registrations List
            if (salesProv.isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (salesProv.registrations.isEmpty)
              const EmptyState(
                icon: Icons.assignment_outlined,
                title: 'Belum Ada Pendaftaran',
                message: 'Silakan daftarkan calon pelanggan baru melalui tombol di atas.',
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: salesProv.registrations.length,
                itemBuilder: (ctx, idx) {
                  final r = salesProv.registrations[idx];
                  return CyberCard(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              r.name,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                            ),
                            StatusBadge(status: r.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${r.phone} • Paket ${r.packageName ?? "Reguler"}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.primaryBlue, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          r.address,
                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
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
