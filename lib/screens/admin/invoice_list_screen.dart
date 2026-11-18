import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/invoice_model.dart';
import '../../providers/invoice_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';
import 'invoice_pay_dialog.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  final _searchController = TextEditingController();
  String _selectedStatus = 'unpaid';
  String _selectedPeriod = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInvoices();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadInvoices() {
    Provider.of<InvoiceProvider>(context, listen: false).fetchInvoices(
      status: _selectedStatus,
      period: _selectedPeriod,
      search: _searchController.text.trim(),
    );
  }

  String _formatCurrency(dynamic amount) {
    final num val = (amount is num) ? amount : (num.tryParse(amount.toString()) ?? 0);
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(val);
  }

  String _formatPeriodLabel(String period) {
    if (period == 'all') return 'Semua Periode';
    try {
      final parts = period.split('-');
      if (parts.length == 2) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final dt = DateTime(year, month);
        return DateFormat('MMMM yyyy', 'id_ID').format(dt);
      }
    } catch (_) {}
    return period;
  }

  void _openPayDialog(InvoiceModel invoice) async {
    final res = await showDialog(
      context: context,
      builder: (_) => InvoicePayDialog(invoice: invoice),
    );
    if (res == true) {
      _loadInvoices();
    }
  }

  void _openGenerateDialog() {
    final currentYearMonth = DateFormat('yyyy-MM').format(DateTime.now());
    final periodCtrl = TextEditingController(text: currentYearMonth);
    final dueDayCtrl = TextEditingController(text: '10');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.playlist_add_check, color: AppTheme.primaryBlue),
            SizedBox(width: 8),
            Text('Generate / Update Tagihan', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sistem akan membuat tagihan baru untuk seluruh pelanggan aktif yang belum memiliki invoice di periode yang dipilih.',
              style: TextStyle(fontSize: 12.5, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: periodCtrl,
              decoration: const InputDecoration(
                labelText: 'Periode (YYYY-MM)',
                hintText: 'Contoh: 2026-11',
                prefixIcon: Icon(Icons.calendar_month),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dueDayCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tanggal Jatuh Tempo',
                hintText: 'Contoh: 10',
                prefixIcon: Icon(Icons.access_time),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final p = periodCtrl.text.trim();
              final day = int.tryParse(dueDayCtrl.text.trim()) ?? 10;
              if (p.isEmpty) return;

              Navigator.pop(ctx);
              final invProvider = Provider.of<InvoiceProvider>(context, listen: false);
              final res = await invProvider.generateInvoices(period: p, dueDay: day);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(res['message'] ?? ''),
                    backgroundColor: res['success'] == true ? AppTheme.accentGreen : AppTheme.accentRed,
                  ),
                );
              }
            },
            child: const Text('Generate Sekarang'),
          ),
        ],
      ),
    );
  }

  void _openEditInvoiceDialog(InvoiceModel inv) {
    final amountCtrl = TextEditingController(text: inv.total.toString());
    final dueDateCtrl = TextEditingController(text: inv.dueDate ?? '');
    String statusVal = inv.status;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Edit Invoice ${inv.invoiceNumber}', style: const TextStyle(fontSize: 15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Pelanggan: ${inv.customerName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 14),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total Tagihan (Rp)', prefixText: 'Rp '),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: dueDateCtrl,
                decoration: const InputDecoration(labelText: 'Jatuh Tempo (YYYY-MM-DD)', prefixIcon: Icon(Icons.calendar_today, size: 18)),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: statusVal,
                decoration: const InputDecoration(labelText: 'Status Pembayaran'),
                items: const [
                  DropdownMenuItem(value: 'unpaid', child: Text('Belum Lunas (Unpaid)')),
                  DropdownMenuItem(value: 'paid', child: Text('Lunas (Paid)')),
                  DropdownMenuItem(value: 'overdue', child: Text('Jatuh Tempo (Overdue)')),
                  DropdownMenuItem(value: 'cancelled', child: Text('Dibatalkan (Cancelled)')),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => statusVal = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                final amt = int.tryParse(amountCtrl.text.trim());
                Navigator.pop(ctx);
                final invProvider = Provider.of<InvoiceProvider>(context, listen: false);
                final res = await invProvider.updateInvoice(
                  invoiceId: inv.id,
                  amount: amt,
                  dueDate: dueDateCtrl.text.trim(),
                  status: statusVal,
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
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final invProvider = Provider.of<InvoiceProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Available periods list + 'all'
    final List<String> periodOptions = ['all', ...invProvider.periods];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing & Riwayat Tagihan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.post_add),
            tooltip: 'Generate / Update Tagihan',
            onPressed: _openGenerateDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan',
            onPressed: _loadInvoices,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama, ID pelanggan, no invoice...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadInvoices();
                        },
                      )
                    : null,
              ),
              onSubmitted: (_) => _loadInvoices(),
            ),
          ),

          // Period & Status Filters Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                // Dropdown Riwayat Bulan Tagihan
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: periodOptions.contains(_selectedPeriod) ? _selectedPeriod : 'all',
                        isExpanded: true,
                        icon: const Icon(Icons.calendar_month, size: 18, color: AppTheme.primaryBlue),
                        items: periodOptions.map((p) {
                          return DropdownMenuItem<String>(
                            value: p,
                            child: Text(
                              _formatPeriodLabel(p),
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedPeriod = val);
                            _loadInvoices();
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Button Tambah Tagihan
                ElevatedButton.icon(
                  onPressed: _openGenerateDialog,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Buat Tagihan', style: TextStyle(fontSize: 11.5)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(110, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),

          // Status Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Belum Lunas'),
                  selected: _selectedStatus == 'unpaid',
                  onSelected: (val) {
                    if (val) {
                      setState(() => _selectedStatus = 'unpaid');
                      _loadInvoices();
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Lunas'),
                  selected: _selectedStatus == 'paid',
                  onSelected: (val) {
                    if (val) {
                      setState(() => _selectedStatus = 'paid');
                      _loadInvoices();
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Jatuh Tempo (Overdue)'),
                  selected: _selectedStatus == 'overdue',
                  onSelected: (val) {
                    if (val) {
                      setState(() => _selectedStatus = 'overdue');
                      _loadInvoices();
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Semua Status'),
                  selected: _selectedStatus == 'all',
                  onSelected: (val) {
                    if (val) {
                      setState(() => _selectedStatus = 'all');
                      _loadInvoices();
                    }
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 12),

          // Invoices List
          Expanded(
            child: invProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : invProvider.invoices.isEmpty
                    ? EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'Tidak Ada Tagihan',
                        message: _selectedStatus == 'unpaid'
                            ? 'Luar biasa! Tidak ada tagihan tertunggak pada filter ini.'
                            : 'Tidak ada invoice yang sesuai kriteria pencarian.',
                        onRetry: _loadInvoices,
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _loadInvoices(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: invProvider.invoices.length,
                          itemBuilder: (context, index) {
                            final inv = invProvider.invoices[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          inv.invoiceNumber,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            StatusBadge(status: inv.status),
                                            const SizedBox(width: 4),
                                            IconButton(
                                              icon: const Icon(Icons.edit, size: 16, color: Colors.grey),
                                              tooltip: 'Edit Invoice',
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              onPressed: () => _openEditInvoiceDialog(inv),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      inv.customerName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'ID: ${inv.custId ?? "-"} • Jatuh Tempo: ${inv.dueDate ?? "-"} • ${inv.packageName ?? "Paket Internet"}',
                                      style: TextStyle(fontSize: 11.5, color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatCurrency(inv.total),
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryBlue,
                                          ),
                                        ),
                                        if (inv.isUnpaid)
                                          ElevatedButton.icon(
                                            onPressed: () => _openPayDialog(inv),
                                            icon: const Icon(Icons.payment, size: 15),
                                            label: const Text('Bayar', style: TextStyle(fontSize: 12)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppTheme.accentGreen,
                                              foregroundColor: Colors.white,
                                              minimumSize: const Size(90, 36),
                                              padding: const EdgeInsets.symmetric(horizontal: 12),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
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
}
