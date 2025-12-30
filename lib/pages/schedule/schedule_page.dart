import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/schedule/schedule_controller.dart';
import 'package:schedule/controller/schedule/timings_controller.dart';
import 'package:schedule/helper/date_time/date_to_day.dart';
import 'package:schedule/helper/convert_datatype/parse_double.dart';
import 'package:schedule/models/dept_availability_model.dart';
import 'package:schedule/pages/schedule/timings_page.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _nHoursController = TextEditingController();

  final ScheduleController _scheduleController = Get.put(ScheduleController());
  final TimingsController _timingsController = Get.put(TimingsController());

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _nHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSlotSelector(context),
        const SizedBox(height: 20),
        _buildAvailableClasses(),
      ],
    );
  }

  Widget _buildSlotSelector(BuildContext context) {
    return Column(
      children: [
        _buildDateSelector(context),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildTimeField(context),
            const SizedBox(width: 10),
            _buildHoursField(),
          ],
        ),
        const SizedBox(height: 15),

        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return _buildInputContainer(
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
            final day = getDayFromDate(selectedDate);
            setState(() {
              _dateController.text =
                  "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}";
            });
            _scheduleController.selectedDay.value = day;
            _scheduleController.selectedDate.value = _dateController.text;
          }
        },
      ),
    );
  }

  Widget _buildTimeField(BuildContext context) {
    return Expanded(
      child: _buildInputContainer(
        child: TextFormField(
          controller: _timeController,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: "Select Time",
            hintStyle: TextStyle(color: Colors.grey),
          ),
          onTap: () async {
            final selectedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );

            if (selectedTime != null) {
              final int totalMinutes =
                  selectedTime.hour * 60 + selectedTime.minute;

              const int minMinutes = 8 * 60; // 8:00 AM
              const int maxMinutes = 18 * 60; // 6:00 PM

              // Check if within allowed range
              if (totalMinutes < minMinutes || totalMinutes > maxMinutes) {
                Get.snackbar(
                  "Invalid Time",
                  "Please select a time between 8:00 AM and 6:00 PM",
                );
                return;
              }

              // Passed validation → update text field
              setState(() {
                _timeController.text =
                    "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}";
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildHoursField() {
    return Expanded(
      child: _buildInputContainer(
        child: TextFormField(
          controller: _nHoursController,
          keyboardType: TextInputType.number,
          // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: "Enter Hours",
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildInputContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.black87),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        onPressed: () {
          _timingsController.hoursRequired.value = safeParseDouble(
            _nHoursController.text,
          );
          _timingsController.initialTiming.value = _timeController.text
              .toString();
          _scheduleController.fetchAvailabilityForDay(
            _scheduleController.selectedDay.value,
          );
        },
        child: const Text(
          "Find Slots",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildAvailableClasses() {
    return Expanded(
      child: Obx(() {
        if (_scheduleController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final list = _scheduleController.departmentAvailabilityList;

        if (list.isEmpty) {
          return const Center(
            child: Text(
              "Please Enter The Details",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
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
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) =>
                    _buildDepartmentCard(list[index]),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDepartmentCard(DepartmentAvailabilityModel dept) {
    return InkWell(
      onTap: () {
        _scheduleController.fetchAvailableRooms(dept.departmentName!);
        Get.to(
          () => SelectTimings(deptAvailabilityModel: dept),
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
                  dept.departmentName!,
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
