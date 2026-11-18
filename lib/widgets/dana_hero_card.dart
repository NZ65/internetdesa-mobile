import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'bouncing_button.dart';

class DanaActionItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? bgColor;
  final String? badgeText;

  const DanaActionItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.bgColor,
    this.badgeText,
  });
}

class DanaHeroCard extends StatefulWidget {
  final String title;
  final String primaryAmount;
  final String? secondaryText;
  final List<DanaActionItem> actions;
  final List<Widget>? footerPills;

  const DanaHeroCard({
    super.key,
    required this.title,
    required this.primaryAmount,
    this.secondaryText,
    required this.actions,
    this.footerPills,
  });

  @override
  State<DanaHeroCard> createState() => _DanaHeroCardState();
}

class _DanaHeroCardState extends State<DanaHeroCard> {
  bool _isAmountVisible = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Upper section: Balance / Title & Amount
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => setState(() => _isAmountVisible = !_isAmountVisible),
                          child: Icon(
                            _isAmountVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            size: 16,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    if (widget.secondaryText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.secondaryText!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryDark,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: _isAmountVisible ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                  firstChild: Text(
                    widget.primaryAmount,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  secondChild: Text(
                    'Rp ••••••••',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? AppTheme.borderDark : const Color(0xFFF1F5F9),
          ),

          // Middle section: 4 Primary Actions Dock (DANA 4 Buttons)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: widget.actions.map((act) {
                return Expanded(
                  child: BouncingButton(
                    onTap: act.onTap,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: act.bgColor ?? (isDark ? const Color(0xFF1E293B) : AppTheme.primaryLight),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: (act.iconColor ?? AppTheme.primaryBlue).withOpacity(0.18),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                act.icon,
                                color: act.iconColor ?? AppTheme.primaryBlue,
                                size: 24,
                              ),
                            ),
                            if (act.badgeText != null)
                              Positioned(
                                top: -2,
                                right: -4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentRed,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.white, width: 1.5),
                                  ),
                                  child: Text(
                                    act.badgeText!,
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
                        const SizedBox(height: 8),
                        Text(
                          act.label,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Optional Footer pills (e.g. Aktif, Isolir, Menunggak)
          if (widget.footerPills != null && widget.footerPills!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFD),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(22),
                  bottomRight: Radius.circular(22),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: widget.footerPills!,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
