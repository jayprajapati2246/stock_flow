import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:stock_flow/Data%20Layear/model/UserModel/user_model.dart';
// Corrected import path and filename
import 'package:stock_flow/Data%20Layear/servisess/database_user.dart';
import 'package:stock_flow/main.dart';

class UserController extends GetxController {
  // Correctly instantiate the service class
  final UserService services = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);


  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      final userModel = await services.getUserProfile(firebaseUser.uid);
      currentUser.value = userModel;
    }
  }
}
