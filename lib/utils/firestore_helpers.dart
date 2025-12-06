import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper utilities for common Firestore operations
class FirestoreHelpers {
  /// Build safe batch-aware operations
  static Future<void> executeBatch(
    FirebaseFirestore firestore,
    List<Future<void> Function(WriteBatch)> operations,
  ) async {
    WriteBatch batch = firestore.batch();
    int ops = 0;
    const maxOps = 450;

    for (final op in operations) {
      if (ops >= maxOps) {
        await batch.commit();
        batch = firestore.batch();
        ops = 0;
      }
      await op(batch);
      ops++;
    }

    if (ops > 0) await batch.commit();
  }

  /// Safe get with null check
  static T? safeGet<T>(Map<String, dynamic>? data, String key) {
    return data != null ? data[key] as T? : null;
  }

  /// Filter applications by status
  static List<Map<String, dynamic>> filterApplicationsByStatus(
    Map<String, dynamic>? applications,
    String date,
    String excludeStatus, {
    required bool exclude,
  }) {
    final appList = <Map<String, dynamic>>[];
    
    if (applications == null) {
      return appList;
    }

    final dateApps = applications[date];
    if (dateApps is! List) return appList;

    for (final app in dateApps) {
      if (app is! Map<String, dynamic>) continue;
      
      final status = (app['status'] as String?)?.toLowerCase() ?? 'pending';
      if (!exclude || status != excludeStatus.toLowerCase()) {
        appList.add(app);
      }
    }

    return appList;
  }
}
