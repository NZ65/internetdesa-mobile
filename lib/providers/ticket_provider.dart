import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/ticket_model.dart';
import '../services/api_service.dart';

class TicketProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<TicketModel> _tickets = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TicketModel> get tickets => _tickets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTickets({String status = 'open'}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.get(AppConfig.epTechnicianTickets, queryParameters: {
        'status': status,
      });

      if (response.data['success'] == true) {
        final list = (response.data['data'] as List)
            .map((e) => TicketModel.fromJson(e))
            .toList();
        _tickets = list;
      } else {
        _errorMessage = response.data['message'];
      }
    } catch (e) {
      _errorMessage = (e is dynamic && e.error != null) ? e.error.toString() : e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> resolveTicket(int ticketId, String notes) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.post(
        '${AppConfig.epResolveTicket}/$ticketId/resolve',
        data: {'resolution_notes': notes},
      );

      _isLoading = false;
      notifyListeners();

      if (response.data['success'] == true) {
        await fetchTickets();
        return true;
      } else {
        _errorMessage = response.data['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = (e is dynamic && e.error != null) ? e.error.toString() : e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Quick Tools: Remote Reboot ONT Modem
  Future<Map<String, dynamic>> quickReboot(int customerId) async {
    try {
      final response = await _api.post(AppConfig.epQuickReboot, data: {
        'customer_id': customerId,
      });
      return {
        'success': response.data['success'] == true,
        'message': response.data['message'] ?? 'Berhasil reboot modem.',
      };
    } catch (e) {
      final msg = (e is dynamic && e.error != null) ? e.error.toString() : e.toString();
      return {'success': false, 'message': msg};
    }
  }

  // Quick Tools: Remote Change Wi-Fi SSID & Password
  Future<Map<String, dynamic>> quickWifi({
    required int customerId,
    required String ssid,
    required String password,
  }) async {
    try {
      final response = await _api.post(AppConfig.epQuickWifi, data: {
        'customer_id': customerId,
        'wifi_ssid': ssid,
        'wifi_password': password,
      });
      return {
        'success': response.data['success'] == true,
        'message': response.data['message'] ?? 'Berhasil ganti WiFi.',
      };
    } catch (e) {
      final msg = (e is dynamic && e.error != null) ? e.error.toString() : e.toString();
      return {'success': false, 'message': msg};
    }
  }
}
