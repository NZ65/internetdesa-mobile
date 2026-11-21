import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/sound_effects.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/zzz_card.dart';
import '../../widgets/zzz_badge.dart';
import '../../widgets/zzz_button.dart';
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
    File? receiptImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCard,
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
                  children: const [
                    Text(
                      'CATAT TRANSAKSI KAS',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.textWhite, letterSpacing: 0.8),
                    ),
                    ZzzBadge(
                      text: 'TELEGRAM TOPIC 874',
                      type: ZzzBadgeType.cyan,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Tipe Transaksi (Out / In)
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('PENGELUARAN (OUT)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11))),
                        selected: type == 'out',
                        onSelected: (_) => setModalState(() => type = 'out'),
                        selectedColor: AppTheme.crimsonRed,
                        backgroundColor: AppTheme.bgDark,
                        labelStyle: TextStyle(color: type == 'out' ? Colors.white : AppTheme.textMuted),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('PEMASUKAN (IN)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11))),
                        selected: type == 'in',
                        onSelected: (_) => setModalState(() => type = 'in'),
                        selectedColor: AppTheme.neonGreen,
                        backgroundColor: AppTheme.bgDark,
                        labelStyle: TextStyle(color: type == 'in' ? AppTheme.bgDark : AppTheme.textMuted),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Nama Keperluan / Barang *',
                    labelStyle: const TextStyle(color: AppTheme.textMuted),
                    hintText: 'Contoh: Patch cord, bensin patroli',
                    hintStyle: const TextStyle(color: AppTheme.textDark),
                    filled: true,
                    fillColor: AppTheme.bgDark,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderDark)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.neonCyan)),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Nominal Rupiah (Rp) *',
                    labelStyle: const TextStyle(color: AppTheme.textMuted),
                    prefixText: 'Rp ',
                    prefixStyle: const TextStyle(color: AppTheme.neonCyan, fontWeight: FontWeight.bold),
                    filled: true,
                    fillColor: AppTheme.bgDark,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderDark)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.neonCyan)),
                  ),
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: category,
                  dropdownColor: AppTheme.bgCard,
                  style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Kategori Pengeluaran',
                    labelStyle: const TextStyle(color: AppTheme.textMuted),
                    filled: true,
                    fillColor: AppTheme.bgDark,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderDark)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.neonCyan)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'operasional', child: Text('Operasional Lapangan')),
                    DropdownMenuItem(value: 'capex', child: Text('Belanja Modal / Perangkat (Capex)')),
                    DropdownMenuItem(value: 'fee_tim', child: Text('Fee Teknisi / Tim')),
                    DropdownMenuItem(value: 'opex', child: Text('Biaya Rutin (Opex)')),
                    DropdownMenuItem(value: 'bandwidth', child: Text('Biaya Bandwidth ISP')),
                    DropdownMenuItem(value: 'lainnya', child: Text('Lain-lain')),
                  ],
                  onChanged: (v) => setModalState(() => category = v ?? 'operasional'),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: recipientCtrl,
                  style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Penerima / Toko (Opsional)',
                    labelStyle: const TextStyle(color: AppTheme.textMuted),
                    filled: true,
                    fillColor: AppTheme.bgDark,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderDark)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.neonCyan)),
                  ),
                ),
                const SizedBox(height: 12),

                // Foto Nota / Struk
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
                        receiptImage != null ? Icons.check_circle_rounded : Icons.receipt_rounded,
                        color: receiptImage != null ? AppTheme.neonGreen : AppTheme.neonCyan,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          receiptImage != null ? 'Struk Nota Terlampir ✓' : 'Lampirkan Foto Struk / Nota',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: receiptImage != null ? AppTheme.neonGreen : AppTheme.textSilver,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.camera_alt_rounded, color: AppTheme.neonCyan, size: 20),
                        onPressed: () async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                          if (picked != null) {
                            setModalState(() => receiptImage = File(picked.path));
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.photo_library_rounded, color: AppTheme.hazardYellow, size: 20),
                        onPressed: () async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                          if (picked != null) {
                            setModalState(() => receiptImage = File(picked.path));
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                ZzzButton(
                  text: 'Simpan & Broadcast Telegram',
                  icon: Icons.send_rounded,
                  style: ZzzButtonStyle.primary,
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
                    if (name.isEmpty || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nama keperluan dan nominal wajib diisi!')),
                      );
                      return;
                    }
                    Navigator.pop(ctx);
                    final ok = await context.read<ExpenseProvider>().createExpense(
                      title: name,
                      amount: amount,
                      type: type,
                      category: category,
                      recipient: recipientCtrl.text.trim(),
                      notes: notesCtrl.text.trim(),
                      receiptFile: receiptImage,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppTheme.bgCard,
                          content: Text(
                            ok ? 'Transaksi kas berhasil dicatat & dibroadcast!' : 'Gagal menyimpan transaksi.',
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expProv = context.watch<ExpenseProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('BUKU KAS KEUANGAN', style: TextStyle(color: AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.neonCyan),
            onPressed: _showAddExpenseModal,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                _buildFilterButton('Semua', 'all'),
                const SizedBox(width: 8),
                _buildFilterButton('Pengeluaran', 'out'),
                const SizedBox(width: 8),
                _buildFilterButton('Pemasukan', 'in'),
              ],
            ),
          ),

          // Transaction List
          Expanded(
            child: expProv.isLoading && expProv.expenses.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppTheme.neonCyan))
                : expProv.expenses.isEmpty
                    ? const EmptyState(
                        icon: Icons.receipt_long_rounded,
                        title: 'Belum Ada Transaksi',
                        message: 'Riwayat pencatatan kas operasional masih kosong.',
                      )
                    : RefreshIndicator(
                        onRefresh: () => expProv.fetchExpenses(type: _selectedType),
                        color: AppTheme.neonCyan,
                        backgroundColor: AppTheme.bgCard,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                          itemCount: expProv.expenses.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final tx = expProv.expenses[index];
                            final isOut = tx.type.toLowerCase() == 'out' || tx.type.toLowerCase() == 'expense';

                            return ZzzCard(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isOut ? AppTheme.crimsonRed.withOpacity(0.12) : AppTheme.neonGreen.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isOut ? AppTheme.crimsonRed.withOpacity(0.4) : AppTheme.neonGreen.withOpacity(0.4),
                                      ),
                                    ),
                                    child: Icon(
                                      isOut ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                                      color: isOut ? AppTheme.crimsonRed : AppTheme.neonGreen,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tx.title,
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textWhite),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${Formatters.formatDateTime(tx.createdAt)} • ${tx.category}',
                                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${isOut ? "- " : "+ "}${Formatters.formatRupiah(tx.amount)}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: isOut ? AppTheme.crimsonRed : AppTheme.neonGreen,
                                    ),
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

  Widget _buildFilterButton(String label, String type) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: InkWell(
        onTap: () {
          SoundEffects.playTap();
          setState(() => _selectedType = type);
          context.read<ExpenseProvider>().fetchExpenses(type: type);
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
