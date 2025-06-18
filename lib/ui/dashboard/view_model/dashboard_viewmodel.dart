import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DashboardViewModel {

  // STC, this one still didnt work:
  // Future<List<Map<String, dynamic>>> fetchTodayWorkoutSchedule(String currentUserId) async { 
  //   try {
  //     // Get the start of today and the start of tomorrow (to set the range)
  //     DateTime now = DateTime.now().toUtc();  // Ensure it's in UTC time
  //     DateTime startOfDay = DateTime(now.year, now.month, now.day);  // 12:00 AM today
  //     DateTime startOfTomorrow = startOfDay.add(const Duration(days: 1));  // 12:00 AM tomorrow

  //     // Convert to Firestore Timestamp
  //     Timestamp startOfDayTimestamp = Timestamp.fromDate(startOfDay);
  //     Timestamp startOfTomorrowTimestamp = Timestamp.fromDate(startOfTomorrow);

  //     // Print for debugging
  //     print("Start of Today: $startOfDayTimestamp");
  //     print("Start of Tomorrow: $startOfTomorrowTimestamp");

  //     CollectionReference scheduleCollection = FirebaseFirestore.instance.collection('workoutSchedule');

  //     // Filter for today's workout schedule by comparing the 'scheduledTime' range
  //     QuerySnapshot snapshot = await scheduleCollection
  //         .where('uid', isEqualTo: currentUserId)
  //         .where('scheduledTime', isGreaterThanOrEqualTo: startOfDayTimestamp)  // After start of today
  //         .where('scheduledTime', isLessThan: startOfTomorrowTimestamp)  // Before start of tomorrow
  //       .get();

  //     List<Map<String, dynamic>> fetchedWorkoutSchedule = snapshot.docs.map((doc) {
  //       return {
  //         'id': doc.id,
  //         'activityType': doc['activityType'],
  //         'description': doc['description'],
  //         'scheduledTime': formatTimestamp(doc['scheduledTime']),
  //       };
  //     }).toList();

  //     return fetchedWorkoutSchedule;
  //   } catch (e) {
  //     print('Error fetching workout schedule: $e');
  //     return [];
  //   }
  // }

  Future<List<Map<String, dynamic>>> fetchWorkoutHistory(String currentUserId) async {
    try {
      CollectionReference workoutCollection =
          FirebaseFirestore.instance.collection('workoutHistory');

      // Filter documents where 'uid' equals currentUserId
      QuerySnapshot snapshot = await workoutCollection
          .where('uid', isEqualTo: currentUserId)
          .get();

      List<Map<String, dynamic>> fetchedWorkoutHistory = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'activityType': doc['activityType'],
          'duration': doc['duration'],
          'timestamp': formatTimestamp(doc['timestamp']),
        };
      }).toList();

      return fetchedWorkoutHistory;
    } catch (e) {
      print('Error fetching workout history: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchNutritionIntake(String currentUserId) async {
    try {
      CollectionReference nutritionCollection =
          FirebaseFirestore.instance.collection('nutritionIntake');

      // Filter documents where 'uid' equals currentUserId
      QuerySnapshot snapshot = await nutritionCollection
          .where('uid', isEqualTo: currentUserId)
          .get();

      List<Map<String, dynamic>> fetchedNutritionIntake = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'calories': doc['calories'],
          'mealTime': formatTimestamp(doc['mealTime']),
          'mealType': doc['mealType'],
        };
      }).toList();

      return fetchedNutritionIntake;
    } catch (e) {
      print('Error fetching nutrition intake: $e');
      return [];
    }
  }

  // Format timestamp
  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate(); // Convert Firestore Timestamp to DateTime
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime); // Format as 'yyyy-MM-dd HH:mm:ss'
  }
  // // Format timestamp
  // String formatTimestampDate(Timestamp timestamp) {
  //   DateTime dateTime = timestamp.toDate(); // Convert Firestore Timestamp to DateTime
  //   return DateFormat('MMMM d, y').format(dateTime); // Format as 'June 14, 2025'
  // }
}