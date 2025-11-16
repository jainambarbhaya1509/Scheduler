import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/schedule_controller.dart';
import 'package:schedule/pages/schedule/timings_page.dart';

String _getDayFromDate(DateTime date) {
  const days = [
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
    "sunday",
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
  bool hasSelectedDate = false;

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Schedule Class",
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        _buildDateSelector(context),
        const SizedBox(height: 20),

        _buildAvailableClasses(),
      ],
    );
  }

  /// Extracted date selector widget
  Widget _buildDateSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _dateController,
        readOnly: true,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "Select Date",
          hintStyle: TextStyle(color: Colors.grey),
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
              hasSelectedDate = true;
              _dateController.text =
                  "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
            });
            _scheduleController.fetchAvailabilityForDay(
              _getDayFromDate(selectedDate),
            );
          }
        },
      ),
    );
  }

  /// Extracted available classes widget
  Widget _buildAvailableClasses() {
    return Expanded(
      child: hasSelectedDate == false
          ? const Center(
              child: Text(
                "Select date to get available classes",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : Obx(() {
              if (_scheduleController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final list = _scheduleController.departmentAvailabilityList;

              if (list.isEmpty) {
                return const Center(
                  child: Text(
                    "No Details Found",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Available Classes",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),

                  /// FIX: ListView must be in Expanded
                  Expanded(
                    child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) =>
                          _buildDepartmentCard(context, list[index]),
                    ),
                  ),
                ],
              );
            }),
    );
  }

  /// Extracted department card widget
  Widget _buildDepartmentCard(BuildContext context, dynamic dept) {
    return InkWell(
      onTap: () {
        _scheduleController.fetchAvailableRooms(dept.deprtmantName!);
        Get.to(
          SelectTimings(deptAvailabilityModel: dept),
          transition: Transition.cupertino,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dept.deprtmantName!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "Class: ${dept.totalClass} | Labs: ${dept.totalLabs}",
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}
