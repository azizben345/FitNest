import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
//import 'dart:math';

class DashboardViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<List<Map<String, dynamic>>> fetchWorkoutHistory(String userId) async {
  try {
    QuerySnapshot snapshot = await _firestore
        .collection('workoutHistory')
        .where('uid', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    List<Map<String, dynamic>> fetchedWorkoutHistory = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      // Always set caloriesExpended safely
      final caloriesExpended = data.containsKey('caloriesExpended') && data['caloriesExpended'] != null
          ? (data['caloriesExpended'] as num).toDouble()
          : 0.0;

      final mapped = {
        'id': doc.id,
        'activityType': data['activityType'] ?? 'Unknown',
        'duration': data['duration'] ?? 0,
        'caloriesExpended': caloriesExpended,
        'timestamp': formatTimestamp(data['timestamp']),
      };

      print('MAPPED WORKOUT: $mapped');  // Debug print to confirm what gets mapped
      return mapped;
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
