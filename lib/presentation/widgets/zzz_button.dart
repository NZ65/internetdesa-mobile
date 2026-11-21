import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/sound_effects.dart';

enum ZzzButtonStyle { primary, secondary, danger, outline }
enum ZzzButtonType { cyan, yellow, danger, muted, outline }

class ZzzButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final ZzzButtonStyle style;
  final bool isLoading;
  final double? width;
  final double height;

  ZzzButton({
    super.key,
    String? text,
    String? label,
    this.icon,
    required this.onPressed,
    ZzzButtonStyle? style,
    ZzzButtonType? type,
    this.isLoading = false,
    this.width,
    this.height = 46,
  })  : text = (text != null && text.isNotEmpty) ? text : (label ?? ''),
        style = style ?? _resolveType(type);

  static ZzzButtonStyle _resolveType(ZzzButtonType? type) {
    if (type == null) return ZzzButtonStyle.primary;
    switch (type) {
      case ZzzButtonType.cyan:
        return ZzzButtonStyle.primary;
      case ZzzButtonType.yellow:
        return ZzzButtonStyle.primary;
      case ZzzButtonType.danger:
        return ZzzButtonStyle.danger;
      case ZzzButtonType.muted:
        return ZzzButtonStyle.secondary;
      case ZzzButtonType.outline:
        return ZzzButtonStyle.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color border;

    switch (style) {
      case ZzzButtonStyle.primary:
        bg = AppTheme.neonCyan;
        fg = AppTheme.bgDark;
        border = AppTheme.neonCyan;
        break;
      case ZzzButtonStyle.secondary:
        bg = AppTheme.bgCardLight;
        fg = AppTheme.textWhite;
        border = AppTheme.borderDark;
        break;
      case ZzzButtonStyle.danger:
        bg = AppTheme.crimsonRed;
        fg = Colors.white;
        border = AppTheme.crimsonRed;
        break;
      case ZzzButtonStyle.outline:
        bg = Colors.transparent;
        fg = AppTheme.neonCyan;
        border = AppTheme.neonCyan;
        break;
    }

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: (isLoading || onPressed == null)
              ? null
              : () {
                  SoundEffects.playTap();
                  onPressed!();
                },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border, width: 1.2),
              boxShadow: style == ZzzButtonStyle.primary
                  ? [
                      BoxShadow(
                        color: AppTheme.neonCyan.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: fg,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 18, color: fg),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text.toUpperCase(),
                        style: TextStyle(
                          color: fg,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
