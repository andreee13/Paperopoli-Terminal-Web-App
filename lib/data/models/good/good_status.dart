class GoodStatus {
  int? id;
  final DateTime timestamp;
  final String name;
  final bool isNew;
  bool isDeleted;
  int? nameId;

  GoodStatus({
    this.id,
    required this.timestamp,
    required this.name,
    required this.isNew,
    required this.isDeleted,
    this.nameId,
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
