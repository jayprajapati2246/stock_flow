import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Manages user authentication state, registration, login, and role-based access control.
class AuthController extends GetxController {
  static AuthController to = Get.find();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // --- Observables for Auth State and UI ---
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoginLoading = false.obs;
  final RxBool isGoogleLoading = false.obs;
  final RxBool isAdmin = false.obs;

  // --- Text Editing Controllers ---
  // For Login
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // For Registration
  final TextEditingController regFnameController = TextEditingController();
  final TextEditingController regLnameController = TextEditingController();
  final TextEditingController regPhonController = TextEditingController();
  final TextEditingController regEmailController = TextEditingController();
  final TextEditingController regPasswordController = TextEditingController();

  @override
  void onReady() {
    super.onReady();
    currentUser.bindStream(_auth.authStateChanges());
    ever(currentUser, _handleAuthChanged);
  }

  void _handleAuthChanged(User? user) {
    if (user != null) {
      // This is a placeholder for checking admin status.
      // You should replace this with your actual logic for determining if a user is an admin.
      // For example, you might check a custom claim or a user role in your database.
      isAdmin.value = true;
    } else {
      isAdmin.value = false;
    }
  }

  @override
  void onClose() {
    // Dispose controllers to prevent memory leaks
    emailController.dispose();
    passwordController.dispose();
    regFnameController.dispose();
    regLnameController.dispose();
    regPhonController.dispose();
    regEmailController.dispose();
    regPasswordController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    isLoginLoading.value = true;
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Get.offAllNamed('/main');
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Login Error', e.message ?? 'An unknown error occurred.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoginLoading.value = false;
    }
  }

  Future<void> register() async {
    isLoginLoading.value = true;
    try {
      await _auth.createUserWithEmailAndPassword(
        email: regEmailController.text.trim(),
        password: regPasswordController.text.trim(),
      );
      await currentUser.value?.updateDisplayName(
          '${regFnameController.text.trim()} ${regLnameController.text.trim()}');

      Get.offAllNamed('/main');
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Registration Error', e.message ?? 'An unknown error occurred.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoginLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    isGoogleLoading.value = true;
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        isGoogleLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      Get.offAllNamed('/main');
    } catch (e) {
      Get.snackbar('Google Sign-In Error', 'Failed to sign in with Google.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isGoogleLoading.value = false;
    }
  }

  /// Signs the user out.
  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    Get.offAllNamed('/login');
  }

  /// Navigates to the registration page.
  void goToRegistration() {
    Get.toNamed('/registration'); // Assuming '/registration' is your route
  }
}