import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playSuccessSound() async {
    try {
      await _player.play(AssetSource('sounds/success.mp3'));
      if (kDebugMode) {
        debugPrint('Playing success sound');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Could not play success sound: $e');
      }
    }
  }

  static Future<void> playFailureSound() async {
    try {
      await _player.play(AssetSource('sounds/failure.mp3'));
      if (kDebugMode) {
        debugPrint('Playing failure sound');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Could not play failure sound: $e');
      }
    }
  }

  static Future<void> dispose() async {
    await _player.dispose();
  }
}