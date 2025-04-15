import 'package:flutter/material.dart';
import 'package:scheduler/models/availability_model.dart';
import 'package:scheduler/widgets/department_info_widget.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final TextEditingController _dateController = TextEditingController();

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
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.black, fontWeight: FontWeight.w500),
            controller: _dateController,
            readOnly: true,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Select Date",
              hintStyle: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.grey, fontWeight: FontWeight.w500),
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
              }
            },
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "Available Classes",
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Expanded(
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: DepartmentInfo(
                  deptAvailabilityModel: DepartmentAvailabilityModel(
                    deprtmantName: "Department $index",
                    totalAvailableClass: "10",
                    totalClass: "20",
                    totalLabs: "5",
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
