import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/requests_controller.dart';
import 'package:schedule/widgets/status_widget.dart';

class ApplicationStatusPage extends StatelessWidget {
  const ApplicationStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final RequestsController controller = Get.put(RequestsController());

    return DefaultTabController(
      length: 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Requests",
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
            child: TabBar(
              labelStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              padding: EdgeInsets.all(5),
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: const Color.fromARGB(255, 80, 80, 80),
                borderRadius: BorderRadius.circular(4),
                shape: BoxShape.rectangle,
              ),
              tabs: const [
                Tab(text: "All"),
                Tab(text: "Accepted"),
                Tab(text: "Rejected"),
                Tab(text: "Pending"),
              ],
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          // tabs
          Expanded(
            child: TabBarView(
              children: [
                // All
                Obx(() {
                  return RefreshIndicator(
                    onRefresh: () async {
                      await controller.fetchUserRequests();
                    },
                    child: ListView.builder(
                      itemCount: controller.allRequests.length,
                      itemBuilder: (context, index) {
                        var request = controller.allRequests[index];
                        return StatusWidget(
                          title: request['username'] ?? '',
                          time: request['timeSlot'] ?? '',
                          status: request['status'] ?? '',
                          description: request['reason'] ?? '',
                        );
                      },
                    ),
                  );
                }),
                // Accepted
                Obx(() {
                  return RefreshIndicator(
                    onRefresh: () async {
                      await controller.fetchUserRequests();
                    },
                    child: ListView.builder(
                      itemCount: controller.acceptedRequests.length,
                      itemBuilder: (context, index) {
                        var request = controller.acceptedRequests[index];
                        return StatusWidget(
                          title: request['username'] ?? '',
                          time: request['timeSlot'] ?? '',
                          status: request['status'] ?? '',
                          description: request['reason'] ?? '',
                        );
                      },
                    ),
                  );
                }),
                // Rejected
                Obx(() {
                  return RefreshIndicator(
                    onRefresh: () async {
                      await controller.fetchUserRequests();
                    },
                    child: ListView.builder(
                      itemCount: controller.rejectedRequests.length,
                      itemBuilder: (context, index) {
                        var request = controller.rejectedRequests[index];
                        return StatusWidget(
                          title: request['username'] ?? '',
                          time: request['timeSlot'] ?? '',
                          status: request['status'] ?? '',
                          description: request['reason'] ?? '',
                        );
                      },
                    ),
                  );
                }),
                // Pending
                Obx(() {
                  return RefreshIndicator(
                    onRefresh: () async {
                      await controller.fetchUserRequests();
                    },
                    child: ListView.builder(
                      itemCount: controller.pendingRequests.length,
                      itemBuilder: (context, index) {
                        var request = controller.pendingRequests[index];
                        return StatusWidget(
                          title: request['username'] ?? '',
                          time: request['timeSlot'] ?? '',
                          status: request['status'] ?? '',
                          description: request['reason'] ?? '',
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
