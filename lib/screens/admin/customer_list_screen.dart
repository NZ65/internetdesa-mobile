import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../models/customer_model.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';
import 'customer_detail_screen.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final _searchController = TextEditingController();
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCustomers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadCustomers() {
    Provider.of<CustomerProvider>(context, listen: false).fetchCustomers(
      search: _searchController.text.trim(),
      status: _selectedStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    final custProvider = Provider.of<CustomerProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Pelanggan'),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama, ID, no HP, atau PPPoE...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadCustomers();
                        },
                      )
                    : null,
              ),
              onSubmitted: (_) => _loadCustomers(),
            ),
          ),

          // Status Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildFilterChip('Semua', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Aktif', 'active'),
                const SizedBox(width: 8),
                _buildFilterChip('Isolir / Nunggak', 'isolated'),
                const SizedBox(width: 8),
                _buildFilterChip(
                  custProvider.pendingCount > 0 ? 'Pasang Baru (${custProvider.pendingCount})' : 'Pasang Baru',
                  'pasang_baru',
                ),
              ],
            ),
          ),
          const Divider(height: 16),

          // Customer List
          Expanded(
            child: custProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : custProvider.customers.isEmpty
                    ? EmptyState(
                        icon: Icons.people_outline,
                        title: _selectedStatus == 'pasang_baru' ? 'Tidak Ada Antrean Pasang Baru' : 'Pelanggan Tidak Ditemukan',
                        message: _selectedStatus == 'pasang_baru'
                            ? 'Seluruh calon pelanggan telah berhasil dipasang & diaktivasi.'
                            : 'Coba ubah kata kunci pencarian atau filter status.',
                        onRetry: _loadCustomers,
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _loadCustomers(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: custProvider.customers.length,
                          itemBuilder: (context, index) {
                            final c = custProvider.customers[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: c.isPasangBaru
                                    ? const BorderSide(color: Color(0xFFF59E0B), width: 1.5)
                                    : BorderSide.none,
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor: c.isPasangBaru
                                      ? const Color(0xFFF59E0B).withOpacity(0.15)
                                      : (c.isIsolated
                                          ? AppTheme.accentRed.withOpacity(0.12)
                                          : AppTheme.accentGreen.withOpacity(0.12)),
                                  child: Icon(
                                    c.isPasangBaru
                                        ? Icons.person_add_alt_1
                                        : (c.isIsolated ? Icons.block : Icons.wifi),
                                    color: c.isPasangBaru
                                        ? const Color(0xFFD97706)
                                        : (c.isIsolated ? AppTheme.accentRed : AppTheme.accentGreen),
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        c.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    StatusBadge(status: c.status),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      '${c.custId} • ${c.packageName ?? "Paket Internet"}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    if (c.address.isNotEmpty)
                                      Text(
                                        c.address,
                                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                                trailing: c.isPasangBaru
                                    ? const Icon(Icons.info_outline, color: Color(0xFFD97706))
                                    : const Icon(Icons.chevron_right),
                                onTap: () {
                                  if (c.isPasangBaru) {
                                    _showPasangBaruDialog(context, c);
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CustomerDetailScreen(customerId: c.id),
                                      ),
                                    );
                                  }
                                },
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

  void _showPasangBaruDialog(BuildContext context, CustomerModel c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.person_add_alt_1, color: Color(0xFFD97706)),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Calon Pelanggan Pasang Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama: ${c.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            Text('No Antrean: ${c.custId}'),
            const SizedBox(height: 4),
            Text('No HP: ${c.phone.isNotEmpty ? c.phone : "-"}'),
            const SizedBox(height: 4),
            Text('Paket: ${c.packageName ?? "Paket Internet"}'),
            const SizedBox(height: 4),
            Text('Alamat: ${c.address.isNotEmpty ? c.address : "-"}'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Color(0xFFB45309)),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Menunggu penarikan dropcore & aktivasi teknisi.',
                      style: TextStyle(fontSize: 11, color: Color(0xFFB45309)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (c.phone.isNotEmpty)
            TextButton.icon(
              onPressed: () async {
                final cleanPhone = c.phone.replaceAll(RegExp(r'[^0-9]'), '');
                final waPhone = cleanPhone.startsWith('0') ? '62${cleanPhone.substring(1)}' : cleanPhone;
                final uri = Uri.parse('https://wa.me/$waPhone');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.chat, color: Colors.green),
              label: const Text('Chat WhatsApp', style: TextStyle(color: Colors.green)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedStatus == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) {
          setState(() => _selectedStatus = value);
          _loadCustomers();
        }
      },
    );
  }
}
