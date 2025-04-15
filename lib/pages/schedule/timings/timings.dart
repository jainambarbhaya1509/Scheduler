import 'package:flutter/material.dart';
import 'package:scheduler/models/availability_model.dart';
import 'package:scheduler/models/class_avalability_model.dart';
import 'package:scheduler/widgets/apply_modal.dart';
import 'package:scheduler/widgets/timings_widgets.dart';

class SelectTimings extends StatelessWidget {
  const SelectTimings({super.key, required this.deptAvailabilityModel});
  final DepartmentAvailabilityModel deptAvailabilityModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 50, left: 12, right: 12, bottom: 10),
        child: DefaultTabController(
          length: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Select Timings",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 10),
              Container(
                // width: 200,
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TabBar(
                  labelStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[900],
                  indicator: BoxDecoration(
                    color: const Color.fromARGB(255, 80, 80, 80),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: "Classroom"),
                    Tab(text: "Lab"),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: TabBarView(
                  children: [
                    // Class Tab
                    ListView.builder(
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: InkWell(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            onTap: () {
                              // Handle tap event
                              showModalBottomSheet(
                                  // isScrollControlled: true,
                                  isDismissible: true,
                                  context: context,
                                  builder: (_) {
                                    return ApplyModal(
                                        title: "Classroom 65",
                                        time: "10:00 AM - 11:00 AM",
                                        applicants: [
                                          {
                                            "name": "John Doe",
                                            "status": "Applied",
                                          },
                                          {
                                            "name": "Jane Smith",
                                            "status": "Applied",
                                          },
                                          {
                                            "name": "Alice Johnson",
                                            "status": "Applied",
                                          },
                                        ]);
                                  });
                            },
                            child: DisplayTimings(
                              classAvalabilityModel: ClassAvalabilityModel(
                                isClassroom: true,
                                className: "Classroom 65",
                                startTime: "10:00 AM",
                                endTime: "11:00 AM",
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // Lab Tab
                    ListView.builder(
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: InkWell(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            onTap: () {
                              // Handle tap event
                              showModalBottomSheet(
                                  // isScrollControlled: true,
                                  isDismissible: true,
                                  context: context,
                                  builder: (_) {
                                    return ApplyModal(
                                        title: "Lab 1",
                                        time: "10:00 AM - 11:00 AM",
                                        applicants: [
                                          {
                                            "name": "John Doe",
                                            "status": "Applied",
                                          },
                                          {
                                            "name": "Jane Smith",
                                            "status": "Applied",
                                          },
                                          {
                                            "name": "Alice Johnson",
                                            "status": "Applied",
                                          },
                                        ]);
                                  });
                            },
                            child: DisplayTimings(
                              classAvalabilityModel: ClassAvalabilityModel(
                                isClassroom: false,
                                className: "Lab 12",
                                startTime: "11:00 AM",
                                endTime: "12:00 PM",
                              ),
                            ),
                          ),
                        );
                      },
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
}
