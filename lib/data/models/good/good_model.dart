import 'good_status.dart';

class GoodModel {
  int id;
  String description;
  String type;
  final List<GoodStatus> status;

  GoodModel({
    required this.id,
    required this.status,
    required this.description,
    required this.type,
  });

  factory GoodModel.fromJson(List json) {
    var v = <GoodStatus>[];
    json.forEach((element) {
      v.addAll({
        GoodStatus(
          id: element['merce_stato_id'],
          timestamp: DateTime.parse(
            element['timestamp'],
          ),
          name: element['nome_stato'],
          isNew: false,
          isDeleted: false,
        ),
      });
    });
    return GoodModel(
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

  factory GoodModel.deepCopy(GoodModel model) => GoodModel(
        id: model.id,
        status: List.from(
          model.status,
        ),
        description: model.description,
        type: model.type,
      );
}
