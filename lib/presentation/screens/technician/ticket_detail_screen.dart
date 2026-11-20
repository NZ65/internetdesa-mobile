import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/sound_effects.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/ticket_model.dart';
import '../../providers/technician_provider.dart';
import '../../widgets/cyber_card.dart';
import '../../widgets/status_badge.dart';

class TicketDetailScreen extends StatefulWidget {
  final TicketModel ticket;

  const TicketDetailScreen({super.key, required this.ticket});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  void _openGoogleMaps(double lat, double lng) async {
    final url = Uri.parse('https://maps.google.com/?q=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _callPhone(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final url = Uri.parse('tel:$clean');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _showResolveDialog() {
    final notesCtrl = TextEditingController(text: 'Telah diperbaiki oleh teknisi lapangan.');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tandai Tiket Selesai', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Catatan Penanganan Masalah:', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
            const SizedBox(height: 8),
            TextField(
              controller: notesCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Contoh: Sambung ulang kabel FO putus di ODP 2.',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await context.read<TechnicianProvider>().resolveTicket(
                widget.ticket.id,
                notesCtrl.text.trim(),
              );
              if (mounted) {
                if (ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tiket berhasil diselesaikan!')),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gagal menyelesaikan tiket.')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tandai Selesai'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.ticket;

    return Scaffold(
      backgroundColor: AppTheme.iceBackground,
      appBar: AppBar(
        title: Text(t.ticketNumber, style: const TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppTheme.textMain),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status & Customer Card
            CyberCard(
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        t.customerName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                      ),
                      StatusBadge(status: t.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryBlue),
                  ),
                  if (t.description != null && t.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      t.description!,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.4),
                    ),
                  ],
                  const Divider(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 16, color: AppTheme.accentRed),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          t.customerAddress ?? 'Alamat belum terdata',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMain),
                        ),
                      ),
                    ],
                  ),
                  if (t.latitude != null && t.longitude != null) ...[
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _openGoogleMaps(t.latitude!, t.longitude!),
                      icon: const Icon(Icons.directions_rounded, size: 16),
                      label: const Text('Buka Peta / Navigasi GPS'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(40),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Customer Contact Actions
            if (t.customerPhone != null && t.customerPhone!.isNotEmpty)
              CyberCard(
                margin: EdgeInsets.zero,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Kontak Pelanggan', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                          Text(t.customerPhone!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.phone_rounded, color: AppTheme.accentGreen),
                      onPressed: () => _callPhone(t.customerPhone!),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Resolve Action Button
            if (t.isOpen)
              ElevatedButton.icon(
                onPressed: _showResolveDialog,
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text('Tandai Gangguan Telah Selesai', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
