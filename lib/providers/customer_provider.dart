import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/customer_model.dart';
import '../models/invoice_model.dart';
import '../models/registration_model.dart';
import '../services/api_service.dart';

class CustomerProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<CustomerModel> _customers = [];
  List<PackageModel> _packages = [];
  int _pendingCount = 0;
  int _unpaidCount = 0;
  bool _isLoading = false;
  String? _errorMessage;

  CustomerModel? _selectedCustomer;
  List<InvoiceModel> _selectedCustomerInvoices = [];
  bool _isLoadingDetail = false;

  List<CustomerModel> get customers => _customers;
  List<PackageModel> get packages => _packages;
  int get pendingCount => _pendingCount;
  int get unpaidCount => _unpaidCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CustomerModel? get selectedCustomer => _selectedCustomer;
  List<InvoiceModel> get selectedCustomerInvoices => _selectedCustomerInvoices;
  bool get isLoadingDetail => _isLoadingDetail;

  Future<void> fetchPackages() async {
    try {
      final response = await _api.get('/packages');
      if (response.data['success'] == true) {
        _packages = (response.data['data'] as List)
            .map((e) => PackageModel.fromJson(e))
            .toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> fetchCustomers({String search = '', String status = 'all'}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.get(AppConfig.epCustomers, queryParameters: {
        'search': search,
        'status': status,
        'limit': 50,
      });

      if (response.data['success'] == true) {
        final list = (response.data['data']['customers'] as List)
            .map((e) => CustomerModel.fromJson(e))
            .toList();
        _customers = list;
        if (response.data['data']['pending_count'] != null) {
          _pendingCount = int.tryParse(response.data['data']['pending_count'].toString()) ?? 0;
        }
        if (response.data['data']['unpaid_count'] != null) {
          _unpaidCount = int.tryParse(response.data['data']['unpaid_count'].toString()) ?? 0;
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

  Future<void> fetchCustomerDetail(int id) async {
    _isLoadingDetail = true;
    _selectedCustomer = null;
    _selectedCustomerInvoices = [];
    notifyListeners();

    try {
      final response = await _api.get('${AppConfig.epCustomers}/$id');
      if (response.data['success'] == true) {
        _selectedCustomer = CustomerModel.fromJson(response.data['data']['customer']);
        if (response.data['data']['invoices'] != null) {
          _selectedCustomerInvoices = (response.data['data']['invoices'] as List)
              .map((e) => InvoiceModel.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoadingDetail = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> updateCustomer({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _api.post('${AppConfig.epCustomers}/$id/update', data: data);
      if (response.data['success'] == true) {
        if (response.data['data'] != null) {
          _selectedCustomer = CustomerModel.fromJson(response.data['data']);
        }
        notifyListeners();
        return {
          'success': true,
          'message': response.data['message'] ?? 'Data pelanggan berhasil diperbarui.',
        };
      }
      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal memperbarui data.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  Future<Map<String, dynamic>> deleteCustomer(int id) async {
    try {
      final response = await _api.post('${AppConfig.epCustomers}/$id/delete');
      if (response.data['success'] == true) {
        _customers.removeWhere((c) => c.id == id);
        notifyListeners();
        return {
          'success': true,
          'message': response.data['message'] ?? 'Pelanggan berhasil dihapus.',
        };
      }
      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal menghapus pelanggan.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }
}
