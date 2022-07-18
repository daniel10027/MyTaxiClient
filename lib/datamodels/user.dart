import 'package:firebase_database/firebase_database.dart';

class Users {
  late String fullName;
  late String email;
  late String phone;
  late String id;

  Users({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.id,
  });

  Users.fromSnapshot(DataSnapshot snapshot) {
    id = snapshot.key!;
    phone = snapshot.child('phone').value.toString();
    email = snapshot.child('email').value.toString();
    fullName = snapshot.child('fullname').value.toString();
  }
}
