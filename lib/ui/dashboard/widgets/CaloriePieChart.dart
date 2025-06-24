import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fitnest_app/ui/services/CalorieCalculatorService.dart';
import 'package:fitnest_app/ui/dashboard/view_model/dashboard_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CaloriePieChart extends StatefulWidget {
  const CaloriePieChart({super.key});

  @override
  State<CaloriePieChart> createState() => _CaloriePieChartState();
}

class _CaloriePieChartState extends State<CaloriePieChart> {
  final DashboardViewModel dashboardVM = DashboardViewModel();
  final CalorieCalculatorService calorieService = CalorieCalculatorService();

  double _calorieTarget = 0;
  double _consumedCalories = 0;
  double _burnedCalories = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCalorieData();
  }

  Future<void> _loadCalorieData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final calorieResult = await calorieService.calculateUserCalorieNeeds();
    final foodLogs = await dashboardVM.fetchNutritionIntake(user.uid);
    final workoutLogs = await dashboardVM.fetchWorkoutHistory(user.uid);

    double consumed = foodLogs.fold(
        0.0, (sum, item) => sum + (item['calories'] as num? ?? 0.0));
    double burned = workoutLogs.fold(
        0.0, (sum, item) => sum + (item['caloriesExpended'] as num? ?? 0.0));

    setState(() {
      _calorieTarget = calorieResult?.total ?? 0;
      _consumedCalories = consumed;
      _burnedCalories = burned;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final remaining = (_calorieTarget - _consumedCalories - _burnedCalories)
        .clamp(0, _calorieTarget);

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.3,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: _consumedCalories,
                  color: Colors.blue,
                  title: '${_consumedCalories.round()} kcal',
                  radius: 50,
                  titleStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                PieChartSectionData(
                  value: remaining.toDouble(),
                  color: Colors.grey[300],
                  title: '${remaining.round()} kcal',
                  radius: 50,
                  titleStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            Text(
              '${_calorieTarget.round()} kcal',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text('Daily Target Overview'),
            const SizedBox(height: 8),
            // Wrap(
            //   spacing: 24,
            //   alignment: WrapAlignment.center,
            //   children: [
            //     _legendDot('Consumed', Colors.blue),
            //     _legendDot('Burned', Colors.orange),
            //     _legendDot('Remaining', Colors.grey),
            //   ],
            // ),
          ],
        ),
      ],
    );
  }
}

Widget _legendDot(String label, Color color) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 12)),
    ],
  );
}
