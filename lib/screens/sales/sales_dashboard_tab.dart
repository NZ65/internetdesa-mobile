import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/sales_provider.dart';
import '../../widgets/anime_mascot_card.dart';
import '../../widgets/bouncing_button.dart';
import '../../widgets/dana_header.dart';
import '../../widgets/dana_hero_card.dart';
import '../../widgets/dana_service_grid.dart';
import '../../widgets/dana_banner_carousel.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';
import 'new_registration_screen.dart';

class SalesDashboardTab extends StatefulWidget {
  const SalesDashboardTab({super.key});

  @override
  State<SalesDashboardTab> createState() => _SalesDashboardTabState();
}

class _SalesDashboardTabState extends State<SalesDashboardTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    Provider.of<SalesProvider>(context, listen: false).fetchRegistrations();
    Provider.of<SalesProvider>(context, listen: false).fetchPackages();
    Provider.of<DashboardProvider>(context, listen: false).fetchDashboard();
  }

  String _formatCurrency(dynamic amount) {
    final num val = (amount is num) ? amount : (num.tryParse(amount.toString()) ?? 0);
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(val);
  }

  void _openWhatsApp(String phone, String name) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final target = clean.startsWith('0') ? '62${clean.substring(1)}' : (clean.startsWith('8') ? '62$clean' : clean);
    final msg = Uri.encodeComponent('Halo Kak $name, terima kasih telah mendaftar pasang baru Internet Desa Sukorejo. Mengenai jadwal survey dan pemasangan kabel kami...');
    final uri = Uri.parse('https://wa.me/$target?text=$msg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showInfoDialog(String title, String message, IconData icon) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primaryBlue, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 13.5, height: 1.4)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(90, 42),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final dash = Provider.of<DashboardProvider>(context);
    final sales = Provider.of<SalesProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final user = auth.user;
    final registrations = sales.registrations;
    final packages = sales.packages;

    // Fee Rp 50.000 per customer registered
    final estimatedFee = registrations.length * 50000;
    final pendingCount = registrations.where((r) => r.status == 'pending').length;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // ==========================================
              // 1. DANA HEADER & HERO SALES CARD
              // ==========================================
              Stack(
                clipBehavior: Clip.none,
                children: [
                  DanaHeader(
                    title: 'Halo, ${user?.name ?? user?.username ?? "Sales"}',
                    subtitle: 'Area: ${user?.areaName ?? "Sukorejo & Sekitarnya"}',
                    roleBadge: 'Sales Mitra',
                    isConnected: true,
                    isRefreshing: sales.isLoading,
                    onRefresh: _loadData,
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 96),
                    child: DanaHeroCard(
                      title: 'ESTIMASI KOMISI / FEE IKR',
                      primaryAmount: _formatCurrency(estimatedFee),
                      secondaryText: '${registrations.length} Pendaftar',
                      actions: [
                        DanaActionItem(
                          label: 'Pasang Baru',
                          icon: Icons.person_add_alt_1_rounded,
                          iconColor: const Color(0xFF00B074),
                          bgColor: const Color(0xFFE6F9F0),
                          onTap: () async {
                            final res = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const NewRegistrationScreen()),
                            );
                            if (res == true) _loadData();
                          },
                        ),
                        DanaActionItem(
                          label: 'Katalog Paket',
                          icon: Icons.inventory_2_rounded,
                          iconColor: AppTheme.primaryBlue,
                          bgColor: AppTheme.primaryLight,
                          badgeText: '${packages.length}',
                          onTap: () {
                            _showInfoDialog(
                              'Pilihan Paket Internet',
                              packages.isEmpty
                                  ? 'Belum ada data paket aktif di server.'
                                  : packages.map((p) => '• ${p.name}: ${_formatCurrency(p.price)} / bln (${p.speed})').join('\n\n'),
                              Icons.inventory_2_rounded,
                            );
                          },
                        ),
                        DanaActionItem(
                          label: 'Port OLT Mireng',
                          icon: Icons.campaign_rounded,
                          iconColor: const Color(0xFFFF8B00),
                          bgColor: const Color(0xFFFEF5E7),
                          badgeText: '128 Kuota',
                          onTap: () {
                            _showInfoDialog(
                              'Perluasan Dk. Mireng',
                              'Kapasitas OLT 128 Pelanggan khusus Paket 50 Mbps Murni Bebas FUP Rp 110.000/bln.',
                              Icons.campaign_rounded,
                            );
                          },
                        ),
                        DanaActionItem(
                          label: 'Brosur & WA',
                          icon: Icons.share_rounded,
                          iconColor: const Color(0xFF7C3AED),
                          bgColor: const Color(0xFFF3E8FF),
                          onTap: () {
                            _showInfoDialog(
                              'Bagikan Info Internet Desa',
                              'Salin pesan promosi dan brosur resmi untuk dibagikan ke grup WhatsApp RT/RW.',
                              Icons.share_rounded,
                            );
                          },
                        ),
                      ],
                      footerPills: [
                        _buildMiniPill(
                          context,
                          label: 'Pendaftar',
                          value: '${registrations.length}',
                          color: AppTheme.primaryBlue,
                          icon: Icons.people_outline,
                        ),
                        Container(height: 16, width: 1, color: const Color(0xFFE2E8F0)),
                        _buildMiniPill(
                          context,
                          label: 'Antrean Survey',
                          value: '$pendingCount',
                          color: const Color(0xFFFF8B00),
                          icon: Icons.hourglass_top_rounded,
                        ),
                        Container(height: 16, width: 1, color: const Color(0xFFE2E8F0)),
                        _buildMiniPill(
                          context,
                          label: 'Fee / Pasang',
                          value: 'Rp 50rb',
                          color: const Color(0xFF00B074),
                          icon: Icons.attach_money_rounded,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ==========================================
              // 2. ANIME MASCOT COMPANION (Desa-chan)
              // ==========================================
              AnimeMascotCard(
                losCount: 0,
                openTicketsCount: pendingCount,
                isNocConnected: true,
                onTapTickets: () {},
                onTapPing: () {},
              ),

              // ==========================================
              // 3. DANA SERVICE GRID (Fitur Sales)
              // ==========================================
              DanaServiceGrid(
                title: 'Alat Pemasaran & Penjualan',
                items: [
                  DanaServiceItem(
                    label: 'Input Warga',
                    icon: Icons.person_add_alt_rounded,
                    iconColor: const Color(0xFF00B074),
                    bgColor: const Color(0xFFE6F9F0),
                    onTap: () async {
                      final res = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NewRegistrationScreen()),
                      );
                      if (res == true) _loadData();
                    },
                  ),
                  DanaServiceItem(
                    label: 'Paket 50 Mbps',
                    icon: Icons.speed_rounded,
                    iconColor: AppTheme.primaryBlue,
                    bgColor: AppTheme.primaryLight,
                    badgeText: 'BEST',
                    onTap: () {
                      _showInfoDialog(
                        'Paket 50 Mbps Unggulan',
                        'Paket warga paling diminati: 50 Mbps unlimited bebas FUP hanya Rp 110.000/bulan.',
                        Icons.speed_rounded,
                      );
                    },
                  ),
                  DanaServiceItem(
                    label: 'Simulasi Fee',
                    icon: Icons.calculate_rounded,
                    iconColor: const Color(0xFFD97706),
                    bgColor: const Color(0xFFFEF3C7),
                    onTap: () {
                      _showInfoDialog(
                        'Simulasi Komisi Sales',
                        'Dapatkan komisi Rp 50.000 per instalasi baru yang berhasil terpasang dan aktif di sistem.',
                        Icons.calculate_rounded,
                      );
                    },
                  ),
                  DanaServiceItem(
                    label: 'Cek Jalur ODP',
                    icon: Icons.share_location_rounded,
                    iconColor: const Color(0xFF0284C7),
                    bgColor: const Color(0xFFE0F2FE),
                    onTap: () {
                      _showInfoDialog(
                        'Jangkauan Tiang ODP',
                        'Jarak maksimal kabel dropcore pelanggan ke tiang ODP adalah 150 meter untuk menjaga redaman optik optimal.',
                        Icons.share_location_rounded,
                      );
                    },
                  ),
                  DanaServiceItem(
                    label: 'Klaim Komisi',
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: const Color(0xFF10B981),
                    bgColor: const Color(0xFFE8F5E9),
                    onTap: () {
                      _showInfoDialog(
                        'Pencairan Komisi',
                        'Total estimasi komisi Anda: ${_formatCurrency(estimatedFee)}. Pembayaran direkap setiap akhir bulan.',
                        Icons.account_balance_wallet_rounded,
                      );
                    },
                  ),
                  DanaServiceItem(
                    label: 'Dk. Mireng',
                    icon: Icons.campaign_rounded,
                    iconColor: AppTheme.accentOrange,
                    bgColor: AppTheme.pastelOrange,
                    badgeText: 'HOT',
                    onTap: () {
                      _showInfoDialog(
                        'Perluasan Dk. Mireng',
                        'Target 128 pelanggan baru. Sosialisasi warga bisa langsung diarahkan ke portal link /mireng.',
                        Icons.campaign_rounded,
                      );
                    },
                  ),
                  DanaServiceItem(
                    label: 'Pusat Brosur',
                    icon: Icons.newspaper_rounded,
                    iconColor: const Color(0xFF7C3AED),
                    bgColor: const Color(0xFFF3E8FF),
                    onTap: () {
                      _showInfoDialog(
                        'Materi Promosi',
                        'Download brosur dan materi promosi resmi Internet Desa Sukorejo di admin kantor.',
                        Icons.newspaper_rounded,
                      );
                    },
                  ),
                  DanaServiceItem(
                    label: 'Bantuan Admin',
                    icon: Icons.support_agent_rounded,
                    iconColor: AppTheme.primaryBlue,
                    bgColor: AppTheme.primaryLight,
                    onTap: () => _openWhatsApp('085226118497', 'Admin'),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ==========================================
              // 4. BANNER CAROUSEL
              // ==========================================
              DanaBannerCarousel(
                banners: [
                  DanaBannerItem(
                    tag: 'KOMISI SALES',
                    title: 'Dapatkan Rp 50.000 / Pasang',
                    subtitle: 'Ajak tetangga dan warga berlangganan fiber optik Internet Desa.',
                    icon: Icons.monetization_on_rounded,
                    gradientColors: const [Color(0xFF00B074), Color(0xFF059669)],
                    onTap: () {},
                  ),
                  DanaBannerItem(
                    tag: 'PERLUASAN MIRENG',
                    title: '128 Port Baru OLT Mireng',
                    subtitle: 'Target penarikan kabel komunitas terbuka untuk pendaftaran warga.',
                    icon: Icons.connect_without_contact_rounded,
                    gradientColors: const [Color(0xFF118EEA), Color(0xFF0C75C2)],
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ==========================================
              // 5. RIWAYAT PENDAFTARAN SALES
              // ==========================================
              Container(
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
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Pendaftar yang Anda Input (${registrations.length})',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    if (sales.isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (registrations.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 36),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.person_add_disabled_rounded, size: 48, color: Color(0xFF94A3B8)),
                              SizedBox(height: 10),
                              Text(
                                'Belum Ada Pendaftar',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Ayo mulai daftarkan calon pelanggan pertama Anda!',
                                style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: registrations.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, indent: 70),
                        itemBuilder: (context, idx) {
                          final reg = registrations[idx];
                          final isInstalled = reg.status == 'installed' || reg.status == 'selesai';

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isInstalled ? AppTheme.pastelGreen : AppTheme.pastelOrange,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Icon(
                                  isInstalled ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                                  color: isInstalled ? AppTheme.accentGreen : AppTheme.accentOrange,
                                  size: 24,
                                ),
                              ),
                            ),
                            title: Text(
                              reg.name,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                            ),
                            subtitle: Text(
                              '${reg.packageName ?? "Paket 50 Mbps"} | ${reg.phone}',
                              style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: (isInstalled ? AppTheme.accentGreen : AppTheme.accentOrange).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isInstalled ? 'TERPASANG' : 'SURVEY',
                                style: TextStyle(
                                  color: isInstalled ? AppTheme.accentGreen : AppTheme.accentOrange,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniPill(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
