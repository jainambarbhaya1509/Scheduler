import 'package:get/get.dart';

class UserController extends GetxController {
  final RxString userId = "".obs;
  final RxString username = "".obs;
  final RxString email = "".obs;
  final RxString department = "".obs;

  /// Set the current logged-in user info
  void setUser(String id, String name, String userEmail, String dept) {
    userId.value = id;
    username.value = name;
    email.value = userEmail;
    department.value = dept;
  }
}
