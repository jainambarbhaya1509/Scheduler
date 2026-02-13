import 'package:flutter/material.dart';

class NotificationTile extends StatelessWidget {
  final String message;
  final String time;
  final bool isRead;

  const NotificationTile({
    super.key,
    required this.message,
    required this.time,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔵 Small unread dot
          if (!isRead)
            Container(
              margin: const EdgeInsets.only(top: 6, right: 8),
              height: 8,
              width: 8,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),

          /// Message
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),

          const SizedBox(width: 10),

          /// Time
          Text(
            time,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}
