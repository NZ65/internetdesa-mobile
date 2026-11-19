import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../models/customer_model.dart';
import '../../models/invoice_model.dart';
import '../../models/registration_model.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/bouncing_button.dart';
import '../../widgets/status_badge.dart';
import 'invoice_pay_dialog.dart';

class CustomerDetailScreen extends StatefulWidget {
  final int customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  bool _showWifiPassword = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final custProvider = Provider.of<CustomerProvider>(context, listen: false);
    custProvider.fetchCustomerDetail(widget.customerId);
    custProvider.fetchPackages();
  }

  void _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _openWhatsApp(String phone, String name) async {
    String clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.startsWith('0')) clean = '62${clean.substring(1)}';
    if (clean.startsWith('8')) clean = '62$clean';
    final msg = Uri.encodeComponent('Halo Kak $name, dari tim teknis Internet Desa Sukorejo...');
    final uri = Uri.parse('https://wa.me/$clean?text=$msg');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label berhasil disalin'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _copyAllCustomerDetails(CustomerModel c) {
    final text = '''
*DETAIL PELANGGAN INTERNET DESA*
ID: ${c.custId}
Nama: ${c.name}
No HP: ${c.phone}
Alamat: ${c.address}
Paket: ${c.packageName ?? '-'} (${_formatCurrency(c.packagePrice ?? 0)}/bln)
Status: ${c.status.toUpperCase()}
Tgl Tagihan: Tgl ${c.billingDate ?? 1} tiap bulan
PPPoE: ${c.mikrotikUsername ?? '-'}
Wi-Fi: ${c.wifiSsid ?? '-'} / Pass: ${c.wifiPassword ?? '-'}
ODP: ${c.odpName ?? '-'} (Port: ${c.odpPort ?? '-'})
''';
    _copyToClipboard(text.trim(), 'Data lengkap pelanggan');
  }

  String _formatCurrency(dynamic amount) {
    final num val = (amount is num) ? amount : (num.tryParse(amount.toString()) ?? 0);
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(val);
  }

  void _openPayDialog(InvoiceModel invoice) async {
    final res = await showDialog(
      context: context,
      builder: (_) => InvoicePayDialog(invoice: invoice),
    );
    if (res == true) {
      _loadData();
    }
  }

  void _showDeleteDialog(CustomerModel c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentRed.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_forever_rounded, color: AppTheme.accentRed, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Hapus Pelanggan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus pelanggan "${c.name}" (${c.custId})?\n\n'
          'Tindakan ini akan menghapus akun PPPoE dari router MikroTik serta riwayat tagihannya.',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final custProvider = Provider.of<CustomerProvider>(context, listen: false);
              final res = await custProvider.deleteCustomer(c.id);
              if (mounted) {
                if (res['success'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(res['message']),
                      backgroundColor: AppTheme.accentGreen,
                    ),
                  );
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(res['message']),
                      backgroundColor: AppTheme.accentRed,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus Permanen'),
          ),
        ],
      ),
    );
  }

  void _showEditCustomerModal(CustomerModel c) {
    final custProvider = Provider.of<CustomerProvider>(context, listen: false);
    final packages = custProvider.packages;

    final nameCtrl = TextEditingController(text: c.name);
    final phoneCtrl = TextEditingController(text: c.phone);
    final addressCtrl = TextEditingController(text: c.address);
    final billingDateCtrl = TextEditingController(text: (c.billingDate ?? 1).toString());
    final wifiSsidCtrl = TextEditingController(text: c.wifiSsid ?? '');
    final wifiPassCtrl = TextEditingController(text: c.wifiPassword ?? '');
    final odpNameCtrl = TextEditingController(text: c.odpName ?? '');
    final odpPortCtrl = TextEditingController(text: c.odpPort ?? '');
    final notesCtrl = TextEditingController(text: c.notes ?? '');

    int? selectedPackageId = c.packageId;
    String selectedStatus = c.status;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bCtx) {
        final isDark = Theme.of(bCtx).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(bCtx).size.height * 0.88,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131C2E) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.danaPrimaryBlue.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.edit_note_rounded, color: AppTheme.danaPrimaryBlue, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Edit Data Pelanggan',
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  c.custId,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(bCtx),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Form Fields Scrollable
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      children: [
                        const Text(
                          'INFORMASI UTAMA',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: AppTheme.danaPrimaryBlue),
                        ),
                        const SizedBox(height: 12),

                        // Nama
                        TextField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nama Lengkap Pelanggan *',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Telepon / WA
                        TextField(
                          controller: phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Nomor WhatsApp / HP *',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Alamat
                        TextField(
                          controller: addressCtrl,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Alamat Lengkap *',
                            prefixIcon: Icon(Icons.home_outlined),
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'LAYANAN & TAGIHAN',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: AppTheme.danaPrimaryBlue),
                        ),
                        const SizedBox(height: 12),

                        // Paket Dropdown
                        if (packages.isNotEmpty)
                          DropdownButtonFormField<int>(
                            value: packages.any((p) => p.id == selectedPackageId) ? selectedPackageId : null,
                            decoration: const InputDecoration(
                              labelText: 'Paket Berlangganan',
                              prefixIcon: Icon(Icons.speed_rounded),
                            ),
                            items: packages.map((pkg) {
                              return DropdownMenuItem<int>(
                                value: pkg.id,
                                child: Text('${pkg.name} • ${_formatCurrency(pkg.price)}'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setModalState(() => selectedPackageId = val);
                            },
                          ),
                        const SizedBox(height: 14),

                        // Status & Billing Day Row
                        Row(
                          children: [
                            // Status
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<String>(
                                value: ['active', 'isolated', 'inactive'].contains(selectedStatus) ? selectedStatus : 'active',
                                decoration: const InputDecoration(
                                  labelText: 'Status Layanan',
                                  prefixIcon: Icon(Icons.toggle_on_outlined),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'active', child: Text('Aktif (Online)')),
                                  DropdownMenuItem(value: 'isolated', child: Text('Isolir (Tunggakan)')),
                                  DropdownMenuItem(value: 'inactive', child: Text('Nonaktif (Putus)')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setModalState(() => selectedStatus = val);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Tanggal Tagihan
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: billingDateCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Tgl Tagih (1-28)',
                                  prefixIcon: Icon(Icons.calendar_month_outlined),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'WI-FI & AKSES JARINGAN',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: AppTheme.danaPrimaryBlue),
                        ),
                        const SizedBox(height: 12),

                        // SSID Wi-Fi
                        TextField(
                          controller: wifiSsidCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nama Wi-Fi (SSID)',
                            prefixIcon: Icon(Icons.wifi_rounded),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Password Wi-Fi
                        TextField(
                          controller: wifiPassCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Password Wi-Fi',
                            prefixIcon: Icon(Icons.lock_outline_rounded),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ODP & Port Row
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: odpNameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Nama ODP',
                                  prefixIcon: Icon(Icons.device_hub_rounded),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: odpPortCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Port ODP',
                                  prefixIcon: Icon(Icons.alt_route_rounded),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Catatan
                        TextField(
                          controller: notesCtrl,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Catatan Tambahan',
                            prefixIcon: Icon(Icons.notes_rounded),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Save Button
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF131C2E) : Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                    child: SafeArea(
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  final name = nameCtrl.text.trim();
                                  if (name.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Nama pelanggan wajib diisi!')),
                                    );
                                    return;
                                  }

                                  setModalState(() => isSaving = true);

                                  final updateData = {
                                    'name': name,
                                    'phone': phoneCtrl.text.trim(),
                                    'address': addressCtrl.text.trim(),
                                    'package_id': selectedPackageId,
                                    'status': selectedStatus,
                                    'billing_date': int.tryParse(billingDateCtrl.text.trim()) ?? 1,
                                    'wifi_ssid': wifiSsidCtrl.text.trim(),
                                    'wifi_password': wifiPassCtrl.text.trim(),
                                    'odp_name': odpNameCtrl.text.trim(),
                                    'odp_port': odpPortCtrl.text.trim(),
                                    'notes': notesCtrl.text.trim(),
                                  };

                                  final res = await custProvider.updateCustomer(
                                    id: c.id,
                                    data: updateData,
                                  );

                                  if (mounted) {
                                    Navigator.pop(bCtx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(res['message']),
                                        backgroundColor: res['success'] ? AppTheme.accentGreen : AppTheme.accentRed,
                                      ),
                                    );
                                    _loadData();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.danaPrimaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text(
                                  'Simpan Perubahan',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final custProvider = Provider.of<CustomerProvider>(context);
    final c = custProvider.selectedCustomer;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      body: custProvider.isLoadingDetail || c == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // DANA Top Header Curved Banner
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    gradient: AppTheme.danaHeaderGradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                ),

                // Main Content
                SafeArea(
                  child: Column(
                    children: [
                      // Top App Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Expanded(
                              child: Text(
                                'Detail Pelanggan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                              tooltip: 'Segarkan Data',
                              onPressed: _loadData,
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: Colors.white),
                              tooltip: 'Edit Pelanggan',
                              onPressed: () => _showEditCustomerModal(c),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                              tooltip: 'Hapus Pelanggan',
                              onPressed: () => _showDeleteDialog(c),
                            ),
                          ],
                        ),
                      ),

                      // Scrollable Details
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          children: [
                            // DANA Hero Card: Customer Summary
                            _buildHeroCard(c, isDark),
                            const SizedBox(height: 16),

                            // DANA Quick Actions Bar
                            _buildQuickActions(c, isDark),
                            const SizedBox(height: 16),

                            // Network & Wi-Fi Details
                            _buildNetworkCard(c, isDark),
                            const SizedBox(height: 16),

                            // Invoices History
                            _buildInvoicesSection(custProvider.selectedCustomerInvoices, isDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeroCard(CustomerModel c, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131C2E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.danaPrimaryBlue.withOpacity(0.12),
                child: Text(
                  c.name.isNotEmpty ? c.name[0].toUpperCase() : 'P',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.danaPrimaryBlue,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Name & Cust ID
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.danaPrimaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            c.custId,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.danaPrimaryBlue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(status: c.status),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Address & Phone
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on_outlined, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  c.address.isNotEmpty ? c.address : 'Alamat belum diatur',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.phone_outlined, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                c.phone.isNotEmpty ? c.phone : 'Nomor belum diatur',
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(CustomerModel c, bool isDark) {
    return Row(
      children: [
        // Call Button
        Expanded(
          child: _buildActionButton(
            icon: Icons.phone_rounded,
            label: 'Telepon',
            color: const Color(0xFF118EEA),
            isDark: isDark,
            onTap: c.phone.isNotEmpty ? () => _callPhone(c.phone) : null,
          ),
        ),
        const SizedBox(width: 10),

        // WhatsApp Button
        Expanded(
          child: _buildActionButton(
            icon: Icons.chat_rounded,
            label: 'WhatsApp',
            color: const Color(0xFF25D366),
            isDark: isDark,
            onTap: c.phone.isNotEmpty ? () => _openWhatsApp(c.phone, c.name) : null,
          ),
        ),
        const SizedBox(width: 10),

        // Edit Button
        Expanded(
          child: _buildActionButton(
            icon: Icons.edit_note_rounded,
            label: 'Edit',
            color: const Color(0xFFFF8800),
            isDark: isDark,
            onTap: () => _showEditCustomerModal(c),
          ),
        ),
        const SizedBox(width: 10),

        // Copy Summary
        Expanded(
          child: _buildActionButton(
            icon: Icons.copy_all_rounded,
            label: 'Salin',
            color: const Color(0xFF8E44AD),
            isDark: isDark,
            onTap: () => _copyAllCustomerDetails(c),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback? onTap,
  }) {
    return BouncingButton(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131C2E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: onTap == null ? Colors.grey : (isDark ? Colors.white : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkCard(CustomerModel c, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131C2E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.pastelBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.wifi_tethering_rounded, color: AppTheme.danaPrimaryBlue, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Informasi Jaringan & Paket',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Paket Berlangganan
          _buildInfoRow(
            icon: Icons.speed_rounded,
            title: 'Paket Berlangganan',
            value: '${c.packageName ?? "Default"} (${_formatCurrency(c.packagePrice ?? 0)}/bln)',
            isDark: isDark,
          ),
          const Divider(height: 20),

          // Tanggal Tagihan
          _buildInfoRow(
            icon: Icons.calendar_today_rounded,
            title: 'Siklus Penagihan',
            value: 'Tgl ${c.billingDate ?? 1} setiap bulan',
            isDark: isDark,
          ),
          const Divider(height: 20),

          // PPPoE Username
          _buildInfoRow(
            icon: Icons.account_circle_outlined,
            title: 'PPPoE Username',
            value: c.mikrotikUsername ?? '-',
            isDark: isDark,
            trailing: c.mikrotikUsername != null && c.mikrotikUsername!.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    onPressed: () => _copyToClipboard(c.mikrotikUsername!, 'PPPoE Username'),
                  )
                : null,
          ),
          const Divider(height: 20),

          // Wi-Fi SSID
          _buildInfoRow(
            icon: Icons.wifi_rounded,
            title: 'Nama Wi-Fi (SSID)',
            value: c.wifiSsid ?? 'Default SSID',
            isDark: isDark,
            trailing: c.wifiSsid != null && c.wifiSsid!.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    onPressed: () => _copyToClipboard(c.wifiSsid!, 'SSID Wi-Fi'),
                  )
                : null,
          ),
          const Divider(height: 20),

          // Wi-Fi Password
          _buildInfoRow(
            icon: Icons.lock_outline_rounded,
            title: 'Password Wi-Fi',
            value: _showWifiPassword ? (c.wifiPassword ?? 'Tanpa Password') : '••••••••',
            isDark: isDark,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(_showWifiPassword ? Icons.visibility_off : Icons.visibility, size: 18),
                  onPressed: () => setState(() => _showWifiPassword = !_showWifiPassword),
                ),
                if (c.wifiPassword != null && c.wifiPassword!.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    onPressed: () => _copyToClipboard(c.wifiPassword!, 'Password Wi-Fi'),
                  ),
              ],
            ),
          ),

          if (c.odpName != null && c.odpName!.isNotEmpty) ...[
            const Divider(height: 20),
            _buildInfoRow(
              icon: Icons.alt_route_rounded,
              title: 'Titik ODP',
              value: '${c.odpName} (Port: ${c.odpPort ?? "-"})',
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    required bool isDark,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildInvoicesSection(List<InvoiceModel> invoices, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131C2E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.pastelGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: AppTheme.accentGreen, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Riwayat Tagihan',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                '${invoices.length} Tagihan',
                style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (invoices.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text('Belum ada riwayat tagihan', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: invoices.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final inv = invoices[index];
                final isPaid = inv.isPaid;

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: isPaid ? AppTheme.accentGreen.withOpacity(0.12) : AppTheme.accentRed.withOpacity(0.12),
                      child: Icon(
                        isPaid ? Icons.check_rounded : Icons.priority_high_rounded,
                        color: isPaid ? AppTheme.accentGreen : AppTheme.accentRed,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            inv.invoiceNumber,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Jatuh Tempo: ${inv.dueDate ?? "-"}',
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatCurrency(inv.total),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        if (!isPaid)
                          SizedBox(
                            height: 26,
                            child: ElevatedButton(
                              onPressed: () => _openPayDialog(inv),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.danaPrimaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Bayar'),
                            ),
                          )
                        else
                          StatusBadge(status: inv.status),
                      ],
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
