import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/sound_effects.dart';
import '../../providers/technician_provider.dart';
import '../../widgets/cyber_card.dart';
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
      backgroundColor: AppTheme.iceBackground,
      appBar: AppBar(
        title: const Text('Infrastruktur ODP Sukorejo', style: TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppTheme.textMain),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Box
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Cari kotak ODP atau lokasi jalan...',
                hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textLight),
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryBlue, size: 20),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),

          // ODP Cards List
          Expanded(
            child: techProv.odps.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const EmptyState(
                        icon: Icons.alt_route_rounded,
                        title: 'ODP Tidak Ditemukan',
                        message: 'Tidak ditemukan kotak ODP dengan kata kunci pencarian.',
                      )
                    : RefreshIndicator(
                        onRefresh: () => techProv.fetchOdps(),
                        color: AppTheme.primaryBlue,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, idx) {
                            final o = filtered[idx];
                            final percent = o.usagePercent;
                            final isFull = o.isFull;

                            return CyberCard(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: isFull ? AppTheme.pastelRed : AppTheme.pastelPurple,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              Icons.alt_route_rounded,
                                              color: isFull ? AppTheme.accentRed : AppTheme.accentPurple,
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                o.name,
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                                              ),
                                              Text(
                                                '${o.odcParent ?? "ODC"} • Port OLT ${o.oltPort ?? "1"}',
                                                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isFull ? AppTheme.pastelRed : AppTheme.pastelGreen,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          isFull ? 'PENUH' : '${o.availablePorts} Sisa Port',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isFull ? AppTheme.accentRed : AppTheme.accentGreen,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),

                                  // Port Capacity Bar
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Kapasitas Port: ${o.usedPorts} / ${o.totalPorts} Terpakai', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                      Text('${(percent * 100).toInt()}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: percent,
                                      backgroundColor: const Color(0xFFE2E8F0),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isFull ? AppTheme.accentRed : (percent > 0.75 ? AppTheme.accentOrange : AppTheme.primaryBlue),
                                      ),
                                      minHeight: 6,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Location Address & Map Button
                                  if (o.address != null)
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textLight),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            o.address!,
                                            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (o.latitude != null && o.longitude != null)
                                          TextButton.icon(
                                            onPressed: () => _openMaps(o.latitude!, o.longitude!),
                                            icon: const Icon(Icons.directions_rounded, size: 14),
                                            label: const Text('Navigasi', style: TextStyle(fontSize: 11)),
                                            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                                          ),
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
