import 'dart:io';
import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/invoice_model.dart';
import '../services/api_service.dart';

class InvoiceProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<InvoiceModel> _invoices = [];
  List<String> _periods = [];
  String _selectedPeriod = 'all';
  String _selectedStatus = 'unpaid';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<InvoiceModel> get invoices => _invoices;
  List<String> get periods => _periods;
  String get selectedPeriod => _selectedPeriod;
  String get selectedStatus => _selectedStatus;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setFilter({String? status, String? period, String? search}) {
    if (status != null) _selectedStatus = status;
    if (period != null) _selectedPeriod = period;
    if (search != null) _searchQuery = search;
    fetchInvoices(status: _selectedStatus, period: _selectedPeriod, search: _searchQuery);
  }

  Future<void> fetchInvoices({
    String? status,
    String? period,
    String? search,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final queryStatus = status ?? _selectedStatus;
    final queryPeriod = period ?? _selectedPeriod;
    final querySearch = search ?? _searchQuery;

    _selectedStatus = queryStatus;
    _selectedPeriod = queryPeriod;
    _searchQuery = querySearch;

    try {
      final response = await _api.get(AppConfig.epInvoices, queryParameters: {
        'status': queryStatus,
        'period': queryPeriod,
        'search': querySearch,
      });

      if (response.data['success'] == true) {
        final list = (response.data['data']['invoices'] as List)
            .map((e) => InvoiceModel.fromJson(e))
            .toList();
        _invoices = list;

        if (response.data['data']['periods'] != null) {
          _periods = List<String>.from(response.data['data']['periods']);
        }
      } else {
        _errorMessage = response.data['message'];
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> generateInvoices({String? period, int dueDay = 10}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.post('${AppConfig.epInvoices}/generate', data: {
        'period': period ?? _selectedPeriod,
        'due_day': dueDay,
      });

      _isLoading = false;
      notifyListeners();

      if (response.data['success'] == true) {
        await fetchInvoices();
        return {
          'success': true,
          'message': response.data['message'] ?? 'Berhasil generate tagihan.',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Gagal generate tagihan.',
        };
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  Future<Map<String, dynamic>> updateInvoice({
    required int invoiceId,
    int? amount,
    String? status,
    String? dueDate,
    String? notes,
  }) async {
    try {
      final response = await _api.post('${AppConfig.epInvoices}/$invoiceId/update', data: {
        if (amount != null) 'amount': amount,
        if (status != null) 'status': status,
        if (dueDate != null) 'due_date': dueDate,
        if (notes != null) 'notes': notes,
      });

      if (response.data['success'] == true) {
        await fetchInvoices();
        return {'success': true, 'message': response.data['message'] ?? 'Berhasil memperbarui tagihan.'};
      } else {
        return {'success': false, 'message': response.data['message'] ?? 'Gagal memperbarui tagihan.'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString().replaceAll('Exception: ', '')};
    }
  }

  Future<bool> payInvoice({
    required int invoiceId,
    required int amount,
    String paymentMethod = 'cash',
    String paymentRef = '',
    String notes = '',
    File? proofFile,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = {
        'amount': amount,
        'payment_method': paymentMethod,
        'payment_ref': paymentRef,
        'notes': notes,
      };

      final files = <String, File?>{
        'proof_image': proofFile,
      };

      final response = await _api.postMultipart(
        '${AppConfig.epPayInvoice}/$invoiceId/pay',
        data,
        files,
      );

      _isLoading = false;
      notifyListeners();

      if (response.data['success'] == true) {
        // Refresh list
        await fetchInvoices();
        return true;
      } else {
        _errorMessage = response.data['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
