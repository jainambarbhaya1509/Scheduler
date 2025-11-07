import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/timings_controller.dart';
import 'package:schedule/models/availability_model.dart';
import 'package:schedule/models/class_avalability_model.dart';
import 'package:schedule/widgets/apply_modal_widget.dart';
import 'package:schedule/widgets/timings_widgets.dart';

class SelectTimings extends StatelessWidget {
  const SelectTimings({super.key, required this.deptAvailabilityModel});

  final DepartmentAvailabilityModel deptAvailabilityModel;

  @override
  Widget build(BuildContext context) {
    final TimingsController controller = Get.put(TimingsController());

    // Fetch once when widget builds
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
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
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
      child: TabBar(
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 20),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black87,
        indicator: BoxDecoration(
          color: const Color.fromARGB(255, 80, 80, 80),
          borderRadius: BorderRadius.circular(4),
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: "Classroom"),
          Tab(text: "Lab"),
        ],
      ),
    );
  }

  Widget _buildListView(
      BuildContext context, List<ClassAvailabilityModel> dataList) {
    if (dataList.isEmpty) {
      return const Center(child: Text("No timings available"));
    }

    return ListView.builder(
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        final model = dataList[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            onTap: () {
              showModalBottomSheet(
                isDismissible: true,
                context: context,
                builder: (_) => ApplyModal(
                  title: model.className,
                  time: model.timings,
                  applicants: model.appliedUsers,
                ),
              );
            },
            child: DisplayTimings(classAvailabilityModel: model),
          ),
        );
      },
    );
  }
}
