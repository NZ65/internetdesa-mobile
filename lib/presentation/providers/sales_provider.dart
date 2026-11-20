import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/sound_effects.dart';
import '../../data/models/registration_model.dart';

class SalesProvider extends ChangeNotifier {
  List<RegistrationModel> _registrations = [];
  List<Map<String, dynamic>> _packages = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<RegistrationModel> get registrations => _registrations;
  List<Map<String, dynamic>> get packages => _packages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchRegistrations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient().get(AppConfig.epSalesRegistrations);
      if (res['success'] == true && res['data'] != null) {
        final list = res['data'] as List;
        _registrations = list.map((r) => RegistrationModel.fromJson(r)).toList();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPackages() async {
    try {
      final res = await ApiClient().get(AppConfig.epSalesPackages);
      if (res['success'] == true && res['data'] != null) {
        final list = res['data'] as List;
        _packages = list.map((p) => Map<String, dynamic>.from(p)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> registerProspect({
    required String name,
    required String phone,
    required String address,
    required int packageId,
    double? latitude,
    double? longitude,
    File? ktpPhoto,
    File? housePhoto,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fields = {
        'name': name.trim(),
        'phone': phone.trim(),
        'address': address.trim(),
        'package_id': packageId.toString(),
        if (latitude != null) 'lat': latitude.toString(),
        if (longitude != null) 'lng': longitude.toString(),
      };

      final files = {
        'ktp_photo': ktpPhoto,
        'house_photo': housePhoto,
      };

      final res = await ApiClient().postMultipart(AppConfig.epSalesRegister, fields, files);
      if (res['success'] == true) {
        SoundEffects.playSuccess();
        await fetchRegistrations();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }
}
