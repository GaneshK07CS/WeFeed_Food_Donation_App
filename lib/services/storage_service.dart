import 'storage_service_stub.dart'
    if (dart.library.html) 'storage_service_web.dart'
    if (dart.library.io) 'storage_service_io.dart';

abstract class LocalStorageService {
  static final LocalStorageService _instance = getStorageService();
  static LocalStorageService get instance => _instance;

  Future<void> init();
  String? getString(String key);
  Future<void> setString(String key, String value);
  Future<void> remove(String key);
  Map<String, String> getAllPrefixed(String prefix);
}
