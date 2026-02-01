import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:stock_flow/Data%20Layear/model/UserModel/user_model.dart';

class UserService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();


  DatabaseReference _profileRef(String uid) =>
      _db.child('users').child(uid).child('profile');


  Future<void> createUserProfile(UserModel user) async {
    try {
      await _profileRef(user.id).set(user.toMap());
    } catch (e) {
      debugPrint("Error creating user profile: $e");
      rethrow;
    }
  }


  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final snapshot = await _profileRef(uid).get();

      if (snapshot.exists && snapshot.value != null) {
        return UserModel.fromMap(
          uid,
          Map<String, dynamic>.from(snapshot.value as Map),
        );
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching user profile: $e");
      return null;
    }
  }
}
