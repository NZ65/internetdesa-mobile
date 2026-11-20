import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final String? customLabel;

  const StatusBadge({super.key, required this.status, this.customLabel});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String text = customLabel ?? status.toUpperCase();

    switch (status.toLowerCase()) {
      case 'active':
      case 'online':
      case 'paid':
      case 'lunas':
      case 'resolved':
      case 'closed':
        bg = AppTheme.pastelGreen;
        fg = AppTheme.accentGreen;
        text = customLabel ?? (status == 'paid' ? 'LUNAS' : (status == 'active' ? 'AKTIF' : 'ONLINE'));
        break;
      case 'isolated':
      case 'suspended':
      case 'offline':
      case 'los':
        bg = AppTheme.pastelRed;
        fg = AppTheme.accentRed;
        text = customLabel ?? (status == 'isolated' || status == 'suspended' ? 'TERISOLIR' : 'LOS / OFFLINE');
        break;
      case 'unpaid':
      case 'pending':
      case 'open':
      case 'in_progress':
        bg = AppTheme.pastelOrange;
        fg = AppTheme.accentOrange;
        text = customLabel ?? (status == 'unpaid' ? 'BELUM BAYAR' : (status == 'pending' ? 'MENUNGGU' : 'DALAM PROSES'));
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = AppTheme.textMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
