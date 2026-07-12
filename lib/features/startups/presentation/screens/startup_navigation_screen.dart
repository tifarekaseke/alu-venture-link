import 'package:flutter/material.dart';

import '../../../analytics/presentation/screens/startup_analytics_screen.dart';
import '../../../applications/presentation/screens/startup_applications_screen.dart';
import '../../../auth/data/models/app_user.dart';
import 'startup_dashboard_screen.dart';
import 'startup_profile_screen.dart';

class StartupNavigationScreen extends StatefulWidget {
  final AppUser user;

  const StartupNavigationScreen({required this.user, super.key});

  @override
  State<StartupNavigationScreen> createState() =>
      _StartupNavigationScreenState();
}

class _StartupNavigationScreenState extends State<StartupNavigationScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      StartupDashboardScreen(
        user: widget.user,
        onOpenApplicants: () {
          _selectDestination(1);
        },
        onOpenAnalytics: () {
          _selectDestination(2);
        },
        onOpenProfile: () {
          _selectDestination(3);
        },
      ),
      StartupApplicationsScreen(user: widget.user),
      StartupAnalyticsScreen(user: widget.user),
      StartupProfileScreen(user: widget.user),
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
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectDestination,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Applicants',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_outlined),
            selectedIcon: Icon(Icons.business),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
