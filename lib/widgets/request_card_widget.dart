import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/requests/requests_controller.dart';

class RequestCard extends StatefulWidget {
  final Map<String, dynamic> request;

  const RequestCard({super.key, required this.request});

  @override
  State<RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {
  final RequestsController controller = Get.find<RequestsController>();

  bool showActions = false;
  bool isUpdating = false;

  Future<void> updateStatus(String newStatus) async {
    setState(() => isUpdating = true);

    final req = widget.request;

    await controller.updateReservationStatus(
      bookingId: req["bookingId"] ?? "",
      dept: req["department"] ?? "",
      newStatus: newStatus,
      day: req["day"] ?? "",
      roomId: req["roomId"] ?? "",
      timeSlot: req["timeSlot"] ?? "",
      isClassroom: !req["roomId"].toString().toUpperCase().contains('L'),
      requestedDate: req["requestedDate"] ?? '',
    );

    if (mounted) {
      setState(() {
        showActions = false;
        isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;

    final room = req["roomId"] ?? "Unknown Room";
    final time = req["timeSlot"] ?? "Unknown Time";
    final user = req["username"] ?? "No Username";
    final reason = req["reason"] ?? "No reason provided";
    final requestedDate = req["requestedDate"] ?? '';

    return InkWell(
      onTap: () => setState(() => showActions = !showActions),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 245, 245, 245),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// FIRST ROW — ROOM + TIMESLOT + USER
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      user,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      requestedDate,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// REASON BOX
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(34, 193, 193, 193),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                reason,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: const Color.fromARGB(150, 28, 28, 30),
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// ACCEPT / REJECT BUTTONS
            if (showActions)
              isUpdating
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                          onPressed: () => updateStatus("Accepted"),
                          icon: const Icon(Icons.check, color: Colors.green),
                          label: const Text(
                            "Accept",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => updateStatus("Rejected"),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.redAccent,
                          ),
                          label: const Text(
                            "Reject",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
          ],
        ),
      ),
    );
  }
}
