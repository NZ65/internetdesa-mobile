import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/status_badge.dart';

class CustomerDetailScreen extends StatefulWidget {
  final int customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerProvider>(context, listen: false).fetchCustomerDetail(widget.customerId);
    });
  }

  void _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _openWhatsApp(String phone) async {
    String clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.startsWith('0')) clean = '62${clean.substring(1)}';
    final uri = Uri.parse('https://wa.me/$clean');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _formatCurrency(dynamic amount) {
    final num val = (amount is num) ? amount : (num.tryParse(amount.toString()) ?? 0);
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(val);
  }

  @override
  Widget build(BuildContext context) {
    final custProvider = Provider.of<CustomerProvider>(context);
    final c = custProvider.selectedCustomer;

    return Scaffold(
      appBar: AppBar(
        title: Text(c?.name ?? 'Detail Pelanggan'),
      ),
      body: custProvider.isLoadingDetail || c == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              c.custId,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                            ),
                            StatusBadge(status: c.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          c.name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          c.address.isNotEmpty ? c.address : 'Alamat belum diatur',
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),

                        // Action Buttons (Call / WA)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: c.phone.isNotEmpty ? () => _callPhone(c.phone) : null,
                                icon: const Icon(Icons.phone, size: 18),
                                label: const Text('Telepon'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: c.phone.isNotEmpty ? () => _openWhatsApp(c.phone) : null,
                                icon: const Icon(Icons.chat, size: 18),
                                label: const Text('WhatsApp'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF25D366),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                const Text('Informasi Jaringan & Paket', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                // Network & WiFi Info Card
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.speed),
                        title: const Text('Paket Berlangganan'),
                        subtitle: Text('${c.packageName ?? "Default"} • ${_formatCurrency(c.packagePrice ?? 0)}/bln'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.account_tree_outlined),
                        title: const Text('PPPoE Username'),
                        subtitle: Text(c.mikrotikUsername ?? '-'),
                        trailing: IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: c.mikrotikUsername ?? ''));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PPPoE disalin')));
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.wifi),
                        title: const Text('Nama Wi-Fi (SSID)'),
                        subtitle: Text(c.wifiSsid ?? 'Default SSID'),
                        trailing: Text(
                          c.wifiPassword != null ? 'Pass: ${c.wifiPassword}' : 'Tanpa Pass',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                const Text('Riwayat Tagihan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                // Invoices History
                if (custProvider.selectedCustomerInvoices.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Text('Belum ada riwayat tagihan', style: TextStyle(color: Colors.grey[600])),
                      ),
                    ),
                  )
                else
                  ...custProvider.selectedCustomerInvoices.map((inv) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: inv.isPaid ? AppTheme.accentGreen.withOpacity(0.12) : AppTheme.accentRed.withOpacity(0.12),
                          child: Icon(
                            inv.isPaid ? Icons.check : Icons.receipt_long,
                            color: inv.isPaid ? AppTheme.accentGreen : AppTheme.accentRed,
                            size: 20,
                          ),
                        ),
                        title: Text(inv.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text('Jatuh Tempo: ${inv.dueDate ?? "-"}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatCurrency(inv.total),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            StatusBadge(status: inv.status),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
    );
  }
}
