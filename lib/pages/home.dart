import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:schedule/pages/profile/profile_page.dart';
import 'package:schedule/pages/requests/requests_page.dart';
import 'package:schedule/pages/schedule/schedule_page.dart';
import 'package:schedule/pages/status/status_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  bool isBottomNavVisible = true; // Define the variable
  final List<Widget> pages = [
    SchedulePage(),
    ApplicationStatusPage(),
    RequestsPage(),
    ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: NotificationListener<UserScrollNotification>(
      onNotification: (notification) {
        if (notification.direction == ScrollDirection.reverse) {
          setState(() => isBottomNavVisible = false);
        } else if (notification.direction == ScrollDirection.forward) {
          setState(() => isBottomNavVisible = true);
        }
        return true;
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 50, left: 12, right: 12, bottom: 10),
        child: Stack(
          children: [
            pages[index],
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: isBottomNavVisible ? 0 : -80,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  alignment: Alignment.center,

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: BottomNavigationBar(
                      currentIndex: index,
                      onTap: (newIndex) => setState(() => index = newIndex),
                      unselectedItemColor: Colors.grey,
                      selectedItemColor: Colors.grey[900],
                      backgroundColor: Colors.white,
                      showUnselectedLabels: false,
                      showSelectedLabels: false,
                      type: BottomNavigationBarType.fixed,
                      landscapeLayout:
                          BottomNavigationBarLandscapeLayout.centered,
                      items: const [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.home_sharp),
                          label: 'Schedule',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.call_missed_outgoing),
                          label: 'Status',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.approval_rounded),
                          label: 'Requests',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.person),
                          label: 'Profile',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
