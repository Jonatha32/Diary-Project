import 'package:flutter/material.dart';
import '../models/emotion_entry.dart';
import 'package:intl/intl.dart';

class EmotionSummaryCard extends StatelessWidget {
  final List<EmotionEntry> emotions;
  final VoidCallback onTap;

  const EmotionSummaryCard({
    super.key,
    required this.emotions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (emotions.isEmpty) {
      return _buildEmptyCard(context);
    }

    // Calcular estadísticas
    final Map<String, int> emotionCounts = {};
    for (var entry in emotions) {
      emotionCounts[entry.emotion] = (emotionCounts[entry.emotion] ?? 0) + 1;
    }

    // Encontrar la emoción más frecuente
    String mostFrequentEmotion = '';
    int maxCount = 0;
    emotionCounts.forEach((emotion, count) {
      if (count > maxCount) {
        maxCount = count;
        mostFrequentEmotion = emotion;
      }
    });

    // Calcular el promedio de valor emocional
    double averageValue = emotions.map((e) => e.emotionValue).reduce((a, b) => a + b) / emotions.length;

    // Obtener la última entrada
    final latestEntry = emotions.reduce((a, b) => a.date.isAfter(b.date) ? a : b);

    return Card(
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tu Bienestar Emocional',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildEmotionIcon(latestEntry.emotion),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Última emoción: ${latestEntry.emotion}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy - HH:mm').format(latestEntry.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      context,
                      title: 'Emoción frecuente',
                      value: mostFrequentEmotion,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      title: 'Promedio',
                      value: _getEmotionTextForValue(averageValue),
                      subtitle: averageValue.toStringAsFixed(1),
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      title: 'Registros',
                      value: emotions.length.toString(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildMiniChart(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Tu Bienestar Emocional',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              const SizedBox(height: 16),
              Icon(
                Icons.sentiment_neutral,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              const Text(
                'No hay registros emocionales',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Toca para ver estadísticas',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String title,
    required String value,
    String? subtitle,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  Widget _buildMiniChart(BuildContext context) {
    if (emotions.length < 3) {
      return const SizedBox.shrink();
    }

    // Ordenar por fecha
    final sortedEmotions = List<EmotionEntry>.from(emotions)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Tomar los últimos 7 registros como máximo
    final recentEmotions = sortedEmotions.length > 7
        ? sortedEmotions.sublist(sortedEmotions.length - 7)
        : sortedEmotions;

    return SizedBox(
      height: 60,
      child: CustomPaint(
        size: const Size(double.infinity, 60),
        painter: _MiniChartPainter(
          emotions: recentEmotions,
          primaryColor: Theme.of(context).colorScheme.primary,
          accentColor: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }

  Widget _buildEmotionIcon(String emotion) {
    IconData iconData;
    Color color;

    switch (emotion.toLowerCase()) {
      case 'feliz':
        iconData = Icons.sentiment_very_satisfied;
        color = const Color(0xFF4CAF50);
        break;
      case 'triste':
        iconData = Icons.sentiment_very_dissatisfied;
        color = const Color(0xFF42A5F5);
        break;
      case 'enojado':
        iconData = Icons.sentiment_very_dissatisfied;
        color = const Color(0xFFF44336);
        break;
      case 'ansioso':
        iconData = Icons.sentiment_dissatisfied;
        color = const Color(0xFFFF9800);
        break;
      case 'tranquilo':
        iconData = Icons.sentiment_satisfied;
        color = const Color(0xFF26A69A);
        break;
      default:
        iconData = Icons.sentiment_neutral;
        color = const Color(0xFF9E9E9E);
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: color.withOpacity(0.2),
      child: Icon(iconData, color: color),
    );
  }

  String _getEmotionTextForValue(double value) {
    if (value >= 4.5) return 'Muy positivo';
    if (value >= 3.5) return 'Positivo';
    if (value >= 2.5) return 'Neutral';
    if (value >= 1.5) return 'Negativo';
    return 'Muy negativo';
  }
}

class _MiniChartPainter extends CustomPainter {
  final List<EmotionEntry> emotions;
  final Color primaryColor;
  final Color accentColor;

  _MiniChartPainter({
    required this.emotions,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (emotions.isEmpty) return;

    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withOpacity(0.3),
          accentColor.withOpacity(0.1),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final width = size.width;
    final height = size.height;
    final horizontalStep = width / (emotions.length - 1);

    // Normalizar los valores para que se ajusten a la altura
    final minValue = 1.0; // El valor mínimo posible es 1
    final maxValue = 5.0; // El valor máximo posible es 5
    final valueRange = maxValue - minValue;

    for (int i = 0; i < emotions.length; i++) {
      final x = i * horizontalStep;
      final normalizedValue = (emotions[i].emotionValue - minValue) / valueRange;
      final y = height - (normalizedValue * height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      // Dibujar puntos
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }

    // Completar el path para el relleno
    fillPath.lineTo(width, height);
    fillPath.lineTo(0, height);
    fillPath.close();

    // Dibujar el relleno
    canvas.drawPath(fillPath, fillPaint);
    
    // Dibujar la línea
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}