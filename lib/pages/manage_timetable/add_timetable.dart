import 'package:flutter/material.dart';

class AddTimeTable extends StatelessWidget {
  const AddTimeTable({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 10, left: 12, right: 12, bottom: 10),
        child: Column(
          children: [
            Text("Manage Time Table", style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,))
          ],
        ),
      ),
    );
  }
}