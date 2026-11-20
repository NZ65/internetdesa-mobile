import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/blue_archive_stage.dart';
import '../../widgets/cyber_card.dart';
import '../../widgets/dana_curved_header.dart';
import '../../widgets/squircle_action_button.dart';
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
      color: AppTheme.primaryBlue,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Signature DANA Curved Header with Live Throughput & Saldo
            DanaCurvedHeader(
              userName: auth.user?.name ?? 'Admin',
              role: auth.user?.role ?? 'Admin',
              areaName: auth.user?.areaName ?? 'Sukorejo',
              saldoKas: dash?.saldoKas ?? 19270293,
              sisaModal: dash?.sisaModal ?? 14553555,
              sisaKasOps: dash?.sisaKasOps ?? 4716738,
              wanRx: dash?.wanRx ?? '0 bps',
              wanTx: dash?.wanTx ?? '0 bps',
              activePppoe: dash?.activePppoe ?? 109,
              onSaldoTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ExpenseLedgerScreen()),
                );
              },
            ),

            // 2. Iconic Blue Archive SCHALE Tactical Terminal & MomoTalk Console
            BlueArchiveStage(
              hasAlert: dashProv.hasAlert,
              losCount: dashProv.losCount,
              userName: auth.user?.name ?? 'Sensei',
              onAlertTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const QuickToolsScreen(initialTab: 1)),
                );
              },
            ),

            // 3. Quick Mission Actions Grid (Blue Archive Tactical Operation Tiles)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 4),
              child: Row(
                children: const [
                  Icon(Icons.dashboard_customize_rounded, color: AppTheme.primaryBlue, size: 15),
                  SizedBox(width: 8),
                  Text(
                    'TACTICAL MISSION BOARD // SECTOR OPERATIONS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textMain,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: CyberCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SquircleActionButton(
                          code: '01',
                          icon: Icons.people_alt_rounded,
                          label: 'Pelanggan',
                          iconColor: AppTheme.primaryBlue,
                          backgroundColor: const Color(0xFFE0F2FE),
                          badgeText: dash != null ? '${dash.totalCustomers}' : '114',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const CustomerListScreen()),
                            );
                          },
                        ),
                        SquircleActionButton(
                          code: '02',
                          icon: Icons.receipt_long_rounded,
                          label: 'Tagihan',
                          iconColor: AppTheme.accentOrange,
                          backgroundColor: AppTheme.pastelOrange,
                          badgeText: (dash?.unpaidCount ?? 0) > 0 ? '${dash!.unpaidCount}' : '28',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const InvoiceListScreen()),
                            );
                          },
                        ),
                        SquircleActionButton(
                          code: '03',
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
                          code: '04',
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
                          code: '05',
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
                          code: '06',
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
                          code: '07',
                          icon: Icons.person_add_alt_1_rounded,
                          label: 'Pasang Baru',
                          iconColor: const Color(0xFF0288D1),
                          backgroundColor: const Color(0xFFE1F5FE),
                          badgeText: (dash?.pendingRegistrations ?? 0) > 0 ? '${dash!.pendingRegistrations}' : '2',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RegisterProspectScreen()),
                            );
                          },
                        ),
                        SquircleActionButton(
                          code: '08',
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

            // 4. Blue Archive Cyber-NOC Hardware HUD (MikroTik Core + OLT FD1602S)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
              child: Row(
                children: const [
                  Icon(Icons.terminal_rounded, color: AppTheme.primaryBlue, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'TELEMETRI HARDWARE // SCHALE CORE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textMain,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // MikroTik Router Card
                  Expanded(
                    child: CyberCard(
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
                              Text('${dash?.activePppoe ?? 109}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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

                  // OLT FD1602S Card
                  Expanded(
                    child: CyberCard(
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
                                '${dash?.onlineOnus ?? 109}',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.accentGreen),
                              ),
                              Text(' / ${dash?.totalOnus ?? 114} ONU', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
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
                              Text(dash?.avgRxPower ?? '-18.3 dBm', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 5. Financial Overview Card (Kas Riil Sukorejo)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
              child: Row(
                children: const [
                  Icon(Icons.pie_chart_rounded, color: AppTheme.primaryBlue, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'STATUS KEUANGAN KAS RIIL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textMain,
                      letterSpacing: 1.0,
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
                            Formatters.formatRupiah(dash?.sisaModal ?? 14553555),
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
                            Formatters.formatRupiah(dash?.sisaKasOps ?? 4716738),
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
                            Formatters.formatRupiah(dash?.totalRevenue ?? 6490006),
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
                            Formatters.formatRupiah(dash?.totalExpense ?? 14513262),
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
