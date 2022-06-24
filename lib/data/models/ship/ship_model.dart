// ignore_for_file: overridden_fields

import 'package:paperopoli_terminal/core/models/main_model.dart';
import 'package:paperopoli_terminal/data/models/ship/ship_status.dart';

class ShipModel extends MainModel {
  @override
  int? id;
  @override
  final List<ShipStatus> status;
  String type;
  @override
  String description;

  ShipModel({
    this.id,
    required this.status,
    required this.type,
    required this.description,
  });

  factory ShipModel.fromJson(List json) {
    var v = <ShipStatus>[];
    for (var element in json) {
      v.addAll({
        ShipStatus(
          id: element['nave_stato_id'],
          timestamp: DateTime.parse(
            element['timestamp'],
          ),
          name: element['nome_stato'],
          isNew: false,
          isDeleted: false,
        ),
      });
    }
    return ShipModel(
      id: json.first['ID'],
      status: v,
      type: json.first['nome_tipo'],
      description: json.first['descrizione'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'description': description,
        'status': status
            .map<Map<String, dynamic>>(
              (e) => e.toJson(id),
            )
            .toList(),
      };

  factory ShipModel.deepCopy(ShipModel shipModel) => ShipModel(
        id: shipModel.id,
        status: List.from(shipModel.status),
        type: shipModel.type,
        description: shipModel.description,
      );
}
