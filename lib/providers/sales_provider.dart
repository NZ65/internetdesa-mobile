import 'dart:io';
import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/registration_model.dart';
import '../services/api_service.dart';

class SalesProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<PackageModel> _packages = [];
  List<RegistrationModel> _registrations = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PackageModel> get packages => _packages;
  List<RegistrationModel> get registrations => _registrations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPackages() async {
    try {
      final response = await _api.get(AppConfig.epSalesPackages);
      if (response.data['success'] == true) {
        final list = (response.data['data'] as List)
            .map((e) => PackageModel.fromJson(e))
            .toList();
        _packages = list;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> fetchRegistrations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.get(AppConfig.epSalesRegistrations);
      if (response.data['success'] == true) {
        final list = (response.data['data'] as List)
            .map((e) => RegistrationModel.fromJson(e))
            .toList();
        _registrations = list;
      } else {
        _errorMessage = response.data['message'];
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> registerCustomer({
    required String name,
    required String phone,
    required String address,
    required int packageId,
    String? dropcoreLength,
    double? latitude,
    double? longitude,
    File? ktpFile,
    File? houseFile,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = {
        'name': name,
        'phone': phone,
        'address': address,
        'package_id': packageId,
        if (dropcoreLength != null && dropcoreLength.isNotEmpty) 'dropcore_length': dropcoreLength,
        if (latitude != null) 'lat': latitude,
        if (longitude != null) 'lng': longitude,
      };

      final files = <String, File?>{
        'ktp_photo': ktpFile,
        'house_photo': houseFile,
      };

      final response = await _api.postMultipart(AppConfig.epSalesRegister, data, files);

      _isLoading = false;
      notifyListeners();

      if (response.data['success'] == true) {
        await fetchRegistrations();
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
}
