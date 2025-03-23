/*import 'package:text_to_speech/text_to_speech.dart';

class TextToSpeechService {
  final TextToSpeech _tts = TextToSpeech();

  TextToSpeechService() {
    _tts.setVolume(1.0); // Max volume
    _tts.setRate(1.0); // Normal speed
    _tts.setPitch(1.0); // Normal pitch
    _tts.setLanguage('en-US'); // Default language
  }

  /// Speak text
  void speak(String text) {
    _tts.speak(text);
  }

  /// Stop speaking
  void stop() {
    _tts.stop();
  }

  /// Set volume (0.0 - 1.0)
  void setVolume(double volume) {
    _tts.setVolume(volume);
  }

  /// Set speech rate (0.0 - 2.0)
  void setRate(double rate) {
    _tts.setRate(rate);
  }

  /// Set pitch (0.0 - 2.0)
  void setPitch(double pitch) {
    _tts.setPitch(pitch);
  }

  /// Set language
  void setLanguage(String languageCode) {
    _tts.setLanguage(languageCode);
  }

  /// Get available languages
  Future<List<String>> getLanguages() async {
    return await _tts.getLanguages();
  }
}
*/
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
