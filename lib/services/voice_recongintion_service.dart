import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechRecognitionService {
  static final SpeechRecognitionService _instance =
      SpeechRecognitionService._internal();

  factory SpeechRecognitionService() => _instance;

  SpeechRecognitionService._internal();

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  bool get isListening => _speechToText.isListening;
  bool get isNotListening => !_speechToText.isListening;
  bool get speechEnabled => _speechEnabled;
  String get lastWords => _lastWords;

  Future<bool> initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (errorNotification) => print('Speech error: $errorNotification'),
    );
    return _speechEnabled;
  }

  Future<void> startListening({
    required Function(SpeechRecognitionResult) onResult,
  }) async {
    if (_speechEnabled) {
      await _speechToText.listen(
        onResult: (result) {
          _lastWords = result.recognizedWords;
          onResult(result);
        },
        listenFor: Duration(seconds: 30), // Listen for longer periods
        pauseFor: Duration(seconds: 3), // Pause detection
      );
    }
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  // Check if speech has stopped and restart if needed
  void checkAndRestartListening(Function startListeningCallback) {
    if (_speechEnabled && !_speechToText.isListening) {
      Future.delayed(Duration(seconds: 1), () {
        startListeningCallback();
      });
    }
  }
}
