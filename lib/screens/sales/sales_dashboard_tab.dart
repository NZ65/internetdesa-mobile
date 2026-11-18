import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/sales_provider.dart';
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
                    roleBadge: 'Sales Partner',
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
                          label: 'Kunci GPS',
                          icon: Icons.my_location_rounded,
                          iconColor: const Color(0xFFFF8B00),
                          bgColor: const Color(0xFFFEF5E7),
                          onTap: () async {
                            final res = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const NewRegistrationScreen()),
                            );
                            if (res == true) _loadData();
                          },
                        ),
                        DanaActionItem(
                          label: 'Brosur Promo',
                          icon: Icons.campaign_rounded,
                          iconColor: const Color(0xFF7C3AED),
                          bgColor: const Color(0xFFF3E8FF),
                          onTap: () {
                            _showInfoDialog(
                              'Promo Pemasangan Internet',
                              'Paket Promo Warga Sukorejo:\n1. 10 Mbps Rp 100.000 / bln\n2. 20 Mbps Rp 150.000 / bln\n3. 30 Mbps Rp 200.000 / bln\nGratis biaya survey dan kabel dropcore awal!',
                              Icons.campaign_rounded,
                            );
                          },
                        ),
                      ],
                      footerPills: [
                        _buildMiniPill(
                          context,
                          label: 'Total Calon',
                          value: '${registrations.length}',
                          color: AppTheme.primaryBlue,
                          icon: Icons.people_outline,
                        ),
                        Container(height: 16, width: 1, color: const Color(0xFFE2E8F0)),
                        _buildMiniPill(
                          context,
                          label: 'Target Bulan',
                          value: '30 Calon',
                          color: const Color(0xFFFF8B00),
                          icon: Icons.flag_outlined,
                        ),
                        Container(height: 16, width: 1, color: const Color(0xFFE2E8F0)),
                        _buildMiniPill(
                          context,
                          label: 'Fee / Pasang',
                          value: 'Rp 50rb',
                          color: const Color(0xFF00B074),
                          icon: Icons.monetization_on_outlined,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ==========================================
              // 2. DANA SERVICE GRID (Menu Sales)
              // ==========================================
              DanaServiceGrid(
                title: 'Alat Pemasaran & Penjualan',
                items: [
                  DanaServiceItem(
                    label: 'Form Pendaftaran',
                    icon: Icons.app_registration_rounded,
                    iconColor: const Color(0xFF00B074),
                    bgColor: const Color(0xFFE6F9F0),
                    badgeText: 'FORM',
                    onTap: () async {
                      final res = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NewRegistrationScreen()),
                      );
                      if (res == true) _loadData();
                    },
                  ),
                  DanaServiceItem(
                    label: 'Cek Jalur ODP',
                    icon: Icons.alt_route_rounded,
                    iconColor: const Color(0xFF0284C7),
                    bgColor: const Color(0xFFE0F2FE),
                    onTap: () {
                      _showInfoDialog(
                        'Cek Coverage Area',
                        'Jaringan kabel fiber optik sudah mencakup seluruh RT/RW di Sukorejo. Maksimal tarikan kabel dropcore rekomendasi: 250 meter dari ODP.',
                        Icons.alt_route_rounded,
                      );
                    },
                  ),
                  DanaServiceItem(
                    label: 'Brosur Digital',
                    icon: Icons.photo_library_rounded,
                    iconColor: const Color(0xFF7C3AED),
                    bgColor: const Color(0xFFF3E8FF),
                    onTap: () {
                      _showInfoDialog(
                        'Brosur Digital Sales',
                        'Materi pamflet dan brosur digital dapat diunduh dari web portal atau diminta ke admin kantor.',
                        Icons.photo_library_rounded,
                      );
                    },
                  ),
                  DanaServiceItem(
                    label: 'Hitung Estimasi',
                    icon: Icons.calculate_rounded,
                    iconColor: const Color(0xFFFF8B00),
                    bgColor: const Color(0xFFFEF5E7),
                    onTap: () {
                      _showInfoDialog(
                        'Kalkulator Pemasangan',
                        'Biaya pasang baru standar:\n• Dropcore s/d 100m: GRATIS\n• Kelebihan kabel: Rp 1.500 / meter\n• ONT Wi-Fi ZTE/Huawei: Dipinjamkan selama berlangganan.',
                        Icons.calculate_rounded,
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ==========================================
              // 3. DANA BANNER CAROUSEL
              // ==========================================
              DanaBannerCarousel(
                banners: [
                  DanaBannerItem(
                    tag: 'FEE KHUSUS',
                    title: 'Dapatkan Bonus Tambahan!',
                    subtitle: 'Capai minimal 25 pelanggan baru dalam satu bulan untuk mendapatkan ekstra reward tunai.',
                    icon: Icons.stars_rounded,
                    gradientColors: const [Color(0xFF6366F1), Color(0xFF4338CA)],
                    onTap: () {},
                  ),
                  DanaBannerItem(
                    tag: 'AUTO SYNC',
                    title: 'Data Masuk Langsung ke Tim',
                    subtitle: 'Calon pelanggan yang diinput otomatis masuk antrean teknisi & grup Telegram.',
                    icon: Icons.sync_alt_rounded,
                    gradientColors: const [Color(0xFF118EEA), Color(0xFF0073C7)],
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ==========================================
              // 4. DAFTAR CALON PELANGGAN TERDAFTAR FEED
              // ==========================================
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
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
                                height: 18,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Antrean Registrasi (${registrations.length})',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () async {
                              final res = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const NewRegistrationScreen()),
                              );
                              if (res == true) _loadData();
                            },
                            child: const Text(
                              '+ Tambah Calon',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: isDark ? AppTheme.borderDark : const Color(0xFFF1F5F9),
                    ),

                    if (sales.isLoading)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (registrations.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(28.0),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.person_add_disabled_rounded, color: Colors.grey, size: 48),
                              SizedBox(height: 12),
                              Text(
                                'Belum Ada Pendaftaran Calon',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Tekan tombol "+ Tambah Calon" untuk input data baru.',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
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
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          thickness: 1,
                          color: isDark ? AppTheme.borderDark : const Color(0xFFF8FAFD),
                        ),
                        itemBuilder: (context, idx) {
                          final reg = registrations[idx];

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F4FD),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      reg.customerName.isNotEmpty ? reg.customerName[0].toUpperCase() : 'C',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.primaryBlue,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        reg.customerName,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Paket: ${reg.packageName} • Dropcore: ~${reg.estimatedDropcoreMeters}m',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    StatusBadge(status: reg.status),
                                    const SizedBox(height: 4),
                                    if (reg.customerPhone.isNotEmpty)
                                      BouncingButton(
                                        onTap: () => _openWhatsApp(reg.customerPhone, reg.customerName),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE8F5E9),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.chat_bubble_outline_rounded, size: 11, color: Color(0xFF00B074)),
                                              SizedBox(width: 3),
                                              Text('WA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF00B074))),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
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

  Widget _buildMiniPill(BuildContext context, {
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 10.5,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}
