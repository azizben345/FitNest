import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ScheduleViewModel {

  CollectionReference scheduleCollection = FirebaseFirestore.instance.collection('workoutSchedule');

  /// fetch workout schedule
  Future<List<Map<String, dynamic>>> fetchWorkoutSchedule(String currentUserId) async {
    try {
      // Filter documents where 'uid' equals currentUserId
      QuerySnapshot snapshot = await scheduleCollection
          .where('uid', isEqualTo: currentUserId)
          .get();

      List<Map<String, dynamic>> fetchedWorkoutSchedule = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'activityType': doc['activityType'],
          'description': doc['description'],
          'status': doc['status'],
          'scheduledTime': formatTimestamp(doc['scheduledTime']),
        };
      }).toList();

      return fetchedWorkoutSchedule;
    } catch (e) {
      print('Error fetching workout schedule: $e');
      return [];
    }
  }

  /// add/create new workout schedule
  Future<void> addSchedule(String uid, String activity, String description, String scheduledTime) async {
    try {
      await scheduleCollection.add({
        'uid': uid,
        'activityType': activity,
        'description': description,
        'status': 'To-do', // default status during creation
        'scheduledTime': Timestamp.fromDate(DateTime.parse(scheduledTime)),
      });
    } catch (e) {
      print('Error adding workout: $e');
    }
  }

  /// update existing workout schedule
  Future<void> updateSchedule(String id, String activity, String description, String status, String scheduledTime) async {
    try {
      await scheduleCollection.doc(id).update({
        'activityType': activity,
        'description': description,
        'status': status, 
        'scheduledTime': Timestamp.fromDate(DateTime.parse(scheduledTime)),
      });
    } catch (e) {
      print('Error updating workout: $e');
    }
  }

  /// only update status of a workout schedule
  Future<void> updateWorkoutStatus(String id, String status) async {
  try {
    await FirebaseFirestore.instance
        .collection('workoutSchedule')
        .doc(id)
        .update({'status': status});
  } catch (e) {
    print('Error updating status: $e');
  }
}

  /// delete a workout schedule
  Future<void> deleteSchedule(String id) async {
    try {
      await scheduleCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting workout: $e');
    }
  }

  // format timestamp
  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate(); // Convert Firestore Timestamp to DateTime
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime); // Format as 'yyyy-MM-dd HH:mm:ss'
  }
}