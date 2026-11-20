import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/app_config.dart';
import '../models/user_model.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Auth Token
  static Future<void> saveToken(String token) async {
    await _prefs?.setString(AppConfig.keyToken, token);
  }

  static String? getToken() {
    return _prefs?.getString(AppConfig.keyToken);
  }

  static Future<void> clearToken() async {
    await _prefs?.remove(AppConfig.keyToken);
  }

  // User Profile
  static Future<void> saveUser(UserModel user) async {
    await _prefs?.setString(AppConfig.keyUser, jsonEncode(user.toJson()));
  }

  static UserModel? getUser() {
    final str = _prefs?.getString(AppConfig.keyUser);
    if (str == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(str));
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearUser() async {
    await _prefs?.remove(AppConfig.keyUser);
  }

  // Base URL
  static Future<void> saveBaseUrl(String url) async {
    await _prefs?.setString(AppConfig.keyBaseUrl, url);
  }

  static String getBaseUrl() {
    return _prefs?.getString(AppConfig.keyBaseUrl) ?? AppConfig.defaultBaseUrl;
  }

  // Sound Feedback Toggle
  static Future<void> setSoundEnabled(bool enabled) async {
    await _prefs?.setBool(AppConfig.keySoundEnabled, enabled);
  }

  static bool isSoundEnabled() {
    return _prefs?.getBool(AppConfig.keySoundEnabled) ?? true;
  }
}
