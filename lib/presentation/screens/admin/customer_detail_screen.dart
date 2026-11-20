import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/sound_effects.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/cyber_card.dart';
import '../../widgets/status_badge.dart';

class CustomerDetailScreen extends StatefulWidget {
  final int customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().fetchCustomerDetail(widget.customerId);
    });
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    SoundEffects.playTap();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label berhasil disalin ke clipboard!'), duration: const Duration(seconds: 1)),
    );
  }

  void _showWifiEditDialog(String currentSsid, String currentPassword) {
    final ssidCtrl = TextEditingController(text: currentSsid);
    final passCtrl = TextEditingController(text: currentPassword);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ubah Pengaturan Wi-Fi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ssidCtrl,
              decoration: const InputDecoration(labelText: 'Nama Wi-Fi (SSID)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(labelText: 'Kata Sandi Wi-Fi', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<CustomerProvider>().updateWifi(
                widget.customerId,
                ssidCtrl.text.trim(),
                passCtrl.text.trim(),
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? 'Wi-Fi berhasil diperbarui!' : 'Gagal mengubah Wi-Fi.')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final custProv = context.watch<CustomerProvider>();
    final c = custProv.selectedCustomer;
    final traffic = custProv.liveTraffic;

    if (custProv.isLoading && c == null) {
      return Scaffold(
        backgroundColor: AppTheme.iceBackground,
        appBar: AppBar(title: const Text('Detail Pelanggan')),
        body: const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
      );
    }

    if (c == null) {
      return Scaffold(
        backgroundColor: AppTheme.iceBackground,
        appBar: AppBar(title: const Text('Detail Pelanggan')),
        body: const Center(child: Text('Pelanggan tidak ditemukan.')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.iceBackground,
      appBar: AppBar(
        title: Text(c.name, style: const TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppTheme.textMain),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryBlue),
            onPressed: () {
              SoundEffects.playTap();
              custProv.fetchCustomerDetail(widget.customerId);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Live Traffic & Status Monitor
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryNavy, Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: AppTheme.cyberGlow,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: (traffic?['online'] == true || c.isOnline) ? AppTheme.accentGreen : AppTheme.accentRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            (traffic?['online'] == true || c.isOnline) ? 'LIVE ONLINE' : 'OFFLINE',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                      Text(
                        'IP: ${traffic?['ip'] ?? c.ipAddress ?? "-"}',
                        style: const TextStyle(color: AppTheme.techCyan, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Speeds
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Live Download', style: TextStyle(color: Colors.white60, fontSize: 10)),
                            const SizedBox(height: 2),
                            Text(
                              traffic?['download_speed'] ?? '0 bps',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 32, width: 1, color: Colors.white24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Live Upload', style: TextStyle(color: Colors.white60, fontSize: 10)),
                            const SizedBox(height: 2),
                            Text(
                              traffic?['upload_speed'] ?? '0 bps',
                              style: const TextStyle(color: AppTheme.techCyan, fontSize: 18, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 24),

                  // Session & Monthly Data Usage
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sesi Ini: ${traffic?['session_total_formatted'] ?? "0 B"}',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      Text(
                        'Daya Optik: ${traffic?['rx_power'] ?? "-18.5 dBm"}',
                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Wi-Fi Credentials & Quick Copy
            CyberCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Pengaturan Wi-Fi Modem', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, color: AppTheme.primaryBlue, size: 18),
                        onPressed: () => _showWifiEditDialog(c.wifiSsid ?? '', c.wifiPassword ?? ''),
                      ),
                    ],
                  ),
                  const Divider(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.wifi, color: AppTheme.primaryBlue, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          c.wifiSsid?.isNotEmpty == true ? c.wifiSsid! : 'SSID Belum Diatur',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (c.wifiSsid?.isNotEmpty == true)
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 16, color: AppTheme.textMuted),
                          onPressed: () => _copyToClipboard(c.wifiSsid!, 'SSID'),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.key_rounded, color: AppTheme.accentOrange, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          c.wifiPassword?.isNotEmpty == true ? c.wifiPassword! : 'Password Belum Diatur',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (c.wifiPassword?.isNotEmpty == true)
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 16, color: AppTheme.textMuted),
                          onPressed: () => _copyToClipboard(c.wifiPassword!, 'Password Wi-Fi'),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Remote NOC Control Actions
            CyberCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Kontrol Jaringan Cepat', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            SoundEffects.playTap();
                            final ok = await custProv.rebootOnt(widget.customerId);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(ok ? 'Perintah reboot berhasil dikirim ke modem!' : 'Gagal mengirim reboot.')),
                              );
                            }
                          },
                          icon: const Icon(Icons.restart_alt_rounded, size: 16),
                          label: const Text('Reboot ONT', style: TextStyle(fontSize: 11)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryBlue,
                            side: const BorderSide(color: AppTheme.primaryBlue),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            SoundEffects.playTap();
                            final ok = await custProv.kickPppoe(widget.customerId, c.mikrotikUsername);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(ok ? 'Sesi PPPoE berhasil di-reset.' : 'Gagal reset sesi PPPoE.')),
                              );
                            }
                          },
                          icon: const Icon(Icons.power_settings_new_rounded, size: 16),
                          label: const Text('Kick PPPoE', style: TextStyle(fontSize: 11)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.accentOrange,
                            side: const BorderSide(color: AppTheme.accentOrange),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      SoundEffects.playTap();
                      final isCurrentlyIsolated = c.isIsolated;
                      final ok = await custProv.toggleIsolate(widget.customerId, !isCurrentlyIsolated);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok ? (isCurrentlyIsolated ? 'Layanan berhasil diaktifkan!' : 'Layanan berhasil diisolir.') : 'Gagal merubah status.'),
                          ),
                        );
                      }
                    },
                    icon: Icon(c.isIsolated ? Icons.lock_open_rounded : Icons.block_rounded, size: 18),
                    label: Text(c.isIsolated ? 'Buka Isolir Layanan' : 'Isolir Layanan Pelanggan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.isIsolated ? AppTheme.accentGreen : AppTheme.accentRed,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),

            // 4. Customer Information
            CyberCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Informasi Berlangganan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                  const Divider(height: 16),
                  _buildInfoRow('ID Pelanggan', c.custId),
                  _buildInfoRow('Paket', '${c.packageName ?? "-"} (${Formatters.formatRupiah(c.packagePrice ?? 0)}/bln)'),
                  _buildInfoRow('ODP Box', '${c.odpName ?? "-"} (Port ${c.odpPort ?? "-"})'),
                  _buildInfoRow('Alamat', c.address),
                  _buildInfoRow('Nomor WhatsApp', c.phone),
                  _buildInfoRow('Jatuh Tempo', 'Tanggal ${c.billingDate ?? 20} setiap bulan'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMain)),
          ),
        ],
      ),
    );
  }
}
