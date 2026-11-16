import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../models/ticket_model.dart';
import '../../providers/ticket_provider.dart';
import '../../widgets/status_badge.dart';

class TicketDetailScreen extends StatefulWidget {
  final TicketModel ticket;

  const TicketDetailScreen({super.key, required this.ticket});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final _resolutionController = TextEditingController(text: 'Telah diperbaiki oleh teknisi lapangan.');

  @override
  void dispose() {
    _resolutionController.dispose();
    super.dispose();
  }

  void _openGoogleMaps(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _callCustomer(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _submitResolve() async {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final success = await ticketProvider.resolveTicket(
      widget.ticket.id,
      _resolutionController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tiket gangguan berhasil ditandai selesai!'),
          backgroundColor: AppTheme.accentGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ticketProvider.errorMessage ?? 'Gagal menyelesaikan tiket.'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.ticket;
    final ticketProvider = Provider.of<TicketProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tiket #${t.id}'),
      ),
      body: ListView(
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
                        'Prioritas: ${t.priority.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: t.priority == 'critical' ? AppTheme.accentRed : AppTheme.accentOrange,
                        ),
                      ),
                      StatusBadge(status: t.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (t.description != null && t.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      t.description!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Text('Informasi Pelanggan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(t.customerName ?? 'Pelanggan'),
                  subtitle: Text(t.customerAddress ?? 'Alamat belum diatur'),
                ),
                if (t.customerPhone != null && t.customerPhone!.isNotEmpty) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: Text(t.customerPhone!),
                    trailing: ElevatedButton.icon(
                      onPressed: () => _callCustomer(t.customerPhone!),
                      icon: const Icon(Icons.call, size: 16),
                      label: const Text('Hubungi'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(100, 36),
                      ),
                    ),
                  ),
                ],
                if (t.latitude != null && t.longitude != null) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.location_on, color: AppTheme.accentRed),
                    title: const Text('Titik Lokasi GPS'),
                    subtitle: Text('${t.latitude}, ${t.longitude}'),
                    trailing: OutlinedButton.icon(
                      onPressed: () => _openGoogleMaps(t.latitude!, t.longitude!),
                      icon: const Icon(Icons.map, size: 16),
                      label: const Text('Rute'),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),
          if (t.isOpen) ...[
            const Text('Tindakan Teknisi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _resolutionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Catatan Perbaikan / Penyelesaian',
                        hintText: 'Contoh: Splice ulang kabel dropcore putus di tiang 4...',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: ticketProvider.isLoading ? null : _submitResolve,
                      icon: const Icon(Icons.check_circle_outline),
                      label: ticketProvider.isLoading
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Tandai Tiket Selesai'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Card(
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: AppTheme.accentGreen),
                title: const Text('Tiket Telah Diselesaikan'),
                subtitle: Text(t.resolution ?? 'Selesai'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
