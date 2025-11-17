import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/timings_controller.dart';
import 'package:schedule/models/class_avalability_model.dart';

class ApplyModal extends StatelessWidget {
  final String title;
  final String time;
  final ClassAvailabilityModel classModel;
  final List<UsersAppliedModel> applicants;

  ApplyModal({
    super.key,
    required this.title,
    required this.time,
    required this.classModel,
    required this.applicants,
  });

  final TextEditingController reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final timingController = Get.find<TimingsController>();

    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    time,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              const Spacer(),

              TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return Dialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Enter details to apply",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),

                              TextFormField(
                                controller: reasonController,
                                maxLength: 60,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  hintText: "Enter reason/details",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),

                              ElevatedButton(
                                onPressed: () {
                                  final reason = reasonController.text.trim();
                                  if (reason.isEmpty) return;

                                  timingController.apply(
                                    classModel: classModel,

                                    timeslot: time,
                                    reason: reason,
                                  );

                                  Get.back(); // close dialog
                                  Get.back(); // close ApplyModal
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  "Apply",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Apply",
                  style: TextStyle(color: Colors.white),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 250,
            child: applicants.isEmpty
                ? const Center(
                    child: Text(
                      "Be the first to apply",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: applicants.length,
                    itemBuilder: (context, index) {
                      final applicant = applicants[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        child: Row(
                          children: [
                            const CircleAvatar(radius: 20),
                            const SizedBox(width: 10),

                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "${applicant.name}\n",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    TextSpan(
                                      text: applicant.description,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Text(
                              applicant.status,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: applicant.status == "Accepted"
                                    ? Colors.green
                                    : applicant.status == "Rejected"
                                    ? Colors.red
                                    : const Color(0xFFB8A606),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
