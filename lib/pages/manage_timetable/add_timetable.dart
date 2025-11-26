import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schedule/helper_func/download.dart';
import 'package:schedule/pages/manage_timetable/view_reservations.dart';
import '../../controller/timetable_controller.dart';

class AddTimeTable extends StatelessWidget {
  const AddTimeTable({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UploadTTController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Manage Time Table",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            IconButton(
              icon: const Icon(Icons.calendar_today_sharp),
              onPressed: () {
                Get.to(
                  () => ViewReservations(),
                  transition: Transition.cupertino,
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),

        _downloadTemplate(),
        const SizedBox(height: 30),

        /// ------------------ Department dropdown ------------------
        Obx(
          () => _buildDropdownRow(
            label: 'Select Department',
            value: controller.department.value.isEmpty
                ? null
                : controller.department.value,
            items: controller.departmentData.keys.toList(),
            onChanged: controller.running.value
                ? null
                : (v) {
                    if (v != null) {
                      controller.department.value = v;
                      controller.resetSelections();
                    }
                  },
          ),
        ),
        const SizedBox(height: 16),

        /// ------------------ Class/Lab dropdown ------------------
        Obx(
          () => _buildDropdownRow(
            label: 'Select Class/Lab',
            value: controller.classNo.value.isEmpty
                ? null
                : controller.classNo.value,
            items: controller.classOptions,
            onChanged: controller.running.value
                ? null
                : (v) {
                    if (v != null) {
                      controller.classNo.value = v;
                    }
                  },
          ),
        ),

        const SizedBox(height: 30),

        /// ------------------ Upload button ------------------
        Obx(
          () => Column(
            children: [
              ElevatedButton.icon(
                onPressed:
                    controller.running.value || controller.classNo.value.isEmpty
                    ? null
                    : () => controller.pickFileAndProcess(),
                icon: const Icon(
                  Icons.upload_file_rounded,
                  color: Colors.white,
                ),
                label: const Text(
                  'Pick & Upload Excel',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  disabledBackgroundColor: Colors.grey,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),

              if (controller.running.value) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.black87,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _downloadTemplate() {
    return InkWell(
      onTap: () {
        downloadExcelFile(
          "https://docs.google.com/spreadsheets/d/1dNVlk9n47tl3xqS5viNG4UXwFpQ8ypTW/edit?usp=sharing&ouid=113030285759050171649&rtpof=true&sd=true",
          "template",
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.black45.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Download .xlsx Template",
              style: TextStyle(
                color: Colors.black45,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Spacer(),
            Icon(Icons.arrow_downward_rounded, size: 15, color: Colors.black45),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownRow({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            hint: Text("Select $label"),
            items: items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
