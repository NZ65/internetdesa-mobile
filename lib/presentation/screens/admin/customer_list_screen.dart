import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/sound_effects.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/zzz_card.dart';
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
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('DIREKTORI PELANGGAN', style: TextStyle(color: AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _onSearch,
                  style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Cari nama, secret PPPoE, atau no HP...',
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
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Semua', 'all'),
                      _buildFilterChip('Online / Aktif', 'active'),
                      _buildFilterChip('Terisolir', 'isolated'),
                      _buildFilterChip('Pending', 'inactive'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // List of Customers
          Expanded(
            child: custProv.isLoading && custProv.customers.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppTheme.neonCyan))
                : custProv.customers.isEmpty
                    ? const EmptyState(
                        icon: Icons.person_off_rounded,
                        title: 'Tidak Ada Pelanggan',
                        message: 'Tidak ditemukan data yang sesuai dengan pencarian.',
                      )
                    : RefreshIndicator(
                        onRefresh: () => custProv.fetchCustomers(status: _selectedStatus, search: _searchController.text),
                        color: AppTheme.neonCyan,
                        backgroundColor: AppTheme.bgCard,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                          itemCount: custProv.customers.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final c = custProv.customers[index];
                            return ZzzCard(
                              padding: const EdgeInsets.all(12),
                              onTap: () {
                                SoundEffects.playTap();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => CustomerDetailScreen(customerId: c.id)),
                                );
                              },
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: c.isOnline
                                          ? AppTheme.neonGreen.withOpacity(0.12)
                                          : (c.isIsolated ? AppTheme.crimsonRed.withOpacity(0.12) : AppTheme.bgDark),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: c.isOnline
                                            ? AppTheme.neonGreen
                                            : (c.isIsolated ? AppTheme.crimsonRed : AppTheme.borderDark),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        (c.mikrotikUsername?.isNotEmpty == true && c.mikrotikUsername!.length >= 4)
                                            ? c.mikrotikUsername!.substring(0, 4)
                                            : c.name.substring(0, 1).toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                          color: c.isOnline ? AppTheme.neonGreen : AppTheme.textSilver,
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
                                          c.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppTheme.textWhite,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${c.odpName ?? "Tanpa ODP"} • ${c.packageName ?? "Paket Standard"}',
                                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                  StatusBadge(status: c.status),
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

  Widget _buildFilterChip(String label, String status) {
    final isSelected = _selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => _changeStatus(status),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.neonCyan.withOpacity(0.15) : AppTheme.bgCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppTheme.neonCyan : AppTheme.borderDark,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              color: isSelected ? AppTheme.neonCyan : AppTheme.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
