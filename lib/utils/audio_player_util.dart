import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlayerUtil {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static String? _currentlyPlayingPath;
  static bool _isPlaying = false;

  static Future<void> playAudio(String audioPath, {Function? onComplete}) async {
    if (_isPlaying && _currentlyPlayingPath == audioPath) {
      // Si ya está reproduciendo este audio, lo pausamos
      await _audioPlayer.pause();
      _isPlaying = false;
      return;
    }

    try {
      // Si estaba reproduciendo otro audio, lo detenemos
      if (_isPlaying) {
        await _audioPlayer.stop();
      }

      // Reproducir el nuevo audio
      await _audioPlayer.play(DeviceFileSource(audioPath));
      _currentlyPlayingPath = audioPath;
      _isPlaying = true;

      // Configurar el callback para cuando termine la reproducción
      _audioPlayer.onPlayerComplete.listen((event) {
        _isPlaying = false;
        _currentlyPlayingPath = null;
        if (onComplete != null) {
          onComplete();
        }
      });
    } catch (e) {
      debugPrint('Error al reproducir audio: $e');
      _isPlaying = false;
    }
  }

  static Future<void> stopAudio() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      _isPlaying = false;
      _currentlyPlayingPath = null;
    }
  }

  static bool isPlaying(String audioPath) {
    return _isPlaying && _currentlyPlayingPath == audioPath;
  }

  static void dispose() {
    _audioPlayer.dispose();
  }
}