import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:deliverapp/core/services/service_locator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants.dart';

final StorageService storageService = locator.get<StorageService>();

class StorageService {
  Future initHiveInApp() async {
    await Hive.initFlutter();
    await Hive.openBox(hiveBoxName);
  }
//
//   Future writeFSS(String key, String value) async {
//     const storage = FlutterSecureStorage();
//
//     AndroidOptions getAndroidOptions() => const AndroidOptions(
//           encryptedSharedPreferences:
//               true, // Use EncryptedSharedPreferences for added security
//         );
//     IOSOptions getIOSOptions() => const IOSOptions(
//           accessibility: KeychainAccessibility
//               .first_unlock, // Controls when the key is accessible
//         );
//
//     await storage.write(
//         key: key,
//         value: value,
//         aOptions: getAndroidOptions(),
//         iOptions: getIOSOptions());
//
//     await storage.write(key: key, value: value);
//   }
//
//   Future<String?> readFSS(String key) async {
//     const storage = FlutterSecureStorage();
//     String? value = await storage.read(key: key);
//     return value;
//   }
//
//   Future readAllFSS() async {
//     const storage = FlutterSecureStorage();
// // Read all values
//     Map<String, String> allValues = await storage.readAll();
//   }
//
//   Future deleteAllKeysFSS() async {
//     const storage = FlutterSecureStorage();
//     await Hive.openBox(hiveBoxName);
//   }
//
//   Future deleteKeyFSS(String key) async {
//     const storage = FlutterSecureStorage();
//     await storage.delete(key: key);
//   }

  clearBox() async {
    var box = Hive.box(hiveBoxName);
    box.clear();
  }

  void setStartLocString(String loc) async {
    try {
      var box = Hive.box(hiveBoxName);
      box.put('START_LOCATION', loc);
      debugPrint("START_LOCATION set success");
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getStartLoc() async {
    try {
      var box = Hive.box(hiveBoxName);
      String? token = box.get('START_LOCATION') as String?;
      return token;
    } catch (e) {
      rethrow;
    }
  }

  void setEndLocString(String loc) async {
    try {
      var box = Hive.box(hiveBoxName);
      box.put('END_LOCATION', loc);
      debugPrint("END_LOCATION set success");
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getEndLoc() async {
    try {
      var box = Hive.box(hiveBoxName);
      String? token = box.get('END_LOCATION') as String?;
      return token;
    } catch (e) {
      rethrow;
    }
  }

  void setIsFirstTime(String data) async {
    try {
      var box = Hive.box(hiveBoxName);
      box.put('IS_FIRST_TIME', data);
      debugPrint("Token set success");
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic>? getIsFirstTime() async {
    try {
      var box = Hive.box(hiveBoxName);
      var token = box.get('IS_FIRST_TIME');
      return token;
    } catch (e) {
      rethrow;
    }
  }

  void setNotificationAsk(String data) async {
    try {
      var box = Hive.box(hiveBoxName);
      box.put('NOTIFICATION_ASK', data);
      debugPrint("notification permission asked");
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getNotificationAsk() async {
    try {
      var box = Hive.box(hiveBoxName);
      var value = box.get('NOTIFICATION_ASK') as String?;
      return value ?? "false";
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getAuthToken() async {
    try {
      var box = Hive.box(hiveBoxName);
      String? token = box.get('TOKEN_STORE_KEY') as String?;
      return token;
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      var box = Hive.box(hiveBoxName);
      String? token = box.get('REFRESH_TOKEN') as String?;
      return token;
    } catch (e) {
      rethrow;
    }
  }

  void setAuthToken(String token) async {
    try {
      var box = Hive.box(hiveBoxName);
      box.put('TOKEN_STORE_KEY', token);
      debugPrint("Token set success");
    } catch (e) {
      rethrow;
    }
  }

  void setRefreshToken(String token) async {
    try {
      var box = Hive.box(hiveBoxName);
      box.put('REFRESH_TOKEN', token);
      debugPrint("Token set success");
    } catch (e) {
      rethrow;
    }
  }

  void setLatitude(String value) async {
    try {
      var box = Hive.box(hiveBoxName);
      box.put(latitudeHiveKey, value);
    } catch (e) {
      rethrow;
    }
  }

  Future<String?>? getLatitude() async {
    try {
      var box = Hive.box(hiveBoxName);
      String? value = box.get(latitudeHiveKey);

      return value;
    } catch (e) {
      rethrow;
    }
  }

  void setLongitude(String value) async {
    try {
      var box = Hive.box(hiveBoxName);
      box.put(longitudeHiveKey, value);
    } catch (e) {
      rethrow;
    }
  }

  Future<String?>? getLongitude() async {
    try {
      var box = Hive.box(hiveBoxName);
      String? value = box.get(longitudeHiveKey);

      return value;
    } catch (e) {
      rethrow;
    }
  }
}

class SecureStorageUtil {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveValue(String key, String value) async {
    // AndroidOptions getAndroidOptions() => const AndroidOptions(
    //   encryptedSharedPreferences: true,
    // );
    //
    // IOSOptions getIOSOptions() => const IOSOptions(
    //   accessibility: KeychainAccessibility.first_unlock,
    // );

    try {
      await _storage.write(
        key: key,
        value: value,
      );
      // aOptions: getAndroidOptions(),
      // iOptions: getIOSOptions());
      debugPrint("Saved value for key: $key");
    } catch (e) {
      debugPrint("Error saving value for key: $key. Error: $e");
    }
  }

  static Future<String?> getValue(String key) async {
    try {
      String? value = await _storage.read(key: key);
      if (value == null) {
        debugPrint("No value found for key: $key");
      } else {
        debugPrint("Retrieved value for key: $key -> $value");
      }
      return value;
    } catch (e) {
      debugPrint("Error retrieving value for key: $key. Error: $e");
      return null;
    }
  }

  static Future<void> deleteValue(String key) async {
    try {
      await _storage.delete(key: key);
      debugPrint("Deleted value for key: $key");
    } catch (e) {
      debugPrint("Error deleting value for key: $key. Error: $e");
    }
  }
}
