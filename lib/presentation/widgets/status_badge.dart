import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    final s = status.toLowerCase();
    if (s == 'active' || s == 'online' || s == 'lunas') {
      bg = AppTheme.neonGreen.withOpacity(0.12);
      fg = AppTheme.neonGreen;
      label = (s == 'lunas') ? 'LUNAS' : 'ONLINE';
      icon = Icons.check_circle_rounded;
    } else if (s == 'los' || s == 'critical' || s == 'isolated' || s == 'terisolir') {
      bg = AppTheme.crimsonRed.withOpacity(0.12);
      fg = AppTheme.crimsonRed;
      label = (s == 'los') ? 'LOS' : 'TERISOLIR';
      icon = Icons.error_rounded;
    } else if (s == 'warning' || s == 'waspada' || s == 'pending' || s == 'menunggu') {
      bg = AppTheme.hazardYellow.withOpacity(0.12);
      fg = AppTheme.hazardYellow;
      label = (s == 'menunggu' || s == 'pending') ? 'PENDING' : 'WASPADA';
      icon = Icons.warning_amber_rounded;
    } else {
      bg = Colors.white.withOpacity(0.08);
      fg = AppTheme.textMuted;
      label = status.toUpperCase();
      icon = Icons.info_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize + 2, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
