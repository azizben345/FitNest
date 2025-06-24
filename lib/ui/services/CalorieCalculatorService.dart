import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalorieBreakdown {
  final int bmr;
  final int activity;
  final int goalAdjustment;

  CalorieBreakdown({
    required this.bmr,
    required this.activity,
    required this.goalAdjustment,
  });
  double get total =>
      bmr.toDouble() + activity.toDouble() + goalAdjustment.toDouble();
}

class CalorieCalculatorService {
  Future<CalorieBreakdown?> calculateUserCalorieNeeds() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('userProfiles')
        .doc(user.uid)
        .get();

    final data = doc.data();
    if (data == null) return null;

    final gender = data['gender'] ?? 'Male';
    final height = (data['height'] ?? 170).toDouble();
    final weight = (data['weight'] ?? 70).toDouble();
    final targetWeight = (data['targetWeight'] ?? 65).toDouble();
    final goal = data['physiqueGoal'] ?? 'Maintain Weight';
    final activityLevel = data['activityLevel'] ?? 'Moderate';

    final bmr = _calculateBMR(gender, weight, height);
    final activity = _calculateActivity(bmr, activityLevel);
    final goalAdjustment = _calculateGoalAdjustment(goal, weight, targetWeight);

    return CalorieBreakdown(
      bmr: bmr.round(),
      activity: activity.round(),
      goalAdjustment: goalAdjustment.round(),
    );
  }

  double _calculateBMR(String gender, double weight, double height,
      {int age = 25}) {
    if (gender == 'Male') {
      return 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      return 10 * weight + 6.25 * height - 5 * age - 161;
    }
  }

  double _calculateActivity(double bmr, String level) {
    final multipliers = {
      'Sedentary': 1.2,
      'Light': 1.375,
      'Moderate': 1.55,
      'Active': 1.725,
      'Very Active': 1.9,
    };
    final multiplier = multipliers[level] ?? 1.55;
    return bmr * multiplier - bmr;
  }

  double _calculateGoalAdjustment(
      String goal, double weight, double targetWeight) {
    if (goal == 'Lose Weight' && weight > targetWeight) {
      return -500;
    } else if (goal == 'Build Muscle') {
      return 250;
    } else {
      return 0;
    }
  }
}
