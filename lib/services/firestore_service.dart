import 'package:cloud_firestore/cloud_firestore.dart';

/// Centralized Firestore service to eliminate redundant instantiation
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreService._internal();

  factory FirestoreService() {
    return _instance;
  }

  FirebaseFirestore get instance => _firestore;

  /// Helper method for batch safe operations
  static const int maxBatchOps = 450;
}
