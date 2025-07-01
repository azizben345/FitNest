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

  String currentUserIdDisplay = ''; // to store the current user ID for display
  List<Map<String, dynamic>> workoutSchedule = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData(); // fetch data on initialization
  }

  Future<void> fetchData() async {
    String? currentUserId = await userViewModel.getUserUid();

    if (currentUserId == null) return;

    List<Map<String, dynamic>> fetched =
        await scheduleViewModel.fetchWorkoutSchedule(currentUserId);

    setState(() {
      currentUserIdDisplay = currentUserId;
      workoutSchedule = fetched;
      isLoading = false;
    });

    // ⬇️ Show missed workout dialog ONLY if there are any
    final missedWorkouts = getMissedWorkouts();
    if (missedWorkouts.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMissedWorkoutDialog(missedWorkouts);
      });
    }
  }

  List<Map<String, dynamic>> getMissedWorkouts() {
    final now = DateTime.now();
    return workoutSchedule.where((workout) {
      final scheduledTime = workout['scheduledDateTime'];
      final status = workout['status'];

      if (scheduledTime == null) return false; // skip if missing date

      return scheduledTime.isBefore(now) && status != 'Completed';
    }).toList();
  }

  void _showMissedWorkoutDialog(List<Map<String, dynamic>> missedWorkouts) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Workout Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: missedWorkouts.map((workout) {
            return ListTile(
              leading: const Icon(Icons.warning, color: Colors.red),
              title: Text(workout['activityType']),
              subtitle: Text('Missed at: ${workout['scheduledTime']}'),
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
  }

  Future<void> markWorkoutAsCompleted(String workoutId) async {
    try {
      await scheduleViewModel.updateWorkoutStatus(workoutId, 'Completed');
      fetchData(); // Refresh list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout marked as Completed')),
      );
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final missedWorkouts = getMissedWorkouts();
    final missedCount = missedWorkouts.length;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text("Workout Schedule"),
            const SizedBox(width: 8),
            if (missedCount > 0)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$missedCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
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
                _selectedDay = DateTime(
                    selectedDay.year, selectedDay.month, selectedDay.day);
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

            // enables dot indicators on workout days
            eventLoader: (day) {
              final normalizedDay = DateTime.utc(day.year, day.month, day.day);
              return workoutSchedule.where((workout) {
                DateTime scheduledDate = workout['scheduledDateTime'];
                return scheduledDate.year == normalizedDay.year &&
                    scheduledDate.month == normalizedDay.month &&
                    scheduledDate.day == normalizedDay.day;
              }).toList();
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
                          DateTime scheduledDate =
                              workoutItem['scheduledDateTime'];
                          if (scheduledDate.year == _selectedDay.year &&
                              scheduledDate.month == _selectedDay.month &&
                              scheduledDate.day == _selectedDay.day) {
                            return ListTile(
                              leading: const Icon(Icons.fitness_center),
                              title: Text(workoutItem['activityType']),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${workoutItem['description']}'),
                                  Text(
                                      'Scheduled at: ${workoutItem['scheduledTime']}'),
                                  Text(
                                    'Status: ${workoutItem['status']}',
                                    style: TextStyle(
                                      color:
                                          workoutItem['status'] == 'Completed'
                                              ? Colors.green
                                              : workoutItem['status'] == 'To-do'
                                                  ? Colors.orange
                                                  : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check_circle,
                                        color: Colors.green),
                                    tooltip: 'Mark as Completed',
                                    onPressed: () => markWorkoutAsCompleted(
                                        workoutItem['id']),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _showScheduleDialog(
                                        existingWorkout: workoutItem),
                                  ),
                                ],
                              ),
                            );
                          }
                          return Container(); // return empty container if not matching selected day
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showScheduleDialog(); // open form/dialog for CRUD
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showScheduleDialog({Map<String, dynamic>? existingWorkout}) {
    final activityController = TextEditingController(
      text: existingWorkout?['activityType'] ?? '',
    );
    final descriptionController = TextEditingController(
      text: existingWorkout?['description'] ?? '',
    );
    String statusValue = existingWorkout?['status'] ?? 'To-do';
    // final statusController = TextEditingController(
    //   text: existingWorkout?['status'] ?? 'To-do',
    // );

    TimeOfDay selectedTime = existingWorkout != null
        ? TimeOfDay.fromDateTime(existingWorkout['scheduledDateTime'])
        : TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existingWorkout == null ? 'Add Workout' : 'Edit Workout'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: activityController,
                decoration: const InputDecoration(labelText: 'Activity'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              DropdownButtonFormField<String>(
                value: statusValue,
                decoration: const InputDecoration(labelText: 'Status'),
                items: ['Completed', 'To-do', 'Skipped'].map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      statusValue = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (pickedTime != null) {
                    setState(() {
                      selectedTime = pickedTime;
                    });
                  }
                },
                child: Text("Select Time: ${selectedTime.format(context)}"),
              ),
            ],
          ),
          actions: [
            if (existingWorkout != null)
              TextButton(
                onPressed: () async {
                  await scheduleViewModel.deleteSchedule(existingWorkout['id']);
                  Navigator.of(context).pop();
                  fetchData();
                },
                child:
                    const Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final activity = activityController.text.trim();
                final description = descriptionController.text.trim();

                // combine selected day with selected time
                final dateTime = DateTime(
                  _selectedDay.year,
                  _selectedDay.month,
                  _selectedDay.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );

                final dateTimeString = dateTime.toIso8601String();

                if (existingWorkout == null) {
                  await scheduleViewModel.addSchedule(
                    currentUserIdDisplay,
                    activity,
                    description,
                    dateTimeString,
                  );
                } else {
                  await scheduleViewModel.updateSchedule(
                    existingWorkout['id'],
                    activity,
                    description,
                    statusValue,
                    dateTimeString,
                  );
                }

                Navigator.of(context).pop();
                fetchData();
              },
              child: Text(existingWorkout == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }
}
