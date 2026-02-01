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
  //
  // // Ensure the logout method is present
  // Future<void> logout() async {
  //   try {
  //     debugPrint("Logout process started...");
  //     await _auth.signOut();
  //     debugPrint("Firebase sign out successful.");
  //     Get.offAll(() => AuthWrapper());
  //     debugPrint("Navigated to AuthWrapper.");
  //   } catch (e) {
  //     debugPrint("Error during logout: $e");
  //     Get.snackbar("Logout Error", "An error occurred: ${e.toString()}");
  //   }
  // }
}
