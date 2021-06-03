class Quay {
  final int id;
  final String description;

  Quay({
    required this.id,
    required this.description,
  });

  factory Quay.fromJson(Map<String, dynamic> json) => Quay(
        id: json['ID'] as int,
        description: json['descrizione'] as String,
      );
}
