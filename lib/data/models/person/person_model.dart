// ignore_for_file: overridden_fields

import 'package:paperopoli_terminal/core/models/main_model.dart';

import 'person_status.dart';

class PersonModel extends MainModel {
  @override
  int? id;
  String cf;
  String fullname;
  String type;
  @override
  late String description = fullname;
  @override
  final List<PersonStatus> status;

  PersonModel({
    this.id,
    required this.status,
    required this.cf,
    required this.fullname,
    required this.type,
  });

  factory PersonModel.fromJson(List json) {
    var v = <PersonStatus>[];
    for (var element in json) {
      v.addAll({
        PersonStatus(
          id: element['persona_stato_id'],
          timestamp: DateTime.parse(
            element['timestamp'],
          ),
          name: element['nome_stato'],
          isNew: false,
          isDeleted: false,
        ),
      });
    }
    return PersonModel(
      id: json.first['ID'],
      status: v,
      type: json.first['nome_tipo'],
      cf: json.first['cf'],
      fullname: json.first['nome_completo'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'cf': cf,
        'fullname': fullname,
        'status': status
            .map<Map<String, dynamic>>(
              (e) => e.toJson(id),
            )
            .toList(),
      };

  factory PersonModel.deepCopy(PersonModel model) => PersonModel(
        id: model.id,
        status: List.from(
          model.status,
        ),
        cf: model.cf,
        fullname: model.fullname,
        type: model.type,
      );
}
