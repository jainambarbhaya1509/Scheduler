/// Helper utilities for slot operations
class SlotHelpers {
  /// Check if slot is available (no applications for given date)
  static bool isSlotAvailable(
    Map<String, dynamic>? slotData,
    String date,
  ) {
    if (slotData == null) return true;
    
    final applications = slotData['applications'];
    if (applications == null || applications is! Map) return true;
    
    final dateApps = applications[date];
    return dateApps == null || (dateApps is List && dateApps.isEmpty);
  }

  /// Get available slot count
  static int countAvailableSlots(
    List<Map<String, dynamic>> slots,
    String date,
  ) {
    return slots.where((slot) => isSlotAvailable(slot, date)).length;
  }

  /// Parse slot time
  static ({String start, String end}) parseSlotTime(String slotId) {
    final parts = slotId.split('-');
    return (
      start: parts.isNotEmpty ? parts.first : slotId,
      end: parts.length > 1 ? parts.last : slotId,
    );
  }
}
