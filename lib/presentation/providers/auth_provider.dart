import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/sound_effects.dart';
import '../../data/models/user_model.dart';
import '../../data/services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _loadUserFromStorage();
  }

  void _loadUserFromStorage() {
    _user = StorageService.getUser();
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient().post(AppConfig.epLogin, data: {
        'username': username.trim(),
        'password': password.trim(),
      });

      if (res['success'] == true && res['token'] != null) {
        final token = res['token'];
        final userMap = res['user'];
        _user = UserModel.fromJson(userMap);

        await StorageService.saveToken(token);
        await StorageService.saveUser(_user!);

        SoundEffects.playSuccess();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw ApiException(res['message'] ?? 'Login gagal. Periksa username dan password.');
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGitHubCode(String code) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient().post(AppConfig.epGithubAuth, data: {
        'code': code.trim(),
      });

      if (res['success'] == true && res['token'] != null) {
        final token = res['token'];
        final userMap = res['user'];
        _user = UserModel.fromJson(userMap);

        await StorageService.saveToken(token);
        await StorageService.saveUser(_user!);

        SoundEffects.playSuccess();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw ApiException(res['message'] ?? 'Login GitHub gagal.');
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient().post(AppConfig.epChangePassword, data: {
        'old_password': oldPassword,
        'new_password': newPassword,
      });

      _isLoading = false;
      notifyListeners();
      return res['success'] == true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    await StorageService.clearToken();
    await StorageService.clearUser();
    notifyListeners();
  }
}
