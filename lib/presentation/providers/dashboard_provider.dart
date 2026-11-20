import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../core/network/api_client.dart';
import '../../data/models/dashboard_model.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardModel? _dashboard;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _pollingTimer;

  DashboardModel? get dashboard => _dashboard;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Mascot assistant emotion state
  bool get hasAlert => (_dashboard?.losOnus ?? 0) > 0 || (_dashboard?.isMikrotikOnline == false);
  int get losCount => _dashboard?.losOnus ?? 0;

  DashboardProvider() {
    fetchDashboard();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      fetchDashboard(silent: true);
    });
  }

  Future<void> fetchDashboard({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final res = await ApiClient().get(AppConfig.epDashboard);
      if (res != null) {
        _dashboard = DashboardModel.fromJson(res);
        _errorMessage = null;
      }
    } catch (e) {
      if (!silent) _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
