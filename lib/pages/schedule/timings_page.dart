import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/timings_controller.dart';
import 'package:schedule/models/availability_model.dart';
import 'package:schedule/models/class_avalability_model.dart';
import 'package:schedule/widgets/apply_modal_widget.dart';

class SelectTimings extends StatelessWidget {
  const SelectTimings({super.key, required this.deptAvailabilityModel});

  final DepartmentAvailabilityModel deptAvailabilityModel;

  @override
  Widget build(BuildContext context) {
    final TimingsController controller = Get.put(TimingsController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchTimings(deptAvailabilityModel);
    });

    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 50, left: 12, right: 12, bottom: 10),
        child: DefaultTabController(
          length: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select Timings",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildTabBar(),
              const SizedBox(height: 10),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return TabBarView(
                    children: [
                      _buildListView(context, controller.classroomList),
                      _buildListView(context, controller.labList),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const TabBar(
        labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        labelColor: Colors.black87,
        unselectedLabelColor: Colors.black54,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: "Classroom"),
          Tab(text: "Lab"),
        ],
      ),
    );
  }

  Widget _buildListView(
    BuildContext context,
    List<ClassAvailabilityModel> dataList,
  ) {
    if (dataList.isEmpty) {
      return const Center(child: Text("No timings available"));
    }

    return ListView.builder(
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        final classModel = dataList[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    classModel.className,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: classModel.timingsList.length,
                  itemBuilder: (context, tIndex) {
                    final timing = classModel.timingsList[tIndex];

                    return InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.white,
                          builder: (_) {
                            return ApplyModal(
                              title: classModel.className,
                              time: timing.timing,
                              classModel: classModel, // ✅ Pass classModel here
                              applicants: timing.appliedUsers,
                            );
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.black12,
                              width: 0.4,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              timing.timing,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
