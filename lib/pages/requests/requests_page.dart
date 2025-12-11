import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/requests/requests_controller.dart';
import 'package:schedule/widgets/request_card_widget.dart';

class RequestsPage extends StatelessWidget {
  const RequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final RequestsController controller = Get.put(RequestsController());
    final searchQuery = "".obs;

    return Container(
      padding: EdgeInsets.all(10),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Requests",
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildSearchBar(context, searchQuery),
          const SizedBox(height: 20),
          _buildRequestsList(context, controller, searchQuery),
        ],
      ),
    );
  }

  /// Extracted search bar widget
  Widget _buildSearchBar(BuildContext context, RxString searchQuery) {
    return TextField(
      onChanged: (value) => searchQuery.value = value,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade200,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        hintText: "Search",
        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
      ),
    );
  }

  /// Extracted requests list widget
  Widget _buildRequestsList(
    BuildContext context,
    RequestsController controller,
    RxString searchQuery,
  ) {
    return Expanded(
      child: Obx(() {
        final filteredRequests = controller.appliedRequests.where((req) {
          final query = searchQuery.value.toLowerCase();
          return query.isEmpty ||
              req['department'].toString().toLowerCase().contains(query) ||
              req['username'].toString().toLowerCase().contains(query) ||
              req['reason'].toString().toLowerCase().contains(query);
        }).toList();

        if (controller.appliedRequests.isEmpty) {
          return const Center(child: Text("No requests found"));
        }

        if (filteredRequests.isEmpty) {
          return const Center(child: Text("No requests found"));
        }

        return ListView.builder(
          itemCount: filteredRequests.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RequestCard(request: controller.appliedRequests[index]),
            );
          },
        );
      }),
    );
  }
}
