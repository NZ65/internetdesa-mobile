import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/sound_effects.dart';
import '../../providers/technician_provider.dart';
import '../../widgets/cyber_card.dart';
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
      backgroundColor: AppTheme.iceBackground,
      appBar: AppBar(
        title: const Text('Diagnosa & Troubleshooting NOC', style: TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.bold, fontSize: 16)),
        iconTheme: const IconThemeData(color: AppTheme.textMain),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: AppTheme.primaryBlue,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
          // 1. Ping Tool View
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CyberCard(
                  margin: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Uji Latensi Host / IP', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                      const SizedBox(height: 4),
                      const Text('Kirim 4 paket ICMP untuk mengecek latensi & packet loss.', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _pingTargetCtrl,
                              decoration: InputDecoration(
                                hintText: 'Contoh: 8.8.8.8 atau 10.10.10.4',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: techProv.isPinging
                                ? null
                                : () => techProv.runPing(_pingTargetCtrl.text),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: techProv.isPinging
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Ping'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                if (techProv.pingResult != null)
                  CyberCard(
                    margin: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Hasil: ${_pingTargetCtrl.text}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: techProv.pingResult?['packet_loss'] == '0%' ? AppTheme.pastelGreen : AppTheme.pastelRed,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Loss: ${techProv.pingResult?['packet_loss'] ?? "0%"}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: techProv.pingResult?['packet_loss'] == '0%' ? AppTheme.accentGreen : AppTheme.accentRed,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rata-rata Latensi: ${techProv.pingResult?['avg_latency'] ?? "-"}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue),
                        ),
                        const Divider(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            techProv.pingResult?['raw_output'] ?? '',
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 10.5, color: Color(0xFF38BDF8)),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // 2. Daftar Pelanggan LOS View
          techProv.losOnus.isEmpty
              ? EmptyState(
                  icon: Icons.check_circle_outline_rounded,
                  title: 'Tidak Ada Pelanggan LOS',
                  message: 'Semua kabel optik dan ONU dalam keadaan normal & terhubung.',
                  onRetry: () => techProv.fetchLosOnus(),
                )
              : RefreshIndicator(
                  onRefresh: () => techProv.fetchLosOnus(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: techProv.losOnus.length,
                    itemBuilder: (ctx, idx) {
                      final item = techProv.losOnus[idx];
                      return CyberCard(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.pastelRed,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.warning_amber_rounded, color: AppTheme.accentRed, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'] ?? 'ONU ${item['onu_id']}',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Port ${item['port']} • SN: ${item['serial_number'] ?? "-"}',
                                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                  ),
                                  Text(
                                    'Penyebab: ${item['down_reason'] ?? "LOS Optical Signal Lost"}',
                                    style: const TextStyle(fontSize: 10, color: AppTheme.accentRed, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

          // 3. Kick PPPoE Session View
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: CyberCard(
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Reset Sesi PPPoE Pelanggan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                  const SizedBox(height: 4),
                  const Text('Putuskan sesi aktif agar pelanggan dial-up ulang dan mendapatkan IP segar.', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _kickUsernameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Username PPPoE Pelanggan',
                      hintText: 'Contoh: 0001SUWITNO',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final u = _kickUsernameCtrl.text.trim();
                      if (u.isEmpty) return;
                      SoundEffects.playTap();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Mengirim sinyal reset untuk $u...')),
                      );
                    },
                    icon: const Icon(Icons.power_settings_new_rounded),
                    label: const Text('Reset / Kick Sesi MikroTik'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentOrange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (widget.asTab) {
      return content;
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: content,
      ),
    );
  }
}
