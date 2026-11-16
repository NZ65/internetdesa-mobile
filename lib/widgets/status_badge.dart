import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    IconData? icon;

    final s = status.toLowerCase();

    if (s == 'active' || s == 'aktif' || s == 'paid' || s == 'lunas' || s == 'resolved' || s == 'installed' || s == 'selesai') {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
      icon = Icons.check_circle_outline;
      label = (s == 'active') ? 'Aktif' : ((s == 'paid') ? 'Lunas' : ((s == 'installed') ? 'Terpasang' : 'Selesai'));
    } else if (s == 'isolated' || s == 'suspended' || s == 'unpaid' || s == 'belum lunas' || s == 'critical' || s == 'los') {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFB91C1C);
      icon = Icons.error_outline;
      label = (s == 'isolated' || s == 'suspended') ? 'Isolir' : ((s == 'unpaid') ? 'Belum Bayar' : 'Gangguan');
    } else if (s == 'pending' || s == 'in_progress' || s == 'survey') {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFB45309);
      icon = Icons.access_time;
      label = (s == 'pending') ? 'Menunggu' : 'Diproses';
    } else {
      bg = const Color(0xFFF1F5F9);
      fg = const Color(0xFF475569);
      label = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
