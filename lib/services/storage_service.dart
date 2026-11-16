import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token
  static Future<void> saveToken(String token) async {
    await _prefs?.setString(AppConfig.keyToken, token);
  }

  static String? getToken() {
    return _prefs?.getString(AppConfig.keyToken);
  }

  static Future<void> clearToken() async {
    await _prefs?.remove(AppConfig.keyToken);
  }

  // User Data
  static Future<void> saveUser(UserModel user) async {
    final str = jsonEncode(user.toJson());
    await _prefs?.setString(AppConfig.keyUser, str);
  }

  static UserModel? getUser() {
    final str = _prefs?.getString(AppConfig.keyUser);
    if (str == null) return null;
    try {
      final map = jsonDecode(str);
      return UserModel.fromJson(map);
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

  // Clear Session
  static Future<void> clearAll() async {
    await _prefs?.remove(AppConfig.keyToken);
    await _prefs?.remove(AppConfig.keyUser);
  }
}
