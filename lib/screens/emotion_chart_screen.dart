import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/emotion_entry.dart';

class EmotionChartScreen extends StatefulWidget {
  final List<EmotionEntry> emotions;

  const EmotionChartScreen({super.key, required this.emotions});

  @override
  State<EmotionChartScreen> createState() => _EmotionChartScreenState();
}

class _EmotionChartScreenState extends State<EmotionChartScreen> with SingleTickerProviderStateMixin {
  String _selectedPeriod = 'semana';
  late List<EmotionEntry> _filteredEmotions;
  late TabController _tabController;
  int _selectedTabIndex = 0;
  
  // Paleta de colores moderna y agradable
  final Map<String, Color> _emotionColors = {
    'feliz': const Color(0xFF4CAF50),     // Verde vibrante
    'tranquilo': const Color(0xFF26A69A), // Verde azulado
    'neutral': const Color(0xFF9E9E9E),   // Gris neutro
    'ansioso': const Color(0xFFFF9800),   // Naranja cálido
    'triste': const Color(0xFF42A5F5),    // Azul claro
    'enojado': const Color(0xFFF44336),   // Rojo suave
  };

  // Colores para el tema general
  final Color _primaryColor = const Color(0xFF6200EE);
  final Color _accentColor = const Color(0xFF03DAC6);
  final Color _backgroundColor = const Color(0xFFF5F5F7);
  final Color _cardColor = Colors.white;
  final Color _textColor = const Color(0xFF333333);
  final Color _lightGrey = const Color(0xFFE0E0E0);
  final Color _mediumGrey = const Color(0xFFBDBDBD);
  final Color _darkGrey = const Color(0xFF757575);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    _filterEmotions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _filterEmotions() {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case 'semana':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'mes':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'año':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        startDate = now.subtract(const Duration(days: 7));
    }

