class Quote {
  final String id;
  final String text;
  final DateTime createdAt;
  final bool isFavorite;

  Quote({
    required this.id,
    required this.text,
    required this.createdAt,
    this.isFavorite = false,
  });

  // Para convertir a/desde JSON para almacenamiento local
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'],
      text: json['text'],
      createdAt: DateTime.parse(json['createdAt']),
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Quote copyWith({
    String? id,
    String? text,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return Quote(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}