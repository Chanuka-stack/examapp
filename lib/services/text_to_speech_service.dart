/*import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechHelper {
  final FlutterTts _flutterTts = FlutterTts();
  Function? _onCompleted;

  // Add this method
  void setCompletionHandler(Function callback) {
    _onCompleted = callback;
  }

  Future<void> initTTS(
      {String language = "en-US",
      double rate = 0.5,
      double pitch = 1.0,
      double volume = 1.0}) async {
    await _flutterTts.setLanguage(language);
    await _flutterTts.setSpeechRate(rate);
    await _flutterTts.setPitch(pitch);
    await _flutterTts.setVolume(volume);

    /* _flutterTts.setCompletionHandler(() {
      if (_onCompleted != null) {
        _onCompleted!();
      }
    });*/
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
}*/

import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async'; // Add this import for Completer

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

    // Set up completion listener one time during initialization
    _flutterTts.setCompletionHandler(() {
      if (_speechCompleter != null && !_speechCompleter!.isCompleted) {
        _speechCompleter!.complete();
      }
    });
  }

  // Add this property to store the current Completer
  Completer? _speechCompleter;

  /*Future<void> speak(String text) async {
    try{
      
    }
    catch(e){
      print("Error in TTS: $e");
    }
    if (text.isEmpty) return;

    // Create a new Completer for this speech request
    _speechCompleter = Completer();

    // Start speaking
    await _flutterTts.speak(text);

    // Return a Future that completes when speech is done
    return _speechCompleter!.future;
  }*/
  Future<void> speak(String text) async {
    try {} catch (e) {
      print("Error in TTS: $e");
    }
    if (text.isEmpty) return;

    // Create a new Completer for this speech request
    _speechCompleter = Completer();

    // Start speaking
    await _flutterTts.speak(text);

    // Return a Future that completes when speech is done
    return _speechCompleter!.future;
  }

  Future<void> stop() async {
    // Also complete any pending completer when stopping
    if (_speechCompleter != null && !_speechCompleter!.isCompleted) {
      _speechCompleter!.complete();
    }
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
