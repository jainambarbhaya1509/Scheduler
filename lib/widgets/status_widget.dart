import 'package:flutter/material.dart';

class StatusWidget extends StatelessWidget {
  final String title;
  final String time;
  final String status;
  final String requestedDate;
  final String description;

  const StatusWidget({
    super.key,
    required this.title,
    required this.time,
    required this.status,
    required this.description,
    required this.requestedDate,
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                requestedDate,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 5),
              Icon(Icons.circle, size: 5, color: Colors.black54,),
              const SizedBox(width: 5),
              Text(
                time,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: status == "Accepted"
                      ? const Color(0xFF34C759).withOpacity(0.15)
                      : status == "Rejected"
                      ? const Color(0xFFFF3B30).withOpacity(0.15)
                      : const Color(0xFFFFCC00).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: status == "Accepted"
                        ? const Color(0xFF34C759)
                        : status == "Rejected"
                        ? const Color(0xFFFF3B30)
                        : const Color(0xFFFFCC00),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "Requested Reason:",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: const Color.fromARGB(150, 28, 28, 30),
            ),
          ),
          SizedBox(
            width: double.infinity,

            child: Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: const Color.fromARGB(150, 28, 28, 30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
