// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:shared_preferences/shared_preferences.dart';
import 'storage_service.dart';

class WebLocalStorageService implements LocalStorageService {
  static final WebLocalStorageService _singleton = WebLocalStorageService._internal();
  factory WebLocalStorageService() => _singleton;
  WebLocalStorageService._internal();

  SharedPreferences? _prefs;
  final Map<String, String> _cache = {};

  @override
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {}

    // Preload known storage keys into memory cache
    for (final k in [
      'wefeed_registered_users',
      'wefeed_donations',
      'wefeed_user_session',
      'wefeed_current_email',
      'wefeed_remember_email',
    ]) {
      final val = getString(k);
      if (val != null && val.isNotEmpty) {
        _cache[k] = val;
      }
    }
  }

  @override
  String? getString(String key) {
    if (_cache.containsKey(key) && _cache[key] != null && _cache[key]!.isNotEmpty) {
      return _cache[key];
    }
    // Check direct HTML localStorage first (synchronous & immediate)
    try {
      final webVal = html.window.localStorage[key] ?? html.window.localStorage['flutter.$key'];
      if (webVal != null && webVal.isNotEmpty) {
        _cache[key] = webVal;
        return webVal;
      }
    } catch (_) {}

    // Fallback to SharedPreferences if loaded
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
    // Write directly to HTML localStorage for zero-latency web persistence
    try {
      html.window.localStorage[key] = value;
      html.window.localStorage['flutter.$key'] = value;
    } catch (_) {}
    // Write to SharedPreferences instance
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
      html.window.localStorage.remove(key);
      html.window.localStorage.remove('flutter.$key');
    } catch (_) {}
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
      for (final key in html.window.localStorage.keys) {
        if (key.startsWith(prefix)) {
          final val = html.window.localStorage[key];
          if (val != null && val.isNotEmpty) {
            results[key] = val;
            _cache[key] = val;
          }
        } else if (key.startsWith('flutter.$prefix')) {
          final cleanKey = key.substring('flutter.'.length);
          final val = html.window.localStorage[key];
          if (val != null && val.isNotEmpty) {
            results[cleanKey] = val;
            _cache[cleanKey] = val;
          }
        }
      }
    } catch (_) {}
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

LocalStorageService getStorageService() => WebLocalStorageService();
