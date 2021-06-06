import 'package:paperopoli_terminal/core/models/main_model_abstract.dart';

import 'operation_status.dart';

class OperationModel extends MainModel {
  @override
  int? id;
  @override
  final List<OperationStatus> status;
  final List<int> ships;
  final List<int> goods;
  final List<int> people;
  final List<int> vehicles;
  String type;
  @override
  String description;
  int trip;

  OperationModel({
    this.id,
    required this.status,
    required this.type,
    required this.description,
    required this.trip,
    required this.ships,
    required this.goods,
    required this.people,
    required this.vehicles,
  });

  factory OperationModel.fromTripJson(Map<String, dynamic> json) =>
      OperationModel(
        id: json['ID'],
        status: [],
        trip: json['viaggio'],
        type: json['nome_tipo'],
        description: json['descrizione'],
        goods: [],
        people: [],
        ships: [],
        vehicles: [],
      );

  factory OperationModel.fromJson(List json) {
    var v = <OperationStatus>[];
    json.forEach((element) {
      v.addAll({
        OperationStatus(
          id: element['movimentazione_stato_id'],
          timestamp: DateTime.parse(
            element['timestamp'],
          ),
          name: element['nome_stato'],
          isNew: false,
          isDeleted: false,
        ),
      });
    });
    return OperationModel(
      id: json.first['ID'],
      status: v,
      trip: json.first['viaggio'],
      type: json.first['nome_tipo'],
      description: json.first['descrizione'],
      goods: json.first['merci'] != ''
          ? (json.first['merci'] as String)
              .split(',')
              .map(
                (e) => int.parse(e),
              )
              .toList()
          : [],
      people: json.first['persone'] != ''
          ? (json.first['persone'] as String)
              .split(',')
              .map(
                (e) => int.parse(e),
              )
              .toList()
          : [],
      ships: json.first['navi'] != ''
          ? (json.first['navi'] as String)
              .split(',')
              .map(
                (e) => int.parse(e),
              )
              .toList()
          : [],
      vehicles: json.first['veicoli'] != ''
          ? (json.first['veicoli'] as String)
              .split(',')
              .map(
                (e) => int.parse(e),
              )
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'description': description,
        'trip': trip,
        'status': status
            .map<Map<String, dynamic>>(
              (e) => e.toJson(id),
            )
            .toList(),
        'ships': ships.join(','),
        'people': people.join(','),
        'goods': goods.join(','),
        'vehicles': vehicles.join(','),
      };

  factory OperationModel.deepCopy(
    OperationModel model,
  ) =>
      OperationModel(
        id: model.id,
        status: List.from(model.status),
        type: model.type,
        description: model.description,
        trip: model.trip,
        goods: model.goods,
        people: model.people,
        ships: model.ships,
        vehicles: model.vehicles,
      );
}
