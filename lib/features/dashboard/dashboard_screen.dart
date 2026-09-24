import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home/home_screen.dart';
import '../schools/school_list_screen.dart';
import '../applications/application_status_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/custom_bottom_nav_bar.dart';
import '../../core/widgets/offline_sync_banner.dart';
import 'package:flutter/foundation.dart';

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
    ApplicationStatusScreen(
      onFindSchoolsTapped: () {
        setState(() => _currentIndex = 1);
      },
    ),
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
      body: Consumer(
        builder: (context,BottomNavigationProvider authProvider, child) {
          return Column(
            children: [
              const OfflineSyncBanner(),
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: _getScreens(), // ✅ calling with ()
                ),
              ),
            ],
          );
        }
        ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

class BottomNavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void changeTab(int index) {
    if (_currentIndex == index) return;

    _currentIndex = index;
    notifyListeners();
  }
}


