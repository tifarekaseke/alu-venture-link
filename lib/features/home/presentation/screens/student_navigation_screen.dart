import 'package:flutter/material.dart';

import '../../../applications/presentation/screens/my_applications_screen.dart';
import '../../../auth/data/models/app_user.dart';
import '../../../bookmarks/presentation/screens/saved_opportunities_screen.dart';
import '../../../profiles/presentation/screens/student_profile_screen.dart';
import 'student_home_screen.dart';

class StudentNavigationScreen extends StatefulWidget {
  final AppUser user;

  const StudentNavigationScreen({
    required this.user,
    super.key,
  });

  @override
  State<StudentNavigationScreen> createState() =>
      _StudentNavigationScreenState();
}

class _StudentNavigationScreenState
    extends State<StudentNavigationScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      StudentHomeScreen(
        user: widget.user,
      ),
      SavedOpportunitiesScreen(
        user: widget.user,
      ),
      MyApplicationsScreen(
        user: widget.user,
      ),
      const StudentProfileScreen(),
    ];
  }

  void _selectDestination(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectDestination,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border_outlined),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Applications',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}