import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/invoice_model.dart';
import '../../providers/invoice_provider.dart';

class InvoicePayDialog extends StatefulWidget {
  final InvoiceModel invoice;

  const InvoicePayDialog({super.key, required this.invoice});

  @override
  State<InvoicePayDialog> createState() => _InvoicePayDialogState();
}

class _InvoicePayDialogState extends State<InvoicePayDialog> {
  final _amountController = TextEditingController();
  final _refController = TextEditingController();
  final _notesController = TextEditingController();
  String _paymentMethod = 'cash';
  File? _proofImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.invoice.total.toString();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _refController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      setState(() {
        _proofImage = File(picked.path);
      });
    }
  }

  void _submitPayment() async {
    final invProvider = Provider.of<InvoiceProvider>(context, listen: false);
    final amount = int.tryParse(_amountController.text.trim()) ?? widget.invoice.total;

    final success = await invProvider.payInvoice(
      invoiceId: widget.invoice.id,
      amount: amount,
      paymentMethod: _paymentMethod,
      paymentRef: _refController.text.trim(),
      notes: _notesController.text.trim(),
      proofFile: _proofImage,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran berhasil! Status LUNAS dan isolir telah dibuka otomatis.'),
          backgroundColor: AppTheme.accentGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(invProvider.errorMessage ?? 'Gagal memproses pembayaran.'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final invProvider = Provider.of<InvoiceProvider>(context);

    return AlertDialog(
      title: Text('Bayar ${widget.invoice.invoiceNumber}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pelanggan: ${widget.invoice.customerName}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),

            // Amount field
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah Bayar (Rp)',
                prefixText: 'Rp ',
              ),
            ),
            const SizedBox(height: 12),

            // Payment Method dropdown
            DropdownButtonFormField<String>(
              value: _paymentMethod,
              decoration: const InputDecoration(labelText: 'Metode Pembayaran'),
              items: const [
                DropdownMenuItem(value: 'cash', child: Text('Tunai / Cash')),
                DropdownMenuItem(value: 'transfer_bca', child: Text('Transfer Bank BCA')),
                DropdownMenuItem(value: 'transfer_bri', child: Text('Transfer Bank BRI')),
                DropdownMenuItem(value: 'transfer_mandiri', child: Text('Transfer Bank Mandiri')),
                DropdownMenuItem(value: 'qris', child: Text('QRIS')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _paymentMethod = val);
              },
            ),
            const SizedBox(height: 12),

            // Notes
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Catatan / No. Referensi',
                hintText: 'Opsional',
              ),
            ),
            const SizedBox(height: 16),

            // Upload Proof Image Section
            const Text('Foto Bukti Pembayaran / Struk:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            if (_proofImage != null) ...[
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(_proofImage!, height: 120, width: double.infinity, fit: BoxFit.cover),
                  ),
                  IconButton(
                    icon: const CircleAvatar(backgroundColor: Colors.white, radius: 14, child: Icon(Icons.close, size: 16, color: Colors.black)),
                    onPressed: () => setState(() => _proofImage = null),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, size: 16),
                    label: const Text('Kamera', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library, size: 16),
                    label: const Text('Galeri', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: invProvider.isLoading ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: invProvider.isLoading ? null : _submitPayment,
          child: invProvider.isLoading
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Simpan Pembayaran'),
        ),
      ],
    );
  }
}
