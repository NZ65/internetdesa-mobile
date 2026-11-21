import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum ZzzBadgeType { cyan, yellow, green, red, purple, muted, success, danger }

class ZzzBadge extends StatelessWidget {
  final String text;
  final ZzzBadgeType type;
  final IconData? icon;
  final double fontSize;

  const ZzzBadge({
    super.key,
    String? text,
    String? label,
    this.type = ZzzBadgeType.cyan,
    this.icon,
    this.fontSize = 10,
  }) : text = text ?? label ?? '';

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color border;

    switch (type) {
      case ZzzBadgeType.cyan:
        bg = AppTheme.neonCyan.withOpacity(0.12);
        fg = AppTheme.neonCyan;
        border = AppTheme.neonCyan.withOpacity(0.4);
        break;
      case ZzzBadgeType.yellow:
        bg = AppTheme.hazardYellow.withOpacity(0.12);
        fg = AppTheme.hazardYellow;
        border = AppTheme.hazardYellow.withOpacity(0.4);
        break;
      case ZzzBadgeType.green:
      case ZzzBadgeType.success:
        bg = AppTheme.neonGreen.withOpacity(0.12);
        fg = AppTheme.neonGreen;
        border = AppTheme.neonGreen.withOpacity(0.4);
        break;
      case ZzzBadgeType.red:
      case ZzzBadgeType.danger:
        bg = AppTheme.crimsonRed.withOpacity(0.12);
        fg = AppTheme.crimsonRed;
        border = AppTheme.crimsonRed.withOpacity(0.4);
        break;
      case ZzzBadgeType.purple:
        bg = AppTheme.electricPurple.withOpacity(0.12);
        fg = AppTheme.electricPurple;
        border = AppTheme.electricPurple.withOpacity(0.4);
        break;
      case ZzzBadgeType.muted:
        bg = Colors.white.withOpacity(0.06);
        fg = AppTheme.textMuted;
        border = Colors.white.withOpacity(0.12);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            text.toUpperCase(),
            style: TextStyle(
              color: fg,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
