import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fitnest_app/ui/authentication/user_viewmodel.dart';
import 'view_model/dashboard_viewmodel.dart';
import 'view_model/schedule_viewmodel.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final UserViewModel userViewModel = UserViewModel();
  final DashboardViewModel dashboardViewModel = DashboardViewModel();
  final ScheduleViewModel scheduleViewModel = ScheduleViewModel();

  String currentUserIdDisplay = ''; // to store the current user ID for display
  List<Map<String, dynamic>> todayWorkoutSchedule = [];
  List<Map<String, dynamic>> workoutHistory = [];
  List<Map<String, dynamic>> nutritionIntake = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData(); // fetch data on initialization
  }

  Future<void> fetchData() async {
    String? currentUserId = await userViewModel.getUserUid();

    if (currentUserId != null) {
      List<Map<String, dynamic>> fetchedTodayWorkoutSchedule =
          await scheduleViewModel.fetchWorkoutSchedule(currentUserId);
      List<Map<String, dynamic>> fetchedWorkoutHistory =
          await dashboardViewModel.fetchWorkoutHistory(currentUserId);
      List<Map<String, dynamic>> fetchedNutritionIntake =
          await dashboardViewModel.fetchNutritionIntake(currentUserId);

      // filter for only today's workout schedule
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      List<Map<String, dynamic>> filteredToday =
          fetchedTodayWorkoutSchedule.where((workout) {
        final scheduledDateTime = DateTime.parse(workout['scheduledTime']);
        final workoutDate = DateTime(scheduledDateTime.year,
            scheduledDateTime.month, scheduledDateTime.day);
        return workoutDate == today;
      }).toList();

      setState(() {
        currentUserIdDisplay = currentUserId; // store the current user ID
        todayWorkoutSchedule = filteredToday;
        workoutHistory = fetchedWorkoutHistory;
        nutritionIntake = fetchedNutritionIntake;
        isLoading = false; // data fetching complete
      });
    } else {
      // handle the case where the user is not logged in
      setState(() {
        isLoading = false;
      });
      print('User not logged in.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Workout Streak Section
                Card(
                  color: Colors.green[50],
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    child: Row(
                      children: [
                        Icon(Icons.local_fire_department,
                            color: Colors.orange[700], size: 36),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Streak of :\n$currentUserIdDisplay',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '🔥 7 days in a row!',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: 50,
                          title: '50%',
                          color: Colors.blue,
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: 50,
                          title: '50%',
                          color: Colors.orange,
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('Calorie Intake'),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('Calories Burned'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Today\'s Workout Schedule',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  color: Colors.grey[200],
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: todayWorkoutSchedule.length,
                    itemBuilder: (context, index) {
                      var todayWorkoutItem = todayWorkoutSchedule[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.run_circle),
                          title: Text(todayWorkoutItem['activityType']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${todayWorkoutItem['description']}'),
                              Text(
                                  'Scheduled at: ${todayWorkoutItem['scheduledTime']}'),
                              Text(
                                'Status: ${todayWorkoutItem['status']}',
                                style: TextStyle(
                                  color: todayWorkoutItem['status'] ==
                                          'Completed'
                                      ? Colors.green
                                      : todayWorkoutItem['status'] == 'To-do'
                                          ? Colors.orange
                                          : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Workout History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Container(
                        constraints: const BoxConstraints(maxHeight: 300),
                        color: Colors.grey[200],
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: workoutHistory.length,
                          itemBuilder: (context, index) {
                            var workout = workoutHistory[index];
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.run_circle),
                                title: Text(workout['activityType']),
                                subtitle: Text(
                                    'Duration: ${workout['duration']} minutes \nTimestamp: ${workout['timestamp']}'),
                              ),
                            );
                          },
                        ),
                      ),
                const SizedBox(height: 16),

                const Text(
                  'Nutrition Intake',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Container(
                        constraints: const BoxConstraints(maxHeight: 300),
                        color: Colors.grey[200],
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: nutritionIntake.length,
                          itemBuilder: (context, index) {
                            var nutrition = nutritionIntake[index];
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.restaurant),
                                title: Text(nutrition['mealType']),
                                subtitle: Text(
                                    'Calorie: ${nutrition['calories']} cal \nMeal Time: ${nutrition['mealTime']}'),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),

      // Dashboard filter button
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                bool showTodaySchedule = true;
                bool showWorkoutHistory = true;
                bool showNutritionIntake = true;

                return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Filter Content Display',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          CheckboxListTile(
                            title: const Text('Today\'s Schedule'),
                            value: showTodaySchedule,
                            onChanged: (bool? value) {
                              setState(() {
                                showTodaySchedule = value ?? false;
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: const Text('Workout History'),
                            value: showWorkoutHistory,
                            onChanged: (bool? value) {
                              setState(() {
                                showWorkoutHistory = value ?? false;
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: const Text('Nutrition Intake'),
                            value: showNutritionIntake,
                            onChanged: (bool? value) {
                              setState(() {
                                showNutritionIntake = value ?? false;
                              });
                            },
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              // filters to the page content here
                            },
                            child: const Text('Apply Filters'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
          child: const Icon(Icons.filter_list_alt),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
