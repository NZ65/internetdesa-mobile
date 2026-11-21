import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/sound_effects.dart';
import '../../providers/technician_provider.dart';
import '../../widgets/zzz_card.dart';
import '../../widgets/zzz_badge.dart';
import '../../widgets/zzz_button.dart';
import '../../widgets/empty_state.dart';

class QuickToolsScreen extends StatefulWidget {
  final int initialTab;
  final bool asTab;

  const QuickToolsScreen({
    super.key,
    this.initialTab = 0,
    this.asTab = false,
  });

  @override
  State<QuickToolsScreen> createState() => _QuickToolsScreenState();
}

class _QuickToolsScreenState extends State<QuickToolsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _pingTargetCtrl = TextEditingController(text: '8.8.8.8');
  final _kickUsernameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTab);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TechnicianProvider>().fetchLosOnus();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pingTargetCtrl.dispose();
    _kickUsernameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final techProv = context.watch<TechnicianProvider>();

    final content = Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('DIAGNOSA & NOC TOOLS', style: TextStyle(color: AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.neonCyan,
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: AppTheme.neonCyan,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.wifi_tethering_rounded, size: 18), text: 'Ping Latensi'),
            Tab(icon: Icon(Icons.warning_amber_rounded, size: 18), text: 'Daftar LOS'),
            Tab(icon: Icon(Icons.restart_alt_rounded, size: 18), text: 'PPPoE Kick'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Tab Ping Tool
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ZzzCard(
                tag: 'ICMP PING TEST',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Uji Latensi Host / IP Pelanggan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textWhite)),
                    const SizedBox(height: 4),
                    const Text('Kirim 4 paket ICMP untuk mengecek latensi & packet loss.', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _pingTargetCtrl,
                            style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: '8.8.8.8 atau 10.30.x.x',
                              hintStyle: const TextStyle(color: AppTheme.textMuted),
                              filled: true,
                              fillColor: AppTheme.bgDark,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderDark)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.neonCyan)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ZzzButton(
                          text: 'Ping',
                          width: 80,
                          height: 44,
                          isLoading: techProv.isPinging,
                          onPressed: () {
                            final target = _pingTargetCtrl.text.trim();
                            if (target.isNotEmpty) {
                              techProv.pingHost(target);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (techProv.pingResult != null)
                ZzzCard(
                  tag: 'CONSOLE OUTPUT',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('HASIL UJI LATENSI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.neonCyan)),
                          ZzzBadge(
                            text: techProv.pingResult!['success'] == true ? 'REACHABLE' : 'UNREACHABLE',
                            type: techProv.pingResult!['success'] == true ? ZzzBadgeType.green : ZzzBadgeType.red,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.bgDark,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.borderDark),
                        ),
                        child: Text(
                          techProv.pingResult!['output'] ?? 'Tidak ada data respons ping.',
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppTheme.neonGreen),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // 2. Tab Daftar LOS Live
          RefreshIndicator(
            onRefresh: () => techProv.fetchLosOnus(),
            color: AppTheme.neonCyan,
            backgroundColor: AppTheme.bgCard,
            child: techProv.isLoading && techProv.losOnus.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppTheme.neonCyan))
                : techProv.losOnus.isEmpty
                    ? const EmptyState(
                        icon: Icons.check_circle_outline_rounded,
                        title: 'Tidak Ada Pelanggan LOS',
                        message: 'Semua koneksi kabel optik OLT Sukorejo terpantau online normal.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: techProv.losOnus.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final onu = techProv.losOnus[index];
                          return ZzzCard(
                            borderColor: AppTheme.crimsonRed,
                            hasGlow: true,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.crimsonRed.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppTheme.crimsonRed.withOpacity(0.4)),
                                  ),
                                  child: const Icon(Icons.warning_amber_rounded, color: AppTheme.crimsonRed, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        onu['name'] ?? onu['onu_sn'] ?? 'ONU Tidak Dikenal',
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textWhite),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'SN: ${onu['serial_number'] ?? onu['onu_sn'] ?? "-"} • PON ${onu['olt_port'] ?? "-"}',
                                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                ZzzBadge(
                                  text: 'LOS',
                                  type: ZzzBadgeType.red,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),

          // 3. Tab PPPoE Kick Tool
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ZzzCard(
                tag: 'MIKROTIK PPPOE SESSION RESET',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Reset Sesi PPPoE Pelanggan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textWhite)),
                    const SizedBox(height: 4),
                    const Text('Putuskan sesi aktif di router MikroTik agar modem dial-up ulang dan mendapat IP baru.', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _kickUsernameCtrl,
                      style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Username PPPoE (Contoh: 0001SUWITNO)',
                        labelStyle: const TextStyle(color: AppTheme.textMuted),
                        filled: true,
                        fillColor: AppTheme.bgDark,
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderDark)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.neonCyan)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ZzzButton(
                      text: 'Kick / Reset Sesi MikroTik',
                      icon: Icons.power_settings_new_rounded,
                      style: ZzzButtonStyle.secondary,
                      onPressed: () async {
                        final u = _kickUsernameCtrl.text.trim();
                        if (u.isEmpty) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(backgroundColor: AppTheme.bgCard, content: Text('Mengirim sinyal reset untuk $u...')),
                        );
                        final ok = await techProv.kickPppoe(u);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppTheme.bgCard,
                              content: Text(
                                ok ? 'Sesi PPPoE $u berhasil di-reset!' : 'Gagal reset sesi PPPoE.',
                                style: TextStyle(color: ok ? AppTheme.neonGreen : AppTheme.crimsonRed),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (widget.asTab) {
      return content;
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bgDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      height: MediaQuery.of(context).size.height * 0.85,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: content,
      ),
    );
  }
}
