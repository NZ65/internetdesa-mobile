import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/sound_effects.dart';
import '../../../data/models/ticket_model.dart';
import '../../providers/technician_provider.dart';
import '../../widgets/zzz_card.dart';
import '../../widgets/zzz_badge.dart';
import '../../widgets/zzz_button.dart';
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
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.neonCyan, width: 1.2),
        ),
        title: const Text('Tandai Tiket Selesai', style: TextStyle(color: AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Catatan Penanganan Masalah:', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
            const SizedBox(height: 8),
            TextField(
              controller: notesCtrl,
              maxLines: 3,
              style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Contoh: Splicing ulang kabel dropcore patah di tiang ODP.',
                hintStyle: TextStyle(color: AppTheme.textMuted),
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
              final success = await context.read<TechnicianProvider>().resolveTicket(
                widget.ticket.id,
                notes: notesCtrl.text.trim(),
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppTheme.bgCard,
                    content: Text(
                      success ? 'Tiket berhasil diselesaikan!' : 'Gagal menyelesaikan tiket.',
                      style: TextStyle(color: success ? AppTheme.neonGreen : AppTheme.crimsonRed),
                    ),
                  ),
                );
                if (success) Navigator.pop(context);
              }
            },
            child: const Text('Konfirmasi Selesai'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.ticket;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: Text(t.ticketNumber, style: const TextStyle(color: AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Hero Card
            ZzzCard(
              tag: 'TICKET PROFILE',
              borderColor: t.isUrgent ? AppTheme.crimsonRed : AppTheme.neonCyan,
              hasGlow: t.isUrgent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ZzzBadge(
                        text: t.category.toUpperCase(),
                        type: ZzzBadgeType.yellow,
                      ),
                      StatusBadge(status: t.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t.customerName,
                    style: const TextStyle(color: AppTheme.textWhite, fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kategori: ${t.category} • Prioritas: ${t.priority.toUpperCase()}',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Description Card
            ZzzCard(
              tag: 'PROBLEM REPORT',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Keluhan / Gejala Gangguan:', style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(
                    (t.description != null && t.description!.isNotEmpty) ? t.description! : 'Tidak ada catatan keluhan tertulis.',
                    style: const TextStyle(color: AppTheme.textWhite, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Customer Contact & Location
            ZzzCard(
              tag: 'DISPATCH TARGET',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: AppTheme.neonCyan, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          (t.customerAddress != null && t.customerAddress!.isNotEmpty)
                              ? t.customerAddress!
                              : 'Alamat tidak tertera',
                          style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  if (t.customerPhone != null && t.customerPhone!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, color: AppTheme.neonGreen, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(t.customerPhone!, style: const TextStyle(color: AppTheme.textWhite, fontSize: 13)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.call, color: AppTheme.neonGreen, size: 20),
                          onPressed: () => _callPhone(t.customerPhone!),
                        ),
                      ],
                    ),
                  ],
                  if (t.latitude != null && t.longitude != null) ...[
                    const SizedBox(height: 12),
                    ZzzButton(
                      text: 'Petunjuk Arah (Google Maps)',
                      icon: Icons.navigation_rounded,
                      style: ZzzButtonStyle.secondary,
                      onPressed: () => _openGoogleMaps(t.latitude!, t.longitude!),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Complete Ticket Button
            if (t.status.toLowerCase() != 'resolved' && t.status.toLowerCase() != 'closed')
              ZzzButton(
                text: 'Tandai Tiket Selesai',
                icon: Icons.check_circle_rounded,
                style: ZzzButtonStyle.primary,
                height: 50,
                onPressed: _showResolveDialog,
              ),
          ],
        ),
      ),
    );
  }
}
