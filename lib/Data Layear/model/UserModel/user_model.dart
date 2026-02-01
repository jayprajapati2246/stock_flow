class UserModel {
  final String id;
  final String fname;
  final String lname;
  final String phone;
  final String email;
  final String? photoURL;

  UserModel({
    required this.id,
    required this.fname,
    required this.lname,
    required this.phone,
    required this.email,
    this.photoURL,
  });

  // A factory to create a UserModel from a map, with null safety
  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      fname: data['fname'] as String? ?? '',
      lname: data['lname'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoURL: data['photoURL'] as String?,
    );
  }

  // Converts the UserModel to a map for writing to the database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fname': fname,
      'lname': lname,
      'phone': phone,
      'email': email,
      'photoURL': photoURL,
    };
  }
}
