import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/sound_effects.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/sales_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/zzz_badge.dart';
import '../../widgets/zzz_button.dart';
import '../../widgets/zzz_card.dart';
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

    final installedCount = salesProv.registrations.where((r) => r.status == 'installed').length;
    final pendingCount = salesProv.registrations.where((r) => r.status == 'pending').length;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            dashProv.fetchDashboard(),
            salesProv.fetchRegistrations(),
          ]);
        },
        color: AppTheme.primaryCyan,
        backgroundColor: AppTheme.bgCardElevated,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Tactical Header
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
                              color: AppTheme.primaryCyan,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'FIELD SALES // ${auth.user?.areaName?.toUpperCase() ?? "SUKOREJO"}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                              color: AppTheme.primaryCyan,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        auth.user?.name ?? 'Sales Officer',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textMain,
                        ),
                      ),
                    ],
                  ),
                  const ZzzBadge(label: 'ONLINE', type: ZzzBadgeType.success),
                ],
              ),
              const SizedBox(height: 20),

              // Tactical Telemetry HUD Card
              ZzzCard(
                tag: 'SALES METRICS',
                isAccent: true,
                child: Row(
                  children: [
                    _buildMetricCol('TOTAL INPUT', '${salesProv.registrations.length}', AppTheme.primaryCyan),
                    Container(width: 1, height: 40, color: AppTheme.borderSubtle),
                    _buildMetricCol('DISETUJUI / AKTIF', '$installedCount', AppTheme.accentGreen),
                    Container(width: 1, height: 40, color: AppTheme.borderSubtle),
                    _buildMetricCol('ANTREAN TEKNISI', '$pendingCount', AppTheme.accentYellow),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Action Tile: Register Prospect
              ZzzButton(
                label: '+ DAFTARKAN CALON PELANGGAN',
                icon: Icons.person_add_alt_1_rounded,
                type: ZzzButtonType.cyan,
                onPressed: () {
                  SoundEffects.playTap();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterProspectScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'DAFTAR PENGAJUAN SAYA',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                      color: AppTheme.textMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    '${salesProv.registrations.length} REKORD',
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: AppTheme.primaryCyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Registrations Stream
              if (salesProv.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: AppTheme.primaryCyan),
                  ),
                )
              else if (salesProv.registrations.isEmpty)
                const EmptyState(
                  icon: Icons.assignment_outlined,
                  title: 'Belum Ada Pendaftaran',
                  message: 'Silakan klik tombol di atas untuk mendaftarkan calon pelanggan baru.',
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: salesProv.registrations.length,
                  itemBuilder: (ctx, idx) {
                    final r = salesProv.registrations[idx];
                    return ZzzCard(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  r.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textMain,
                                  ),
                                ),
                              ),
                              StatusBadge(status: r.status),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.phone_android_rounded, size: 14, color: AppTheme.primaryCyan),
                              const SizedBox(width: 6),
                              Text(
                                r.phone,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textMain,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.wifi_rounded, size: 14, color: AppTheme.accentYellow),
                              const SizedBox(width: 4),
                              Text(
                                r.packageName ?? 'Reguler',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.accentYellow,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textMuted),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  r.address,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textMuted,
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
      ),
    );
  }

  Widget _buildMetricCol(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: AppTheme.textMuted,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
