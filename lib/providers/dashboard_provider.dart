import 'dart:async';
import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/dashboard_model.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  DashboardData? _dashboardData;
  bool _isLoading = false;
  String? _errorMessage;

  // Real-time LOS Telemetry & Alerts
  int _losCount = 0;
  List<Map<String, dynamic>> _losItems = [];
  final Set<String> _knownLosKeys = {};
  Timer? _pollingTimer;

  DashboardData? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get losCount => _losCount;
  List<Map<String, dynamic>> get losItems => _losItems;

  DashboardProvider() {
    startAutoPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void startAutoPolling() {
    _pollingTimer?.cancel();
    // Poll every 35 seconds for live status & LOS check
    _pollingTimer = Timer.periodic(const Duration(seconds: 35), (timer) {
      fetchDashboard(isBackground: true);
      checkOltLosStatus();
    });
  }

  Future<void> fetchDashboard({bool isBackground = false}) async {
    if (!isBackground) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final response = await _api.get(AppConfig.epDashboard);
      if (response.data['success'] == true) {
        _dashboardData = DashboardData.fromJson(response.data['data']);
        
        // Also check if OLT LOS count is provided in dashboard
        final olt = _dashboardData?.olt;
        if (olt != null && olt['los_onus'] != null) {
          final count = (olt['los_onus'] is num) ? (olt['los_onus'] as num).toInt() : int.tryParse(olt['los_onus'].toString()) ?? 0;
          _losCount = count;
        }
      } else {
        if (!isBackground) {
          _errorMessage = response.data['message'] ?? 'Gagal memuat dashboard.';
        }
      }
    } catch (e) {
      if (!isBackground) {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      }
    }

    // Always follow up with detailed LOS check
    await checkOltLosStatus();

    if (!isBackground) {
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> checkOltLosStatus() async {
    try {
      final res = await _api.get(AppConfig.epToolsLos);
      if (res.data['success'] == true) {
        final List<dynamic> rawItems = res.data['items'] ?? [];
        final previousLosCount = _losCount;
        _losItems = rawItems.map((e) => Map<String, dynamic>.from(e)).toList();
        
        // Filter specifically for pure LOS (cable cut) or power off
        final pureLos = _losItems.where((o) => o['is_los'] == true || o['status'] == 'offline').toList();
        _losCount = pureLos.length;

        // Check for new LOS that wasn't alerted yet
        for (final item in pureLos) {
          final key = '${item['onu_id']}_${item['serial_number'] ?? item['name']}';
          if (!_knownLosKeys.contains(key)) {
            _knownLosKeys.add(key);
            // Fire high priority local Android notification
            final custName = item['name'] ?? 'Pelanggan';
            final port = item['port'] ?? 'PON';
            final rx = item['rx_power'] ?? '0.00 dBm';
            NotificationService.showLosNotification(
              customerName: custName,
              detail: 'Kabel optik putus di Port $port ($rx). Harap segera cek jalur!',
            );
          }
        }

        // If LOS recovered
        if (previousLosCount > 0 && _losCount == 0) {
          NotificationService.showGeneralNotification(
            title: '✅ Jaringan Pulih',
            body: 'Semua koneksi kabel fiber optik pelanggan telah kembali normal.',
          );
        }
        notifyListeners();
      }
    } catch (_) {
      // Silently ignore background polling errors
    }
  }
}
