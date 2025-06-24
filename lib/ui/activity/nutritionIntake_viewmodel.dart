import 'package:cloud_firestore/cloud_firestore.dart';

class NutritionIntakeViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addFood({
    required String userId,
    required String mealType,
    required double calories,
    required DateTime mealTime,
  }) async {
    try {
      await _firestore.collection('nutritionIntake').add({
        'uid': userId,
        'mealType': mealType,
        'calories': calories,
        'mealTime': Timestamp.fromDate(mealTime),
      });

      print('Nutrition intake added successfully!');
    } catch (e) {
      print('Error adding nutrition intake: $e');
    }
  }
}
