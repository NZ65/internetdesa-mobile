import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/ticket_model.dart';
import '../services/api_service.dart';

class TicketProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<TicketModel> _tickets = [];
  Map<String, dynamic>? _toolsOverview;
  List<dynamic> _losOnus = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TicketModel> get tickets => _tickets;
  Map<String, dynamic>? get toolsOverview => _toolsOverview;
  List<dynamic> get losOnus => _losOnus;
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
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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
      final msg = e.toString().replaceAll('Exception: ', '');
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
        'message': response.data['message'] ?? 'Berhasil ubah SSID & kata sandi Wi-Fi.',
      };
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      return {'success': false, 'message': msg};
    }
  }

  // Network Tools: Fetch Tools Overview (Live MikroTik & OLT Status)
  Future<void> fetchToolsOverview() async {
    try {
      final response = await _api.get(AppConfig.epToolsOverview);
      if (response.data['success'] == true) {
        _toolsOverview = response.data['data'];
        notifyListeners();
      }
    } catch (e) {}
  }

  // Network Tools: Ping Test
  Future<Map<String, dynamic>> pingTest(String target) async {
    try {
      final response = await _api.post(AppConfig.epToolsPing, data: {
        'target': target,
      });
      return response.data;
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  // Network Tools: Kick / Reset PPPoE Session
  Future<Map<String, dynamic>> kickPppoe(String username, [int? customerId]) async {
    try {
      final response = await _api.post(AppConfig.epToolsKick, data: {
        'username': username,
        if (customerId != null) 'customer_id': customerId,
      });
      return {
        'success': response.data['success'] == true,
        'message': response.data['message'] ?? 'Perintah kick PPPoE terkirim.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  // Network Tools: Scan OLT LOS & Dying Gasp ONUs
  Future<List<dynamic>> scanOltLos() async {
    try {
      final response = await _api.get(AppConfig.epToolsLos);
      if (response.data['success'] == true) {
        _losOnus = response.data['items'] ?? [];
        notifyListeners();
        return _losOnus;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Network Tools: Toggle Isolate / Restore Customer Service
  Future<Map<String, dynamic>> toggleIsolate(int customerId, String action) async {
    try {
      final response = await _api.post(AppConfig.epToolsIsolate, data: {
        'customer_id': customerId,
        'action': action,
      });
      return {
        'success': response.data['success'] == true,
        'message': response.data['message'] ?? 'Aksi berhasil dieksekusi.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }
}
