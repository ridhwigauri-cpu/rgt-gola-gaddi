import 'package:flutter/services.dart';

/// Android ke TextToSpeech se bolne ka chhota bridge (koi extra package nahi).
class Speech {
  static const MethodChannel _ch = MethodChannel('rgt/tts');

  /// Hindi me bolta hai. Phone me Hindi voice na ho to default voice.
  static Future<void> say(String text) async {
    try {
      await _ch.invokeMethod('speak', {'text': text});
    } catch (_) {
      // TTS na ho to chup-chaap ignore
    }
  }
}
