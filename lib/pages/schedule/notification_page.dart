import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/notif/notification_controller.dart';
import 'package:schedule/models/notification_model.dart';
import 'package:schedule/widgets/notification_tile_widget.dart';

class NotificationPage extends StatelessWidget {
  NotificationPage({super.key});

  final NotificationController controller = Get.put(NotificationController());

  /// 🔹 Convert timestamp → "2 min ago"
  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} hr ago";
    if (diff.inDays == 1) return "Yesterday";
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Notifications",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),

              Expanded(
                child: StreamBuilder<List<NotificationModel>>(
                  stream: controller.getNotificationsStream(),
                  builder: (context, snapshot) {
                    /// Loading
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    /// Error
                    if (snapshot.hasError) {
                      return const Center(child: Text("Something went wrong"));
                    }

                    final notifications = snapshot.data ?? [];

                    /// Empty state
                    if (notifications.isEmpty) {
                      return const Center(
                        child: Text("No notifications yet"),
                      );
                    }

                    return ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notif = notifications[index];
                        final time = _formatTime(notif.createdAt);

                        return Dismissible(
                          key: Key(notif.id),
                          direction: DismissDirection.endToStart,

                          /// Swipe delete 🗑
                          onDismissed: (_) =>
                              controller.deleteNotification(notif.id),

                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Colors.red,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),

                          child: GestureDetector(
                            /// Tap → mark as read ✅
                            onTap: () =>
                                controller.markAsRead(notif.id),

                            child: NotificationTile(
                              message: "${notif.title}\n${notif.body}",
                              time: time,
                              isRead: notif.isRead,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
