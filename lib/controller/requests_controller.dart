import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/user_controller.dart';

class RequestsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final UserController _userController = Get.find<UserController>();

  // Lists for each status
  var allRequests = <Map<String, dynamic>>[].obs;
  var acceptedRequests = <Map<String, dynamic>>[].obs;
  var rejectedRequests = <Map<String, dynamic>>[].obs;
  var pendingRequests = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();

    fetchUserRequests();
    fetchReqForAdmin();
  }

  Future<void> fetchUserRequests() async {
    try {
      RxString userEmail = _userController.email;
      print(userEmail);
      // Clear previous lists
      allRequests.clear();
      acceptedRequests.clear();
      rejectedRequests.clear();
      pendingRequests.clear();

      // Get all departments
      final departmentsSnapshot = await _firestore.collection('requests').get();

      for (var deptDoc in departmentsSnapshot.docs) {
        String deptName = deptDoc.id;
        print(deptName);
        // Get requests_list inside each department
        final requestsSnapshot = await _firestore
            .collection('requests')
            .doc(deptName)
            .collection('requests_list')
            .get();

        for (var requestDoc in requestsSnapshot.docs) {
          var data = requestDoc.data();
          print(data["email"]);
          // Filter by logged-in user's email
          if (data['email'] == userEmail.value) {
            allRequests.add(data);

            String status = data['status'] ?? 'Pending';
            switch (status.toLowerCase()) {
              case 'accepted':
                acceptedRequests.add(data);
                break;
              case 'rejected':
                rejectedRequests.add(data);
                break;
              case 'pending':
              default:
                pendingRequests.add(data);
                break;
            }
          }
        }
      }
      print(allRequests);
    } catch (e) {
      print("Error fetching requests: $e");
    }
  }

  var searchQuery = "".obs;

  Future<void> fetchReqForAdmin() async {
    try {
      String dept = _userController.department.value;

      allRequests.clear();

      final requestsSnapshot = await _firestore
          .collection('requests')
          .doc(dept)
          .collection('requests_list')
          .get();

      for (var requestDoc in requestsSnapshot.docs) {
        allRequests.add(requestDoc.data());
      }

      print('All requests for $dept: $allRequests');
    } catch (e) {
      print("Error fetching requests for admin: $e");
    }
  }

  Future<void> updateReservationStatus({
    required String email,
    required String dept,
    required String timeSlot, // to identify the specific request
    required String newStatus, // 'Accepted' or 'Rejected'
  }) async {
    try {
      // Reference to the requests_list for the department
      final requestsRef = _firestore
          .collection('requests')
          .doc(dept)
          .collection('requests_list');

      // Query the document by email and timeSlot (or any unique identifier)
      final querySnapshot = await requestsRef
          .where('email', isEqualTo: email)
          .where('timeSlot', isEqualTo: timeSlot)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("No request found for $email at $timeSlot");
        return;
      }

      // Update the status of the matching request(s)
      for (var doc in querySnapshot.docs) {
        await requestsRef.doc(doc.id).update({'status': newStatus});
        print("Request status updated to $newStatus for $email");
      }

      // Optionally refresh the local lists

// TODO: 

      fetchReqForAdmin();
      fetchUserRequests();
    } catch (e) {
      print("Error updating request status: $e");
    }
  }
}
