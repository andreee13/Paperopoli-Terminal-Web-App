// ignore_for_file: overridden_fields

import 'package:paperopoli_terminal/core/models/main_model.dart';

class QuayModel extends MainModel {
  @override
  final int id;
  @override
  final String description;

  QuayModel({
    required this.id,
    required this.description,
  });

  factory QuayModel.fromJson(Map<String, dynamic> json) => QuayModel(
        id: json['ID'] as int,
        description: json['descrizione'] as String,
      );
}
