import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/sound_effects.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/cyber_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';
import 'customer_detail_screen.dart';

class CustomerListScreen extends StatefulWidget {
  final String initialStatus;

  const CustomerListScreen({super.key, this.initialStatus = 'all'});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final _searchController = TextEditingController();
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().fetchCustomers(status: _selectedStatus);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String val) {
    context.read<CustomerProvider>().fetchCustomers(search: val, status: _selectedStatus);
  }

  void _changeStatus(String status) {
    SoundEffects.playTap();
    setState(() => _selectedStatus = status);
    context.read<CustomerProvider>().fetchCustomers(status: status, search: _searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final custProv = context.watch<CustomerProvider>();

    return Scaffold(
      backgroundColor: AppTheme.iceBackground,
      appBar: AppBar(
        title: const Text('Daftar Pelanggan', style: TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppTheme.textMain),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search & Filter Box
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _onSearch,
                  decoration: InputDecoration(
                    hintText: 'Cari nama, ID, nomor WA, atau ODP...',
                    hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textLight),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryBlue, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _onSearch('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 10),

                // Filter Tabs (Semua, Aktif, Isolir, Belum Bayar, Pasang Baru)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'Semua'),
                      _buildFilterChip('active', 'Aktif'),
                      _buildFilterChip('isolated', 'Terisolir'),
                      _buildFilterChip('unpaid', 'Belum Bayar (${custProv.unpaidCount})'),
                      _buildFilterChip('pasang_baru', 'Antrean Pasang (${custProv.pendingCount})'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Customer List
          Expanded(
            child: custProv.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
                : custProv.customers.isEmpty
                    ? EmptyState(
                        icon: Icons.people_outline_rounded,
                        title: 'Tidak Ada Pelanggan',
                        message: 'Tidak ditemukan pelanggan sesuai kriteria pencarian.',
                        onRetry: () => custProv.fetchCustomers(),
                      )
                    : RefreshIndicator(
                        onRefresh: () => custProv.fetchCustomers(status: _selectedStatus),
                        color: AppTheme.primaryBlue,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: custProv.customers.length,
                          itemBuilder: (ctx, idx) {
                            final c = custProv.customers[idx];
                            return CyberCard(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              padding: const EdgeInsets.all(14),
                              onTap: () {
                                SoundEffects.playTap();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => CustomerDetailScreen(customerId: c.id),
                                  ),
                                );
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Avatar Initials
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: c.isOnline ? AppTheme.pastelGreen : (c.isIsolated ? AppTheme.pastelRed : const Color(0xFFE2E8F0)),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Center(
                                      child: Text(
                                        c.name.isNotEmpty ? c.name[0].toUpperCase() : 'P',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: c.isOnline ? AppTheme.accentGreen : (c.isIsolated ? AppTheme.accentRed : AppTheme.textMain),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                c.name,
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            StatusBadge(status: c.status),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${c.custId} • ${c.packageName ?? "Paket"} (${Formatters.formatCompactRupiah(c.packagePrice ?? 0)})',
                                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.alt_route_rounded, size: 12, color: AppTheme.textLight),
                                            const SizedBox(width: 4),
                                            Text(
                                              c.odpName ?? 'ODP Belum Diatur',
                                              style: const TextStyle(fontSize: 11, color: AppTheme.primaryBlue, fontWeight: FontWeight.w600),
                                            ),
                                            if (c.hasUnpaid) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.pastelOrange,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  'Tunggakan ${Formatters.formatCompactRupiah(c.unpaidAmount)}',
                                                  style: const TextStyle(fontSize: 9.5, color: AppTheme.accentOrange, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
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

  Widget _buildFilterChip(String status, String label) {
    final isSelected = _selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => _changeStatus(status),
        selectedColor: AppTheme.primaryBlue,
        backgroundColor: const Color(0xFFF1F5F9),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textMain,
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        showCheckmark: false,
      ),
    );
  }
}
