class OperationStatus {
  int? id;
  final DateTime timestamp;
  final String name;
  int? nameId;
  final bool isNew;
  bool isDeleted;

  OperationStatus({
    this.id,
    required this.timestamp,
    required this.name,
    this.nameId,
    required this.isNew,
    required this.isDeleted,
  });

  Map<String, dynamic> toJson(int? id) => {
        'id': id,
        'status_id': this.id,
        'timestamp': timestamp.toIso8601String(),
        'stato': nameId,
        'name_id': nameId,
        'is_new': isNew,
        'is_deleted': isDeleted,
      };
}
