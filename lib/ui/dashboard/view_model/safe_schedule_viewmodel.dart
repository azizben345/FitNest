import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SafeScheduleViewModel {
  CollectionReference scheduleCollection =
      FirebaseFirestore.instance.collection('workoutSchedule');

  Future<List<Map<String, dynamic>>> fetchWorkoutSchedule(
      String currentUserId) async {
    try {
      QuerySnapshot snapshot =
          await scheduleCollection.where('uid', isEqualTo: currentUserId).get();

      List<Map<String, dynamic>> fetchedWorkoutSchedule =
          snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'activityType': doc['activityType'],
          'description': doc['description'],
          'status': doc['status'],
          'scheduledTime': formatTimestamp(doc['scheduledTime']),
          'scheduledDateTime': doc['scheduledTime'].toDate(),
        };
      }).toList();

      return fetchedWorkoutSchedule;
    } catch (e) {
      print('Error fetching workout schedule: $e');
      return [];
    }
  }

  Future<void> addSchedule(String uid, String activity, String description,
      String scheduledTime) async {
    try {
      await scheduleCollection.add({
        'uid': uid,
        'activityType': activity,
        'description': description,
        'status': 'To-do',
        'scheduledTime': Timestamp.fromDate(DateTime.parse(scheduledTime)),
      });
    } catch (e) {
      print('Error adding workout: $e');
    }
  }

  Future<void> updateSchedule(String id, String activity, String description,
      String status, String scheduledTime) async {
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

  Future<void> deleteSchedule(String id) async {
    try {
      await scheduleCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting workout: $e');
    }
  }

  Future<void> updateWorkoutStatus(String id, String status) async {
    try {
      await scheduleCollection.doc(id).update({'status': status});
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }
}
