import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'schedule_page.dart';
import '../profile/profile_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitnest_app/ui/services/notification_service.dart';
import 'package:fitnest_app/ui/authentication/user_viewmodel.dart';
import 'package:fitnest_app/ui/dashboard/view_model/schedule_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(
    home: HomeNavigationView(),
    debugShowCheckedModeBanner: false,
  ));
}

class HomeNavigationView extends StatefulWidget {
  const HomeNavigationView({super.key});

  @override
  State<HomeNavigationView> createState() => _HomeNavigationViewState();
}

class _HomeNavigationViewState extends State<HomeNavigationView> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardView(),
    const SchedulePage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () async {
              final userViewModel = UserViewModel();
              String? userId = await userViewModel.getUserUid();

              if (userId == null) return;

              final scheduleViewModel = ScheduleViewModel();
              final missed = await scheduleViewModel.getMissedWorkouts(userId);

              if (missed.isNotEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Missed Workouts'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: missed.map((workout) {
                        return ListTile(
                          leading: const Icon(Icons.warning, color: Colors.red),
                          title: Text(workout['activityType']),
                          subtitle:
                              Text('Missed at: ${workout['scheduledTime']}'),
                        );
                      }).toList(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No missed workouts! 🎉')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // refresh whole dashboard
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeNavigationView(),
                ),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/profile_pic_default.jpg'),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 1:
        return 'Schedule';
      case 2:
        return 'Profile';
      default:
        return 'Dashboard';
    }
  }
}
