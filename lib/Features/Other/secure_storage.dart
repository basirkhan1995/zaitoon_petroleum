import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final _storage = FlutterSecureStorage();

  static Future<void> saveCredentials(String username, String password) async {
    await _storage.write(key: 'usrName', value: username);
    await _storage.write(key: 'usrPass', value: password);
  }

  static Future<Map<String, String?>> getCredentials() async {
    final username = await _storage.read(key: 'usrName');
    final password = await _storage.read(key: 'usrPass');
    return {'usrName': username, 'usrPass': password};
  }

  static Future<void> clearCredentials() async {
    await _storage.delete(key: 'usrName');
    await _storage.delete(key: 'usrPass');
  }
}