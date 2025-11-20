import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schedule/models/availability_model.dart';
import 'package:schedule/pages/schedule/timings_page.dart';


class DepartmentInfo extends StatelessWidget {
  const DepartmentInfo({super.key, required this.deptAvailabilityModel});

  final DepartmentAvailabilityModel deptAvailabilityModel;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(
          () => SelectTimings(
                deptAvailabilityModel: deptAvailabilityModel,
              ),
          transition: Transition.rightToLeft),
      borderRadius: BorderRadius.circular(10),
      splashColor: Colors.white.withOpacity(0.2),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color.fromARGB(34, 193, 193, 193),
          borderRadius: BorderRadius.circular(10),
          
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              deptAvailabilityModel.departmentName ?? "unknown",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 37, 37, 37).withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                _buildInfoText("Total",
                    int.parse(deptAvailabilityModel.totalAvailableClass ?? "nan")),
                const SizedBox(width: 15),
                _buildInfoText(
                    "Class", int.parse(deptAvailabilityModel.totalClass ?? "nan")),
                const SizedBox(width: 15),
                _buildInfoText(
                    "Labs", int.parse(deptAvailabilityModel.totalLabs ?? "nan")),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoText(String label, int count) {
    return Text(
      "$label: $count",
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.green,
      ),
    );
  }
}
