import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/requests/requests_controller.dart';
import 'package:schedule/widgets/status_widget.dart';

class ApplicationStatusPage extends StatelessWidget {
  const ApplicationStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final RequestsController controller = Get.put(RequestsController());

    return Container(
      padding: EdgeInsets.all(10),

      child: DefaultTabController(
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
            const SizedBox(height: 10),

            _buildTabBar(),
            const SizedBox(height: 10),

            Expanded(child: _buildTabView(controller)),
          ],
        ),
      ),
    );
  }

  /// Extracted tab bar widget
  Widget _buildTabBar() {
    return Container(
      // margin: const EdgeInsets.symmetric(horizontal: 16),
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
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: "All"),
          Tab(text: "Accepted"),
          Tab(text: "Rejected"),
          Tab(text: "Pending"),
        ],
      ),
    );
  }

  /// Consolidated tab views with helper method
  Widget _buildTabView(RequestsController controller) {
    return TabBarView(
      children: [
        _buildRefreshableList(controller, controller.allRequests),
        _buildRefreshableList(controller, controller.acceptedRequests),
        _buildRefreshableList(controller, controller.rejectedRequests),
        _buildRefreshableList(controller, controller.pendingRequests),
      ],
    );
  }

  /// Extracted reusable refreshable list widget
  Widget _buildRefreshableList(
    RequestsController controller,
    RxList<Map<String, dynamic>> requestList,
  ) {
    return Obx(() {
      return RefreshIndicator(
        onRefresh: () async => {},
        child: requestList.isEmpty
            ? const Center(child: Text("No requests"))
            : ListView.builder(
                itemCount: requestList.length,
                itemBuilder: (context, index) {
                  var request = requestList[index];
                  return StatusWidget(
                    requestedDate: request["requestedDate"] ?? '',
                    title: request['username'] ?? '',
                    time: request['timeSlot'] ?? '',
                    status: request['status'] ?? '',
                    description: request['reason'] ?? '',
                  );
                },
              ),
      );
    });
  }
}
