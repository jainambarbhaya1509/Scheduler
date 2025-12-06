import 'package:get/get.dart';
import 'package:schedule/services/session_service.dart';

class SessionController extends GetxController {
  final _sessionService = SessionService();

  Future<void> setSession(
    String username,
    String email,
    String password,
    String dept,
    bool isHOD,
    bool isSuperAdmin,
    bool isAdmin,
  ) => _sessionService.setSession(
    username: username,
    email: email,
    password: password,
    dept: dept,
    isHOD: isHOD,
    isSuperAdmin: isSuperAdmin,
    isAdmin: isAdmin,
  );

  Future<Map<String, dynamic>> getSession() => _sessionService.getSession();

  Future<bool> isLoggedIn() => _sessionService.isLoggedIn();

  Future<void> clearSession() => _sessionService.clearSession();
}
