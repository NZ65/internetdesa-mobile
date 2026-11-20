import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/sound_effects.dart';

class SquircleActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback onTap;
  final String? badgeText;
  final String? code;

  const SquircleActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.backgroundColor,
    required this.onTap,
    this.badgeText,
    this.code,
  });

  @override
  State<SquircleActionButton> createState() => _SquircleActionButtonState();
}

class _SquircleActionButtonState extends State<SquircleActionButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    SoundEffects.playTap();
    await _controller.forward();
    await _controller.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.iconColor.withOpacity(0.22),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.iconColor.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(widget.icon, color: widget.iconColor, size: 24),
                  ),
                ),

                // Tactical Operation Code Tag (Blue Archive Style: 01, 02, ...)
                if (widget.code != null && widget.code!.isNotEmpty)
                  Positioned(
                    top: -3,
                    left: -3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: AppTheme.techCyan.withOpacity(0.6), width: 0.8),
                      ),
                      child: Text(
                        widget.code!,
                        style: const TextStyle(
                          color: AppTheme.techCyan,
                          fontSize: 7.5,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),

                // Alert / Counter Badge
                if (widget.badgeText != null && widget.badgeText!.isNotEmpty)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.accentRed,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentRed.withOpacity(0.4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        widget.badgeText!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMain,
                letterSpacing: 0.1,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
