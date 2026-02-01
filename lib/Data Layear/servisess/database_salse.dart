import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:stock_flow/Data%20Layear/Controller/auth_controller.dart';

class TransactionService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final AuthController _authController = Get.find<AuthController>();

  // New Structure: users / {userId} / stock_transactions
  String? get _transactionPath {
    final user = _authController.currentUser.value;
    if (user == null) return null;
    return 'users/${user.id}/stock_transactions';
  }

  Future<void> addTransaction(Map<String, dynamic> transactionData) async {
    final path = _transactionPath;
    if (path == null) return;

    final ref = _db.child(path).push();
    transactionData['id'] = ref.key;
    transactionData['timestamp'] = ServerValue.timestamp;
    await ref.set(transactionData);
  }

  Stream<List<Map<String, dynamic>>> getTransactions() {
    final user = _authController.currentUser.value;
    if (user == null) return Stream.value([]);

    final path = 'users/${user.id}/stock_transactions';
    return _db.child(path).onValue.map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists || snapshot.value == null) return [];

      final data = snapshot.value;
      if (data is Map) {
        return data.entries.map((entry) {
          return Map<String, dynamic>.from(entry.value as Map);
        }).toList();
      }
      return [];
    });
  }
}
