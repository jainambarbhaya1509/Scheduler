import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/schedule/timings_controller.dart';
import 'package:schedule/models/dept_availability_model.dart';
import 'package:schedule/models/class_avalability_model.dart';
import 'package:schedule/models/class_timing_model.dart';
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
              Expanded(child: _buildTabView(context, controller)),
            ],
          ),
        ),
      ),
    );
  }

  /// Extracted tab bar widget
  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 245, 245, 245), // iOS system gray
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelPadding: EdgeInsets.zero,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.black54,
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600, // Apple-like
        ),
        tabs: const [
          Tab(text: "Classroom"),
          Tab(text: "Lab"),
        ],
      ),
    );
  }

  /// Extracted tab view widget
  Widget _buildTabView(BuildContext context, TimingsController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.black12,
                color: Colors.black,
              ),
            );
      }

      return TabBarView(
        children: [
          _buildListView(context, controller.classroomList),
          _buildListView(context, controller.labList),
        ],
      );
    });
  }

  /// Extracted list view widget
  Widget _buildListView(
    BuildContext context,
    List<ClassAvailabilityModel> dataList,
  ) {
    if (dataList.isEmpty) {
      return const Center(child: Text("No timings available"));
    }

    return ListView.builder(
      itemCount: dataList.length,
      itemBuilder: (context, index) =>
          _buildClassCard(context, dataList[index]),
    );
  }

  /// Extracted class card widget
  Widget _buildClassCard(
    BuildContext context,
    ClassAvailabilityModel classModel,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              itemBuilder: (context, tIndex) => _buildTimingTile(
                context,
                classModel,
                classModel.timingsList[tIndex],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Extracted timing tile widget
  Widget _buildTimingTile(
    BuildContext context,
    ClassAvailabilityModel classModel,
    ClassTiming timing,
  ) {
    final timingController = Get.find<TimingsController>();

    // Block only Pending or Accepted
    final appliedUser = timing.appliedUsers.isNotEmpty
        ? timing.appliedUsers.first
        : null;

    final bool isPendingOrAccepted =
        appliedUser != null &&
        (appliedUser.status == "Pending" || appliedUser.status == "Accepted");

    // Rejected should NOT block
    final bool isRejected =
        appliedUser != null && appliedUser.status == "Rejected";

    return InkWell(
      onTap: isPendingOrAccepted
          ? null
          : () {
              showDialog(
                context: context,
                builder: (BuildContext builder) {
                  return ApplyReasonDialog(
                    roomId: classModel.className,
                    isClassroom: classModel.isClassroom,
                    department: deptAvailabilityModel.departmentName.toString(),
                    slotId: timing.timing,
                    onSubmit: (reason) {
                      timingController.apply(
                        classModel: classModel,
                        timeslot: timing.timing,
                        consideredSlots: timing.consideredSlots,
                        reason: reason,
                      );
                    },
                  );
                },
              );
            },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black12, width: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    timing.timing,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isPendingOrAccepted
                          ? Colors.black54
                          : Colors.black87,
                    ),
                  ),
                  const Spacer(),

                  // Show name + status only for Pending & Accepted
                  if (appliedUser != null && !isRejected)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          appliedUser.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          appliedUser.status == "Accepted"
                              ? "Booked"
                              : "Pending",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: appliedUser.status == "Accepted"
                                ? Colors.green
                                : const Color(0xFFB8A606),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            if (!isPendingOrAccepted)
              const Icon(Icons.arrow_forward_ios_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}
