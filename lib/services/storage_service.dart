import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      // Crash-safe: app continues without storage
      assert(() { print('[StorageService] init failed: $e'); return true; }());
    }
  }

  static Future<bool> setString(String key, String value) async {
    try { return await _prefs?.setString(key, value) ?? false; } catch (_) { return false; }
  }

  static String? getString(String key) {
    try { return _prefs?.getString(key); } catch (_) { return null; }
  }

  static Future<bool> setBool(String key, bool value) async {
    try { return await _prefs?.setBool(key, value) ?? false; } catch (_) { return false; }
  }

  static bool? getBool(String key) {
    try { return _prefs?.getBool(key); } catch (_) { return null; }
  }

  static Future<bool> setInt(String key, int value) async {
    try { return await _prefs?.setInt(key, value) ?? false; } catch (_) { return false; }
  }

  static int? getInt(String key) {
    try { return _prefs?.getInt(key); } catch (_) { return null; }
  }

  static Future<bool> remove(String key) async {
    try { return await _prefs?.remove(key) ?? false; } catch (_) { return false; }
  }

  static Future<bool> clear() async {
    try { return await _prefs?.clear() ?? false; } catch (_) { return false; }
  }
}
