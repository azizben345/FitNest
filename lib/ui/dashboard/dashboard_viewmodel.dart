import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
//import 'dart:math';

class DashboardViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchWorkoutHistory(String userId) async {
    try {
      // Filter by current user's ID assuming 'userId' field in workoutHistory
      QuerySnapshot snapshot = await _firestore
          .collection('workoutHistory')
          .where('uid', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      List<Map<String, dynamic>> fetchedWorkoutHistory =
          snapshot.docs.map((doc) {
            // print('RAW doc: ${doc.data()}');
            return {
              'id': doc.id,
              'activityType': doc['activityType'],
              'duration': doc['duration'],
              'caloriesExpended': (doc['caloriesExpended'] as num?)?.toDouble() ?? 0.0,
              'timestamp': formatTimestamp(doc['timestamp']),
            };
          }).toList();

      return fetchedWorkoutHistory;
    } catch (e) {
      print('Error fetching workout history: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchNutritionIntake(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('nutritionIntake')
          .doc(userId)
          .collection('meals')
          .orderBy('mealTime', descending: true)
          .limit(30)
          .get();

      // Return data, keeping mealTime as Timestamp object for flexibility
      return querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'calories': (doc.data()['calories'] as num?)?.toDouble() ?? 0.0,
          'mealTime': doc.data()['mealTime'] as Timestamp?,
          'mealType': doc.data()['mealType'] as String? ?? 'N/A',
        };
      }).toList();
    } catch (e) {
      print('Error fetching nutrition intake for user $userId: $e');
      return [];
    }
  }

  // to format timestamp
  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime =
        timestamp.toDate(); // convert Firestore Timestamp to DateTime
    return DateFormat('yyyy-MM-dd HH:mm:ss')
        .format(dateTime); // format as 'yyyy-MM-dd HH:mm:ss'
  }
}
