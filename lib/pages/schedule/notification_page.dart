import 'package:flutter/material.dart';
import 'package:schedule/widgets/notification_tile_widget.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

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
                child: ListView(
                  children:  [
                    NotificationTile(
                      message: "Your slot just got approved",
                      time: "2 min ago",
                    ),
                    NotificationTile(
                      message: "Time table updated successfully",
                      time: "12 min ago",
                    ),
                    NotificationTile(
                      message: "New reservation added",
                      time: "1 hr ago",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}