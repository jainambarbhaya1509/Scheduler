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
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildTabBar(),
          const SizedBox(height: 20),
          Expanded(child: _buildTabView(controller)),
        ],
      ),
    );
  }

  /// Extracted tab bar widget
  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const TabBar(
        labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        padding: EdgeInsets.all(5),
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: Color.fromARGB(255, 80, 80, 80),
          borderRadius: BorderRadius.all(Radius.circular(4)),
          shape: BoxShape.rectangle,
        ),
        tabs: [
          Tab(text: "All"),
          Tab(text: "Accepted"),
          Tab(text: "Rejected"),
          Tab(text: "Pending"),
        ],
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
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
