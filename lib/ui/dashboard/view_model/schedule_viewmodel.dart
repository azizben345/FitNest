import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ScheduleViewModel {
  Future<List<Map<String, dynamic>>> fetchWorkoutSchedule(String currentUserId) async {
    try {
      CollectionReference scheduleCollection =
          FirebaseFirestore.instance.collection('workoutSchedule');

      // Filter documents where 'uid' equals currentUserId
      QuerySnapshot snapshot = await scheduleCollection
          .where('uid', isEqualTo: currentUserId)
          .get();

      List<Map<String, dynamic>> fetchedWorkoutSchedule = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'activityType': doc['activityType'],
          'description': doc['description'],
          'scheduledTime': formatTimestamp(doc['scheduledTime']),
        };
      }).toList();

      return fetchedWorkoutSchedule;
    } catch (e) {
      print('Error fetching workout schedule: $e');
      return [];
    }
  }

  // Format timestamp
  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate(); // Convert Firestore Timestamp to DateTime
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime); // Format as 'yyyy-MM-dd HH:mm:ss'
  }
}