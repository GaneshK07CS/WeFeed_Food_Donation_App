import 'package:shared_preferences/shared_preferences.dart';
import 'storage_service.dart';

class IoLocalStorageService implements LocalStorageService {
  static final IoLocalStorageService _singleton = IoLocalStorageService._internal();
  factory IoLocalStorageService() => _singleton;
  IoLocalStorageService._internal();

  SharedPreferences? _prefs;
  final Map<String, String> _cache = {};

  @override
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      for (final k in [
        'wefeed_registered_users',
        'wefeed_donations',
        'wefeed_user_session',
        'wefeed_current_email',
        'wefeed_remember_email',
      ]) {
        final val = _prefs?.getString(k);
        if (val != null && val.isNotEmpty) {
          _cache[k] = val;
        }
      }
    } catch (e) {
      // Fallback
    }
  }

  @override
  String? getString(String key) {
    if (_cache.containsKey(key) && _cache[key] != null && _cache[key]!.isNotEmpty) {
      return _cache[key];
    }
    if (_prefs != null) {
      final val = _prefs!.getString(key);
      if (val != null && val.isNotEmpty) {
        _cache[key] = val;
        return val;
      }
    }
    return null;
  }

  @override
  Future<void> setString(String key, String value) async {
    _cache[key] = value;
    try {
      if (_prefs == null) {
        _prefs = await SharedPreferences.getInstance();
      }
      await _prefs?.setString(key, value);
    } catch (_) {}
  }

  @override
  Future<void> remove(String key) async {
    _cache.remove(key);
    try {
      if (_prefs == null) {
        _prefs = await SharedPreferences.getInstance();
      }
      await _prefs?.remove(key);
    } catch (_) {}
  }

  @override
  Map<String, String> getAllPrefixed(String prefix) {
    final Map<String, String> results = {};
    _cache.forEach((k, v) {
      if (k.startsWith(prefix) && v.isNotEmpty) {
        results[k] = v;
      }
    });
    try {
      if (_prefs != null) {
        for (final key in _prefs!.getKeys()) {
          if (key.startsWith(prefix)) {
            final val = _prefs!.getString(key);
            if (val != null && val.isNotEmpty) {
              results[key] = val;
              _cache[key] = val;
            }
          }
        }
      }
    } catch (_) {}
    return results;
  }
}

LocalStorageService getStorageService() => IoLocalStorageService();
