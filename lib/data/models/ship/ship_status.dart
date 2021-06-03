class ShipStatus {
  int? id;
  final DateTime timestamp;
  final String name;
  int? name_id;
  final bool isNew;
  bool isDeleted;

  ShipStatus({
    this.id,
    required this.timestamp,
    required this.name,
    this.name_id,
    required this.isNew,
    required this.isDeleted,
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
