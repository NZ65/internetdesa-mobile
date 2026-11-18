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
      color = const Color(0xFF10B981); // Emerald
      icon = Icons.check_circle_rounded;
      label = (s == 'active' || s == 'aktif') ? 'Aktif' : ((s == 'paid' || s == 'lunas') ? 'Lunas' : ((s == 'installed') ? 'Terpasang' : 'Selesai'));
    } else if (s == 'pasang_baru' || s == 'pending' || s == 'in_progress' || s == 'survey') {
      color = const Color(0xFFF59E0B); // Amber
      icon = Icons.person_add_alt_1_rounded;
      label = (s == 'pasang_baru') ? 'Pasang Baru' : ((s == 'pending') ? 'Menunggu' : 'Diproses');
    } else if (s == 'isolated' || s == 'suspended' || s == 'unpaid' || s == 'belum lunas' || s == 'critical' || s == 'los') {
      color = const Color(0xFFF43F5E); // Crimson
      icon = Icons.error_rounded;
      label = (s == 'suspended' || s == 'isolated') ? 'Isolir' : ((s == 'unpaid' || s == 'belum lunas') ? 'Belum Bayar' : 'LOS / Rusak');
    } else {
      color = const Color(0xFF94A3B8); // Slate
      icon = Icons.info_outline_rounded;
      label = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.12),
        borderRadius: BorderRadius.circular(12),
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
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.6),
                    blurRadius: 4,
                  ),
                ],
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
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
