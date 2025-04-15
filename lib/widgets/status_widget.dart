import 'package:flutter/material.dart';

class StatusWidget extends StatelessWidget {
  final String title;
  final String time;
  final String status;
  final String description;

  const StatusWidget({
    super.key,
    required this.title,
    required this.time,
    required this.status,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 245, 245, 245),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                status,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: status == "Accepted"
                          ? Colors.green
                          : status == "Rejected"
                              ? Colors.red
                              : const Color.fromARGB(255, 184, 166, 6),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(34, 193, 193, 193),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: const Color.fromARGB(95, 28, 28, 28),
                    )),
          )
        ],
      ),
    );
  }
}
