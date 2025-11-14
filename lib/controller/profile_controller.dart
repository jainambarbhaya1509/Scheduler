import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Profile fields
  final username = "".obs;
  final email = "".obs;
  final isHOD = false.obs;

  // Loading
  final loading = true.obs;

  // Pass logged-in user email
  final String userEmail;

  ProfileController(this.userEmail);

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      loading.value = true;

      final query = await _db
          .collection("faculty")
          .where("email", isEqualTo: userEmail)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        username.value = data["username"];
        email.value = data["email"];
        isHOD.value = data["isHOD"];
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      loading.value = false;
    }
  }
}
