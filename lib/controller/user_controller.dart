import 'package:get/get.dart';

class UserController extends GetxController {
  final RxString userId = "".obs;
  final RxString username = "".obs;
  final RxString email = "".obs;
  final RxString department = "".obs;
  final RxBool isHOD = false.obs;
  final RxBool isAdmin = false.obs;

  /// Set the current logged-in user info
  void setUser(String id, String name, String userEmail, String dept, {bool hod = false, bool admin = false}) {
    userId.value = id;
    username.value = name;
    email.value = userEmail;
    department.value = dept;
    isHOD.value = hod;
    isAdmin.value = admin;
  }

  /// Clear user data on logout
  void clearUser() {
    userId.value = "";
    username.value = "";
    email.value = "";
    department.value = "";
    isHOD.value = false;
    isAdmin.value = false;
  }
}
