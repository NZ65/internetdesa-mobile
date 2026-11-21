import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/sound_effects.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/invoice_provider.dart';
import '../../widgets/zzz_card.dart';
import '../../widgets/zzz_badge.dart';
import '../../widgets/zzz_button.dart';
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
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.initialStatus;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoiceProvider>().fetchInvoices(status: _currentStatus);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showPayModal(int invoiceId, String invoiceNo, String customerName, num amount) {
    String method = 'cash';
    final notesCtrl = TextEditingController();
    File? proofFile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(modalCtx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('CATAT PEMBAYARAN TAGIHAN', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textWhite)),
                  Text(invoiceNo, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.neonCyan)),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.bgDark,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.borderDark),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(customerName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textWhite)),
                        const Text('Pelanggan Sukorejo', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                      ],
                    ),
                    Text(
                      Formatters.formatRupiah(amount),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.neonGreen),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Payment Method Toggle
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Tunai (Cash)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                      selected: method == 'cash',
                      onSelected: (_) => setModalState(() => method = 'cash'),
                      selectedColor: AppTheme.neonGreen,
                      backgroundColor: AppTheme.bgDark,
                      labelStyle: TextStyle(color: method == 'cash' ? AppTheme.bgDark : AppTheme.textMuted),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Transfer Bank', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                      selected: method == 'transfer',
                      onSelected: (_) => setModalState(() => method = 'transfer'),
                      selectedColor: AppTheme.neonCyan,
                      backgroundColor: AppTheme.bgDark,
                      labelStyle: TextStyle(color: method == 'transfer' ? AppTheme.bgDark : AppTheme.textMuted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextField(
                controller: notesCtrl,
                style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Catatan Pembayaran (Opsional)',
                  labelStyle: const TextStyle(color: AppTheme.textMuted),
                  filled: true,
                  fillColor: AppTheme.bgDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderDark)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.neonCyan)),
                ),
              ),
              const SizedBox(height: 12),

              // Bukti Transfer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.bgDark,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.borderDark),
                ),
                child: Row(
                  children: [
                    Icon(
                      proofFile != null ? Icons.check_circle_rounded : Icons.receipt_rounded,
                      color: proofFile != null ? AppTheme.neonGreen : AppTheme.neonCyan,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        proofFile != null ? 'Bukti Terlampir ✓' : 'Upload Bukti Transfer (Opsional)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: proofFile != null ? AppTheme.neonGreen : AppTheme.textSilver,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.photo_library_rounded, color: AppTheme.neonCyan, size: 20),
                      onPressed: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                        if (picked != null) {
                          setModalState(() => proofFile = File(picked.path));
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              ZzzButton(
                text: 'Konfirmasi Pembayaran Lunas',
                icon: Icons.check_circle_rounded,
                style: ZzzButtonStyle.primary,
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
                      SnackBar(
                        backgroundColor: AppTheme.bgCard,
                        content: Text(
                          ok ? 'Tagihan berhasil dibayar & kuitansi terbit!' : 'Gagal memproses pembayaran.',
                          style: TextStyle(color: ok ? AppTheme.neonGreen : AppTheme.crimsonRed),
                        ),
                      ),
                    );
                  }
                },
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
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('TAGIHAN & BILLING', style: TextStyle(color: AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter & Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                  onChanged: (v) => invProv.fetchInvoices(status: _currentStatus, search: v),
                  decoration: InputDecoration(
                    hintText: 'Cari nama pelanggan atau nomor invoice...',
                    hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.neonCyan, size: 20),
                    filled: true,
                    fillColor: AppTheme.bgCard,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderDark)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.neonCyan, width: 1.5)),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildFilterChip('Belum Bayar', 'unpaid'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Lunas', 'paid'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Semua Tagihan', 'all'),
                  ],
                ),
              ],
            ),
          ),

          // Invoices List
          Expanded(
            child: invProv.isLoading && invProv.invoices.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppTheme.neonCyan))
                : invProv.invoices.isEmpty
                    ? const EmptyState(
                        icon: Icons.receipt_long_rounded,
                        title: 'Tidak Ada Tagihan',
                        message: 'Tidak ada data tagihan yang sesuai dengan filter.',
                      )
                    : RefreshIndicator(
                        onRefresh: () => invProv.fetchInvoices(status: _currentStatus, search: _searchCtrl.text),
                        color: AppTheme.neonCyan,
                        backgroundColor: AppTheme.bgCard,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                          itemCount: invProv.invoices.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final inv = invProv.invoices[index];
                            final isUnpaid = inv.isUnpaid;

                            return ZzzCard(
                              padding: const EdgeInsets.all(14),
                              borderColor: isUnpaid ? AppTheme.hazardYellow.withOpacity(0.4) : AppTheme.borderDark,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        inv.invoiceNumber,
                                        style: const TextStyle(color: AppTheme.neonCyan, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                                      ),
                                      StatusBadge(status: inv.status),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              inv.customerName,
                                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textWhite),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Jatuh Tempo: ${Formatters.formatDate(inv.dueDate)}',
                                              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        Formatters.formatRupiah(inv.amount),
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: isUnpaid ? AppTheme.hazardYellow : AppTheme.neonGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (isUnpaid) ...[
                                    const SizedBox(height: 12),
                                    ZzzButton(
                                      text: 'Terima Bayar',
                                      icon: Icons.payments_rounded,
                                      style: ZzzButtonStyle.secondary,
                                      height: 38,
                                      onPressed: () => _showPayModal(inv.id, inv.invoiceNumber, inv.customerName, inv.amount),
                                    ),
                                  ],
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
    final isSelected = _currentStatus == status;
    return Expanded(
      child: InkWell(
        onTap: () {
          SoundEffects.playTap();
          setState(() => _currentStatus = status);
          context.read<InvoiceProvider>().fetchInvoices(status: status, search: _searchCtrl.text);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.neonCyan.withOpacity(0.15) : AppTheme.bgCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? AppTheme.neonCyan : AppTheme.borderDark),
          ),
          alignment: Alignment.center,
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
