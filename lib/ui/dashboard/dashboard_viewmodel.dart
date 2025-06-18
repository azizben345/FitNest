import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DashboardViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> fetchWorkoutHistory() async {
    final user = _auth.currentUser; // Use _auth instance
    if (user == null) {
      print("No user logged in to fetch workout history.");
      return [];
    }
    try {
      // Filter by current user's ID assuming 'userId' field in workoutHistory
      QuerySnapshot snapshot = await _firestore
          .collection('workoutHistory')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .get();

      List<Map<String, dynamic>> fetchedWorkoutHistory =
          snapshot.docs.map((doc) {
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

  // Future<List<Map<String, dynamic>>> fetchWorkoutHistory() async {
  //   try {
  //     CollectionReference workoutCollection =
  //         FirebaseFirestore.instance.collection('workoutHistory');

  //     QuerySnapshot snapshot = await workoutCollection.get();

  //     List<Map<String, dynamic>> fetchedWorkoutHistory =
  //         snapshot.docs.map((doc) {
  //       return {
  //         'id': doc.id,
  //         'activityType': doc['activityType'],
  //         'duration': doc['duration'],
  //         'timestamp': formatTimestamp(doc['timestamp']),
  //       };
  //     }).toList();

  //     return fetchedWorkoutHistory;
  //   } catch (e) {
  //     print('Error fetching workout history: $e');
  //     return [];
  //   }
  // }

  // Future<List<Map<String, dynamic>>> fetchNutritionIntake() async {
  //   try {
  //     CollectionReference nutritionCollection =
  //         FirebaseFirestore.instance.collection('nutritionIntake');

  //     QuerySnapshot snapshot = await nutritionCollection.get();

  //     List<Map<String, dynamic>> fetchedNutritionIntake =
  //         snapshot.docs.map((doc) {
  //       return {
  //         'id': doc.id,
  //         'calories': doc['calories'],
  //         'mealTime': formatTimestamp(doc['mealTime']),
  //         'mealType': doc['mealType'],
  //       };
  //     }).toList();

  //     return fetchedNutritionIntake;
  //   } catch (e) {
  //     print('Error fetching nutrition intake: $e');
  //     return [];
  //   }
  // }

  Future<List<Map<String, dynamic>>> fetchNutritionIntake() async {
    final user = _auth.currentUser; // Get current user
    if (user == null) {
      print("No user logged in to fetch nutrition intake.");
      return [];
    }

    try {
      final querySnapshot = await _firestore
          .collection('nutritionIntake')
          .doc(user.uid) // Document for the specific user
          .collection('meals') // Subcollection of meals for that user
          .orderBy('mealTime', descending: true)
          .limit(30) // Fetch enough data for the chart (e.g., last 30 entries)
          .get();

      // Return data, keeping mealTime as Timestamp object for flexibility
      return querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'calories': (doc.data()?['calories'] as num?)?.toDouble() ?? 0.0,
          'mealTime':
              doc.data()?['mealTime'] as Timestamp?, // Keep as Timestamp!
          'mealType': doc.data()?['mealType'] as String? ?? 'N/A',
        };
      }).toList();
    } catch (e) {
      print('Error fetching nutrition intake for user ${user.uid}: $e');
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
