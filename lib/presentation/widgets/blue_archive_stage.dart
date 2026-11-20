import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/sound_effects.dart';

/// Authentic Blue Archive SCHALE Tactical Terminal & MomoTalk Dispatch Deck
/// Pure Blue Archive sci-fi military tactical aesthetic with NO cartoon mascots.
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
  late final AnimationController _haloController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  int _memoIndex = 0;

  final List<String> _tacticalMemos = [
    'Sensei, seluruh 109 subscriber node di sektor Sukorejo online prima. MikroTik Core X86 & OLT FD1602S beroperasi nominal pada latency 1.2ms.',
    'Laporan Finansial: Pembukuan kas komando & kuitansi tagihan tersinkronisasi otomatis ke grup Telegram Sukorejo Topic #874.',
    'Topologi Jaringan: 15 box ODP terpantau aman tanpa redaman tinggi. Nilai rata-rata optical power normal di -18.5 dBm.',
    'Pusat Komando Schale siap. Ketuk tile operasi misi di bawah untuk mengeksekusi tugas teknisi, billing, dan kas.',
  ];

  @override
  void initState() {
    super.initState();
    _haloController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _haloController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _cycleMemo() {
    SoundEffects.playTap();
    setState(() {
      _memoIndex = (_memoIndex + 1) % _tacticalMemos.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isAlert = widget.hasAlert;
    final String currentMemo = isAlert
        ? '🚨 MOMOTALK PRIORITY ALERT // Terdeteksi ${widget.losCount} pelanggan mengalami redaman LOS / kabel optik putus di lapangan! Ketuk untuk membuka Tactical Diagnostics.'
        : _tacticalMemos[_memoIndex];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isAlert
              ? AppTheme.accentRed.withOpacity(0.5)
              : AppTheme.techCyan.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isAlert
                ? AppTheme.accentRed.withOpacity(0.12)
                : AppTheme.primaryBlue.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Background Subtle Cyber Grid & Decals
            Positioned.fill(
              child: CustomPaint(
                painter: _CyberGridPainter(isAlert: isAlert),
              ),
            ),

            // Top-right Blue Archive Chamfered Tactical Tag
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: isAlert ? AppTheme.accentRed : const Color(0xFF0F172A),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAlert ? Icons.warning_amber_rounded : Icons.shield_rounded,
                      color: isAlert ? Colors.white : AppTheme.techCyan,
                      size: 11,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isAlert
                          ? 'EMERGENCY TACTICAL ALERT'
                          : 'SCHALE NOC // SECTOR 03',
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

            // Top Hazard Caution Stripes on Alert
            if (isAlert)
              Positioned(
                top: 0,
                left: 0,
                right: 170,
                height: 4,
                child: CustomPaint(
                  painter: _HazardStripePainter(),
                ),
              ),

            // Main Console Layout
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Upper Console: Kivotos Vector Halo + MomoTalk Tactical Dispatch
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left: Pure Vector Kivotos Halo & Sensei Authorization Core
                      GestureDetector(
                        onTap: isAlert ? (widget.onAlertTap ?? _cycleMemo) : _cycleMemo,
                        child: Container(
                          width: 82,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B132B),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isAlert ? AppTheme.accentRed : AppTheme.techCyan,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isAlert
                                    ? AppTheme.accentRed.withOpacity(0.3)
                                    : AppTheme.techCyan.withOpacity(0.25),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Vector Kivotos Halo with Rotation & Pulse
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _pulseAnimation.value,
                                    child: child,
                                  );
                                },
                                child: RotationTransition(
                                  turns: _haloController,
                                  child: SizedBox(
                                    width: 46,
                                    height: 46,
                                    child: CustomPaint(
                                      painter: _KivotosHaloPainter(
                                        color: isAlert ? AppTheme.accentRed : AppTheme.techCyan,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Sensei Authority Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: isAlert ? AppTheme.accentRed : AppTheme.primaryBlue,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'SENSEI',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 3),

                              // Diamond Level & Status
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.diamond_rounded,
                                    color: isAlert ? AppTheme.accentRed : AppTheme.techCyan,
                                    size: 8,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    isAlert ? 'LOS ALERT' : 'LV.100',
                                    style: TextStyle(
                                      color: isAlert ? const Color(0xFFFF8A80) : Colors.white70,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Right: Authentic MomoTalk Tactical Terminal Bubble
                      Expanded(
                        child: GestureDetector(
                          onTap: isAlert ? (widget.onAlertTap ?? _cycleMemo) : _cycleMemo,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isAlert
                                    ? AppTheme.accentRed.withOpacity(0.35)
                                    : const Color(0xFFCBD5E1),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // MomoTalk Header Bar
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isAlert ? AppTheme.accentRed : const Color(0xFFFF4081),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 9),
                                          SizedBox(width: 4),
                                          Text(
                                            'MOMOTALK',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8.5,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isAlert ? 'PRIORITY DISPATCH' : 'SCHALE COMMS',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: isAlert ? AppTheme.accentRed : AppTheme.textMuted,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.touch_app_rounded,
                                      size: 13,
                                      color: AppTheme.textLight,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // Memo Content with Corner Reticle Framing
                                Text(
                                  currentMemo,
                                  style: TextStyle(
                                    fontSize: 11.5,
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

                  const SizedBox(height: 8),

                  // Bottom Micro-Decals (Kivotos Protocol & Encryption Barcode)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '::: PROTOCOL: PPPOE_V4 // AES-256',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.blueGrey.shade600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'KIVOTOS OS v3.8.2 :::',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.blueGrey.shade600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Corner Targeting Reticles [ + ]
            const Positioned(
              top: 4,
              left: 6,
              child: Text(
                '+',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Positioned(
              bottom: 4,
              right: 6,
              child: Text(
                '+',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Vector Painter for Blue Archive Kivotos Halo
/// Draws geometric segmented cyber halo rings with inner diamond star
class _KivotosHaloPainter extends CustomPainter {
  final Color color;

  _KivotosHaloPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer Glow Paint
    final glowPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    // Sharp Vector Paint
    final mainPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.85)
      ..style = PaintingStyle.fill;

    // 1. Outer Ring with 4 Segmented Arcs
    const sweepAngle = math.pi / 2.8;
    for (int i = 0; i < 4; i++) {
      final startAngle = (i * math.pi / 2) + 0.15;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 2),
        startAngle,
        sweepAngle,
        false,
        glowPaint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 2),
        startAngle,
        sweepAngle,
        false,
        mainPaint,
      );
    }

    // 2. Inner Concentric Ring
    canvas.drawCircle(center, radius * 0.55, mainPaint);

    // 3. Central 8-Point Kivotos Geometric Star / Rhombus
    final path = Path();
    const points = 8;
    final outerR = radius * 0.42;
    final innerR = radius * 0.18;

    for (int i = 0; i < points * 2; i++) {
      final r = (i % 2 == 0) ? outerR : innerR;
      final angle = (i * math.pi / points) - (math.pi / 2);
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, fillPaint);

    // 4. Center Dot Reticle
    canvas.drawCircle(center, 2.0, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _KivotosHaloPainter oldDelegate) => oldDelegate.color != color;
}

/// Cyber Grid Background Lines Painter
class _CyberGridPainter extends CustomPainter {
  final bool isAlert;

  _CyberGridPainter({required this.isAlert});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isAlert
          ? const Color(0xFFFFEBEE).withOpacity(0.6)
          : const Color(0xFFF1F5F9).withOpacity(0.8)
      ..strokeWidth = 0.8;

    // Draw horizontal grid lines
    const double step = 20.0;
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw vertical grid lines
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CyberGridPainter oldDelegate) => oldDelegate.isAlert != isAlert;
}

/// Hazard Diagonal Stripe Painter for Alerts
class _HazardStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final yellowPaint = Paint()
      ..color = const Color(0xFFFFB800)
      ..style = PaintingStyle.fill;
    final blackPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    const double stripeWidth = 8.0;
    for (double x = -size.height; x < size.width + size.height; x += stripeWidth * 2) {
      final path = Path()
        ..moveTo(x, size.height)
        ..lineTo(x + stripeWidth, size.height)
        ..lineTo(x + stripeWidth + size.height, 0)
        ..lineTo(x + size.height, 0)
        ..close();
      canvas.drawPath(path, yellowPaint);

      final darkPath = Path()
        ..moveTo(x + stripeWidth, size.height)
        ..lineTo(x + stripeWidth * 2, size.height)
        ..lineTo(x + stripeWidth * 2 + size.height, 0)
        ..lineTo(x + stripeWidth + size.height, 0)
        ..close();
      canvas.drawPath(darkPath, blackPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HazardStripePainter oldDelegate) => false;
}
