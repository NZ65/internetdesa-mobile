import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../models/customer_model.dart';
import '../../models/invoice_model.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';
import 'customer_detail_screen.dart';
import 'invoice_pay_dialog.dart';

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

  String _formatCurrency(dynamic amount) {
    final num val = (amount is num) ? amount : (num.tryParse(amount?.toString() ?? '0') ?? 0);
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(val);
  }

  void _openWhatsApp(String phone, String name) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final waPhone = cleanPhone.startsWith('0') ? '62${cleanPhone.substring(1)}' : (cleanPhone.startsWith('8') ? '62$cleanPhone' : cleanPhone);
    final msg = Uri.encodeComponent('Halo Kak $name, dari tim teknisi Internet Desa Sukorejo...');
    final uri = Uri.parse('https://wa.me/$waPhone?text=$msg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _sendWhatsAppReminder(CustomerModel c) async {
    final cleanPhone = c.phone.replaceAll(RegExp(r'[^0-9]'), '');
    final waPhone = cleanPhone.startsWith('0') ? '62${cleanPhone.substring(1)}' : (cleanPhone.startsWith('8') ? '62$cleanPhone' : cleanPhone);
    final amountStr = _formatCurrency(c.unpaidAmount ?? c.packagePrice ?? 110000);
    final dueStr = c.earliestDueDate != null ? ' (Jatuh Tempo: ${c.earliestDueDate})' : '';
    final msg = Uri.encodeComponent(
      'Halo Bpk/Ibu ${c.name}, kami menginformasikan tagihan Internet Desa ID: ${c.custId} sebesar $amountStr$dueStr belum lunas. Pembayaran dapat diserahkan ke kantor desa atau via transfer. Abaikan jika sudah membayar. Terima kasih! 🙏',
    );
    final uri = Uri.parse('https://wa.me/$waPhone?text=$msg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _callPhone(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openMaps(double? lat, double? lng, String address) async {
    if (lat != null && lng != null && lat != 0.0 && lng != 0.0) {
      final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openDirectPayDialog(CustomerModel c) async {
    final dummyInvoice = InvoiceModel(
      id: c.unpaidInvoiceId ?? 0,
      invoiceNumber: 'INV-${c.custId}',
      customerId: c.id,
      customerName: c.name,
      period: c.earliestDueDate ?? 'Bulan Berjalan',
      total: c.unpaidAmount ?? c.packagePrice ?? 110000,
      status: 'unpaid',
      dueDate: c.earliestDueDate ?? '',
      createdAt: '',
    );

    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => InvoicePayDialog(invoice: dummyInvoice),
    );

    if (res == true) {
      _loadCustomers();
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
          // Search Header
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
                _buildFilterChip(
                  'Belum Bayar',
                  'unpaid',
                  count: custProvider.unpaidCount > 0 ? custProvider.unpaidCount : null,
                  badgeColor: AppTheme.accentRed,
                ),
                const SizedBox(width: 8),
                _buildFilterChip('Aktif', 'active', count: null),
                const SizedBox(width: 8),
                _buildFilterChip('Isolir / Nunggak', 'isolated', count: null),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Pasang Baru',
                  'pasang_baru',
                  count: custProvider.pendingCount > 0 ? custProvider.pendingCount : null,
                  badgeColor: AppTheme.accentOrange,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Divider(height: 1),

          // Customer List
          Expanded(
            child: custProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : custProvider.customers.isEmpty
                    ? EmptyState(
                        icon: _selectedStatus == 'unpaid'
                            ? Icons.verified_rounded
                            : (_selectedStatus == 'pasang_baru'
                                ? Icons.people_outline_rounded
                                : Icons.people_outline_rounded),
                        title: _selectedStatus == 'unpaid'
                            ? 'Alhamdulillah, Semua Lunas!'
                            : (_selectedStatus == 'pasang_baru'
                                ? 'Tidak Ada Antrean Pasang Baru'
                                : 'Pelanggan Tidak Ditemukan'),
                        message: _selectedStatus == 'unpaid'
                            ? 'Seluruh pelanggan saat ini telah melunasi tagihan internet desa.'
                            : (_selectedStatus == 'pasang_baru'
                                ? 'Seluruh calon pelanggan telah berhasil dipasang & diaktivasi.'
                                : 'Coba ubah kata kunci pencarian atau filter status pelanggan.'),
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
                            final isUnpaidCust = c.isUnpaid || _selectedStatus == 'unpaid';

                            // 1. KARTU KHUSUS PELANGGAN BELUM BAYAR (UNPAID)
                            if (isUnpaidCust && !isPasang) {
                              return _buildUnpaidCustomerCard(context, c, isDark);
                            }

                            // 2. KARTU KHUSUS ANTREAN PASANG BARU
                            if (isPasang) {
                              return _buildPasangBaruCard(context, c, isDark);
                            }

                            // 3. KARTU PELANGGAN REGULER (AKTIF / ISOLIR)
                            return _buildRegularCustomerCard(context, c, isDark, isIso);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET KARTU 1: PELANGGAN BELUM BAYAR (UNPAID)
  // ==========================================
  Widget _buildUnpaidCustomerCard(BuildContext context, CustomerModel c, bool isDark) {
    final unpaidTotal = c.unpaidAmount ?? c.packagePrice ?? 110000;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1420) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentRed.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentRed.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CustomerDetailScreen(customerId: c.id)),
            );
            _loadCustomers();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppTheme.accentRed.withOpacity(0.15),
                      child: const Icon(Icons.receipt_long_rounded, color: AppTheme.accentRed, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  c.name,
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentRed.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'BELUM LUNAS',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.accentRed,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'ID: ${c.custId} • ${c.packageName ?? "Paket Internet"}',
                            style: TextStyle(fontSize: 11.5, color: isDark ? Colors.grey[400] : const Color(0xFF64748B), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Box Tagihan Nominal & Jatuh Tempo
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A1B28) : const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.accentRed.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Tagihan Belum Bayar', style: TextStyle(fontSize: 10.5, color: AppTheme.accentRed, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(
                            _formatCurrency(unpaidTotal),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.accentRed),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Jatuh Tempo', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(
                            c.earliestDueDate ?? 'Tgl ${c.billingDate ?? 20}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : const Color(0xFF334155)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                if (c.address.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          c.address,
                          style: TextStyle(fontSize: 11.5, color: isDark ? Colors.grey[400] : const Color(0xFF64748B)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // Direct Action Buttons for Unpaid Customers
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: c.phone.isNotEmpty ? () => _sendWhatsAppReminder(c) : null,
                        icon: const Icon(Icons.chat_bubble_rounded, size: 15, color: Color(0xFF25D366)),
                        label: const Text('Ingatkan WA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF25D366))),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF25D366)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openDirectPayDialog(c),
                        icon: const Icon(Icons.payments_rounded, size: 15, color: Colors.white),
                        label: const Text('Catat Bayar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B074),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET KARTU 2: ANTREAN PASANG BARU
  // ==========================================
  Widget _buildPasangBaruCard(BuildContext context, CustomerModel c, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F1A14) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentOrange.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentOrange.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showPasangBaruDialog(context, c),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppTheme.accentOrange.withOpacity(0.15),
                      child: const Icon(Icons.person_add_alt_1_rounded, color: AppTheme.accentOrange, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  c.name,
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentOrange.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'PASANG BARU',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.accentOrange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'No Antrean: ${c.custId} • ${c.packageName ?? "Paket Internet"}',
                            style: TextStyle(fontSize: 11.5, color: isDark ? Colors.grey[400] : const Color(0xFF64748B), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Info Paket & Status
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF282016) : const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.accentOrange.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt_rounded, size: 16, color: AppTheme.accentOrange),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Pilihan: ${c.packageName ?? "Paket Standar"} • ${_formatCurrency(c.packagePrice ?? 110000)}/bln',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.accentOrange),
                        ),
                      ),
                    ],
                  ),
                ),

                if (c.address.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          c.address,
                          style: TextStyle(fontSize: 11.5, color: isDark ? Colors.grey[400] : const Color(0xFF64748B)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // Direct Action Buttons for Pasang Baru
                Row(
                  children: [
                    if (c.phone.isNotEmpty) ...[
                      IconButton.filledTonal(
                        onPressed: () => _callPhone(c.phone),
                        icon: const Icon(Icons.phone_rounded, size: 16, color: AppTheme.primaryBlue),
                        tooltip: 'Telepon Langsung',
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.primaryLight,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: () => _openWhatsApp(c.phone, c.name),
                        icon: const Icon(Icons.chat_bubble_rounded, size: 16, color: Color(0xFF25D366)),
                        tooltip: 'Chat WhatsApp',
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFE8F5E9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openMaps(c.latitude, c.longitude, c.address),
                        icon: const Icon(Icons.map_rounded, size: 15, color: AppTheme.primaryBlue),
                        label: const Text('Buka Peta', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showPasangBaruDialog(context, c),
                        icon: const Icon(Icons.bolt_rounded, size: 15, color: Colors.white),
                        label: const Text('Aktivasi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentOrange,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET KARTU 3: PELANGGAN REGULER (AKTIF / ISOLIR)
  // ==========================================
  Widget _buildRegularCustomerCard(BuildContext context, CustomerModel c, bool isDark, bool isIso) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131C2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isIso ? AppTheme.accentRed.withOpacity(0.35) : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          width: 1,
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
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CustomerDetailScreen(customerId: c.id)),
            );
            _loadCustomers();
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
                      backgroundColor: isIso ? AppTheme.accentRed.withOpacity(0.15) : AppTheme.primaryBlue.withOpacity(0.15),
                      child: Icon(
                        isIso ? Icons.lock_clock_rounded : Icons.wifi_rounded,
                        color: isIso ? AppTheme.accentRed : AppTheme.primaryBlue,
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
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
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
                          style: TextStyle(fontSize: 11.5, color: isDark ? Colors.grey[400] : const Color(0xFF64748B)),
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
                      'PPPoE: ${c.mikrotikUsername ?? "-"}',
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
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
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

  Widget _buildFilterChip(String label, String value, {int? count, Color? badgeColor}) {
    final isSelected = _selectedStatus == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bColor = badgeColor ?? (isSelected ? Colors.white : AppTheme.primaryBlue);

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
                color: isSelected ? Colors.white.withOpacity(0.3) : bColor.withOpacity(0.18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : bColor,
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
