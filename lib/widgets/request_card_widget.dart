import 'package:flutter/material.dart';

class RequestCard extends StatefulWidget {
  final String title;
  final String time;
  final String professor;
  final String description;

  const RequestCard({
    super.key,
    required this.title,
    required this.time,
    required this.professor,
    required this.description,
  });

  @override
  State<RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {
  bool showAcceptRejectButtons = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          showAcceptRejectButtons = !showAcceptRejectButtons;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
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
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      widget.time,
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
                  widget.professor,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[600],
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
              child: Text(widget.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: const Color.fromARGB(95, 28, 28, 28),
                      )),
            ),
            const SizedBox(height: 10),
            if (showAcceptRejectButtons)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    label: Text("Accept",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold, color: Colors.green)),
                    icon: const Icon(Icons.check, color: Colors.green),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    label: Text("Reject",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent)),
                    icon: const Icon(Icons.close, color: Colors.redAccent),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}