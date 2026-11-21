import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/sound_effects.dart';
import '../../data/models/invoice_model.dart';

class InvoiceProvider extends ChangeNotifier {
  List<InvoiceModel> _invoices = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _currentStatus = 'unpaid';
  int _currentPage = 1;
  int _totalPages = 1;
  num _totalUnpaidAmount = 0;

  List<InvoiceModel> get invoices => _invoices;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  num get totalUnpaidAmount => _totalUnpaidAmount;
  int get totalPages => _totalPages;
  int get currentPage => _currentPage;

  Future<void> fetchInvoices({
    String? status,
    int page = 1,
    bool silent = false,
    String? search,
  }) async {
    if (status != null) _currentStatus = status;
    _currentPage = page;

    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final Map<String, dynamic> queryParams = {
        'status': _currentStatus,
        'page': _currentPage,
        'limit': 30,
      };
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final res = await ApiClient().get(AppConfig.epInvoices, queryParameters: queryParams);

      if (res['success'] == true && res['data'] != null) {
        final data = res['data'];
        final list = data['invoices'] as List? ?? [];
        _invoices = list.map((i) => InvoiceModel.fromJson(i)).toList();
        _totalUnpaidAmount = data['total_unpaid'] ?? 0;
        if (data['pagination'] != null) {
          _totalPages = data['pagination']['totalPages'] ?? 1;
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> payInvoice({
    required int invoiceId,
    required num amount,
    String paymentMethod = 'cash',
    String? notes,
    File? proofImage,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fields = {
        'amount': amount.toString(),
        'payment_method': paymentMethod,
        'notes': notes?.trim() ?? '',
      };
      final files = {
        'proof_image': proofImage,
      };

      final res = await ApiClient().postMultipart('${AppConfig.epInvoices}/$invoiceId/pay', fields, files);
      if (res['success'] == true) {
        SoundEffects.playSuccess();
        await fetchInvoices(silent: true);
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }
}