    setState(() {
      _filteredEmotions = widget.emotions
          .where((e) => e.date.isAfter(startDate))
          .toList();
      _filteredEmotions.sort((a, b) => a.date.compareTo(b.date));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          secondary: _accentColor,
          background: _backgroundColor,
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: _textColor,
          displayColor: _textColor,
        ),
      ),
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          title: const Text('Evolución Emocional', 
            style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: _accentColor,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'Gráfico', icon: Icon(Icons.show_chart)),
              Tab(text: 'Estadísticas', icon: Icon(Icons.pie_chart)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildChartTab(),
            _buildStatsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildChartTab() {
    return Column(
      children: [
        _buildPeriodSelector(),
        Expanded(
          child: _filteredEmotions.isEmpty
              ? _buildEmptyState()
              : _buildChart(),
        ),
        if (_filteredEmotions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildLegend(),
          ),
      ],
    );
  }

  Widget _buildStatsTab() {
    if (_filteredEmotions.isEmpty) {
      return _buildEmptyState();
    }

    // Calcular estadísticas
    final Map<String, int> emotionCounts = {};
    for (var entry in _filteredEmotions) {
      emotionCounts[entry.emotion] = (emotionCounts[entry.emotion] ?? 0) + 1;
    }

    // Calcular el promedio de valor emocional
    double averageValue = 0;
    if (_filteredEmotions.isNotEmpty) {
      averageValue = _filteredEmotions.map((e) => e.emotionValue).reduce((a, b) => a + b) / 
          _filteredEmotions.length;
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodSelector(),
          const SizedBox(height: 24),
          _buildStatCard(
            title: 'Resumen del Período',
            child: Column(
              children: [
                _buildStatItem(
                  icon: Icons.calendar_today,
                  title: 'Período',
                  value: _getPeriodText(),
                ),
                _buildStatItem(
                  icon: Icons.tag_faces,
                  title: 'Emoción predominante',
                  value: mostFrequentEmotion,
                  color: mostFrequentEmotion.isNotEmpty 
                      ? _emotionColors[mostFrequentEmotion.toLowerCase()] 
                      : Colors.grey,
                ),
                _buildStatItem(
                  icon: Icons.trending_up,
                  title: 'Promedio emocional',
                  value: averageValue.toStringAsFixed(1),
                  subtitle: _getEmotionTextForValue(averageValue),
                ),
                _buildStatItem(
                  icon: Icons.bar_chart,
                  title: 'Total de registros',
                  value: _filteredEmotions.length.toString(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildStatCard(
            title: 'Distribución de Emociones',
            child: SizedBox(
              height: 250,
              child: _buildEmotionDistributionChart(emotionCounts),
            ),
          ),
          const SizedBox(height: 24),
          _buildStatCard(
            title: 'Tendencia Emocional',
            child: _buildTrendAnalysis(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({required String title, required Widget child}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color ?? _primaryColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: _textColor.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: color ?? _textColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPeriodText() {
    switch (_selectedPeriod) {
      case 'semana':
        return 'Últimos 7 días';
      case 'mes':
        return 'Último mes';
      case 'año':
        return 'Último año';
      default:
        return 'Últimos 7 días';
    }
  }

  String _getEmotionTextForValue(double value) {
    if (value >= 4.5) return 'Muy positivo';
    if (value >= 3.5) return 'Positivo';
    if (value >= 2.5) return 'Neutral';
    if (value >= 1.5) return 'Negativo';
    return 'Muy negativo';
  }

  Widget _buildEmotionDistributionChart(Map<String, int> emotionCounts) {
    if (emotionCounts.isEmpty) {
      return const Center(child: Text('No hay datos suficientes'));
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: emotionCounts.entries.map((entry) {
          return PieChartSectionData(
            color: _emotionColors[entry.key.toLowerCase()] ?? Colors.grey,
            value: entry.value.toDouble(),
            title: '${(entry.value / _filteredEmotions.length * 100).toStringAsFixed(0)}%',
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrendAnalysis() {
    if (_filteredEmotions.length < 3) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Se necesitan más registros para analizar tendencias',
          textAlign: TextAlign.center,
        ),
      );
    }

    // Analizar si la tendencia es positiva, negativa o estable
    List<int> values = _filteredEmotions.map((e) => e.emotionValue).toList();
    double firstHalfAvg = 0;
    double secondHalfAvg = 0;
    
    int midPoint = values.length ~/ 2;
    for (int i = 0; i < midPoint; i++) {
      firstHalfAvg += values[i];
    }
    for (int i = midPoint; i < values.length; i++) {
      secondHalfAvg += values[i];
    }
    
    firstHalfAvg /= midPoint;
    secondHalfAvg /= (values.length - midPoint);
    
    double difference = secondHalfAvg - firstHalfAvg;
    String trendText;
    IconData trendIcon;
    Color trendColor;
    
    if (difference > 0.5) {
      trendText = 'Tu bienestar emocional está mejorando';
      trendIcon = Icons.trending_up;
      trendColor = Colors.green;
    } else if (difference < -0.5) {
      trendText = 'Tu bienestar emocional está disminuyendo';
      trendIcon = Icons.trending_down;
      trendColor = Colors.red;
    } else {
      trendText = 'Tu bienestar emocional se mantiene estable';
      trendIcon = Icons.trending_flat;
      trendColor = Colors.amber;
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Icon(trendIcon, size: 48, color: trendColor),
          const SizedBox(height: 16),
          Text(
            trendText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: trendColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Basado en ${values.length} registros en el período seleccionado',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: _textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 0,
        color: _cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: _primaryColor.withOpacity(0.2), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: SegmentedButton<String>(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (states) {
                  if (states.contains(MaterialState.selected)) {
                    return _primaryColor;
                  }
                  return Colors.transparent;
                },
              ),
            ),
            segments: const [
              ButtonSegment(
                value: 'semana',
                label: Text('Semana'),
                icon: Icon(Icons.calendar_view_week),
              ),
              ButtonSegment(
                value: 'mes',
                label: Text('Mes'),
                icon: Icon(Icons.calendar_view_month),
              ),
              ButtonSegment(
                value: 'año',
                label: Text('Año'),
                icon: Icon(Icons.calendar_today),
              ),
            ],
            selected: {_selectedPeriod},
            onSelectionChanged: (Set<String> selection) {
              setState(() {
                _selectedPeriod = selection.first;
                _filterEmotions();
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_outlined,
            size: 80,
            color: _mediumGrey,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay suficientes datos para mostrar',
            style: TextStyle(
              fontSize: 18,
              color: _darkGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Registra tus emociones para ver estadísticas',
            style: TextStyle(
              fontSize: 14,
              color: _darkGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(_createLineChartData()),
      ),
    );
  }

  LineChartData _createLineChartData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: _lightGrey,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: _lightGrey,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= _filteredEmotions.length || value < 0) {
                return const SizedBox();
              }
              
              final date = _filteredEmotions[value.toInt()].date;
              String text;
              
              switch (_selectedPeriod) {
                case 'semana':
                  text = DateFormat('E').format(date); // Día de la semana abreviado
                  break;
                case 'mes':
                  text = DateFormat('d').format(date); // Día del mes
                  break;
                case 'año':
                  text = DateFormat('MMM').format(date); // Mes abreviado
                  break;
                default:
                  text = DateFormat('d').format(date);
              }
              
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _textColor.withOpacity(0.7),
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              String text = '';
              switch (value.toInt()) {
                case 1:
                  text = 'Triste';
                  break;
                case 2:
                  text = 'Ansioso';
                  break;
                case 3:
                  text = 'Neutral';
                  break;
                case 4:
                  text = 'Tranquilo';
                  break;
                case 5:
                  text = 'Feliz';
                  break;
              }
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 10,
                    color: _textColor.withOpacity(0.7),
                  ),
                ),
              );
            },
            reservedSize: 60,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: _lightGrey),
      ),
      minX: 0,
      maxX: _filteredEmotions.length - 1.0,
      minY: 0,
      maxY: 6,
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.white.withOpacity(0.8),
          tooltipRoundedRadius: 8,
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((spot) {
              final emotion = _filteredEmotions[spot.x.toInt()];
              return LineTooltipItem(
                '${emotion.emotion}\n',
                TextStyle(
                  color: _emotionColors[emotion.emotion.toLowerCase()] ?? Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: DateFormat('dd/MM/yyyy').format(emotion.date),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
        touchSpotThreshold: 20,
      ),
      lineBarsData: [
        LineChartBarData(
          spots: _filteredEmotions.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble(), entry.value.emotionValue.toDouble());
          }).toList(),
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              _primaryColor.withOpacity(0.8),
              _accentColor.withOpacity(0.8),
            ],
          ),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              Color color = _emotionColors[_filteredEmotions[index].emotion.toLowerCase()] ?? Colors.grey;
              return FlDotCirclePainter(
                radius: 6,
                color: color,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _primaryColor.withOpacity(0.3),
                _accentColor.withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Card(
      elevation: 0,
      color: _cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: _lightGrey, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Leyenda de Emociones',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: _emotionColors.entries.map((entry) {
                return _buildLegendItem(
                  entry.key.substring(0, 1).toUpperCase() + entry.key.substring(1),
                  entry.value,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: _textColor,
          ),
        ),
      ],
    );
  }
}