import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechHelper {
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> initTTS(
      {String language = "en-US",
      double rate = 0.5,
      double pitch = 1.0,
      double volume = 1.0}) async {
    await _flutterTts.setLanguage(language);
    await _flutterTts.setSpeechRate(rate);
    await _flutterTts.setPitch(pitch);
    await _flutterTts.setVolume(volume);
  }

  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  Future<void> pause() async {
    await _flutterTts.pause();
  }

  Future<List<dynamic>> getLanguages() async {
    return await _flutterTts.getLanguages;
  }

  Future<void> setVoice(String name, String locale) async {
    await _flutterTts.setVoice({"name": name, "locale": locale});
  }
}
