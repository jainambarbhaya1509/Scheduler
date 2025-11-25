import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SessionController {
  final SharedPreferencesAsync pref = SharedPreferencesAsync();
  final uuid = Uuid();

  /// Save user session after login
  Future<void> setSession(
    String email,
    String password,
    bool isHOD,
    bool isSuperAdmin,
    bool isAdmin,
  ) async {
    await pref.setString("uuid", uuid.v4());
    await pref.setString("email", email);
    await pref.setString("password", password);
    await pref.setBool("isHOD", isHOD);
    await pref.setBool("isSuperAdmin", isSuperAdmin);
    await pref.setBool("isAdmin", isAdmin);
  }

  /// Fetch session
  Future<Map<String, dynamic>> getSession() async {
    return {
      "uuid": await pref.getString("uuid"),
      "email": await pref.getString("email"),
      "password": await pref.getString("password"),
      "isHOD": await pref.getBool("isHOD") ?? false,
      "isSuperAdmin": await pref.getBool("isSuperAdmin") ?? false,
      "isAdmin": await pref.getBool("isAdmin") ?? false,
    };
  }

  /// Check if login exists
  Future<bool> isLoggedIn() async {
    final id = await pref.getString("uuid");
    return id != null;
  }

  /// Clear all session info
  Future<void> clearSession() async {
    await pref.clear();
  }
}
