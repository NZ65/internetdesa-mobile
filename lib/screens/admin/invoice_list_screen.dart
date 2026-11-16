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
      search: _searchController.text.trim(),
    );
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
      _loadInvoices();
    }
  }

  @override
  Widget build(BuildContext context) {
    final invProvider = Provider.of<InvoiceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing & Tagihan'),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari invoice atau nama pelanggan...',
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

          // Status Filter Tabs
          Padding(
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
                  label: const Text('Semua'),
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
          const Divider(height: 16),

          // Invoices List
          Expanded(
            child: invProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : invProvider.invoices.isEmpty
                    ? EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'Tidak Ada Tagihan',
                        message: _selectedStatus == 'unpaid'
                            ? 'Luar biasa! Semua tagihan telah lunas.'
                            : 'Tidak ada invoice yang sesuai.',
                        onRetry: _loadInvoices,
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _loadInvoices(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: invProvider.invoices.length,
                          itemBuilder: (context, index) {
                            final inv = invProvider.invoices[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
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
                                            fontSize: 14,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                        ),
                                        StatusBadge(status: inv.status),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      inv.customerName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Jatuh Tempo: ${inv.dueDate ?? "-"} • ${inv.packageName ?? "Paket Internet"}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatCurrency(inv.total),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryBlue,
                                          ),
                                        ),
                                        if (inv.isUnpaid)
                                          ElevatedButton.icon(
                                            onPressed: () => _openPayDialog(inv),
                                            icon: const Icon(Icons.payment, size: 16),
                                            label: const Text('Bayar'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppTheme.accentGreen,
                                              minimumSize: const Size(100, 38),
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
