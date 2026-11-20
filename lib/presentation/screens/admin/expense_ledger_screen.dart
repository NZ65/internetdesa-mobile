import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/sound_effects.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/cyber_card.dart';
import '../../widgets/empty_state.dart';

class ExpenseLedgerScreen extends StatefulWidget {
  final bool openAddModal;

  const ExpenseLedgerScreen({super.key, this.openAddModal = false});

  @override
  State<ExpenseLedgerScreen> createState() => _ExpenseLedgerScreenState();
}

class _ExpenseLedgerScreenState extends State<ExpenseLedgerScreen> {
  String _selectedType = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().fetchExpenses(type: _selectedType);
      if (widget.openAddModal) {
        _showAddExpenseModal();
      }
    });
  }

  void _showAddExpenseModal() {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final recipientCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String type = 'out';
    String category = 'operasional';
    String paymentSource = 'Kas Operasional';
    String paymentMethod = 'cash';
    File? receiptImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(modalCtx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Catat Transaksi Kas',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('AUTO TELEGRAM 874', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Tipe Transaksi
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Pengeluaran (Out)')),
                        selected: type == 'out',
                        onSelected: (_) => setModalState(() => type = 'out'),
                        selectedColor: AppTheme.accentRed,
                        labelStyle: TextStyle(color: type == 'out' ? Colors.white : AppTheme.textMain, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Pemasukan (In)')),
                        selected: type == 'in',
                        onSelected: (_) => setModalState(() => type = 'in'),
                        selectedColor: AppTheme.accentGreen,
                        labelStyle: TextStyle(color: type == 'in' ? Colors.white : AppTheme.textMain, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nama Keperluan / Barang *',
                    hintText: 'Contoh: Beli Patch Cord, Bensin Patroli',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Nominal Rupiah (Rp) *',
                    hintText: '50000',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),

                // Kategori Dropdown
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: InputDecoration(
                    labelText: 'Kategori Pengeluaran',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'operasional', child: Text('Operasional Kantor / Lapangan')),
                    DropdownMenuItem(value: 'capex', child: Text('Belanja Modal / Perangkat (Capex)')),
                    DropdownMenuItem(value: 'fee_tim', child: Text('Fee Teknisi / Sales')),
                    DropdownMenuItem(value: 'opex', child: Text('Biaya Rutin (Opex)')),
                    DropdownMenuItem(value: 'bandwidth', child: Text('Biaya Bandwidth ISP')),
                    DropdownMenuItem(value: 'lainnya', child: Text('Lain-lain')),
                  ],
                  onChanged: (v) => setModalState(() => category = v ?? 'operasional'),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: recipientCtrl,
                  decoration: InputDecoration(
                    labelText: 'Penerima / Toko (Opsional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),

                // Foto Nota / Struk (Kamera / Galeri)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        receiptImage != null ? Icons.check_circle_rounded : Icons.receipt_rounded,
                        color: receiptImage != null ? AppTheme.accentGreen : AppTheme.primaryBlue,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              receiptImage != null ? 'Struk Nota Terlampir ✓' : 'Foto Struk Nota Belanja',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                            ),
                            const Text('Otomatis dikirim ke grup Telegram kas', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 75);
                          if (picked != null) {
                            setModalState(() => receiptImage = File(picked.path));
                          }
                        },
                        icon: const Icon(Icons.camera_alt_rounded, size: 16),
                        label: const Text('Foto', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final amount = num.tryParse(amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                    if (name.isEmpty || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nama keperluan dan nominal wajib diisi!')),
                      );
                      return;
                    }
                    Navigator.pop(ctx);
                    final ok = await context.read<ExpenseProvider>().addExpense(
                      itemName: name,
                      amount: amount,
                      type: type,
                      category: category,
                      paymentSource: paymentSource,
                      paymentMethod: paymentMethod,
                      recipient: recipientCtrl.text.trim(),
                      notes: notesCtrl.text.trim(),
                      receiptImage: receiptImage,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(ok ? '✅ Transaksi berhasil dicatat & disiarkan ke Telegram!' : 'Gagal mencatat transaksi.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Simpan & Siarkan ke Telegram', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expProv = context.watch<ExpenseProvider>();

    return Scaffold(
      backgroundColor: AppTheme.iceBackground,
      appBar: AppBar(
        title: const Text('Buku Kas Keuangan', style: TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppTheme.textMain),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppTheme.primaryBlue, size: 26),
            onPressed: _showAddExpenseModal,
          ),
        ],
      ),
      body: Column(
        children: [
          // Saldo Summary Header Card
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: AppTheme.cyberGlow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TOTAL SALDO KAS TERSEDIA', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.formatRupiah(expProv.saldoTersisa),
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  const Divider(color: Colors.white24, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Sisa Modal Awal', style: TextStyle(color: Colors.white70, fontSize: 10)),
                          Text(Formatters.formatCompactRupiah(expProv.sisaModal), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Sisa Kas Ops Sukorejo', style: TextStyle(color: Colors.white70, fontSize: 10)),
                          Text(Formatters.formatCompactRupiah(expProv.sisaKasOps), style: const TextStyle(color: AppTheme.techCyan, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Filter Row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                _buildTypeChip('all', 'Semua Transaksi'),
                const SizedBox(width: 8),
                _buildTypeChip('out', 'Pengeluaran (Out)'),
                const SizedBox(width: 8),
                _buildTypeChip('in', 'Pemasukan (In)'),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: expProv.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
                : expProv.transactions.isEmpty
                    ? EmptyState(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Belum Ada Transaksi',
                        message: 'Belum ada catatan transaksi kas untuk filter ini.',
                        onRetry: () => expProv.fetchExpenses(type: _selectedType),
                      )
                    : RefreshIndicator(
                        onRefresh: () => expProv.fetchExpenses(type: _selectedType),
                        color: AppTheme.primaryBlue,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: expProv.transactions.length,
                          itemBuilder: (ctx, idx) {
                            final tx = expProv.transactions[idx];
                            final isOut = tx.isExpense;

                            return CyberCard(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isOut ? AppTheme.pastelRed : AppTheme.pastelGreen,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      isOut ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                                      color: isOut ? AppTheme.accentRed : AppTheme.accentGreen,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tx.itemName,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${Formatters.formatShortDate(tx.transactionDate)} • ${tx.category.toUpperCase()}',
                                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                        ),
                                        if (tx.recipient != null && tx.recipient!.isNotEmpty)
                                          Text('Penerima: ${tx.recipient}', style: const TextStyle(fontSize: 10, color: AppTheme.textLight)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${isOut ? "- " : "+ "}${Formatters.formatRupiah(tx.amount)}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: isOut ? AppTheme.accentRed : AppTheme.accentGreen,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        tx.paymentMethod.toUpperCase(),
                                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppTheme.textLight),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExpenseModal,
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Catat Kas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTypeChip(String type, String label) {
    final isSelected = _selectedType == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        SoundEffects.playTap();
        setState(() => _selectedType = type);
        context.read<ExpenseProvider>().fetchExpenses(type: type);
      },
      selectedColor: AppTheme.primaryBlue,
      backgroundColor: const Color(0xFFF1F5F9),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textMain,
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      showCheckmark: false,
    );
  }
}
