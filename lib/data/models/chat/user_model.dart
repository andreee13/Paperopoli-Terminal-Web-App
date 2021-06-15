import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final DateTime creationTime;
  final DateTime lastSignInTime;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.creationTime,
    required this.lastSignInTime,
  });

  factory UserModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      UserModel(
        uid: json['uid'],
        email: json['email'],
        displayName: json['displayName'],
        creationTime: DateTime.parse(json['creationTime']),
        lastSignInTime: DateTime.parse(json['lastSignInTime']),
      );

  factory UserModel.fromFirebaseUser(
    User user,
  ) =>
      UserModel(
        uid: user.uid,
        email: user.email!,
        displayName: user.displayName!,
        creationTime: user.metadata.creationTime!,
        lastSignInTime: user.metadata.lastSignInTime!,
      );
}
