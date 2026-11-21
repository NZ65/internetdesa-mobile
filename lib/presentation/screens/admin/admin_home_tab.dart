import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/zzz_card.dart';
import '../../widgets/zzz_badge.dart';
import 'customer_list_screen.dart';
import 'expense_ledger_screen.dart';
import 'invoice_list_screen.dart';
import '../technician/odp_map_screen.dart';
import '../technician/quick_tools_screen.dart';
import '../sales/register_prospect_screen.dart';

class AdminHomeTab extends StatefulWidget {
  const AdminHomeTab({super.key});

  @override
  State<AdminHomeTab> createState() => _AdminHomeTabState();
}

class _AdminHomeTabState extends State<AdminHomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dashProv = context.watch<DashboardProvider>();
    final dash = dashProv.dashboard;

    return RefreshIndicator(
      onRefresh: () => dashProv.fetchDashboard(),
      color: AppTheme.neonCyan,
      backgroundColor: AppTheme.bgCard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 52, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: System ID & User
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
                          'INTERNET DESA // SECTOR ${auth.user?.areaName?.toUpperCase() ?? "SUKOREJO"}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: AppTheme.neonCyan,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      auth.user?.name ?? 'COMMANDER',
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
                  text: auth.user?.role ?? 'ADMIN',
                  type: ZzzBadgeType.cyan,
                  icon: Icons.shield_rounded,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Hero Telemetry Card (ZZZ Style)
            ZzzCard(
              tag: 'LIVE NOC TELEMETRY',
              borderColor: AppTheme.neonCyan,
              hasGlow: true,
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
                            'LIVE WAN THROUGHPUT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textMuted,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dash?.wanRx ?? '145.2 Mbps',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.neonCyan,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.bgDark,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.borderDark),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_upward_rounded, size: 14, color: AppTheme.hazardYellow),
                            const SizedBox(width: 4),
                            Text(
                              dash?.wanTx ?? '27.1 Mbps',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textSilver,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.borderDark, height: 1),
                  const SizedBox(height: 14),

                  // Mini stats row: Saldo Kas & Online PPPoE
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ExpenseLedgerScreen()),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'SALDO KAS OPERASIONAL',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                Formatters.formatCurrency(dash?.saldoKas ?? 19270293),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.hazardYellow,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(width: 1, height: 30, color: AppTheme.borderDark),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PPPoE ONLINE',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(Icons.wifi_tethering_rounded, size: 14, color: AppTheme.neonGreen),
                                const SizedBox(width: 6),
                                Text(
                                  '${dash?.activePppoe ?? 109} / ${dash?.totalCustomers ?? 114}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.neonGreen,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Emergency LOS Alert Banner (If Any)
            if (dashProv.hasAlert || (dashProv.losCount > 0)) ...[
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QuickToolsScreen(initialTab: 1)),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.crimsonRed.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.crimsonRed, width: 1.2),
                    boxShadow: [
                      BoxShadow(color: AppTheme.crimsonRed.withOpacity(0.2), blurRadius: 12),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppTheme.crimsonRed, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CRITICAL // DETEKSI KABEL OPTIK PUTUS',
                              style: TextStyle(
                                color: AppTheme.crimsonRed,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              'Ada ${dashProv.losCount} pelanggan mengalami LOS fisik. Klik untuk periksa.',
                              style: const TextStyle(
                                color: AppTheme.textSilver,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppTheme.crimsonRed),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Section Header: Tactical Actions
            Row(
              children: const [
                Icon(Icons.dashboard_customize_rounded, size: 14, color: AppTheme.neonCyan),
                SizedBox(width: 8),
                Text(
                  'SECTOR OPERATIONS // QUICK ACTIONS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textSilver,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tactical Grid (8 Tiles)
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                _buildActionTile(
                  context,
                  icon: Icons.people_alt_rounded,
                  label: 'Pelanggan',
                  color: AppTheme.neonCyan,
                  badge: '${dash?.totalCustomers ?? 114}',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerListScreen())),
                ),
                _buildActionTile(
                  context,
                  icon: Icons.receipt_long_rounded,
                  label: 'Tagihan',
                  color: AppTheme.hazardYellow,
                  badge: '${dash?.unpaidCount ?? 28}',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvoiceListScreen())),
                ),
                _buildActionTile(
                  context,
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Buku Kas',
                  color: AppTheme.neonGreen,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseLedgerScreen())),
                ),
                _buildActionTile(
                  context,
                  icon: Icons.alt_route_rounded,
                  label: 'ODP Map',
                  color: AppTheme.electricPurple,
                  badge: '15',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OdpMapScreen())),
                ),
                _buildActionTile(
                  context,
                  icon: Icons.speed_rounded,
                  label: 'Diagnosa',
                  color: AppTheme.neonCyan,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuickToolsScreen())),
                ),
                _buildActionTile(
                  context,
                  icon: Icons.warning_amber_rounded,
                  label: 'Cek LOS',
                  color: AppTheme.crimsonRed,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuickToolsScreen(initialTab: 1))),
                ),
                _buildActionTile(
                  context,
                  icon: Icons.add_card_rounded,
                  label: 'Catat Kas',
                  color: AppTheme.accentOrange,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseLedgerScreen(openAddModal: true))),
                ),
                _buildActionTile(
                  context,
                  icon: Icons.person_add_alt_1_rounded,
                  label: 'Pasang Baru',
                  color: AppTheme.neonCyan,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterProspectScreen())),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Sector Financial Overview
            ZzzCard(
              tag: 'FINANCIAL SECTOR OVERVIEW',
              borderColor: AppTheme.borderDark,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Pendapatan Terverifikasi',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                      Text(
                        Formatters.formatCurrency(dash?.totalPaidThisMonth ?? 18450000),
                        style: const TextStyle(
                          color: AppTheme.textWhite,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Piutang Tagihan Tertunda',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                      Text(
                        Formatters.formatCurrency(dash?.totalUnpaidThisMonth ?? 4600000),
                        style: const TextStyle(
                          color: AppTheme.crimsonRed,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    String? badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderDark, width: 1.2),
        ),
        padding: const EdgeInsets.all(8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textWhite,
                  ),
                ),
              ],
            ),
            if (badge != null)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.bgDark,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
