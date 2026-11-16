import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/customer_model.dart';
import '../models/invoice_model.dart';
import '../services/api_service.dart';

class CustomerProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<CustomerModel> _customers = [];
  bool _isLoading = false;
  String? _errorMessage;

  CustomerModel? _selectedCustomer;
  List<InvoiceModel> _selectedCustomerInvoices = [];
  bool _isLoadingDetail = false;

  List<CustomerModel> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CustomerModel? get selectedCustomer => _selectedCustomer;
  List<InvoiceModel> get selectedCustomerInvoices => _selectedCustomerInvoices;
  bool get isLoadingDetail => _isLoadingDetail;

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
      } else {
        _errorMessage = response.data['message'];
      }
    } catch (e) {
      _errorMessage = (e is dynamic && e.error != null) ? e.error.toString() : e.toString();
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
      _errorMessage = (e is dynamic && e.error != null) ? e.error.toString() : e.toString();
    }

    _isLoadingDetail = false;
    notifyListeners();
  }
}
