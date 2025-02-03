import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageUtil {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<void> save(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> get(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> remove(String key) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> removeAll() async {
    await _secureStorage.deleteAll();
  }
}
