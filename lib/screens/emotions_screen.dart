import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/emotion_entry.dart';
import '../utils/storage_manager.dart';
import '../widgets/emotion_summary_card.dart';
import 'emotion_form_screen.dart';
import 'emotion_detail_screen.dart';
import 'emotion_chart_screen.dart';

class EmotionsScreen extends StatefulWidget {
  const EmotionsScreen({super.key});

  @override
  State<EmotionsScreen> createState() => _EmotionsScreenState();
}

class _EmotionsScreenState extends State<EmotionsScreen> {
  List<EmotionEntry> _emotions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmotions();
  }

  Future<void> _loadEmotions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final emotions = await StorageManager.loadEmotions();
      setState(() {
        _emotions = emotions;
        _emotions.sort((a, b) => b.date.compareTo(a.date)); // Ordenar por fecha descendente
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar emociones: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Diario Emocional', 
          style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmotionChartScreen(emotions: _emotions),
                ),
              );
            },
            tooltip: 'Ver evolución',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EmotionFormScreen(),
            ),
          );
          if (result == true) {
            _loadEmotions();
          }
        },
        tooltip: 'Nueva emoción',
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_emotions.isEmpty) {
      return _buildEmptyState();
    }
    
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          EmotionSummaryCard(
            emotions: _emotions,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmotionChartScreen(emotions: _emotions),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Text(
              'Registros recientes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildEmotionsList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sentiment_neutral,
              size: 80,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No has registrado emociones',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6C757D),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Comienza a registrar cómo te sientes',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6C757D),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EmotionFormScreen(),
                ),
              ).then((value) {
                if (value == true) {
                  _loadEmotions();
                }
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Registrar emoción'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _emotions.length,
      itemBuilder: (context, index) {
        final emotion = _emotions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmotionDetailScreen(emotion: emotion),
                ),
              ).then((value) {
                if (value == true) {
                  _loadEmotions();
                }
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (emotion.imageUrl != null) ...[
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.file(
                      File(emotion.imageUrl!),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          color: const Color(0xFFE0E0E0),
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 40),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildEmotionIcon(emotion.emotion),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  emotion.emotion,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  DateFormat('EEEE, d MMMM yyyy - HH:mm', 'es').format(emotion.date),
                                  style: const TextStyle(
                                    color: Color(0xFF757575),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        emotion.description,
                        style: const TextStyle(fontSize: 14),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
      radius: 24,
      backgroundColor: color.withOpacity(0.2),
      child: Icon(iconData, color: color, size: 28),
    );
  }
}