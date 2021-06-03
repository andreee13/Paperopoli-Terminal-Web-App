class VehicleStatus {
  int? id;
  final DateTime timestamp;
  final String name;
  final bool isNew;
  bool isDeleted;
  int? name_id;

  VehicleStatus({
    this.id,
    required this.timestamp,
    required this.name,
    required this.isNew,
    required this.isDeleted,
    this.name_id,
  });

  Map<String, dynamic> toJson(int id) => {
        'id': id,
        'status_id': this.id,
        'timestamp': timestamp,
        'stato': name_id,
        'name_id': name_id,
        'is_new': isNew,
        'is_deleted': isDeleted,
      };
}
