import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final username = "".obs;
  final email = "".obs;
  final isHOD = false.obs;
  final isAdmin = false.obs;
  final loading = true.obs;

  final String userEmail;
  StreamSubscription? _profileSubscription;

  ProfileController(this.userEmail);

  @override
  void onInit() {
    super.onInit();
    _setupProfileListener();
  }

  /// Real-time profile listener
  void _setupProfileListener() {
    _profileSubscription = _db
        .collection("faculty")
        .where("email", isEqualTo: userEmail)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      loading.value = false;
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        username.value = data["username"] ?? "";
        email.value = data["email"] ?? "";
        isHOD.value = data["isHOD"] ?? false;
        isAdmin.value = data["isAdmin"] ?? false;

      }
    }, onError: (e) {
      loading.value = false;
      print("Error fetching profile: $e");
    });
  }

  @override
  void onClose() {
    _profileSubscription?.cancel();
    super.onClose();
  }
}
