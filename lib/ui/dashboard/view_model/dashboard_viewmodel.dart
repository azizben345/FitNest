import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DashboardViewModel {
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
}