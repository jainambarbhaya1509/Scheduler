import 'package:flutter/material.dart';
import 'package:schedule/widgets/request_card_widget.dart';


class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
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
            child: ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RequestCard(
                title: "Class ${index + 1}",
                time: "10:00 AM - 11:00 AM",
                professor: "Professor ${index + 1}",
                description:
                    "This is a description of the class. It contains all the details about the class.",
              ),
            );
          },
        )),
      ],
    );
  }
}


