import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {
  static SharedPreferences? _prefs;

  // Keys
  static const String tokenKey = 'token';
  static const String userIdKey = 'userId';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> setToken(String token) async {
    if (_prefs == null) await init();
    return await _prefs!.setString(tokenKey, token);
  }

  static String? getToken() {
    return _prefs?.getString(tokenKey);
  }

  static Future<bool> removeToken() async {
    if (_prefs == null) await init();
    return await _prefs!.remove(tokenKey);
  }

  static Future<bool> setUserId(String userId) async {
    if (_prefs == null) await init();
    return await _prefs!.setString(userIdKey, userId);
  }

  static String? getUserId() {
    return _prefs?.getString(userIdKey);
  }

  static Future<bool> removeUserId() async {
    if (_prefs == null) await init();
    return await _prefs!.remove(userIdKey);
  }
}
