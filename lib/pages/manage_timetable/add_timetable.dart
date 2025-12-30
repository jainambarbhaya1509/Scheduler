import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schedule/helper/download/download_mobile.dart';
import 'package:schedule/helper/download/download_web.dart';
import 'package:schedule/pages/manage_timetable/view_reservations.dart';
import '../../controller/schedule/timetable_controller.dart';

class AddTimeTable extends StatelessWidget {
  const AddTimeTable({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TimetableController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _downloadTemplate(),
        const SizedBox(height: 16),

        /// ------------------ Upload button ------------------
        Obx(() {
          if (controller.classes.isNotEmpty) {
            return Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Upload button at the top
                  TextButton(
                    onPressed: controller.running.value
                        ? null
                        : () => controller.pickFileAndProcess(),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black87,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text(
                      'Pick & Upload Excel',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // List of uploaded classes
                  Expanded(
                    child: ListView.builder(
                      itemCount: controller.classes.length,
                      itemBuilder: (context, index) {
                        final className = controller.classes[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                className,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              Spacer(),
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      title: Text(
                                        'Confirm Delete',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text.rich(
                                            TextSpan(
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 14,
                                              ),
                                              children: [
                                                const TextSpan(
                                                  text:
                                                      'Are you sure you want to delete this class?\n\n',
                                                ),
                                                const TextSpan(
                                                  text:
                                                      '1. All faculty requests for this class will be removed.\n',
                                                ),
                                                const TextSpan(
                                                  text:
                                                      '2. It won\'t be visible for booking.\n',
                                                ),
                                                TextSpan(
                                                  text:
                                                      '3. You will have to upload a new template having class ',
                                                ),
                                                TextSpan(
                                                  text: className,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const TextSpan(text: ' only.'),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      actionsAlignment: MainAxisAlignment.end,
                                      actionsPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.black87,
                                            textStyle: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            controller.deleteClass(className);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 12,
                                            ),
                                            textStyle: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.delete),
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
          } else {
            // fallback UI when no classes
            return Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload_rounded, size: 100, color: Colors.black87),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: controller.running.value
                        ? null
                        : () => controller.pickFileAndProcess(),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black87,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                    ),
                    child: const Text(
                      'Pick & Upload Excel',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (controller.running.value) ...[
                    const SizedBox(height: 20),
                    LinearProgressIndicator(
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.black87,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }
        }),
      ],
    );
  }

  Widget _downloadTemplate() {
    return InkWell(
      onTap: () {
        if (kIsWeb) {
          downloadExcelFileWeb("timetable_template.xlsx");
        } else {
          downloadExcelFileApp("timetable_template.xlsx");
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black45.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Download .xlsx Template",
              style: TextStyle(
                color: Colors.black45,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Spacer(),
            Icon(Icons.arrow_downward_rounded, size: 20, color: Colors.black45),
          ],
        ),
      ),
    );
  }
}
