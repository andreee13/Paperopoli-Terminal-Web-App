import 'package:paperopoli_terminal/data/models/vehicle/vehicle_status.dart';

import 'vehicle_status.dart';

class VehicleModel {
  int id;
  String plate;
  String type;
  final List<VehicleStatus> status;

  VehicleModel({
    required this.id,
    required this.status,
    required this.plate,
    required this.type,
  });

  factory VehicleModel.fromJson(List json) {
    var v = <VehicleStatus>[];
    json.forEach((element) {
      v.addAll({
        VehicleStatus(
          id: element['veicolo_stato_id'],
          timestamp: DateTime.parse(
            element['timestamp'],
          ),
          name: element['nome_stato'],
          isNew: false,
          isDeleted: false,
        ),
      });
    });
    return VehicleModel(
      id: json.first['ID'],
      status: v,
      type: json.first['nome_tipo'],
      plate: json.first['targa'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'plate': plate,
        'status': status
            .map<Map<String, dynamic>>(
              (e) => e.toJson(id),
            )
            .toList(),
      };

  factory VehicleModel.deepCopy(VehicleModel model) => VehicleModel(
        id: model.id,
        status: List.from(
          model.status,
        ),
        plate: model.plate,
        type: model.type,
      );
}
