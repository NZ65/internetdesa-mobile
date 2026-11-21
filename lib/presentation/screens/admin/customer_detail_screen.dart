import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/sound_effects.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/zzz_card.dart';
import '../../widgets/zzz_badge.dart';

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
      SnackBar(
        backgroundColor: AppTheme.bgCard,
        content: Text('$label disalin ke clipboard!', style: const TextStyle(color: AppTheme.neonCyan)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showWifiEditDialog(String currentSsid, String currentPassword) {
    final ssidCtrl = TextEditingController(text: currentSsid);
    final passCtrl = TextEditingController(text: currentPassword);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.neonCyan, width: 1.2),
        ),
        title: const Text('Ubah Pengaturan Wi-Fi', style: TextStyle(color: AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ssidCtrl,
              style: const TextStyle(color: AppTheme.textWhite),
              decoration: const InputDecoration(
                labelText: 'Nama Wi-Fi (SSID)',
                labelStyle: TextStyle(color: AppTheme.textMuted),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.borderDark)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.neonCyan)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passCtrl,
              style: const TextStyle(color: AppTheme.textWhite),
              decoration: const InputDecoration(
                labelText: 'Kata Sandi Wi-Fi',
                labelStyle: TextStyle(color: AppTheme.textMuted),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.borderDark)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.neonCyan)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonCyan,
              foregroundColor: AppTheme.bgDark,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<CustomerProvider>().updateWifi(
                widget.customerId,
                ssidCtrl.text.trim(),
                passCtrl.text.trim(),
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppTheme.bgCard,
                    content: Text(
                      success ? 'Wi-Fi berhasil diperbarui!' : 'Gagal mengubah Wi-Fi.',
                      style: TextStyle(color: success ? AppTheme.neonGreen : AppTheme.crimsonRed),
                    ),
                  ),
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
        backgroundColor: AppTheme.bgDark,
        appBar: AppBar(title: const Text('DETAIL PELANGGAN')),
        body: const Center(child: CircularProgressIndicator(color: AppTheme.neonCyan)),
      );
    }

    if (c == null) {
      return Scaffold(
        backgroundColor: AppTheme.bgDark,
        appBar: AppBar(title: const Text('DETAIL PELANGGAN')),
        body: const Center(child: Text('Pelanggan tidak ditemukan.', style: TextStyle(color: AppTheme.textMuted))),
      );
    }

    final isOnline = traffic?['online'] == true || c.isOnline;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: Text(c.name.toUpperCase(), style: const TextStyle(color: AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.w900)),
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.neonCyan),
            onPressed: () {
              SoundEffects.playTap();
              custProv.fetchCustomerDetail(widget.customerId);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Live Telemetry & Speed Card
            ZzzCard(
              tag: 'LIVE TELEMETRY',
              borderColor: isOnline ? AppTheme.neonCyan : AppTheme.crimsonRed,
              hasGlow: true,
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
                              color: isOnline ? AppTheme.neonGreen : AppTheme.crimsonRed,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: isOnline ? AppTheme.neonGreen : AppTheme.crimsonRed,
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isOnline ? 'LIVE PPPoE ACTIVE' : 'OFFLINE / DISCONNECTED',
                            style: TextStyle(
                              color: isOnline ? AppTheme.neonGreen : AppTheme.crimsonRed,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'IP: ${traffic?['ip'] ?? c.ipAddress ?? "-"}',
                        style: const TextStyle(color: AppTheme.neonCyan, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Real-time Throughput (Download / Upload)
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('LIVE DOWNLOAD', style: TextStyle(color: AppTheme.textMuted, fontSize: 9, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 2),
                            Text(
                              traffic?['download_speed'] ?? '0 bps',
                              style: const TextStyle(color: AppTheme.textWhite, fontSize: 18, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 32, width: 1, color: AppTheme.borderDark),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('LIVE UPLOAD', style: TextStyle(color: AppTheme.textMuted, fontSize: 9, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 2),
                            Text(
                              traffic?['upload_speed'] ?? '0 bps',
                              style: const TextStyle(color: AppTheme.neonCyan, fontSize: 18, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: AppTheme.borderDark, height: 24),

                  // Session Total & Optical Power
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sesi Ini: ${traffic?['session_total_formatted'] ?? "0 B"}',
                        style: const TextStyle(color: AppTheme.textSilver, fontSize: 11),
                      ),
                      Row(
                        children: [
                          const Text('Sinyal Optik: ', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                          Text(
                            traffic?['rx_power'] ?? "-18.5 dBm",
                            style: const TextStyle(color: AppTheme.neonCyan, fontSize: 11, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Wi-Fi Settings Card
            ZzzCard(
              tag: 'WI-FI SETTINGS',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PENGATURAN WI-FI MODEM',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textSilver, letterSpacing: 0.8),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, color: AppTheme.neonCyan, size: 18),
                        onPressed: () => _showWifiEditDialog(c.wifiSsid ?? '', c.wifiPassword ?? ''),
                      ),
                    ],
                  ),
                  const Divider(color: AppTheme.borderDark, height: 12),
                  Row(
                    children: [
                      const Icon(Icons.wifi, color: AppTheme.neonCyan, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          c.wifiSsid?.isNotEmpty == true ? c.wifiSsid! : 'SSID Belum Diatur',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textWhite),
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
                      const Icon(Icons.key_rounded, color: AppTheme.hazardYellow, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          c.wifiPassword?.isNotEmpty == true ? c.wifiPassword! : 'Password Belum Diatur',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textWhite),
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
            const SizedBox(height: 16),

            // 3. Tactical Network Controls
            ZzzCard(
              tag: 'REMOTE NOC CONTROLS',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'KONTROL JARINGAN CEPAT',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textSilver, letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            SoundEffects.playTap();
                            final ok = await custProv.rebootOnt(widget.customerId);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppTheme.bgCard,
                                  content: Text(ok ? 'Perintah reboot berhasil dikirim ke modem!' : 'Gagal mengirim reboot.'),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.restart_alt_rounded, size: 16),
                          label: const Text('Reboot ONT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.neonCyan,
                            side: const BorderSide(color: AppTheme.neonCyan),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            SoundEffects.playTap();
                            final ok = await custProv.kickPppoe(widget.customerId, c.mikrotikUsername);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppTheme.bgCard,
                                  content: Text(ok ? 'Sesi PPPoE berhasil di-reset.' : 'Gagal reset sesi PPPoE.'),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.power_settings_new_rounded, size: 16),
                          label: const Text('Kick PPPoE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.hazardYellow,
                            side: const BorderSide(color: AppTheme.hazardYellow),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      SoundEffects.playTap();
                      final isCurrentlyIsolated = c.isIsolated;
                      final ok = await custProv.toggleIsolate(widget.customerId, !isCurrentlyIsolated);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppTheme.bgCard,
                            content: Text(
                              ok ? (isCurrentlyIsolated ? 'Layanan berhasil diaktifkan!' : 'Layanan berhasil diisolir.') : 'Gagal merubah status.',
                              style: TextStyle(color: isCurrentlyIsolated ? AppTheme.neonGreen : AppTheme.crimsonRed),
                            ),
                          ),
                        );
                      }
                    },
                    icon: Icon(c.isIsolated ? Icons.lock_open_rounded : Icons.block_rounded, size: 18),
                    label: Text(
                      c.isIsolated ? 'BUKA ISOLIR LAYANAN' : 'ISOLIR LAYANAN PELANGGAN',
                      style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.isIsolated ? AppTheme.neonGreen : AppTheme.crimsonRed,
                      foregroundColor: AppTheme.bgDark,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. Subscription & Infrastructure Information
            ZzzCard(
              tag: 'ACCOUNT INFO',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'INFORMASI BERLANGGANAN',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textSilver, letterSpacing: 0.8),
                  ),
                  const Divider(color: AppTheme.borderDark, height: 16),
                  _buildInfoRow('ID Pelanggan', c.custId),
                  _buildInfoRow('Username PPPoE', c.mikrotikUsername ?? '-'),
                  _buildInfoRow('Paket Layanan', '${c.packageName ?? "-"} (${Formatters.formatRupiah(c.packagePrice ?? 0)}/bln)'),
                  _buildInfoRow('Infrastruktur ODP', '${c.odpName ?? "-"} (Port ${c.odpPort ?? "-"})'),
                  _buildInfoRow('Nomor WhatsApp', c.phone),
                  _buildInfoRow('Alamat Pemasangan', c.address),
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
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textWhite)),
          ),
        ],
      ),
    );
  }
}
