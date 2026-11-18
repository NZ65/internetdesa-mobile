import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.status,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color color;
    String label;
    IconData? icon;

    final s = status.toLowerCase();

    if (s == 'active' || s == 'aktif' || s == 'paid' || s == 'lunas' || s == 'resolved' || s == 'installed' || s == 'selesai') {
      color = const Color(0xFF00B074); // DANA Green
      icon = Icons.check_circle_rounded;
      label = (s == 'active' || s == 'aktif') ? 'Aktif' : ((s == 'paid' || s == 'lunas') ? 'Lunas' : ((s == 'installed') ? 'Terpasang' : 'Selesai'));
    } else if (s == 'pasang_baru' || s == 'pending' || s == 'in_progress' || s == 'survey') {
      color = const Color(0xFFFF8B00); // DANA Orange
      icon = Icons.hourglass_top_rounded;
      label = (s == 'pasang_baru') ? 'Pasang Baru' : ((s == 'pending') ? 'Menunggu' : 'Diproses');
    } else if (s == 'isolated' || s == 'suspended' || s == 'unpaid' || s == 'belum lunas' || s == 'critical' || s == 'los') {
      color = const Color(0xFFF43F5E); // DANA Red
      icon = Icons.error_outline_rounded;
      label = (s == 'suspended' || s == 'isolated') ? 'Isolir' : ((s == 'unpaid' || s == 'belum lunas') ? 'Belum Lunas' : 'Gangguan');
    } else {
      color = const Color(0xFF64748B); // Slate
      icon = Icons.info_outline_rounded;
      label = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.35 : 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 5.5,
              height: 5.5,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ] else if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
