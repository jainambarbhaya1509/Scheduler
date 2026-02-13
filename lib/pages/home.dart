import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schedule/pages/manage_timetable/add_timetable.dart';
import 'package:schedule/pages/manage_timetable/view_reservations.dart';
import 'package:schedule/pages/profile/profile_page.dart';
import 'package:schedule/pages/requests/requests_page.dart';
import 'package:schedule/pages/schedule/notification_page.dart';
import 'package:schedule/pages/schedule/schedule_page.dart';
import 'package:schedule/pages/status/status_page.dart';
import 'package:schedule/pages/superadmin/superadmin_page.dart';

class HomePage extends StatefulWidget {
  final String loggedEmail;
  final bool isHOD, isAdmin, isSuperAdmin;

  const HomePage({
    super.key,
    required this.loggedEmail,
    required this.isHOD,
    required this.isAdmin,
    required this.isSuperAdmin,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;

  late final List<Widget> pages;
  late final List<BottomNavigationBarItem> navItems;
  late final List<String> navLabels;

  @override
  void initState() {
    super.initState();

    pages = [];
    navItems = [];
    navLabels = [];

    // ---------------------------------------------------
    // SUPERADMIN ONLY
    // ---------------------------------------------------
    if (widget.isSuperAdmin && !widget.isAdmin && !widget.isHOD) {
      pages.add(SuperAdminPage());
      navLabels.add("User Management");
      navItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: "User Management",
        ),
      );
    }

    // ---------------------------------------------------
    // ADMIN + HOD ONLY
    // ---------------------------------------------------
    if (widget.isAdmin && !widget.isSuperAdmin && widget.isHOD) {
      pages.add(const SchedulePage());
      navLabels.add("Schedule Class");
      navItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: "Schedule",
        ),
      );

      pages.add(const ApplicationStatusPage());
      navLabels.add("Application Status");
      navItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.call_missed_outgoing),
          label: "Status",
        ),
      );
      pages.add(const RequestsPage());
      navLabels.add("Manage Requests");
      navItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.approval_rounded),
          label: "Requests",
        ),
      );
      pages.add(AddTimeTable());
      navLabels.add("Manage Time Table");
      navItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: "Add Time Table",
        ),
      );
    }

    // ---------------------------------------------------
    // ADMIN ONLY
    // ---------------------------------------------------
    if (widget.isAdmin && !widget.isSuperAdmin && !widget.isHOD) {
      pages.add(const SchedulePage());
      navLabels.add("Schedule Class");
      navItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: "Schedule",
        ),
      );

      pages.add(const ApplicationStatusPage());
      navLabels.add("Application Status");
      navItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.call_missed_outgoing),
          label: "Status",
        ),
      );
      pages.add(AddTimeTable());
      navLabels.add("Manage Time Table");
      navItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: "Add Time Table",
        ),
      );
    }

    // ---------------------------------------------------
    // HOD ONLY — also has Schedule + Status
    // ---------------------------------------------------
    if (widget.isHOD && !widget.isAdmin && !widget.isSuperAdmin) {
      pages.add(const SchedulePage());
      navLabels.add("Schedule Class");
      navItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: "Schedule",
        ),
      );

      pages.add(const ApplicationStatusPage());
      navLabels.add("Application Status");
      navItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.call_missed_outgoing),
          label: "Status",
        ),
      );

      pages.add(const RequestsPage());
      navLabels.add("Manage Requests");
      navItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.approval_rounded),
          label: "Requests",
        ),
      );
    }

    // ---------------------------------------------------
    // NORMAL FACULTY (NOT admin, NOT superadmin, NOT HOD)
    // ---------------------------------------------------
    if (!widget.isAdmin && !widget.isSuperAdmin && !widget.isHOD) {
      pages.add(const SchedulePage());
      navLabels.add("Schedule Class");
      navItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: "Schedule",
        ),
      );

      pages.add(const ApplicationStatusPage());
      navLabels.add("Application Status");
      navItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.call_missed_outgoing),
          label: "Status",
        ),
      );
    }

    // ---------------------------------------------------
    // PROFILE — ALWAYS LAST
    // ---------------------------------------------------
    pages.add(ProfilePage(loggedEmail: widget.loggedEmail));
    navLabels.add("Profile");
    navItems.add(
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  navLabels[index],
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (index == 0) ...[
                  IconButton(
                    onPressed: () => Get.to(() => NotificationPage()),
                    icon: Icon(Icons.notifications),
                  ),
                ],
                if (index == 2) ...[
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.manage_history),
                  ),
                ],
                if (index == 3) ...[
                  IconButton(
                    icon: const Icon(Icons.calendar_today_sharp),
                    onPressed: () {
                      Get.to(
                        () => ViewReservations(),
                        transition: Transition.cupertino,
                      );
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            Expanded(child: pages[index]),
          ],
        ),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (newIndex) => setState(() => index = newIndex),
          items: navItems,
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
