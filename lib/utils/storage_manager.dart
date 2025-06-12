import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/emotion_entry.dart';
import '../models/quote.dart';

class StorageManager {
  static const String _emotionsKey = 'emotions';
  static const String _quotesKey = 'quotes';

  // Guardar emociones
  static Future<void> saveEmotions(List<EmotionEntry> emotions) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encodedEmotions = emotions
        .map((emotion) => jsonEncode(emotion.toJson()))
        .toList();
    await prefs.setStringList(_emotionsKey, encodedEmotions);
  }

  // Cargar emociones
  static Future<List<EmotionEntry>> loadEmotions() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? encodedEmotions = prefs.getStringList(_emotionsKey);
    
    if (encodedEmotions == null) return [];
    
    return encodedEmotions
        .map((encoded) => EmotionEntry.fromJson(jsonDecode(encoded)))
        .toList();
  }

  // Guardar frases
  static Future<void> saveQuotes(List<Quote> quotes) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encodedQuotes = quotes
        .map((quote) => jsonEncode(quote.toJson()))
        .toList();
    await prefs.setStringList(_quotesKey, encodedQuotes);
  }

  // Cargar frases
  static Future<List<Quote>> loadQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? encodedQuotes = prefs.getStringList(_quotesKey);
    
    if (encodedQuotes == null) return [];
    
    return encodedQuotes
        .map((encoded) => Quote.fromJson(jsonDecode(encoded)))
        .toList();
  }
}