import 'dart:convert';

import 'user_model.dart';

class MessageModel {
  late UserModel sender;
  late String body;
  late DateTime date;

  MessageModel({
    required this.sender,
    required this.body,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'sender': {
          'uid': sender.uid,
          'displayName': sender.displayName,
          'email': sender.email,
          'creationTime': sender.creationTime.toIso8601String(),
          'lastSignInTime': sender.lastSignInTime.toIso8601String(),
        },
        'body': body,
        'date': date.toIso8601String(),
      };

  factory MessageModel.fromJson(
    Map<String, dynamic> map,
  ) =>
      MessageModel(
        sender: UserModel.fromJson(map['sender']),
        body: map['body'],
        date: DateTime.parse(map['date']),
      );

  String toJson() => json.encode(
        toMap(),
      );
}
