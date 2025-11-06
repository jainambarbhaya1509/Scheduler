import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/schedule_controller.dart';
import 'package:schedule/pages/schedule/timings_page.dart';
import 'package:schedule/widgets/department_info_widget.dart';

String getDayFromDate(DateTime date) {
  const days = [
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
  ];
  return days[date.weekday - 1];
}

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final TextEditingController _dateController = TextEditingController();
  final ScheduleController _scheduleController = Get.put(ScheduleController());

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Schedule Class",
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            controller: _dateController,
            readOnly: true,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Select Date",
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (selectedDate != null) {
                setState(() {
                  _dateController.text =
                      "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
                });

                String selectedDay = getDayFromDate(selectedDate);

                final scheduleController = Get.find<ScheduleController>();
                scheduleController.fetchAvailabilityForDay(selectedDay);
              }
            },
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "Available Classes",
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Expanded(
          child: Obx(() {
            final list = _scheduleController.departmentAvailabilityList;
            // if (list.isEmpty) return Text("No data found");

            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final dept = list[index];
                return InkWell(
                  onTap: () {
                    _scheduleController.fetchAvailableRooms(dept.deprtmantName!);

                    Get.to(
                      SelectTimings(deptAvailabilityModel: dept),
                      transition: Transition.cupertino,
                    );
                  },
                  child: Container(
                    child: Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dept.deprtmantName!,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "Class: ${dept.totalClass} | Labs: ${dept.totalLabs}",
                            ),
                          ],
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios_rounded, size: 15),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
