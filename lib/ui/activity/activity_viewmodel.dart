import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityViewmodel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addWorkout({
  required String userId,
  required String activityType,
  required int duration,  // in minutes
  required double caloriesExpended,  // pass from user input or calculate
  }) async {
    try {
      await _firestore.collection('workoutHistory').add({
        'uid': userId,
        'activityType': activityType,
        'duration': duration,
        'caloriesExpended': caloriesExpended,
        'timestamp': Timestamp.now(),
      });

      print('Workout added successfully!');
    } catch (e) {
      print('Error adding workout: $e');
    }
  }

}