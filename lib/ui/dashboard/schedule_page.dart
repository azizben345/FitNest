import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fitnest_app/ui/authentication/user_viewmodel.dart';
import 'view_model/schedule_viewmodel.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  _SchedulePageState createState() => _SchedulePageState(); 
}

class _SchedulePageState extends State<SchedulePage> { 
  
  final UserViewModel userViewModel = UserViewModel();
  final ScheduleViewModel scheduleViewModel = ScheduleViewModel();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  //String currentUserIdDisplay = ''; // to store the current user ID for display
  List<Map<String, dynamic>> workoutSchedule = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData(); // fetch data on initialization
  }

  Future<void> fetchData() async {
    String? currentUserId = await userViewModel.getUserUid(); 

    if (currentUserId != null) {
      List<Map<String, dynamic>> fetchedWorkoutSchedule = await scheduleViewModel.fetchWorkoutSchedule(currentUserId);

      setState(() {
        //currentUserIdDisplay = currentUserId; // store the current user ID
        workoutSchedule = fetchedWorkoutSchedule;
        isLoading = false;  // data fetching complete
      });
    } else {
      // handle the case where the user is not logged in
      setState(() {
        isLoading = false;
      });
      print('User not logged in.');
    }
  }
  
  // final Map<DateTime, List<String>> _workoutSchedule = {
  //   DateTime.utc(2025, 5, 20): ['Push-ups', 'Running', 'Yoga'],
  //   DateTime.utc(2025, 5, 21): ['Pull-ups', 'Cycling'],
  //   DateTime.utc(2025, 5, 22): ['Squats', 'Swimming'],
  // };
  // List<String> _getWorkoutsForDay(DateTime day) {
  //   final normalizedDay = DateTime.utc(day.year, day.month, day.day);
  //   return _workoutSchedule[normalizedDay] ?? [];
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: const Text("Workout Schedule"),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2020, 1, 1),
            lastDay: DateTime(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },

            /// 🔥 enables dot indicators on workout days
            eventLoader: (day) {
              final normalizedDay = DateTime.utc(day.year, day.month, day.day);
              return workoutSchedule
                  .where((workout) {
                    DateTime scheduledDate = DateTime.parse(workout['scheduledTime']);
                    return scheduledDate.year == normalizedDay.year &&
                        scheduledDate.month == normalizedDay.month &&
                        scheduledDate.day == normalizedDay.day;
                  })
                  .toList();
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : workoutSchedule.isEmpty
                    ? Center(
                        child: Text(
                          'No workouts scheduled for this day: \n$_selectedDay',
                          style: const TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: workoutSchedule.length,
                        itemBuilder: (context, index) {
                          var workoutItem = workoutSchedule[index];
                          DateTime scheduledDate = DateTime.parse(workoutItem['scheduledTime']);
                          if (scheduledDate.year == _selectedDay.year &&
                              scheduledDate.month == _selectedDay.month &&
                              scheduledDate.day == _selectedDay.day) {
                            return ListTile(
                              leading: const Icon(Icons.fitness_center),
                              title: Text(workoutItem['activityType']),  
                              subtitle: Text(
                                  '${workoutItem['description']} \nScheduled at: ${(workoutItem['scheduledTime'])}'),
                            );
                          }
                          return Container(); // return empty container if not matching selected day
                        },
                      ),
          ),
        ],
      ),
    );
  }
}