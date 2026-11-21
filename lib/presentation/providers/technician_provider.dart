import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/sound_effects.dart';
import '../../data/models/odp_model.dart';
import '../../data/models/ticket_model.dart';

class TechnicianProvider extends ChangeNotifier {
  List<TicketModel> _tickets = [];
  List<OdpModel> _odps = [];
  List<Map<String, dynamic>> _losOnus = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Ping Tool Results
  Map<String, dynamic>? _pingResult;
  bool _isPinging = false;

  List<TicketModel> get tickets => _tickets;
  List<OdpModel> get odps => _odps;
  List<Map<String, dynamic>> get losOnus => _losOnus;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get pingResult => _pingResult;
  bool get isPinging => _isPinging;

  Future<void> fetchTickets({String status = 'open'}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient().get(AppConfig.epTechnicianTickets, queryParameters: {'status': status});
      if (res['success'] == true && res['data'] != null) {
        final list = res['data'] as List;
        _tickets = list.map((t) => TicketModel.fromJson(t)).toList();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resolveTicket(int ticketId, [String resolutionNotes = '', String? notes]) async {
    final effectiveNotes = (notes != null && notes.isNotEmpty) ? notes : resolutionNotes;
    try {
      final res = await ApiClient().post('${AppConfig.epTechnicianTickets}/$ticketId/resolve', data: {
        'resolution_notes': effectiveNotes.trim(),
      });
      if (res['success'] == true) {
        SoundEffects.playSuccess();
        await fetchTickets(status: 'open');
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
    return false;
  }

  Future<void> fetchOdps() async {
    try {
      final res = await ApiClient().get(AppConfig.epOdp);
      if (res['success'] == true && res['data'] != null) {
        final list = res['data'] as List;
        _odps = list.map((o) => OdpModel.fromJson(o)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> fetchLosOnus() async {
    try {
      final res = await ApiClient().get(AppConfig.epToolsLos);
      if (res['success'] == true && res['items'] != null) {
        final list = res['items'] as List;
        _losOnus = list.map((item) => Map<String, dynamic>.from(item)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> runPing(String target) async {
    _isPinging = true;
    _pingResult = null;
    notifyListeners();

    try {
      final res = await ApiClient().post(AppConfig.epToolsPing, data: {'target': target.trim()});
      _pingResult = Map<String, dynamic>.from(res);
      SoundEffects.playTap();
    } catch (e) {
      _pingResult = {'success': false, 'raw_output': e.toString()};
    } finally {
      _isPinging = false;
      notifyListeners();
    }
  }
}
