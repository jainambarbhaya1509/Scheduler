import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/requests_controller.dart';
import 'package:schedule/widgets/request_card_widget.dart';

class RequestsPage extends StatelessWidget {
  const RequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject controller
    final RequestsController controller = Get.put(RequestsController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Requests",
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextField(
          onChanged: (value) {
            controller.searchQuery.value = value;
          },
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: Colors.black, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            hintText: "Search",
            hintStyle: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.grey, fontWeight: FontWeight.w500),
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Obx(() {
            // Filter requests if searchQuery is not empty
            final filteredRequests = controller.allRequests.where((req) {
              final query = controller.searchQuery.value.toLowerCase();
              return req['department']
                      .toString()
                      .toLowerCase()
                      .contains(query) ||
                  req['username'].toString().toLowerCase().contains(query) ||
                  req['reason'].toString().toLowerCase().contains(query);
            }).toList();

            if (controller.allRequests.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              itemCount: filteredRequests.length,
              itemBuilder: (context, index) {
                final request = filteredRequests[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: RequestCard(
                    dept: request["department"],
                    email: request["email"],
                    title: request['roomId'] ?? 'N/A',
                    time: request['timeSlot'] ?? 'N/A',
                    professor: request['username'] ?? 'N/A',
                    description: request['reason'] ?? '',
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
