import 'operation_status.dart';

class OperationModel {
  int id;
  String description;
  String type;
  List<OperationStatus> status;

  OperationModel({
    required this.id,
    required this.description,
    required this.type,
    required this.status,
  });

  factory OperationModel.fromJson(Map<String, dynamic> json) => OperationModel(
        id: json['ID'],
        description: json['descrizione'],
        type: json['nome_tipo'],
        status: [],
      );
}
