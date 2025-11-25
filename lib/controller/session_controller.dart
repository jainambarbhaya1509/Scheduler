import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SessionController {
  final SharedPreferencesAsync pref = SharedPreferencesAsync();
  final uuid = Uuid();

  /// Save user session after login or password change
  Future<void> setSession(
    String username,
    String email,
    String password,
    String dept,
    bool isHOD,
    bool isSuperAdmin,
    bool isAdmin,
  ) async {
    await pref.setString("uuid", uuid.v4());
    await pref.setString("username", username);
    await pref.setString("email", email);
    await pref.setString("password", password);
    await pref.setString("department", dept);
    await pref.setBool("isHOD", isHOD);
    await pref.setBool("isSuperAdmin", isSuperAdmin);
    await pref.setBool("isAdmin", isAdmin);
  }

  /// Fetch session
  Future<Map<String, dynamic>> getSession() async {
    return {
      "uuid": await pref.getString("uuid"),
      "username": await pref.getString("username"),
      "email": await pref.getString("email"),
      "password": await pref.getString("password"),
      "department": await pref.getString("department"),
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
