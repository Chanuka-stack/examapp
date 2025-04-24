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

  // Initialize speech recognition and handle errors/permissions
  Future<bool> initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onStatus: (status) {
          print('[SpeechRecognition] Status: $status');
          // Attempt to restart if stopped unexpectedly
          if (status == 'notListening' || status == 'done') {
            _speechToText.cancel();
            _speechEnabled = true;
          }
        },
        onError: (errorNotification) {
          print('[SpeechRecognition] Error: $errorNotification');
          // Reset state on error
          _speechToText.cancel();
          _speechEnabled = false;
        },
        finalTimeout: Duration(seconds: 5),
      );
      if (!_speechEnabled) {
        print('[SpeechRecognition] Initialization failed. Check microphone permissions.');
      } else {
        print('[SpeechRecognition] Initialized successfully.');
      }
      return _speechEnabled;
    } catch (e) {
      print('[SpeechRecognition] Exception during initialization: $e');
      _speechEnabled = false;
      return false;
    }
  }

  // Start listening for speech and handle errors robustly
  Future<void> startListening({
    required Function(SpeechRecognitionResult) onResult,
  }) async {
    if (!_speechEnabled) {
      print('[SpeechRecognition] Not initialized. Call initSpeech() first.');
      return;
    }
    try {
      await _speechToText.listen(
        onResult: (result) {
          _lastWords = result.recognizedWords;
          onResult(result);
        },
        listenFor: Duration(seconds: 30), // Extended listening time
        pauseFor: Duration(seconds: 3), // Longer pause detection
        listenMode: ListenMode.confirmation, // Better for command recognition
        cancelOnError: false, // Don't cancel on errors
        partialResults: true, // Get partial results for faster response
      );
      print('[SpeechRecognition] Listening started.');
    } catch (e) {
      print('[SpeechRecognition] Error starting listening: $e');
    }
  }

  // Stop listening and log
  Future<void> stopListening() async {
    try {
      await _speechToText.stop();
      print('[SpeechRecognition] Listening stopped.');
    } catch (e) {
      print('[SpeechRecognition] Error during stop: $e');
    }
  }

  // Check if speech has stopped and restart if needed
  void checkAndRestartListening(Function startListeningCallback) {
    if (!_speechEnabled) return;

    if (!_speechToText.isListening) {
      print('Speech recognition stopped, attempting to restart...');
      Future.delayed(Duration(seconds: 1), () {
        startListeningCallback();
      });
    }
  }

  void autoRestartListening({
    required Function(SpeechRecognitionResult) onResult,
    Duration listenFor = const Duration(seconds: 30),
    Duration pauseFor = const Duration(seconds: 3),
    bool continuous = true,
  }) {
    _speechToText.statusListener = (status) {
      if (continuous &&
          (status == "notListening" || status == "done") &&
          _speechEnabled) {
        Future.delayed(const Duration(milliseconds: 500), () async {
          await _speechToText.listen(
              onResult: (result) {
                _lastWords = result.recognizedWords;
                onResult(result);
              },
              listenFor: Duration(seconds: 30), // Listen for longer periods
              pauseFor: Duration(seconds: 3));
        });
      }
    };
  }
}
