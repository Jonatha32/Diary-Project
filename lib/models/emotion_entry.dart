class EmotionEntry {
  final String id;
  final DateTime date;
  final String emotion;
  final String description;
  final String? imageUrl;
  final int emotionValue; // Valor numérico para gráficos (1-5)

  EmotionEntry({
    required this.id,
    required this.date,
    required this.emotion,
    required this.description,
    this.imageUrl,
    required this.emotionValue,
  });

  // Para convertir a/desde JSON para almacenamiento local
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'emotion': emotion,
      'description': description,
      'imageUrl': imageUrl,
      'emotionValue': emotionValue,
    };
  }

  factory EmotionEntry.fromJson(Map<String, dynamic> json) {
    return EmotionEntry(
      id: json['id'],
      date: DateTime.parse(json['date']),
      emotion: json['emotion'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      emotionValue: json['emotionValue'] ?? _getDefaultEmotionValue(json['emotion']),
    );
  }

  // Obtener un valor numérico basado en la emoción para usar en gráficos
  static int _getDefaultEmotionValue(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'feliz':
        return 5;
      case 'tranquilo':
        return 4;
      case 'neutral':
        return 3;
      case 'ansioso':
        return 2;
      case 'triste':
      case 'enojado':
        return 1;
      default:
        return 3;
    }
  }

  EmotionEntry copyWith({
    String? id,
    DateTime? date,
    String? emotion,
    String? description,
    String? imageUrl,
    int? emotionValue,
  }) {
    return EmotionEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      emotion: emotion ?? this.emotion,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      emotionValue: emotionValue ?? this.emotionValue,
    );
  }
}