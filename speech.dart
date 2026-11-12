import 'package:flutter/services.dart';

/// Android TextToSpeech bridge (koi extra package nahi).
class Speech {
  static const MethodChannel _ch = MethodChannel('rgt/tts');

  static Future<void> say(String text) async {
    try {
      await _ch.invokeMethod('speak', {'text': text});
    } catch (_) {}
  }
}
