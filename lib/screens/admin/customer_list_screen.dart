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

  void _openWhatsApp(String phone, String name) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final waPhone = cleanPhone.startsWith('0') ? '62${cleanPhone.substring(1)}' : (cleanPhone.startsWith('8') ? '62$cleanPhone' : cleanPhone);
    final msg = Uri.encodeComponent('Halo Kak $name, dari layanan Internet Desa Sukorejo...');
    final uri = Uri.parse('https://wa.me/$waPhone?text=$msg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final custProvider = Provider.of<CustomerProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Pelanggan & Jaringan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan',
            onPressed: _loadCustomers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama, ID, no HP, atau PPPoE...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
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
                _buildFilterChip('Semua Pelanggan', 'all', count: null),
                const SizedBox(width: 8),
                _buildFilterChip('Aktif', 'active', count: null),
                const SizedBox(width: 8),
                _buildFilterChip('Isolir / Nunggak', 'isolated', count: null),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Pasang Baru',
                  'pasang_baru',
                  count: custProvider.pendingCount > 0 ? custProvider.pendingCount : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Divider(height: 1),

          // Customer List
          Expanded(
            child: custProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : custProvider.customers.isEmpty
                    ? EmptyState(
                        icon: Icons.people_outline_rounded,
                        title: _selectedStatus == 'pasang_baru'
                            ? 'Tidak Ada Antrean Pasang Baru'
                            : 'Pelanggan Tidak Ditemukan',
                        message: _selectedStatus == 'pasang_baru'
                            ? 'Seluruh calon pelanggan telah berhasil dipasang & diaktivasi.'
                            : 'Coba ubah kata kunci pencarian atau filter status pelanggan.',
                        onRetry: _loadCustomers,
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _loadCustomers(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: custProvider.customers.length,
                          itemBuilder: (context, index) {
                            final c = custProvider.customers[index];
                            final isPasang = c.isPasangBaru;
                            final isIso = c.isIsolated;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF131C2E) : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isPasang
                                      ? AppTheme.accentOrange.withOpacity(0.5)
                                      : (isIso
                                          ? AppTheme.accentRed.withOpacity(0.35)
                                          : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0))),
                                  width: isPasang ? 1.5 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(isDark ? 0.35 : 0.04),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    if (isPasang) {
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
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 22,
                                              backgroundColor: isPasang
                                                  ? AppTheme.accentOrange.withOpacity(0.15)
                                                  : (isIso
                                                      ? AppTheme.accentRed.withOpacity(0.15)
                                                      : AppTheme.primaryBlue.withOpacity(0.15)),
                                              child: Icon(
                                                isPasang
                                                    ? Icons.person_add_alt_1_rounded
                                                    : (isIso ? Icons.lock_clock_rounded : Icons.wifi_rounded),
                                                color: isPasang
                                                    ? AppTheme.accentOrange
                                                    : (isIso ? AppTheme.accentRed : AppTheme.primaryBlue),
                                                size: 22,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    c.name,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w900,
                                                      fontSize: 15,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                                        decoration: BoxDecoration(
                                                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: Text(
                                                          c.custId,
                                                          style: TextStyle(
                                                            fontSize: 10.5,
                                                            fontFamily: 'monospace',
                                                            fontWeight: FontWeight.bold,
                                                            color: isDark ? Colors.grey[300] : const Color(0xFF475569),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Expanded(
                                                        child: Text(
                                                          c.packageName ?? 'Paket Internet',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            StatusBadge(status: c.status),
                                          ],
                                        ),
                                        if (c.address.isNotEmpty) ...[
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  c.address,
                                                  style: TextStyle(
                                                    fontSize: 11.5,
                                                    color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                        const SizedBox(height: 10),
                                        const Divider(height: 1),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'IP: ${c.ipAddress.isNotEmpty ? c.ipAddress : "-"}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                if (c.phone.isNotEmpty) ...[
                                                  IconButton(
                                                    icon: const Icon(Icons.chat_bubble_rounded, color: Color(0xFF25D366), size: 18),
                                                    tooltip: 'Chat WhatsApp',
                                                    padding: EdgeInsets.zero,
                                                    constraints: const BoxConstraints(),
                                                    onPressed: () => _openWhatsApp(c.phone, c.name),
                                                  ),
                                                  const SizedBox(width: 14),
                                                ],
                                                Icon(
                                                  isPasang ? Icons.info_outline_rounded : Icons.arrow_forward_ios_rounded,
                                                  size: 14,
                                                  color: isPasang ? AppTheme.accentOrange : (isDark ? Colors.grey[500] : Colors.grey[400]),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.person_add_alt_1_rounded, color: AppTheme.accentOrange),
            SizedBox(width: 8),
            Expanded(
              child: Text('Calon Pasang Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama: ${c.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 6),
            Text('No Antrean: ${c.custId}'),
            const SizedBox(height: 4),
            Text('No HP: ${c.phone.isNotEmpty ? c.phone : "-"}'),
            const SizedBox(height: 4),
            Text('Paket: ${c.packageName ?? "Paket Internet"}'),
            const SizedBox(height: 4),
            Text('Alamat: ${c.address.isNotEmpty ? c.address : "-"}'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.accentOrange.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accentOrange.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: AppTheme.accentOrange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Menunggu penarikan dropcore & aktivasi modem oleh teknisi.',
                      style: TextStyle(fontSize: 11.5, color: AppTheme.accentOrange, fontWeight: FontWeight.w600),
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
              onPressed: () => _openWhatsApp(c.phone, c.name),
              icon: const Icon(Icons.chat_bubble_rounded, color: Color(0xFF25D366), size: 18),
              label: const Text('Chat WA', style: TextStyle(color: Color(0xFF25D366), fontWeight: FontWeight.bold)),
            ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, {int? count}) {
    final isSelected = _selectedStatus == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : const Color(0xFF475569)),
            ),
          ),
          if (count != null && count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.3) : AppTheme.accentOrange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppTheme.accentOrange,
                ),
              ),
            ),
          ],
        ],
      ),
      selected: isSelected,
      selectedColor: AppTheme.primaryBlue,
      backgroundColor: isDark ? const Color(0xFF131C2E) : const Color(0xFFF1F5F9),
      side: BorderSide(
        color: isSelected
            ? AppTheme.primaryBlue
            : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (val) {
        if (val) {
          setState(() => _selectedStatus = value);
          _loadCustomers();
        }
      },
    );
  }
}
