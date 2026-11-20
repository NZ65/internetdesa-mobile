import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/sound_effects.dart';

class BlueArchiveMascot extends StatefulWidget {
  final bool hasAlert;
  final int losCount;
  final VoidCallback? onAlertTap;

  const BlueArchiveMascot({
    super.key,
    required this.hasAlert,
    this.losCount = 0,
    this.onAlertTap,
  });

  @override
  State<BlueArchiveMascot> createState() => _BlueArchiveMascotState();
}

class _BlueArchiveMascotState extends State<BlueArchiveMascot> with SingleTickerProviderStateMixin {
  int _dialogueIndex = 0;
  late final AnimationController _animController;
  late final Animation<double> _bounceAnimation;

  final List<String> _cheerfulDialogues = [
    'Sensei! Jaringan Sukorejo 100% prima, semua node beroperasi lancar tanpa kendala! ✨',
    'Laporan harian: Sesi PPPoE aktif dan stabil. Semangat bertugas hari ini! 💖',
    'Airi siap membantu monitoring router MikroTik & OLT kapan pun Sensei butuh! 📡',
    'Catatan kas & kuitansi tersinkronisasi rapi ke grup Telegram komando. 👍',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0.0, end: -6.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _cycleDialogue() {
    SoundEffects.playTap();
    setState(() {
      _dialogueIndex = (_dialogueIndex + 1) % _cheerfulDialogues.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String currentDialogue = widget.hasAlert
        ? 'Perhatian Sensei! Ditemukan ${widget.losCount} pelanggan terdeteksi LOS/kabel optik putus. Segera tinjau antrean teknisi!'
        : _cheerfulDialogues[_dialogueIndex];

    final Color badgeColor = widget.hasAlert ? AppTheme.accentRed : AppTheme.primaryBlue;
    final String assetPath = widget.hasAlert
        ? 'assets/images/mascot_alert.png'
        : 'assets/images/mascot_happy.png';

    return GestureDetector(
      onTap: widget.hasAlert ? widget.onAlertTap ?? _cycleDialogue : _cycleDialogue,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.hasAlert ? AppTheme.accentRed.withOpacity(0.3) : AppTheme.primaryBlue.withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.hasAlert ? AppTheme.accentRed.withOpacity(0.08) : AppTheme.primaryBlue.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Airi Character Mascot with subtle floating bounce
            AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _bounceAnimation.value),
                  child: child,
                );
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: widget.hasAlert
                            ? [AppTheme.pastelRed, Colors.white]
                            : [const Color(0xFFE1F5FE), Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: widget.hasAlert ? AppTheme.accentRed : AppTheme.techCyan,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        assetPath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          widget.hasAlert ? Icons.warning_rounded : Icons.face,
                          color: badgeColor,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        widget.hasAlert ? Icons.priority_high : Icons.bolt,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Speech Bubble with Blue Archive NOC Tag
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: widget.hasAlert ? AppTheme.pastelRed : const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.hasAlert ? '🚨 NOC ALERT • AIRI' : '💬 ASISTEN NOC • AIRI',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: widget.hasAlert ? AppTheme.accentRed : AppTheme.primaryBlue,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Ketuk balon',
                        style: TextStyle(fontSize: 10, color: AppTheme.textLight),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    currentDialogue,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: widget.hasAlert ? AppTheme.accentRed : AppTheme.textMain,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
