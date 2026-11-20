import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/sound_effects.dart';

class BlueArchiveStage extends StatefulWidget {
  final bool hasAlert;
  final int losCount;
  final String userName;
  final VoidCallback? onAlertTap;

  const BlueArchiveStage({
    super.key,
    required this.hasAlert,
    this.losCount = 0,
    required this.userName,
    this.onAlertTap,
  });

  @override
  State<BlueArchiveStage> createState() => _BlueArchiveStageState();
}

class _BlueArchiveStageState extends State<BlueArchiveStage> with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _haloController;
  late final Animation<double> _floatAnim;
  int _dialogueIdx = 0;

  final List<String> _dialogues = [
    'Sensei! Jaringan Sukorejo beroperasi 100% optimal. Semua 114 node pelanggan terpantau stabil tanpa kendala! ✨',
    'Laporan Schale: Router MikroTik X86 dan OLT C-Data FD1602S terhubung prima. Semangat bertugas, Sensei! 📡',
    'Airi selalu siap mendampingi monitoring trafik dan pembukuan kas komando kapan pun dibutuhkan! 💖',
    'Kwitansi tagihan dan buku kas otomatis tersinkronisasi ke grup Telegram komando Sukorejo. 👍',
  ];

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _haloController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _haloController.dispose();
    super.dispose();
  }

  void _tapAiri() {
    SoundEffects.playTap();
    setState(() {
      _dialogueIdx = (_dialogueIdx + 1) % _dialogues.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAlert = widget.hasAlert;
    final currentText = isAlert
        ? 'PERHATIAN SENSEI! Radar mendeteksi ${widget.losCount} pelanggan mengalami sinyal LOS/kabel optik putus! Segera arahkan tim teknisi!'
        : _dialogues[_dialogueIdx];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isAlert
              ? [const Color(0xFFFFF1F2), Colors.white]
              : [const Color(0xFFE0F2FE), const Color(0xFFF0FDF4), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isAlert ? AppTheme.accentRed.withOpacity(0.4) : AppTheme.techCyan.withOpacity(0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isAlert ? AppTheme.accentRed.withOpacity(0.12) : AppTheme.primaryBlue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Blue Archive Cyber Grid & Diagonal Hazard Stripes Accent
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isAlert ? AppTheme.accentRed : AppTheme.primaryBlue,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isAlert ? '🚨 TACTICAL ALERT' : '🛡️ SCHALE NOC // SUKOREJO',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              child: Column(
                children: [
                  // Stage Row: Airi Character Illustration (Left) + Blue Archive Speech Bubble (Right)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Prominent Airi Character with Floating Animated Halo
                      GestureDetector(
                        onTap: isAlert ? (widget.onAlertTap ?? _tapAiri) : _tapAiri,
                        child: AnimatedBuilder(
                          animation: _floatAnim,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _floatAnim.value),
                              child: child,
                            );
                          },
                          child: Stack(
                            alignment: Alignment.topCenter,
                            clipBehavior: Clip.none,
                            children: [
                              // Glowing Kivotos Halo above head
                              Positioned(
                                top: -14,
                                child: RotationTransition(
                                  turns: _haloController,
                                  child: Container(
                                    width: 44,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isAlert ? AppTheme.accentRed : AppTheme.techCyan,
                                        width: 2.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isAlert
                                              ? AppTheme.accentRed.withOpacity(0.8)
                                              : AppTheme.techCyan.withOpacity(0.8),
                                          blurRadius: 10,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Airi Character Portrait Box (High Resolution)
                              Container(
                                width: 92,
                                height: 92,
                                margin: const EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: isAlert ? AppTheme.accentRed : AppTheme.techCyan,
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isAlert
                                          ? AppTheme.accentRed.withOpacity(0.3)
                                          : AppTheme.primaryBlue.withOpacity(0.25),
                                      blurRadius: 14,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    isAlert
                                        ? 'assets/images/mascot_alert.png'
                                        : 'assets/images/mascot_happy.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.face,
                                      size: 50,
                                      color: AppTheme.primaryBlue,
                                    ),
                                  ),
                                ),
                              ),

                              // Relationship Bond Tag
                              Positioned(
                                bottom: -4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isAlert ? AppTheme.accentRed : const Color(0xFF0F172A),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.white, width: 1.5),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isAlert ? Icons.warning_amber_rounded : Icons.favorite_rounded,
                                        color: isAlert ? Colors.white : const Color(0xFFFF4081),
                                        size: 9,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        isAlert ? 'DANGER' : 'LV.100',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Blue Archive Dialogue Bubble
                      Expanded(
                        child: GestureDetector(
                          onTap: isAlert ? (widget.onAlertTap ?? _tapAiri) : _tapAiri,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(18),
                                bottomRight: Radius.circular(18),
                                bottomLeft: Radius.circular(18),
                                topLeft: Radius.circular(4),
                              ),
                              border: Border.all(
                                color: isAlert ? AppTheme.accentRed.withOpacity(0.3) : const Color(0xFFBAE6FD),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      isAlert ? '🚨 LAPORAN DARURAT' : '💬 AIRI • ASISTEN SCHALE',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: isAlert ? AppTheme.accentRed : AppTheme.primaryBlue,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(Icons.touch_app_rounded, size: 12, color: AppTheme.textLight),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  currentText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isAlert ? AppTheme.accentRed : AppTheme.textMain,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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
