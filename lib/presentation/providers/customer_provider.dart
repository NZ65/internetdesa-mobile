import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/sound_effects.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/invoice_model.dart';

class CustomerProvider extends ChangeNotifier {
  List<CustomerModel> _customers = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _pendingCount = 0;
  int _unpaidCount = 0;
  int _currentPage = 1;
  int _totalPages = 1;
  String _currentStatus = 'all';
  String _currentSearch = '';

  // Selected Customer Detail & Live Metrics
  CustomerModel? _selectedCustomer;
  List<InvoiceModel> _customerInvoices = [];
  Map<String, dynamic>? _liveTraffic;
  bool _isLoadingTraffic = false;

  List<CustomerModel> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get pendingCount => _pendingCount;
  int get unpaidCount => _unpaidCount;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  CustomerModel? get selectedCustomer => _selectedCustomer;
  List<InvoiceModel> get customerInvoices => _customerInvoices;
  Map<String, dynamic>? get liveTraffic => _liveTraffic;
  bool get isLoadingTraffic => _isLoadingTraffic;

  Future<void> fetchCustomers({
    String? status,
    String? search,
    int page = 1,
    bool silent = false,
  }) async {
    if (status != null) _currentStatus = status;
    if (search != null) _currentSearch = search;
    _currentPage = page;

    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final res = await ApiClient().get(AppConfig.epCustomers, queryParameters: {
        'status': _currentStatus,
        'search': _currentSearch,
        'page': _currentPage,
        'limit': 25,
      });

      if (res['success'] == true && res['data'] != null) {
        final data = res['data'];
        final list = data['customers'] as List? ?? [];
        _customers = list.map((c) => CustomerModel.fromJson(c)).toList();
        _pendingCount = data['pending_count'] ?? 0;
        _unpaidCount = data['unpaid_count'] ?? 0;
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

  Future<void> fetchCustomerDetail(int id) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedCustomer = null;
    _customerInvoices = [];
    _liveTraffic = null;
    notifyListeners();

    try {
      final res = await ApiClient().get('${AppConfig.epCustomers}/$id');
      if (res['success'] == true && res['data'] != null) {
        final data = res['data'];
        _selectedCustomer = CustomerModel.fromJson(data['customer']);
        final invList = data['invoices'] as List? ?? [];
        _customerInvoices = invList.map((i) => InvoiceModel.fromJson(i)).toList();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    // Auto-fetch live traffic in background
    fetchLiveTraffic(id);
  }

  Future<void> fetchLiveTraffic(int id) async {
    _isLoadingTraffic = true;
    notifyListeners();

    try {
      final res = await ApiClient().get('${AppConfig.epCustomers}/$id/traffic');
      if (res['success'] == true && res['data'] != null) {
        _liveTraffic = res['data'];
      }
    } catch (_) {} finally {
      _isLoadingTraffic = false;
      notifyListeners();
    }
  }

  Future<bool> updateWifi(int customerId, String ssid, String password) async {
    try {
      final res = await ApiClient().post(AppConfig.epQuickWifi, data: {
        'customer_id': customerId,
        'wifi_ssid': ssid.trim(),
        'wifi_password': password.trim(),
      });
      if (res['success'] == true) {
        SoundEffects.playSuccess();
        fetchCustomerDetail(customerId);
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
    return false;
  }

  Future<bool> rebootOnt(int customerId) async {
    try {
      final res = await ApiClient().post(AppConfig.epQuickReboot, data: {
        'customer_id': customerId,
      });
      if (res['success'] == true) {
        SoundEffects.playSuccess();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
    return false;
  }

  Future<bool> kickPppoe(int customerId, String username) async {
    try {
      final res = await ApiClient().post(AppConfig.epToolsKick, data: {
        'customer_id': customerId,
        'username': username,
      });
      if (res['success'] == true) {
        SoundEffects.playSuccess();
        fetchLiveTraffic(customerId);
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
    return false;
  }

  Future<bool> toggleIsolate(int customerId, bool isolate) async {
    try {
      final res = await ApiClient().post(AppConfig.epToolsIsolate, data: {
        'customer_id': customerId,
        'action': isolate ? 'isolate' : 'restore',
      });
      if (res['success'] == true) {
        SoundEffects.playSuccess();
        fetchCustomerDetail(customerId);
        fetchCustomers(silent: true);
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
    return false;
  }
}
