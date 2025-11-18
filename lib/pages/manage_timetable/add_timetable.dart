import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/upload_controller.dart';

class AddTimeTable extends StatelessWidget {
  const AddTimeTable({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UploadTTController());
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 10, left: 12, right: 12, bottom: 10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Manage Time Table",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => _buildDropdownRow(
                  label: 'Select Department',
                  value: controller.department.value,
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
              const SizedBox(height: 24),
              Obx(
                () => Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed:
                          controller.running.value ||
                              controller.classNo.value.isEmpty
                          ? null
                          : () => controller.pickFileAndProcess(),
                      icon: const Icon(
                        Icons.upload_file_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Pick & Upload Excel',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),

                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.black87,
                        disabledBackgroundColor: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (controller.running.value)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: SizedBox(
                          height: 20,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.black87,
                            ),
                          ),
                        ),
                      ),
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
            hint: Text(
              'Select $label',
              style: const TextStyle(color: Colors.black54),
            ),
            items: items
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
