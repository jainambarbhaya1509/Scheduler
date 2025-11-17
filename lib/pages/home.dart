import 'package:flutter/material.dart';
import 'package:schedule/pages/manage_timetable/add_timetable.dart';
import 'package:schedule/pages/manage_timetable/view_reservations.dart';
import 'package:schedule/pages/profile/profile_page.dart';
import 'package:schedule/pages/requests/requests_page.dart';
import 'package:schedule/pages/schedule/schedule_page.dart';
import 'package:schedule/pages/status/status_page.dart';

class HomePage extends StatefulWidget {
  final String loggedEmail;
  final bool isHOD, isAdmin;

  const HomePage({
    super.key,
    required this.loggedEmail,
    required this.isHOD,
    required this.isAdmin,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    // Build pages dynamically
    pages = [];

    if (widget.isAdmin) {
      pages.add(AddTimeTable());
      pages.add(ViewReservations());

    }

    if (!widget.isAdmin) {
      pages.add(const SchedulePage());
      pages.add(const ApplicationStatusPage());
    }
    if (widget.isHOD) {
      pages.add(const RequestsPage());
    }

    pages.add(ProfilePage(loggedEmail: widget.loggedEmail));
  }

  /// Build bottom navigation items dynamically based on isHOD
  List<BottomNavigationBarItem> buildNavItems() {
    final items = <BottomNavigationBarItem>[];

    if (widget.isAdmin) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: "Add Time Table",
        ),
      );
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.view_agenda),
          label: "View Reservations",
        ),
      );
    }
    if (!widget.isAdmin) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: "Schedule",
        ),
      );
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.call_missed_outgoing),
          label: "Status",
        ),
      );
    }
    if (widget.isHOD) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.approval_rounded),
          label: "Requests",
        ),
      );
    }

    items.add(
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
    );

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 50, left: 12, right: 12),
        child: pages[index],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (newIndex) {
            setState(() => index = newIndex);
          },
          items: buildNavItems(),
          unselectedItemColor: Colors.grey,
          selectedItemColor: Colors.black,
          backgroundColor: Colors.white,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
