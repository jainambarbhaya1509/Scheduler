import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/home_controller.dart';
import 'package:schedule/controller/schedule_controller.dart';
import 'package:schedule/controller/timings_controller.dart';
import 'package:schedule/helper_func/date_to_day.dart';
import 'package:schedule/pages/schedule/timings_page.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final TextEditingController _dateController = TextEditingController();
  final ScheduleController _scheduleController = Get.put(ScheduleController());
  final TimingsController _timingsController = Get.put(TimingsController());
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _nHoursController = TextEditingController();

  bool hasSelectedDate = false;

  final HomeController homeController = Get.put(HomeController());

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
        Row(
          children: [
            Text(
              "Schedule Class",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Spacer(),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications_active_rounded),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Obx(() {
              return homeController.changeMode.isTrue
                  ? _buildDateSelector(context)
                  : _buildSlotSelector(context);
            }),
            Spacer(),
            IconButton(
              onPressed: () {
                homeController.changeSearchMode();
              },
              icon: Icon(Icons.swap_calls),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _buildAvailableClasses(),
      ],
    );
  }

  /// ---------------------- DATE PICKER ----------------------

  Widget _buildSlotSelector(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: MediaQuery.sizeOf(context).width * 0.8,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _dateController,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            readOnly: true,
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
                  hasSelectedDate = true;
                  _dateController.text =
                      "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
                });

                // IMPORTANT: update both controllers
                _timingsController.date.value = selectedDate.toString();
                _scheduleController.selectedDate.value = selectedDate
                    .toString();
                _scheduleController.selectedDay.value = day;
                _scheduleController.fetchAllAvailableSlots(
                  _scheduleController.selectedDay.value,
                  time: _timeController.text.toString(),
                  nHr: _nHoursController.text.toString(),
                );
              }
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              width: MediaQuery.sizeOf(context).width * 0.39,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _timeController, // Controller for selected time

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
                    setState(() {
                      _timeController.text =
                          "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}";
                    });
                  }
                },
                onSubmitted: (value) {
                  print("Time submitted");

                  _scheduleController.fetchAllAvailableSlots(
                    _scheduleController.selectedDay.value,
                    time: _timeController.text.toString(),
                    nHr: _nHoursController.text.toString(),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),

            Container(
              width: MediaQuery.sizeOf(context).width * 0.39,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _nHoursController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Enter Hours",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (value) {
                  _nHoursController.text = (int.tryParse(value) ?? 0) as String;
                },
                onTap: () {
                  _scheduleController.fetchAllAvailableSlots(
                    _scheduleController.selectedDay.value,
                    time: _timeController.text.toString(),
                    nHr: _nHoursController.text.toString(),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 0.8,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _dateController,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        readOnly: true,
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
              hasSelectedDate = true;
              _dateController.text =
                  "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
            });

            // IMPORTANT: update both controllers
            _timingsController.date.value = selectedDate.toString();
            _scheduleController.selectedDay.value = day;

            _scheduleController.fetchAvailabilityForDay(day);
          }
        },
      ),
    );
  }

  /// ---------------------- CLASS LIST ----------------------
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

  /// ---------------------- DEPARTMENT CARD ----------------------
  Widget _buildDepartmentCard(BuildContext context, dynamic dept) {
    return InkWell(
      onTap: () {
        _scheduleController.fetchAvailableRooms(dept.deprtmantName!);

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
