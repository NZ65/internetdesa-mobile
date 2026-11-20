import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/sound_effects.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/invoice_provider.dart';
import '../../widgets/cyber_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';

class InvoiceListScreen extends StatefulWidget {
  final String initialStatus;

  const InvoiceListScreen({super.key, this.initialStatus = 'unpaid'});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.initialStatus;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoiceProvider>().fetchInvoices(status: _currentStatus);
    });
  }

  void _showPayModal(int invoiceId, String invoiceNo, String customerName, num amount) {
    String method = 'cash';
    final notesCtrl = TextEditingController();
    File? proofFile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(modalCtx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Konfirmasi Bayar • $invoiceNo',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textMain),
              ),
              const SizedBox(height: 4),
              Text('Pelanggan: $customerName', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Nominal Tagihan:', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                  Text(
                    Formatters.formatRupiah(amount),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Metode Pembayaran:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Tunai (Cash)')),
                      selected: method == 'cash',
                      onSelected: (_) => setModalState(() => method = 'cash'),
                      selectedColor: AppTheme.primaryBlue,
                      labelStyle: TextStyle(color: method == 'cash' ? Colors.white : AppTheme.textMain, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Transfer Bank')),
                      selected: method == 'transfer',
                      onSelected: (_) => setModalState(() => method = 'transfer'),
                      selectedColor: AppTheme.primaryBlue,
                      labelStyle: TextStyle(color: method == 'transfer' ? Colors.white : AppTheme.textMain, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                decoration: InputDecoration(
                  hintText: 'Catatan tambahan (opsional)...',
                  hintStyle: const TextStyle(fontSize: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 75);
                  if (picked != null) {
                    setModalState(() => proofFile = File(picked.path));
                  }
                },
                icon: const Icon(Icons.camera_alt_rounded, size: 16),
                label: Text(proofFile != null ? 'Foto Struk Dipilih ✓' : 'Ambil Foto Struk (Opsional)', style: const TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final ok = await context.read<InvoiceProvider>().payInvoice(
                    invoiceId: invoiceId,
                    amount: amount,
                    paymentMethod: method,
                    notes: notesCtrl.text.trim(),
                    proofImage: proofFile,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(ok ? 'Pembayaran berhasil diverifikasi!' : 'Gagal verifikasi pembayaran.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Tandai Telah Dibayar & Masuk Kas', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final invProv = context.watch<InvoiceProvider>();

    return Scaffold(
      backgroundColor: AppTheme.iceBackground,
      appBar: AppBar(
        title: const Text('Tagihan & Billing', style: TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppTheme.textMain),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Belum Bayar')),
                    selected: _currentStatus == 'unpaid',
                    onSelected: (_) {
                      SoundEffects.playTap();
                      setState(() => _currentStatus = 'unpaid');
                      invProv.fetchInvoices(status: 'unpaid');
                    },
                    selectedColor: AppTheme.accentOrange,
                    labelStyle: TextStyle(
                      color: _currentStatus == 'unpaid' ? Colors.white : AppTheme.textMain,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Lunas (Paid)')),
                    selected: _currentStatus == 'paid',
                    onSelected: (_) {
                      SoundEffects.playTap();
                      setState(() => _currentStatus = 'paid');
                      invProv.fetchInvoices(status: 'paid');
                    },
                    selectedColor: AppTheme.accentGreen,
                    labelStyle: TextStyle(
                      color: _currentStatus == 'paid' ? Colors.white : AppTheme.textMain,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Invoices List
          Expanded(
            child: invProv.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
                : invProv.invoices.isEmpty
                    ? EmptyState(
                        icon: Icons.receipt_long_rounded,
                        title: 'Tidak Ada Tagihan',
                        message: 'Semua tagihan untuk status ini telah terselesaikan.',
                        onRetry: () => invProv.fetchInvoices(status: _currentStatus),
                      )
                    : RefreshIndicator(
                        onRefresh: () => invProv.fetchInvoices(status: _currentStatus),
                        color: AppTheme.primaryBlue,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: invProv.invoices.length,
                          itemBuilder: (ctx, idx) {
                            final inv = invProv.invoices[idx];
                            return CyberCard(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        inv.customerName,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                                      ),
                                      StatusBadge(status: inv.status),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${inv.invoiceNo} • Periode ${inv.period}',
                                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Total Tagihan', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                                          Text(
                                            Formatters.formatRupiah(inv.total),
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.textMain),
                                          ),
                                        ],
                                      ),
                                      if (!inv.isPaid)
                                        ElevatedButton(
                                          onPressed: () => _showPayModal(inv.id, inv.invoiceNo, inv.customerName, inv.total),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.primaryBlue,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                            elevation: 0,
                                          ),
                                          child: const Text('Bayar Tagihan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                        ),
                                    ],
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
}
