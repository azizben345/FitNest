import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// import 'dart:math';

class ProfileViewmodel {
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> fetchUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      print("No user logged in to fetch profile.");
      return null;
    }

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('userProfiles').doc(user.uid).get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        print("User profile not found for UID: ${user.uid}");
        return null;
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // Calculates the target calorie intake based on user profile and goals
  double? calculateDailyCalorieGoals({
    required Map<String, dynamic> userProfile,
    String? activityLevel, // Make optional, use default if null
    double? weightLossTargetKgPerWeek, // Make optional, use default if null
  }) {
    final double? heightCm = (userProfile['height'] as num?)?.toDouble();
    final double? weightKg = (userProfile['weight'] as num?)?.toDouble();
    final String? gender = userProfile['gender'] as String?;

    // Use provided activity level, or default to 'Moderately Active'
    final String effectiveActivityLevel = activityLevel ??
        userProfile['activityLevel'] as String? ??
        'moderately active';
    // Use provided weight loss target, or default to 0.5 kg/week
    final double effectiveWeightLossTargetKgPerWeek =
        weightLossTargetKgPerWeek ??
            (userProfile['weightLossTargetKgPerWeek'] as num?)?.toDouble() ??
            0.5;

    DateTime? birthday;
    if (userProfile['birthday'] is Timestamp) {
      birthday = (userProfile['birthday'] as Timestamp).toDate();
    } else if (userProfile['birthday'] is String) {
      try {
        birthday = DateTime.parse(userProfile['birthday']);
      } catch (e) {
        print("Error parsing birthday string in user profile: $e");
      }
    }

    if (heightCm == null ||
        heightCm <= 0 ||
        weightKg == null ||
        weightKg <= 0 ||
        gender == null ||
        gender.isEmpty ||
        birthday == null) {
      print(
          "Missing crucial profile data for calorie calculation (height, weight, gender, or birthday).");
      return null; // Return null if data is incomplete
    }

    final today = DateTime.now();
    int ageYears = today.year - birthday.year;
    if (today.month < birthday.month ||
        (today.month == birthday.month && today.day < birthday.day)) {
      ageYears--;
    }

    double bmr;
    if (gender.toLowerCase() == 'male') {
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * ageYears) + 5;
    } else if (gender.toLowerCase() == 'female') {
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * ageYears) - 161;
    } else {
      print("Unsupported gender for BMR calculation: $gender");
      return null;
    }

    double activityMultiplier;
    switch (effectiveActivityLevel.toLowerCase()) {
      case 'sedentary':
        activityMultiplier = 1.2;
        break;
      case 'lightly active':
        activityMultiplier = 1.375;
        break;
      case 'moderately active':
        activityMultiplier = 1.55;
        break;
      case 'very active':
        activityMultiplier = 1.725;
        break;
      case 'extra active':
        activityMultiplier = 1.9;
        break;
      default:
        activityMultiplier = 1.55;
        break;
    }

    final double tdee = bmr * activityMultiplier;
    final double dailyCalorieDeficit =
        effectiveWeightLossTargetKgPerWeek * 7700 / 7;

    double netCalorieTarget = tdee - dailyCalorieDeficit;
    return netCalorieTarget.roundToDouble(); // Round to nearest whole number
  }

  // Method to aggregate daily calories (as provided by you)
  Map<DateTime, double> aggregateDailyCalories(
      List<Map<String, dynamic>> nutritionIntake) {
    Map<DateTime, double> dailyCalories = {};

    for (var entry in nutritionIntake) {
      final Timestamp? mealTimeTimestamp = entry['mealTime'];
      final double calories = entry['calories'] as double;

      if (mealTimeTimestamp != null) {
        final DateTime mealTime = mealTimeTimestamp.toDate();
        final DateTime day =
            DateTime(mealTime.year, mealTime.month, mealTime.day);

        dailyCalories.update(day, (value) => value + calories,
            ifAbsent: () => calories);
      } else {
        print('Warning: Nutrition entry with null mealTime found: $entry');
      }
    }
    return dailyCalories;
  }
}