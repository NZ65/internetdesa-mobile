import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ZzzCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final String? tag;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool hasGlow;
  final bool isAccent;

  const ZzzCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.tag,
    this.borderColor,
    this.onTap,
    this.hasGlow = false,
    this.isAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? (isAccent ? AppTheme.neonCyan : AppTheme.borderDark);
    final effectiveGlow = hasGlow || isAccent;
    Widget content = child;

    if (tag != null) {
      content = Stack(
        clipBehavior: Clip.none,
        children: [
          content,
          Positioned(
            top: -10,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.bgDark,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: effectiveBorderColor, width: 1),
              ),
              child: Text(
                tag!.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: effectiveBorderColor,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: effectiveBorderColor,
          width: effectiveGlow ? 1.5 : 1.0,
        ),
        boxShadow: effectiveGlow
            ? [
                BoxShadow(
                  color: effectiveBorderColor.withOpacity(0.25),
                  blurRadius: 16,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                )
              ]
            : AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppTheme.neonCyan.withOpacity(0.1),
          highlightColor: AppTheme.neonCyan.withOpacity(0.05),
          child: Padding(
            padding: padding,
            child: content,
          ),
        ),
      ),
    );
  }
}
