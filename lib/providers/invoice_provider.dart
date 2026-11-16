import 'dart:io';
import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/invoice_model.dart';
import '../services/api_service.dart';

class InvoiceProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<InvoiceModel> _invoices = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<InvoiceModel> get invoices => _invoices;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchInvoices({String status = 'unpaid', String search = ''}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.get(AppConfig.epInvoices, queryParameters: {
        'status': status,
        'search': search,
      });

      if (response.data['success'] == true) {
        final list = (response.data['data']['invoices'] as List)
            .map((e) => InvoiceModel.fromJson(e))
            .toList();
        _invoices = list;
      } else {
        _errorMessage = response.data['message'];
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
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
