import 'package:text_to_speech/text_to_speech.dart';

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
