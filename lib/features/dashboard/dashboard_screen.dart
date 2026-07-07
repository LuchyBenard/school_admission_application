import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../schools/school_list_screen.dart';
import '../applications/application_form_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/custom_bottom_nav_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  // ✅ Method not field
  List<Widget> _getScreens() => [
    HomeScreen(
      onFindSchoolsTapped: () {
        setState(() => _currentIndex = 1);
      },
    ),
    const SchoolListScreen(),
    const ApplicationFormScreen(),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _getScreens(), // ✅ calling with ()
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}