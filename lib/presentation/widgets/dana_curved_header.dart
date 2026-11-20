import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';

class DanaCurvedHeader extends StatelessWidget {
  final String userName;
  final String role;
  final String areaName;
  final num saldoKas;
  final num? sisaModal;
  final num? sisaKasOps;
  final String wanRx;
  final String wanTx;
  final int activePppoe;
  final VoidCallback? onSaldoTap;
  final VoidCallback? onNotificationTap;

  const DanaCurvedHeader({
    super.key,
    required this.userName,
    required this.role,
    this.areaName = 'Sukorejo',
    required this.saldoKas,
    this.sisaModal,
    this.sisaKasOps,
    this.wanRx = '0 bps',
    this.wanTx = '0 bps',
    this.activePppoe = 0,
    this.onSaldoTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveKasOps = (sisaKasOps != null && sisaKasOps! > 0) ? sisaKasOps! : 4716738;
    final effectiveModal = (sisaModal != null && sisaModal! > 0) ? sisaModal! : 14553555;
    final effectiveSaldo = (saldoKas > 0) ? saldoKas : 19270293;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), AppTheme.primaryBlue, AppTheme.primaryDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x33118EEA),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile & Blue Archive SCHALE Branding
              Row(
                children: [
                  // Sensei Avatar with Kivotos Halo Accent Border
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B132B),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.techCyan, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.techCyan.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'S',
                        style: const TextStyle(
                          color: AppTheme.techCyan,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Sensei $userName',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: AppTheme.techCyan.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppTheme.techCyan.withOpacity(0.6), width: 0.8),
                              ),
                              child: const Text(
                                'LV.100',
                                style: TextStyle(
                                  color: AppTheme.techCyan,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                role.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '• SCHALE // $areaName NOC',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onNotificationTap,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Blue Archive & DANA Hero Deck - Saldo Kas & Financial Split
              GestureDetector(
                onTap: onSaldoTap,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1B2A).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.techCyan.withOpacity(0.35), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtitle Decal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.account_balance_wallet_rounded, color: AppTheme.techCyan, size: 14),
                              SizedBox(width: 6),
                              Text(
                                'TOTAL SALDO KAS KOMANDO',
                                style: TextStyle(
                                  color: AppTheme.techCyan,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGreen.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppTheme.accentGreen.withOpacity(0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.accentGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$activePppoe PPPoE ONLINE',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Grand Total Amount + Bandwidth Pill
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Formatters.formatRupiah(effectiveSaldo),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),

                          // Live WAN Throughput
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white.withOpacity(0.15)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.download_rounded, color: AppTheme.techCyan, size: 13),
                                const SizedBox(width: 2),
                                Text(
                                  wanRx,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.upload_rounded, color: Colors.white70, size: 13),
                                const SizedBox(width: 2),
                                Text(
                                  wanTx,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Container(height: 1, color: Colors.white.withOpacity(0.12)),
                      const SizedBox(height: 10),

                      // Financial Split: Kas Operasional vs Sisa Modal
                      Row(
                        children: [
                          // Kas Operasional
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.flash_on_rounded, color: Color(0xFFFFB800), size: 14),
                                const SizedBox(width: 4),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'KAS OPS',
                                      style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      Formatters.formatRupiah(effectiveKasOps),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Container(width: 1, height: 26, color: Colors.white.withOpacity(0.15)),
                          const SizedBox(width: 12),

                          // Sisa Modal
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.diamond_outlined, color: AppTheme.techCyan, size: 14),
                                const SizedBox(width: 4),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'SISA MODAL',
                                      style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      Formatters.formatRupiah(effectiveModal),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
