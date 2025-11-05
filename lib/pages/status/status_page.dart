import 'package:flutter/material.dart';
import 'package:schedule/widgets/status_widget.dart';


class ApplicationStatusPage extends StatelessWidget {
  const ApplicationStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Requests",
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              labelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              padding: EdgeInsets.all(5),
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: const Color.fromARGB(255, 80, 80, 80),
                borderRadius: BorderRadius.circular(4),
                shape: BoxShape.rectangle,
              ),
              tabs: const [
                Tab(text: "All"),
                Tab(text: "Accepted"),
                Tab(text: "Rejected"),
                Tab(text: "Pending"),
              ],
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          // tabs
          Expanded(
            child: TabBarView(
              children: [
                // all
                ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return StatusWidget(
                      title: "Classroom 65",
                      time: "10:00 AM - 11:00 AM",
                      status: "Accepted",
                      description:
                          "Extra Class for student of information technology",
                    );
                  },
                ),
                // approved
                ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return StatusWidget(
                      title: "Classroom 65",
                      time: "10:00 AM - 11:00 AM",
                      status: "Accepted",
                      description:
                          "Extra Class for student of information technology",
                    );
                  },
                ),
                // rejected
                ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return StatusWidget(
                      title: "Classroom 65",
                      time: "10:00 AM - 11:00 AM",
                      status: "Rejected",
                      description:
                          "Extra Class for student of information technology",
                    );
                  },
                ),
                // pending
                ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return StatusWidget(
                      title: "Classroom 65",
                      time: "10:00 AM - 11:00 AM",
                      status: "Pending",
                      description:
                          "Extra Class for student of information technology",
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
