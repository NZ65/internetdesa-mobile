import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null && _user != null;

  AuthProvider() {
    initAuth();
  }

  void initAuth() {
    _token = StorageService.getToken();
    _user = StorageService.getUser();
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.post(AppConfig.epLogin, data: {
        'username': username,
        'password': password,
      });

      if (response.data['success'] == true) {
        final tokenStr = response.data['token'];
        final userObj = UserModel.fromJson(response.data['user']);

        _token = tokenStr;
        _user = userObj;

        await StorageService.saveToken(tokenStr);
        await StorageService.saveUser(userObj);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Login gagal.';
      }
    } catch (e) {
      _errorMessage = (e is dynamic && e.error != null) ? e.error.toString() : e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> loginWithGithubCode(String code) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.post(AppConfig.epGithubAuth, data: {
        'code': code.trim(),
      });

      if (response.data['success'] == true) {
        final tokenStr = response.data['token'];
        final userObj = UserModel.fromJson(response.data['user']);

        _token = tokenStr;
        _user = userObj;

        await StorageService.saveToken(tokenStr);
        await StorageService.saveUser(userObj);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Otentikasi GitHub gagal.';
      }
    } catch (e) {
      _errorMessage = (e is dynamic && e.error != null) ? e.error.toString() : e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    await StorageService.clearAll();
    notifyListeners();
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.post(AppConfig.epChangePassword, data: {
        'old_password': oldPassword,
        'new_password': newPassword,
      });

      _isLoading = false;
      notifyListeners();
      return response.data['success'] == true;
    } catch (e) {
      _errorMessage = (e is dynamic && e.error != null) ? e.error.toString() : e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
