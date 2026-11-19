import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'bouncing_button.dart';

class DanaBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;
  final VoidCallback onCenterActionTap;
  final List<DanaNavItem> items;

  const DanaBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onCenterActionTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.borderDark : const Color(0xFFEDF2F7),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            children: [
              // Left Tab 0
              if (items.isNotEmpty)
                _buildNavItem(0, items[0], isDark),

              // Left Tab 1
              if (items.length > 1)
                _buildNavItem(1, items[1], isDark),

              // Center Floating Action Button (DANA Pay / Quick Action Style)
              Expanded(
                child: Center(
                  child: BouncingButton(
                    onTap: onCenterActionTap,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF118EEA), Color(0xFF0C75C2)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withOpacity(0.45),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withOpacity(0.9),
                          width: 2.5,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.bolt_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Right Tab 2 (Maps to screen index 2)
              if (items.length > 2)
                _buildNavItem(2, items[2], isDark),

              // Right Tab 3 (Maps to screen index 3)
              if (items.length > 3)
                _buildNavItem(3, items[3], isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, DanaNavItem item, bool isDark) {
    final isSelected = currentIndex == index;
    final color = isSelected
        ? AppTheme.primaryBlue
        : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8));

    return Expanded(
      child: InkWell(
        onTap: () => onTabSelected(index),
        splashColor: AppTheme.primaryLight,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? item.activeIcon : item.icon,
                  color: color,
                  size: 24,
                ),
                if (item.badgeCount != null && item.badgeCount! > 0)
                  Positioned(
                    top: -3,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppTheme.accentRed,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item.badgeCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class DanaNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final int? badgeCount;

  const DanaNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.badgeCount,
  });
}
