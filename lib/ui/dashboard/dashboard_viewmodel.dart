import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class DashboardViewModel {
  Future<List<Map<String, dynamic>>> fetchWorkoutHistory() async {
    try {
      CollectionReference workoutCollection = FirebaseFirestore.instance.collection('workoutHistory');
      
      QuerySnapshot snapshot = await workoutCollection.get();
      
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
  
  Future<List<Map<String, dynamic>>> fetchNutritionIntake() async {
    try {
      CollectionReference nutritionCollection = FirebaseFirestore.instance.collection('nutritionIntake');
      
      QuerySnapshot snapshot = await nutritionCollection.get();
      
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

  // to format timestamp
  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate(); // convert Firestore Timestamp to DateTime
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime); // format as 'yyyy-MM-dd HH:mm:ss'
  }
}
