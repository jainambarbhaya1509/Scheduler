import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/requests_controller.dart';

class RequestCard extends StatefulWidget {
  final Map<String, dynamic> request;

  const RequestCard({super.key, required this.request});

  @override
  State<RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {
  final RequestsController controller = Get.find<RequestsController>();
  bool showAcceptRejectButtons = false;
  bool isUpdating = false;

  void updateStatus(String newStatus) async {
    setState(() {
      isUpdating = true;
    });

    await controller.updateReservationStatus(
      bookingId: widget.request["bookingId"],
      dept: widget.request["department"],
      newStatus: newStatus,
      day: widget.request["day"],
      roomId: widget.request["roomId"],
      timeSlot: widget.request["timeSlot"],
      isClassroom: widget.request["isClassroom"] ?? true,
    );

    setState(() {
      showAcceptRejectButtons = false;
      isUpdating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;

    return InkWell(
      onTap: () {
        setState(() {
          showAcceptRejectButtons = !showAcceptRejectButtons;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 245, 245, 245),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// ROOM / LAB NAME
                    Text(
                      req["roomId"] ?? "",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),

                    /// TIMESLOT
                    Text(
                      req["timeSlot"] ?? "",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                /// USER EMAIL
                Text(
                  req["email"] ?? "",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// REASON BOX
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(34, 193, 193, 193),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                req["reason"] ?? "",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: const Color.fromARGB(95, 28, 28, 28),
                    ),
              ),
            ),

            const SizedBox(height: 10),

            /// ACCEPT / REJECT BUTTONS
            if (showAcceptRejectButtons)
              isUpdating
                  ? const CircularProgressIndicator()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                          onPressed: () => updateStatus('Accepted'),
                          icon: const Icon(Icons.check, color: Colors.green),
                          label: Text(
                            "Accept",
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => updateStatus('Rejected'),
                          icon: const Icon(Icons.close, color: Colors.redAccent),
                          label: Text(
                            "Reject",
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
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
