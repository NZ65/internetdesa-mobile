import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/sound_effects.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/blue_archive_mascot.dart';
import '../../widgets/cyber_card.dart';
import '../../widgets/dana_curved_header.dart';
import '../../widgets/squircle_action_button.dart';
import 'customer_list_screen.dart';
import 'expense_ledger_screen.dart';
import 'invoice_list_screen.dart';
import '../technician/odp_map_screen.dart';
import '../technician/quick_tools_screen.dart';
import '../sales/register_prospect_screen.dart';

class AdminHomeTab extends StatelessWidget {
  const AdminHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dashProv = context.watch<DashboardProvider>();
    final dash = dashProv.dashboard;

    return RefreshIndicator(
      onRefresh: () => dashProv.fetchDashboard(),
      color: AppTheme.primaryBlue,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Signature DANA Curved Header
            DanaCurvedHeader(
              userName: auth.user?.name ?? 'Admin',
              role: auth.user?.role ?? 'Admin',
              areaName: auth.user?.areaName ?? 'Sukorejo',
              saldoKas: dash?.saldoKas ?? 0,
              wanRx: dash?.wanRx ?? '0 bps',
              wanTx: dash?.wanTx ?? '0 bps',
              activePppoe: dash?.activePppoe ?? 0,
              onSaldoTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ExpenseLedgerScreen()),
                );
              },
            ),

            // 2. Interactive Blue Archive Mascot Assistant (Airi)
            BlueArchiveMascot(
              hasAlert: dashProv.hasAlert,
              losCount: dashProv.losCount,
              onAlertTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const QuickToolsScreen(initialTab: 1)),
                );
              },
            ),

            // 3. Quick Actions Grid (DANA Squircle Style)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: CyberCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SquircleActionButton(
                          icon: Icons.people_alt_rounded,
                          label: 'Pelanggan',
                          iconColor: AppTheme.primaryBlue,
                          backgroundColor: const Color(0xFFE0F2FE),
                          badgeText: dash != null ? '${dash.totalCustomers}' : null,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const CustomerListScreen()),
                            );
                          },
                        ),
                        SquircleActionButton(
                          icon: Icons.receipt_long_rounded,
                          label: 'Tagihan',
                          iconColor: AppTheme.accentOrange,
                          backgroundColor: AppTheme.pastelOrange,
                          badgeText: (dash?.unpaidCount ?? 0) > 0 ? '${dash!.unpaidCount}' : null,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const InvoiceListScreen()),
                            );
                          },
                        ),
                        SquircleActionButton(
                          icon: Icons.add_card_rounded,
                          label: 'Catat Kas',
                          iconColor: AppTheme.accentGreen,
                          backgroundColor: AppTheme.pastelGreen,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ExpenseLedgerScreen(openAddModal: true)),
                            );
                          },
                        ),
                        SquircleActionButton(
                          icon: Icons.alt_route_rounded,
                          label: 'ODP Map',
                          iconColor: AppTheme.accentPurple,
                          backgroundColor: AppTheme.pastelPurple,
                          badgeText: '15',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const OdpMapScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SquircleActionButton(
                          icon: Icons.speed_rounded,
                          label: 'Diagnosa',
                          iconColor: AppTheme.techCyan,
                          backgroundColor: const Color(0xFFE0F7FA),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const QuickToolsScreen()),
                            );
                          },
                        ),
                        SquircleActionButton(
                          icon: Icons.warning_amber_rounded,
                          label: 'Cek LOS',
                          iconColor: AppTheme.accentRed,
                          backgroundColor: AppTheme.pastelRed,
                          badgeText: (dash?.losOnus ?? 0) > 0 ? '${dash!.losOnus}' : null,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const QuickToolsScreen(initialTab: 1)),
                            );
                          },
                        ),
                        SquircleActionButton(
                          icon: Icons.person_add_alt_1_rounded,
                          label: 'Pasang Baru',
                          iconColor: const Color(0xFF0288D1),
                          backgroundColor: const Color(0xFFE1F5FE),
                          badgeText: (dash?.pendingRegistrations ?? 0) > 0 ? '${dash!.pendingRegistrations}' : null,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RegisterProspectScreen()),
                            );
                          },
                        ),
                        SquircleActionButton(
                          icon: Icons.account_balance_wallet_rounded,
                          label: 'Buku Kas',
                          iconColor: const Color(0xFF5E35B1),
                          backgroundColor: const Color(0xFFEDE7F6),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ExpenseLedgerScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 4. NOC Hardware Telemetry (MikroTik Core + OLT FD1602S)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Row(
                children: const [
                  Icon(Icons.router_rounded, color: AppTheme.primaryBlue, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'TELEMETRI HARDWARE NOC',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textMain,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // MikroTik Card
                  Expanded(
                    child: CyberCard(
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: dash?.isMikrotikOnline == true ? AppTheme.accentGreen : AppTheme.accentRed,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'MikroTik Core',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            dash?.wanRx ?? '0 bps',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue),
                          ),
                          const Text('Live WAN Download', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('PPPoE Aktif:', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                              Text('${dash?.activePppoe ?? 0}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('CPU Load:', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                              Text('${dash?.cpuLoad ?? 0}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // OLT Card
                  Expanded(
                    child: CyberCard(
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: dash?.isOltOnline == true ? AppTheme.accentGreen : AppTheme.accentRed,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'OLT C-Data',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                '${dash?.onlineOnus ?? 0}',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.accentGreen),
                              ),
                              Text(' / ${dash?.totalOnus ?? 0} ONU', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                            ],
                          ),
                          const Text('ONU Terdaftar', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('ONU LOS:', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                              Text(
                                '${dash?.losOnus ?? 0}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: (dash?.losOnus ?? 0) > 0 ? AppTheme.accentRed : AppTheme.textMain,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Daya Optik:', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                              Text(dash?.avgRxPower ?? '-18.5 dBm', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 5. Financial Overview Card (Buku Kas Sukorejo)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Row(
                children: const [
                  Icon(Icons.pie_chart_rounded, color: AppTheme.primaryBlue, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'RINGKASAN KEUANGAN KAS RIIL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textMain,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),

            CyberCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Sisa Modal Awal', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                          const SizedBox(height: 2),
                          Text(
                            Formatters.formatRupiah(dash?.sisaModal ?? 0),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textMain),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Sisa Kas Operasional', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                          const SizedBox(height: 2),
                          Text(
                            Formatters.formatRupiah(dash?.sisaKasOps ?? 0),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.accentGreen),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pendapatan Bulan Ini', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                          const SizedBox(height: 2),
                          Text(
                            Formatters.formatRupiah(dash?.totalRevenue ?? 0),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primaryBlue),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Beban Pengeluaran Bulan Ini', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                          const SizedBox(height: 2),
                          Text(
                            Formatters.formatRupiah(dash?.totalExpense ?? 0),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.accentRed),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
