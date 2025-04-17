import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('EventSync', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text('Khushi Sanghavi', style: TextStyle(fontSize: 16)),
                  Icon(Icons.settings),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Profile Image
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
            ),

            const SizedBox(height: 12),

            // Name & Info
            const Text('Khushi Sanghavi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 4),
            const Text('#SAP ID', style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 8),

            // Email & Phone
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.email, size: 16),
                SizedBox(width: 4),
                Text('khushi@gmail.com'),
              ],
            ),
            const SizedBox(height: 4),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone, size: 16),
                SizedBox(width: 4),
                Text('9876543210'),
              ],
            ),

            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Computer Science student passionate about UI/UX design and web development',
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 12),

            // Edit & Share Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Edit Profile'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.share),
                      label: const Text('Share Profile'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Academic Info
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Academic Information',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),

            const ListTile(
              leading: Icon(Icons.school),
              title: Text('DJ Sanghvi'),
              subtitle: Text('College'),
            ),
            const ListTile(
              leading: Icon(Icons.menu_book),
              title: Text('Computer Science'),
              subtitle: Text('Department'),
            ),
            const ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('3rd Year'),
              subtitle: Text('Year'),
            ),
            const ListTile(
              leading: Icon(Icons.bar_chart),
              title: Text('9.15/10.0'),
              subtitle: Text('GPA'),
            ),
          ],
        ),
      ),

      // Footer Navigation
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: 3,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
