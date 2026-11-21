import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/sound_effects.dart';
import '../../providers/technician_provider.dart';
import '../../widgets/zzz_card.dart';
import '../../widgets/zzz_badge.dart';
import '../../widgets/empty_state.dart';

class OdpMapScreen extends StatefulWidget {
  const OdpMapScreen({super.key});

  @override
  State<OdpMapScreen> createState() => _OdpMapScreenState();
}

class _OdpMapScreenState extends State<OdpMapScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TechnicianProvider>().fetchOdps();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openMaps(double lat, double lng) async {
    final url = Uri.parse('https://maps.google.com/?q=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final techProv = context.watch<TechnicianProvider>();
    final query = _searchCtrl.text.toLowerCase().trim();

    final filtered = techProv.odps.where((o) {
      if (query.isEmpty) return true;
      return o.name.toLowerCase().contains(query) || (o.address?.toLowerCase().contains(query) ?? false);
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('DIREKTORI ODP // SUKOREJO', style: TextStyle(color: AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Cari nama ODP (Contoh: ODC 1 ODP 2)...',
                hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.neonCyan, size: 20),
                filled: true,
                fillColor: AppTheme.bgCard,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.borderDark),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.neonCyan, width: 1.5),
                ),
              ),
            ),
          ),

          // List of ODPs
          Expanded(
            child: techProv.isLoading && techProv.odps.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppTheme.neonCyan))
                : filtered.isEmpty
                    ? const EmptyState(
                        icon: Icons.alt_route_rounded,
                        title: 'ODP Tidak Ditemukan',
                        message: 'Tidak ada data ODP yang cocok dengan kata kunci.',
                      )
                    : RefreshIndicator(
                        onRefresh: () => techProv.fetchOdps(),
                        color: AppTheme.neonCyan,
                        backgroundColor: AppTheme.bgCard,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final odp = filtered[index];
                            final totalPort = odp.totalPorts > 0 ? odp.totalPorts : 8;
                            final usedPort = odp.usedPorts;
                            final hasCapacity = usedPort < totalPort;

                            return ZzzCard(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        odp.name,
                                        style: const TextStyle(
                                          color: AppTheme.textWhite,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      ZzzBadge(
                                        text: '$usedPort / $totalPort PORT',
                                        type: hasCapacity ? ZzzBadgeType.cyan : ZzzBadgeType.red,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textMuted),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          odp.address?.isNotEmpty == true ? odp.address! : 'Lokasi ODP Sukorejo',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const Divider(color: AppTheme.borderDark, height: 1),
                                  const SizedBox(height: 10),

                                  // Capacity Progress Bar & Map Link
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            LinearProgressIndicator(
                                              value: totalPort > 0 ? (usedPort / totalPort).clamp(0.0, 1.0) : 0,
                                              backgroundColor: AppTheme.bgDark,
                                              color: hasCapacity ? AppTheme.neonCyan : AppTheme.crimsonRed,
                                              minHeight: 5,
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              hasCapacity ? 'Tersisa ${totalPort - usedPort} port kosong' : 'PORT PENUH',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: hasCapacity ? AppTheme.neonGreen : AppTheme.crimsonRed,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (odp.latitude != null && odp.longitude != null) ...[
                                        const SizedBox(width: 14),
                                        InkWell(
                                          onTap: () {
                                            SoundEffects.playTap();
                                            _openMaps(odp.latitude!, odp.longitude!);
                                          },
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: AppTheme.neonCyan.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: AppTheme.neonCyan.withOpacity(0.4)),
                                            ),
                                            child: const Row(
                                              children: [
                                                Icon(Icons.navigation_rounded, size: 14, color: AppTheme.neonCyan),
                                                SizedBox(width: 4),
                                                Text('GPS MAP', style: TextStyle(color: AppTheme.neonCyan, fontSize: 10, fontWeight: FontWeight.w900)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
