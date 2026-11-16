import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
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
                        title: 'Pelanggan Tidak Ditemukan',
                        message: 'Coba ubah kata kunci pencarian atau filter status.',
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
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor: c.isIsolated
                                      ? AppTheme.accentRed.withOpacity(0.12)
                                      : AppTheme.accentGreen.withOpacity(0.12),
                                  child: Icon(
                                    c.isIsolated ? Icons.block : Icons.wifi,
                                    color: c.isIsolated ? AppTheme.accentRed : AppTheme.accentGreen,
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
                                      '${c.custId} • ${c.packageName ?? "Paket"}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    if (c.odpName != null && c.odpName!.isNotEmpty)
                                      Text(
                                        'ODP: ${c.odpName} (Port ${c.odpPort ?? "-"})',
                                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                      ),
                                  ],
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CustomerDetailScreen(customerId: c.id),
                                    ),
                                  );
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
