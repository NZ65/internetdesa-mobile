import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/dashboard_model.dart';
import '../services/api_service.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  DashboardData? _dashboardData;
  bool _isLoading = false;
  String? _errorMessage;

  DashboardData? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.get(AppConfig.epDashboard);
      if (response.data['success'] == true) {
        _dashboardData = DashboardData.fromJson(response.data['data']);
      } else {
        _errorMessage = response.data['message'] ?? 'Gagal memuat dashboard.';
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }
}
