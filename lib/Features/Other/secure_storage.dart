import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

class SecureStorage {
  static const FlutterSecureStorage _secureStorage =
  FlutterSecureStorage(
    webOptions: WebOptions(
      dbName: "secureDb",
      publicKey: "my_secure_web_key_123",
    ),
  );

  // -----------------------------------
  // SAVE CREDENTIALS
  // -----------------------------------
  static Future<void> saveCredentials(
      String username, String password) async {
    if (kIsWeb) {
      try {
        // Try using secure storage first
        await _secureStorage.write(key: 'usrName', value: username);
        await _secureStorage.write(key: 'usrPass', value: password);
      } catch (e) {
        // Fallback: Browser localStorage using package:web
        web.window.localStorage.setItem('usrName', username);
        web.window.localStorage.setItem('usrPass', password);
      }
      return;
    }

    // Mobile + Desktop
    await _secureStorage.write(key: 'usrName', value: username);
    await _secureStorage.write(key: 'usrPass', value: password);
  }

  // -----------------------------------
  // GET CREDENTIALS
  // -----------------------------------
  static Future<Map<String, String?>> getCredentials() async {
    if (kIsWeb) {
      try {
        final u = await _secureStorage.read(key: 'usrName');
        final p = await _secureStorage.read(key: 'usrPass');

        if (u != null && p != null) {
          return {'usrName': u, 'usrPass': p};
        }
      } catch (_) {}

      // Fallback: localStorage
      return {
        'usrName': web.window.localStorage.getItem('usrName'),
        'usrPass': web.window.localStorage.getItem('usrPass'),
      };
    }

    // Mobile + Desktop
    final username = await _secureStorage.read(key: 'usrName');
    final password = await _secureStorage.read(key: 'usrPass');

    return {'usrName': username, 'usrPass': password};
  }

  // -----------------------------------
  // CLEAR CREDENTIALS
  // -----------------------------------
  static Future<void> clearCredentials() async {
    if (kIsWeb) {
      try {
        await _secureStorage.delete(key: 'usrName');
        await _secureStorage.delete(key: 'usrPass');
      } catch (_) {
        web.window.localStorage.removeItem('usrName');
        web.window.localStorage.removeItem('usrPass');
      }
      return;
    }

    // Mobile + Desktop
    await _secureStorage.delete(key: 'usrName');
    await _secureStorage.delete(key: 'usrPass');
  }
}



// class SecureStorage {
//   static const FlutterSecureStorage _storage = FlutterSecureStorage(
//     webOptions: WebOptions(
//       dbName: "secureDb",
//       publicKey: "my_secure_web_key_123",
//     ),
//   );
//
//   static Future<void> saveCredentials(String username, String password) async {
//     await _storage.write(key: 'usrName', value: username);
//     await _storage.write(key: 'usrPass', value: password);
//   }
//
//   static Future<Map<String, String?>> getCredentials() async {
//     final username = await _storage.read(key: 'usrName');
//     final password = await _storage.read(key: 'usrPass');
//
//     return {
//       'usrName': username,
//       'usrPass': password,
//     };
//   }
//
//   static Future<void> clearCredentials() async {
//     await _storage.delete(key: 'usrName');
//     await _storage.delete(key: 'usrPass');
//   }
// }
