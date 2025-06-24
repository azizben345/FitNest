import 'package:fitnest_app/ui/services/CalorieCalculatorService.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fitnest_app/ui/authentication/user_viewmodel.dart';
import 'view_model/dashboard_viewmodel.dart';
import 'view_model/schedule_viewmodel.dart';
import 'package:fitnest_app/ui/activity/activity.dart';
import 'package:fitnest_app/ui/activity/temp_activity_page.dart';
import 'package:fitnest_app/ui/activity/nutritionIntake.dart';
import 'package:fitnest_app/ui/activity/nutritionIntake_viewmodel.dart';
import 'package:fitnest_app/ui/services/CalorieCalculatorService.dart';
import 'package:fitnest_app/ui/dashboard/widgets/CaloriePieChart.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final UserViewModel userViewModel = UserViewModel();
  final DashboardViewModel dashboardViewModel = DashboardViewModel();
  final ScheduleViewModel scheduleViewModel = ScheduleViewModel();
  final CalorieCalculatorService calorieService = CalorieCalculatorService();

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

  void fetchCalorieBreakdown() async {
    final result = await calorieService.calculateUserCalorieNeeds();
    if (result != null) {
      print(
          "BMR: ${result.bmr}, Activity: ${result.activity}, Goal: ${result.goalAdjustment}");
    }
  }

  @override
  Widget build(BuildContext context) {
    // calculate workout streaks
    Map<String, int> calculateStreak(List<Map<String, dynamic>> history) {
      history.sort((a, b) => DateTime.parse(b['timestamp'])
          .compareTo(DateTime.parse(a['timestamp'])));

      int currentStreak = 0;
      int longestStreak = 0;
      int tempStreak =
          0; // temporary streak to track streaks throughout history

      DateTime today = DateTime.now();
      DateTime expectedDate = DateTime(today.year, today.month, today.day);

      // to track streaks in the past, including longest streak
      for (var workout in history) {
        DateTime workoutDate = DateTime.parse(workout['timestamp']);
        workoutDate =
            DateTime(workoutDate.year, workoutDate.month, workoutDate.day);

        if (workoutDate == expectedDate) {
          // workout on expected date, increase streak
          currentStreak++;
          tempStreak++;
          longestStreak = tempStreak > longestStreak
              ? tempStreak
              : longestStreak; // update longest streak
          expectedDate = expectedDate.subtract(const Duration(days: 1));
        } else if (workoutDate.isBefore(expectedDate)) {
          // break in streak (date mismatch), reset temporary streak
          tempStreak = 0;
        }
      }

      return {
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
      };
    }

    final streaks = calculateStreak(workoutHistory);
    final int currentStreak = streaks['currentStreak'] ?? 0;
    final int longestStreak = streaks['longestStreak'] ?? 0;

    // filter calorie data from start and end of the current week (Monday to Sunday)
    DateTime now = DateTime.now();
    DateTime weekStart = now.subtract(Duration(days: now.weekday - 1));
    DateTime weekEnd = weekStart.add(const Duration(days: 6));

    // filter nutrition intake for this week
    List<Map<String, dynamic>> weekNutrition = nutritionIntake.where((meal) {
      DateTime mealTime = DateTime.parse(meal['mealTime']);
      return mealTime.isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
          mealTime.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();
    // filter workout history for this week
    List<Map<String, dynamic>> weekWorkouts = workoutHistory.where((workout) {
      DateTime workoutTime = DateTime.parse(workout['timestamp']);
      return workoutTime
              .isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
          workoutTime.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();

    // calculate total calories consumed and burned for this week
    double totalCaloriesIn = weekNutrition.fold(
        0.0, (prev, item) => prev + (item['calories'] as num));
    double totalCaloriesOut = weekWorkouts.fold(
        0.0, (prev, item) => prev + (item['caloriesExpended'] as num? ?? 0));

    // Prepare data for bar chart: caloriesExpended per day (Monday to Sunday)
    List<double> caloriesPerDay = List.filled(7, 0.0); // index 0 = Monday

    for (var workout in weekWorkouts) {
      DateTime workoutTime = DateTime.parse(workout['timestamp']);
      int weekdayIndex = workoutTime.weekday - 1; // Monday = 0
      if (weekdayIndex >= 0 && weekdayIndex < 7) {
        caloriesPerDay[weekdayIndex] +=
            (workout['caloriesExpended'] as num? ?? 0).toDouble();
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // workout Streak Section
                Card(
                  color: Colors.green[50],
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Workout Streaks',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.local_fire_department,
                                color: Colors.orange[700], size: 36),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('🔥 Current streak: $currentStreak days'),
                                Text('🏅 Longest streak: $longestStreak days'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                CaloriePieChart(),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: totalCaloriesIn,
                          title:
                              '${(totalCaloriesIn / (totalCaloriesIn + totalCaloriesOut) * 100).toStringAsFixed(1)}%',
                          color: Colors.blue,
                          radius: 40,
                        ),
                        PieChartSectionData(
                          value: totalCaloriesOut,
                          title:
                              '${(totalCaloriesOut / (totalCaloriesIn + totalCaloriesOut) * 100).toStringAsFixed(1)}%',
                          color: Colors.orange,
                          radius: 40,
                        )
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

                // Calorie Expended Line Chart
                const Text(
                  'Calories Expended This Week',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 250,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const days = [
                                'Mon',
                                'Tue',
                                'Wed',
                                'Thu',
                                'Fri',
                                'Sat',
                                'Sun'
                              ];
                              if (value >= 0 && value <= 6) {
                                return Text(days[value.toInt()]);
                              }
                              return const SizedBox.shrink();
                            },
                            interval: 1,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      minX: 0,
                      maxX: 6, // 7 days in a week
                      minY: 0,
                      maxY: caloriesPerDay.isEmpty
                          ? 0
                          : caloriesPerDay.reduce((a, b) => a > b ? a : b),
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(
                            7,
                            (i) => FlSpot(i.toDouble(), caloriesPerDay[i]),
                          ),
                          isCurved: true,
                          color: Colors.orange,
                          barWidth: 4,
                          belowBarData: BarAreaData(
                              show: true,
                              color: Colors.orange.withOpacity(0.3)),
                        ),
                      ],
                    ),
                  ),
                ),
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
                                    'Duration: ${workout['duration']} minutes \nTimestamp: ${workout['timestamp']}\nCalories Expended: ${workout['caloriesExpended']} cal'),
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

      // navigate to activity or nutrition page on button press
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 8),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          elevation: 8,
          icon: const Icon(Icons.add, size: 28),
          label: const Text(
            'Add',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (context) => Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading:
                          const Icon(Icons.directions_run, color: Colors.blue),
                      title: const Text('Add Activity'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AddWorkoutPage(userId: currentUserIdDisplay)),
                        );
                      },
                    ),
                    ListTile(
                      leading:
                          const Icon(Icons.restaurant, color: Colors.orange),
                      title: const Text('Add Nutrition Intake'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const NutritionIntakePage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
