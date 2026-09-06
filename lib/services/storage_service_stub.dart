import 'storage_service.dart';

class StubLocalStorageService implements LocalStorageService {
  static final StubLocalStorageService _singleton = StubLocalStorageService._internal();
  factory StubLocalStorageService() => _singleton;
  StubLocalStorageService._internal();

  final Map<String, String> _cache = {};

  @override
  Future<void> init() async {}

  @override
  String? getString(String key) => _cache[key];

  @override
  Future<void> setString(String key, String value) async {
    _cache[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _cache.remove(key);
  }

  @override
  Map<String, String> getAllPrefixed(String prefix) {
    final Map<String, String> results = {};
    _cache.forEach((k, v) {
      if (k.startsWith(prefix)) {
        results[k] = v;
      }
    });
    return results;
  }
}

LocalStorageService getStorageService() => StubLocalStorageService();
