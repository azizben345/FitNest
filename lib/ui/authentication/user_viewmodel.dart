import 'package:firebase_auth/firebase_auth.dart';

class UserViewModel {
  // fetch the current user's UID
  Future<String?> getUserUid() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;  // return the user's UID or null if not logged in
  }
}
