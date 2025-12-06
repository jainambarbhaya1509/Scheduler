import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Optimized session service with singleton pattern
class SessionService {
  static final SessionService _instance = SessionService._internal();

  final SharedPreferencesAsync _pref = SharedPreferencesAsync();
  final _uuid = const Uuid();

  // Cache session data to avoid repeated reads
  Map<String, dynamic>? _sessionCache;

  SessionService._internal();

  factory SessionService() {
    return _instance;
  }

  /// Save user session
  Future<void> setSession({
    required String username,
    required String email,
    required String password,
    required String dept,
    required bool isHOD,
    required bool isSuperAdmin,
    required bool isAdmin,
  }) async {
    await _pref.setString("uuid", _uuid.v4());
    await _pref.setString("username", username);
    await _pref.setString("email", email);
    await _pref.setString("password", password);
    await _pref.setString("department", dept);
    await _pref.setBool("isHOD", isHOD);
    await _pref.setBool("isSuperAdmin", isSuperAdmin);
    await _pref.setBool("isAdmin", isAdmin);
    
    _sessionCache = null;
  }

  /// Get cached session (avoids repeated SharedPreferences reads)
  Future<Map<String, dynamic>> getSession() async {
    if (_sessionCache != null) return _sessionCache!;
    
    _sessionCache = {
      "uuid": await _pref.getString("uuid"),
      "username": await _pref.getString("username"),
      "email": await _pref.getString("email"),
      "password": await _pref.getString("password"),
      "department": await _pref.getString("department"),
      "isHOD": await _pref.getBool("isHOD") ?? false,
      "isSuperAdmin": await _pref.getBool("isSuperAdmin") ?? false,
      "isAdmin": await _pref.getBool("isAdmin") ?? false,
    };
    
    return _sessionCache!;
  }

  /// Check if logged in
  Future<bool> isLoggedIn() async {
    final id = await _pref.getString("uuid");
    return id != null;
  }

  /// Clear session
  Future<void> clearSession() async {
    await _pref.clear();
    _sessionCache = null;
  }
}
