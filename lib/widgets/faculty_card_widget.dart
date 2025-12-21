import 'package:flutter/material.dart';

class FacultyCardWidget extends StatelessWidget {
  final String position;
  final String department;
  final String username;

  const FacultyCardWidget({
    super.key,
    required this.position,
    required this.department,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 245, 245, 245),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                position,
                softWrap: true,
                style: const TextStyle(
                  color: Colors.black45,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              Text(
                department,
                style: TextStyle(
                  color: Colors.black45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            username,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
