import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/customer_model.dart';
import '../../providers/customer_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../widgets/empty_state.dart';

class QuickToolsScreen extends StatefulWidget {
  const QuickToolsScreen({super.key});

  @override
  State<QuickToolsScreen> createState() => _QuickToolsScreenState();
}

class _QuickToolsScreenState extends State<QuickToolsScreen> {
  final _searchController = TextEditingController();
  CustomerModel? _selectedCustomer;
  bool _isRebooting = false;

  void _searchCustomer() async {
    final term = _searchController.text.trim();
    if (term.isEmpty) return;

    final custProvider = Provider.of<CustomerProvider>(context, listen: false);
    await custProvider.fetchCustomers(search: term);

    if (custProvider.customers.isNotEmpty) {
      setState(() {
        _selectedCustomer = custProvider.customers.first;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pelanggan tidak ditemukan.')),
        );
      }
    }
  }

  void _rebootModem() async {
    if (_selectedCustomer == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Reboot Modem'),
        content: Text('Apakah Anda yakin ingin mengirim sinyal reboot ke ONT milik ${_selectedCustomer!.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            child: const Text('Reboot'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isRebooting = true);

    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final res = await ticketProvider.quickReboot(_selectedCustomer!.id);

    setState(() => _isRebooting = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['message']),
        backgroundColor: res['success'] ? AppTheme.accentGreen : AppTheme.accentRed,
      ),
    );
  }

  void _openChangeWifiDialog() {
    if (_selectedCustomer == null) return;

    final ssidController = TextEditingController(text: _selectedCustomer!.wifiSsid ?? '');
    final passController = TextEditingController(text: _selectedCustomer!.wifiPassword ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ganti Nama & Sandi Wi-Fi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pelanggan: ${_selectedCustomer!.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: ssidController,
              decoration: const InputDecoration(labelText: 'Nama Wi-Fi (SSID)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passController,
              decoration: const InputDecoration(labelText: 'Password Wi-Fi Baru'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final newSsid = ssidController.text.trim();
              final newPass = passController.text.trim();
              if (newSsid.isEmpty || newPass.isEmpty) return;

              Navigator.pop(ctx);
              final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
              final res = await ticketProvider.quickWifi(
                customerId: _selectedCustomer!.id,
                ssid: newSsid,
                password: newPass,
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(res['message']),
                    backgroundColor: res['success'] ? AppTheme.accentGreen : AppTheme.accentRed,
                  ),
                );
              }
            },
            child: const Text('Terapkan ke Modem'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alat Diagnostik & Remote ONT'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Search Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pilih Target Pelanggan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Ketik nama / PPPoE...',
                            prefixIcon: Icon(Icons.search),
                          ),
                          onSubmitted: (_) => _searchCustomer(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _searchCustomer,
                        icon: const Icon(Icons.arrow_forward),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Customer Profile Selected
          if (_selectedCustomer != null) ...[
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
                          _selectedCustomer!.custId,
                          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                        ),
                        Text('PPPoE: ${_selectedCustomer!.mikrotikUsername ?? "-"}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedCustomer!.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _selectedCustomer!.address,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.wifi, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'SSID: ${_selectedCustomer!.wifiSsid ?? "Belum Diatur"}\nPass: ${_selectedCustomer!.wifiPassword ?? "Default"}',
                              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text('Aksi Remote TR-069 & OLT OMCI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),

            // Remote Reboot Action Button
            ElevatedButton.icon(
              onPressed: _isRebooting ? null : _rebootModem,
              icon: _isRebooting
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.restart_alt),
              label: Text(_isRebooting ? 'Mengirim Sinyal Reboot...' : 'Reboot Modem Jarak Jauh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentOrange,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            // Change WiFi Action Button
            ElevatedButton.icon(
              onPressed: _openChangeWifiDialog,
              icon: const Icon(Icons.wifi_password),
              label: const Text('Ganti Nama & Password WiFi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ] else ...[
            const SizedBox(height: 32),
            const EmptyState(
              icon: Icons.router_outlined,
              title: 'Cari Pelanggan Terlebih Dahulu',
              message: 'Gunakan kotak pencarian di atas untuk memilih ONT modem pelanggan yang ingin di-reboot atau diganti Wi-Fi nya.',
            ),
          ],
        ],
      ),
    );
  }
}
