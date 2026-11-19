import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'bouncing_button.dart';

class AnimeMascotCard extends StatefulWidget {
  final int losCount;
  final int openTicketsCount;
  final bool isNocConnected;
  final VoidCallback? onTapLos;
  final VoidCallback? onTapTickets;
  final VoidCallback? onTapPing;

  const AnimeMascotCard({
    super.key,
    required this.losCount,
    this.openTicketsCount = 0,
    this.isNocConnected = true,
    this.onTapLos,
    this.onTapTickets,
    this.onTapPing,
  });

  @override
  State<AnimeMascotCard> createState() => _AnimeMascotCardState();
}

class _AnimeMascotCardState extends State<AnimeMascotCard> with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  late AnimationController _jumpController;
  late Animation<double> _jumpAnimation;

  bool _isExpanded = true;
  int _quoteIndex = 0;
  bool _showReaction = false;

  final List<String> _happyQuotes = [
    'Halo Kak! Desa-chan siap pantau jaringan Sukorejo & Mireng hari ini! ✨',
    'Total pelanggan aktif online lancar jaya, redaman optik aman di -18 dBm! ⚡',
    'Setiap pengeluaran kas otomatis ter-broadcast ke grup Telegram topic 874 lho! 💵',
    'Pelanggan butuh ganti sandi Wi-Fi? Bisa langsung reset via ONT Remote kak! 🔑',
    'Semangat melayani desa! Jangan lupa ngopi dan jaga keselamatan di tiang ya~ ☕',
  ];

  @override
  void initState() {
    super.initState();
    // Gentle floating / breathing
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 0.98, end: 1.03).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // Interactive Tap Jump / Bounce
    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _jumpAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.18).chain(CurveTween(curve: Curves.easeOutQuad)), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.18, end: 0.95).chain(CurveTween(curve: Curves.easeInQuad)), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 0.95, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 30),
    ]).animate(_jumpController);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _jumpController.dispose();
    super.dispose();
  }

  void _onTapMascot() {
    _jumpController.forward(from: 0.0);
    setState(() {
      _quoteIndex = (_quoteIndex + 1);
      _showReaction = true;
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _showReaction = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasLos = widget.losCount > 0;
    final hasTickets = widget.openTicketsCount > 0;
    final isAlert = hasLos || !widget.isNocConnected;

    // Status colors
    final Color alertColor = hasLos
        ? AppTheme.accentRed
        : (!widget.isNocConnected ? AppTheme.accentOrange : (hasTickets ? AppTheme.accentOrange : AppTheme.primaryBlue));

    final String mascotAsset = isAlert
        ? 'assets/images/mascot_alert.png'
        : 'assets/images/mascot_interactive_happy.png';

    final List<String> activeQuotes = isAlert
        ? [
            'Awas kak! Ada ${widget.losCount} pelanggan kabel optik putus (LOS)! 🚨',
            'Segera koordinasikan dengan tim teknisi lapangan di jalur ODP ya! 🛠️',
            'Ketuk tombol "Buka Detail LOS" di bawah untuk melihat pelanggan terdampak! ⚠️',
          ]
        : _happyQuotes;

    final String currentDialogue = activeQuotes[_quoteIndex % activeQuotes.length];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isAlert ? alertColor.withOpacity(0.5) : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
          width: isAlert ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isAlert ? alertColor.withOpacity(0.12) : Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Bar of the Mascot Card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 14, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isAlert ? alertColor : AppTheme.accentGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (isAlert ? alertColor : AppTheme.accentGreen).withOpacity(0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Asisten Virtual Internet Desa',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.touch_app_rounded, size: 10, color: AppTheme.primaryBlue),
                          SizedBox(width: 2),
                          Text(
                            'Sentuh Aku ✨',
                            style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppTheme.primaryDark),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF242E4C) : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: isDark ? Colors.white70 : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_isExpanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Interactive Mascot Image with Jump & Breathing Animations
                  GestureDetector(
                    onTap: _onTapMascot,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ScaleTransition(
                          scale: _jumpAnimation,
                          child: ScaleTransition(
                            scale: _breathingAnimation,
                            child: Container(
                              width: 82,
                              height: 86,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  colors: isAlert
                                      ? [const Color(0xFFFEECEE), const Color(0xFFFFF0F2)]
                                      : [const Color(0xFFE0F2FE), const Color(0xFFBAE6FD)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: isAlert ? alertColor.withOpacity(0.4) : AppTheme.primaryBlue.withOpacity(0.35),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isAlert ? alertColor : AppTheme.primaryBlue).withOpacity(0.18),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.asset(
                                mascotAsset,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Image.asset(
                                  'assets/images/mascot_happy.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    isAlert ? Icons.warning_amber_rounded : Icons.face_rounded,
                                    size: 40,
                                    color: alertColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Floating Heart / Sparkle Reaction on Tap
                        if (_showReaction)
                          Positioned(
                            top: -10,
                            right: -6,
                            child: AnimatedOpacity(
                              opacity: _showReaction ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 300),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(color: Colors.black12, blurRadius: 4),
                                  ],
                                ),
                                child: Text(
                                  isAlert ? '⚡' : '💖',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Speech Bubble & Quick Action
                  Expanded(
                    child: GestureDetector(
                      onTap: _onTapMascot,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                isAlert ? '🚨 Airi (NOC Alert)' : '✨ Desa-chan (Airi)',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: isAlert ? alertColor : (isDark ? Colors.white : AppTheme.textPrimary),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (isAlert ? alertColor : AppTheme.accentGreen).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isAlert ? 'Perhatian!' : 'Aktif',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: isAlert ? alertColor : AppTheme.accentGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),

                          // Message Text with Smooth Animated Switcher
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              currentDialogue,
                              key: ValueKey<String>(currentDialogue),
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.35,
                                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Action Button
                          if (hasLos && widget.onTapLos != null)
                            BouncingButton(
                              onTap: widget.onTapLos,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentRed,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.accentRed.withOpacity(0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.bolt_rounded, size: 13, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text(
                                      'Buka Detail LOS',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                                    ),
                                    SizedBox(width: 2),
                                    Icon(Icons.chevron_right_rounded, size: 14, color: Colors.white),
                                  ],
                                ),
                              ),
                            )
                          else if (hasTickets && widget.onTapTickets != null)
                            BouncingButton(
                              onTap: widget.onTapTickets,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentOrange,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.confirmation_num_outlined, size: 13, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text(
                                      'Lihat Tiket',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                                    ),
                                    Icon(Icons.chevron_right_rounded, size: 14, color: Colors.white),
                                  ],
                                ),
                              ),
                            )
                          else if (widget.onTapPing != null)
                            BouncingButton(
                              onTap: widget.onTapPing,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLight,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3), width: 1),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.speed_rounded, size: 13, color: AppTheme.primaryBlue),
                                    SizedBox(width: 4),
                                    Text(
                                      'Cek Ping Server',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue),
                                    ),
                                    Icon(Icons.chevron_right_rounded, size: 14, color: AppTheme.primaryBlue),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
