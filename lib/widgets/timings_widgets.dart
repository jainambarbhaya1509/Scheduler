import 'package:flutter/material.dart';
import 'package:schedule/models/class_avalability_model.dart';

class DisplayTimings extends StatelessWidget {
  const DisplayTimings({super.key, required this.classAvailabilityModel});

  final ClassAvailabilityModel classAvailabilityModel;

  @override
  Widget build(BuildContext context) {
    final hasApplicants = classAvailabilityModel.appliedUsers.isNotEmpty;
    final applicantCount = classAvailabilityModel.appliedUsers.length;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color.fromARGB(34, 193, 193, 193),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class name and timing
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: "${classAvailabilityModel.className}\n",
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: classAvailabilityModel.timings,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // const SizedBox(height: 6),

          // // Optional info line if users applied
          // if (hasApplicants)
          //   Text(
          //     applicantCount == 1
          //         ? "1 user has applied"
          //         : "$applicantCount users have applied",
          //     style: Theme.of(context).textTheme.bodySmall?.copyWith(
          //           fontWeight: FontWeight.w500,
          //           color: Colors.grey[700],
          //         ),
          //   ),
        ],
      ),
    );
  }
}
