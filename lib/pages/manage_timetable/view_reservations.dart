import 'package:flutter/material.dart';

class ViewReservations extends StatelessWidget {
  const ViewReservations({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 10, left: 12, right: 12, bottom: 10),
        child: Column(
          children: [
            Text("Current Reservations",style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,))
          ],
        ),
      ),
    );
  }
}