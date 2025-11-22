import 'package:flutter/material.dart';
import 'package:schedule/pages/manage_timetable/add_timetable.dart';
import 'package:schedule/pages/manage_timetable/view_reservations.dart';
import 'package:schedule/pages/profile/profile_page.dart';
import 'package:schedule/pages/requests/requests_page.dart';
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

  @override
  void initState() {
    super.initState();

    pages = [];
    navItems = [];

    // ---------------------------------------------------
    // SUPERADMIN ONLY
    // ---------------------------------------------------
    if (widget.isSuperAdmin && !widget.isAdmin && !widget.isHOD) {
      pages.add(SuperAdminPage());
      navItems.add(const BottomNavigationBarItem(
        icon: Icon(Icons.group),
        label: "User Management",
      ));
    }

    // ---------------------------------------------------
    // ADMIN ONLY
    // ---------------------------------------------------
    if (widget.isAdmin && !widget.isSuperAdmin && !widget.isHOD) {
      pages.add(AddTimeTable());
      navItems.add(const BottomNavigationBarItem(
        icon: Icon(Icons.add),
        label: "Add Time Table",
      ));

      pages.add(ITSlotsDashboardFull());
      navItems.add(const BottomNavigationBarItem(
        icon: Icon(Icons.view_agenda),
        label: "Reservations",
      ));
    }

    // ---------------------------------------------------
    // HOD ONLY — also has Schedule + Status
    // ---------------------------------------------------
    if (widget.isHOD && !widget.isAdmin && !widget.isSuperAdmin) {
      pages.add(const SchedulePage());
      navItems.add(const BottomNavigationBarItem(
        icon: Icon(Icons.home_rounded),
        label: "Schedule",
      ));

      pages.add(const ApplicationStatusPage());
      navItems.add(const BottomNavigationBarItem(
        icon: Icon(Icons.call_missed_outgoing),
        label: "Status",
      ));

      pages.add(const RequestsPage());
      navItems.add(const BottomNavigationBarItem(
        icon: Icon(Icons.approval_rounded),
        label: "Requests",
      ));
    }

    // ---------------------------------------------------
    // NORMAL FACULTY (NOT admin, NOT superadmin, NOT HOD)
    // ---------------------------------------------------
    if (!widget.isAdmin && !widget.isSuperAdmin && !widget.isHOD) {
      pages.add(const SchedulePage());
      navItems.add(const BottomNavigationBarItem(
        icon: Icon(Icons.home_rounded),
        label: "Schedule",
      ));

      pages.add(const ApplicationStatusPage());
      navItems.add(const BottomNavigationBarItem(
        icon: Icon(Icons.call_missed_outgoing),
        label: "Status",
      ));
    }

    // ---------------------------------------------------
    // PROFILE — ALWAYS LAST
    // ---------------------------------------------------
    pages.add(ProfilePage(loggedEmail: widget.loggedEmail));
    navItems.add(const BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: "Profile",
    ));
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
