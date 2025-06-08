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

  // Function to format timestamp
  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate(); // Convert Firestore Timestamp to DateTime
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime); // Format as 'yyyy-MM-dd HH:mm:ss'
  }
}
