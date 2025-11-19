import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/timetable_controller.dart';

class AddTimeTable extends StatelessWidget {
  const AddTimeTable({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UploadTTController());

    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Manage Time Table",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

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
                      onPressed: controller.running.value ||
                              controller.classNo.value.isEmpty
                          ? null
                          : () => controller.pickFileAndProcess(),
                      icon: const Icon(Icons.upload_file_rounded, color: Colors.white),
                      label: const Text(
                        'Pick & Upload Excel',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.black87),
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
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
        Text(label,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
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
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
