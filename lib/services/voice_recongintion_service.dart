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
    try {
      _speechEnabled = await _speechToText.initialize(
        onStatus: (status) {
          print('Speech status: $status');
          // Attempt to restart if stopped unexpectedly
          if (status == 'notListening' || status == 'done') {
            _speechToText.cancel();
          }
        },
        onError: (errorNotification) {
          print('Speech error: $errorNotification');
          // Reset state on error
          _speechToText.cancel();
          _speechEnabled = false;
        },
        finalTimeout: Duration(seconds: 5),
      );
      return _speechEnabled;
    } catch (e) {
      print('Error initializing speech: $e');
      _speechEnabled = false;
      return false;
    }
  }

  Future<bool> startListening({
    required Function(SpeechRecognitionResult) onResult,
  }) async {
    if (!_speechEnabled) {
      print('Speech not initialized');
      return false;
    }

    try {
      bool started = await _speechToText.listen(
        onResult: (result) {
          _lastWords = result.recognizedWords;
          onResult(result);
        },
        listenFor: Duration(minutes: 5), // Extended listening time
        pauseFor: Duration(seconds: 10), // Longer pause detection
        listenMode: ListenMode.confirmation, // Better for command recognition
        cancelOnError: false, // Don't cancel on errors
        partialResults: true, // Get partial results for faster response
      );

      if (started) {
        // Set up auto-restart when listening stops
        _speechToText.statusListener = (status) {
          if ((status == 'notListening' || status == 'done') && _speechEnabled) {
            Future.delayed(Duration(milliseconds: 500), () {
              if (!_speechToText.isListening && _speechEnabled) {
                startListening(onResult: onResult);
              }
            });
          }
        };
      }

      return started;
    } catch (e) {
      print('Error starting speech recognition: $e');
      return false;
    }
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
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
