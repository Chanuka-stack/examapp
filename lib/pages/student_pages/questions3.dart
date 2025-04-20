import 'dart:io';

import 'package:app1/data/exam.dart';
import 'package:app1/data/student.dart';
import 'package:app1/pages/student_pages/sudent_home2.dart';
import 'package:app1/services/text_to_speech_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import '../../services/voice_recongintion_service.dart';
import 'package:flutter/material.dart';
import '../components/audio_button.dart';
import '../../services/timer.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';

class Qesutions extends StatefulWidget {
  final Map<String, dynamic> examData;

  const Qesutions({Key? key, required this.examData}) : super(key: key);

  @override
  State<Qesutions> createState() => _QesutionsState();
}

enum ExamState { ready, inProgress, ended }

class _QesutionsState extends State<Qesutions> {
  final TextToSpeechHelper _ttsHelper = TextToSpeechHelper();
  final SpeechRecognitionService _speechService = SpeechRecognitionService();
  final ExamFirebaseService _examService = ExamFirebaseService();
  final TextEditingController _answerController = TextEditingController();

  bool _isInitialized = false;
  bool _isDisposed = false;
  String _lastWords = '';
  bool _isListening = false;
  bool _isSubmitting = false;

  ExamState _currentState = ExamState.ready;

  int _currentSectionIndex = 0;
  int _currentQuestionIndex = -1;
  int _currentSubQuestionIndex = -1;

  // Question list without formal data models
  List<Map<String, dynamic>> sections = [];

  // Map to store answers
  Map<String, String> _answers = {};
  final Map<String, String> _audioRecordings = {};

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _determineExamState();
    await _loadExamQuestions(widget.examData['id']);
    await _initSpeechAndStart();

    // Announce voice commands when app starts
    Future.delayed(Duration(seconds: 3), () {
      if (mounted && !_isDisposed) {
        _speakVoiceCommands();
      }
    });
  }

  void _speakVoiceCommands() {
    if (_currentState == ExamState.ready) {
      _speak(
          'Voice commands available. Say "I am ready for exam" to start the exam.');
    } else if (_currentState == ExamState.inProgress) {
      _speak('Voice commands available. Say "next question" to move to the next question. ' +
          'Say "previous question" to go back. Say "repeat question" to hear the current question again. ' +
          'Say "submit exam" to finish and submit your exam.');
    } else if (_currentState == ExamState.ended) {
      _speak('Exam ended. Say "go to home" to return to the home page.');
    }
  }

  void _endExam() {
    // This method is called in the timer countdown's onEnd but doesn't exist
    // It should be changed to _submitExam which already exists
    if (mounted && !_isDisposed) {
      _submitExam();
    }
  }

  void _determineExamState() {
    final DateTime now = DateTime.now();
    final DateTime examStartTime = convertFirebaseTimestampAndTimeString(
        widget.examData['examDateTime'], widget.examData['startTime']);
    final DateTime examEndTime = convertFirebaseTimestampAndTimeString(
        widget.examData['examDateTime'], widget.examData['endTime']);

    if (now.isBefore(examStartTime)) {
      _currentState = ExamState.ready;
    } else if (now.isAfter(examEndTime)) {
      _currentState = ExamState.ended;
    } else {
      _currentState = ExamState.inProgress;
    }
  }

  DateTime convertFirebaseTimestampAndTimeString(
      Timestamp firebaseTimestamp, String timeString) {
    // Convert Firebase Timestamp to DateTime
    final DateTime date = firebaseTimestamp.toDate();

    // Parse the time string
    final List<String> timeParts = timeString.split(":");
    final int hours = int.parse(timeParts[0]);
    final int minutes = int.parse(timeParts[1]);

    // Create a new DateTime with the date from Firebase and time from string
    return DateTime(
      date.year,
      date.month,
      date.day,
      hours,
      minutes,
    );
  }

  Future<void> _initSpeechAndStart() async {
    if (!mounted) return;

    await _speechService.initSpeech();

    if (!mounted) return;

    setState(() {
      _isInitialized = true;
    });

    // Start listening automatically
    _startListening();
  }

  Future<void> _loadExamQuestions(String examId) async {
    try {
      final data = await _examService.getExamWithQuestions(examId);

      if (!mounted) return;

      setState(() {
        sections = (data['sections'] ?? []).cast<Map<String, dynamic>>();
      });
    } catch (e) {
      print('Error loading exam questions: $e');
    }
  }

  void _startListening() async {
    if (!mounted || _isDisposed) return;

    try {
      await _speechService.startListening(onResult: _processResult);
      setState(() {
        _isListening = true;
      });

      // Set up a timer to check if listening has stopped
      Future.delayed(Duration(seconds: 5), () {
        if (mounted && !_isDisposed && !_isListening) {
          _speechService.checkAndRestartListening(_startListening);
        }
      });
    } catch (e) {
      print('Error starting listening: $e');
      // Try to restart listening after a delay
      Future.delayed(Duration(seconds: 2), () {
        if (mounted && !_isDisposed) {
          _startListening();
        }
      });
    }
  }

  void _processResult(SpeechRecognitionResult result) {
    if (!mounted || _isDisposed) return;

    setState(() {
      _lastWords = result.recognizedWords.toLowerCase();

      // Process voice commands based on the current state
      if (_currentState == ExamState.ready) {
        if (_lastWords.contains('i am ready for exam') ||
            _lastWords.contains('start exam') ||
            _lastWords.contains('begin exam')) {
          _goToFirstQuestion();
        } else if (_lastWords.contains('help') ||
            _lastWords.contains('commands')) {
          _speakVoiceCommands();
        }
      } else if (_currentState == ExamState.inProgress) {
        if (_lastWords.contains('next question') ||
            _lastWords.contains('go to next') ||
            _lastWords.contains('forward')) {
          _nextQuestion();
        } else if (_lastWords.contains('previous question') ||
            _lastWords.contains('go back') ||
            _lastWords.contains('back')) {
          _previousQuestion();
        } else if (_lastWords.contains('repeat question') ||
            _lastWords.contains('say again') ||
            _lastWords.contains('what was the question')) {
          _repeatCurrentQuestion();
        } else if (_lastWords.contains('submit exam') ||
            _lastWords.contains('finish exam') ||
            _lastWords.contains('end exam')) {
          _submitExam();
        } else if (_lastWords.contains('which question') ||
            _lastWords.contains('what question') ||
            _lastWords.contains('question number') ||
            _lastWords.contains('where am i')) {
          _announceCurrentPosition();
        } else if (_lastWords.contains('help') ||
            _lastWords.contains('commands')) {
          _speakVoiceCommands();
        } else if (_lastWords.contains('start recording') ||
            _lastWords.contains('record answer')) {
          _startAnswerRecording();
        } else if (_lastWords.contains('stop recording')) {
          _stopAnswerRecording();
        }
      } else if (_currentState == ExamState.ended) {
        if (_lastWords.contains('go to home') ||
            _lastWords.contains('home page') ||
            _lastWords.contains('go home')) {
          _navigateToHome();
        } else if (_lastWords.contains('help') ||
            _lastWords.contains('commands')) {
          _speakVoiceCommands();
        }
      }
    });
  }

  void _announceCurrentPosition() {
    if (sections.isEmpty) return;

    if (_currentQuestionIndex == -1) {
      _speak('You are at the exam introduction.');
      return;
    }

    final sectionTitle = sections[_currentSectionIndex]['title'];
    final questionNumber = _currentQuestionIndex + 1;
    final subQuestionNumber = _currentSubQuestionIndex + 1;
    final totalQuestions = sections[_currentSectionIndex]['questions'].length;
    final totalSubQuestions = sections[_currentSectionIndex]['questions']
            [_currentQuestionIndex]['subQuestions']
        .length;

    _speak(
        'You are in section $sectionTitle, question $questionNumber out of $totalQuestions, ' +
            'sub-question $subQuestionNumber out of $totalSubQuestions.');
  }

  void _repeatCurrentQuestion() {
    if (sections.isEmpty ||
        _currentQuestionIndex == -1 ||
        _currentSectionIndex >= sections.length ||
        _currentQuestionIndex >=
            sections[_currentSectionIndex]['questions'].length) {
      return;
    }

    final question =
        sections[_currentSectionIndex]['questions'][_currentQuestionIndex];
    final subQuestion = question['subQuestions'][_currentSubQuestionIndex];

    _ttsHelper.stop();
    _speak('Question ${_currentQuestionIndex + 1}: ${question['title']}');
    Future.delayed(Duration(milliseconds: 2000), () {
      _speak(
          'Sub-question ${_currentSubQuestionIndex + 1}: ${subQuestion['text']}. Worth ${subQuestion['marks']} marks.');
    });
  }

  // For voice-activated answer recording
  bool _isRecordingAnswer = false;
  String _currentRecordedAnswer = '';

  void _startAnswerRecording() {
    if (!mounted || _isDisposed) return;

    _speak(
        'Starting to record your answer. Speak clearly. Say "stop recording" when finished.');
    setState(() {
      _isRecordingAnswer = true;
      _currentRecordedAnswer = '';
    });

    // Stop the regular command listener and start a dedicated answer listener
    _speechService.stopListening();
    Future.delayed(Duration(milliseconds: 500), () {
      _speechService.startListening(onResult: _processAnswerRecording);
    });
  }

  void _processAnswerRecording(SpeechRecognitionResult result) {
    if (!mounted || _isDisposed || !_isRecordingAnswer) return;

    final words = result.recognizedWords.toLowerCase();

    if (words.contains('stop recording')) {
      _stopAnswerRecording();
      return;
    }

    // Append the recognized text to the current answer
    _currentRecordedAnswer += ' ' + result.recognizedWords;

    // Update the text field
    _answerController.text = _currentRecordedAnswer.trim();

    // Save the answer
    _saveCurrentAnswer();
  }

  void _stopAnswerRecording() {
    if (!mounted || _isDisposed) return;

    _speak('Recording stopped. Your answer has been saved.');
    setState(() {
      _isRecordingAnswer = false;
    });

    // Stop the answer listener and restart the command listener
    _speechService.stopListening();
    Future.delayed(Duration(milliseconds: 500), () {
      _startListening();
    });
  }

  void _saveCurrentAnswer() {
    if (_currentQuestionIndex == -1 || _currentSubQuestionIndex == -1) return;

    // Create a unique key for this question/subquestion
    final answerKey =
        '${_currentSectionIndex}_${_currentQuestionIndex}_${_currentSubQuestionIndex}';

    // Save the answer
    _answers[answerKey] = _answerController.text;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _speechService.stopListening();
    _ttsHelper.stop();
    _answerController.dispose();
    super.dispose();
  }

  void _nextQuestion() {
    if (!mounted || _isDisposed) return;

    // Save the current answer before moving
    _saveCurrentAnswer();

    _ttsHelper.stop();

    setState(() {
      // Check if we have sections loaded
      if (sections.isEmpty || _currentSectionIndex >= sections.length) {
        return;
      }

      // Check if we're at a valid question index
      if (_currentQuestionIndex >= 0 &&
          _currentQuestionIndex <
              sections[_currentSectionIndex]['questions'].length) {
        final currentQuestion =
            sections[_currentSectionIndex]['questions'][_currentQuestionIndex];

        if (_currentSubQuestionIndex <
            currentQuestion['subQuestions'].length - 1) {
          // Go to next subquestion
          _currentSubQuestionIndex++;
        } else {
          // Go to next question
          _currentSubQuestionIndex = 0;
          if (_currentQuestionIndex <
              sections[_currentSectionIndex]['questions'].length - 1) {
            _currentQuestionIndex++;
          } else {
            // Go to next section
            if (_currentSectionIndex < sections.length - 1) {
              _currentSectionIndex++;
              _currentQuestionIndex = 0;
            } else {
              // End exam if all sections are completed
              _submitExam();
              return;
            }
          }
        }
      } else if (_currentQuestionIndex == -1) {
        // First question
        _goToFirstQuestion();
      }

      // Load the answer for the new question if it exists
      _loadCurrentAnswer();
    });
  }

  void _previousQuestion() {
    if (!mounted || _isDisposed) return;

    // Save the current answer before moving
    _saveCurrentAnswer();

    _ttsHelper.stop();

    setState(() {
      // Check if we're at the beginning
      if (_currentSubQuestionIndex == 0 &&
          _currentQuestionIndex == 0 &&
          _currentSectionIndex == 0) {
        _currentSubQuestionIndex = -1;
        _currentQuestionIndex = -1;
        return;
      }

      if (sections.isEmpty || _currentSectionIndex >= sections.length) {
        return;
      }

      if (_currentSubQuestionIndex > 0) {
        // Go to previous subquestion
        _currentSubQuestionIndex--;
      } else {
        // Go to previous question
        if (_currentQuestionIndex > 0) {
          _currentQuestionIndex--;

          if (_currentQuestionIndex <
              sections[_currentSectionIndex]['questions'].length) {
            final prevQuestion = sections[_currentSectionIndex]['questions']
                [_currentQuestionIndex];
            _currentSubQuestionIndex = prevQuestion['subQuestions'].length - 1;
          }
        } else {
          // Go to previous section
          if (_currentSectionIndex > 0) {
            _currentSectionIndex--;

            if (_currentSectionIndex < sections.length) {
              _currentQuestionIndex =
                  sections[_currentSectionIndex]['questions'].length - 1;

              if (_currentQuestionIndex >= 0 &&
                  _currentQuestionIndex <
                      sections[_currentSectionIndex]['questions'].length) {
                final prevQuestion = sections[_currentSectionIndex]['questions']
                    [_currentQuestionIndex];
                _currentSubQuestionIndex =
                    prevQuestion['subQuestions'].length - 1;
              }
            }
          }
        }
      }

      // Load the answer for the new question if it exists
      _loadCurrentAnswer();
    });
  }

  void _loadCurrentAnswer() {
    if (_currentQuestionIndex == -1 || _currentSubQuestionIndex == -1) {
      _answerController.text = '';
      return;
    }

    // Create a unique key for this question/subquestion
    final answerKey =
        '${_currentSectionIndex}_${_currentQuestionIndex}_${_currentSubQuestionIndex}';

    // Load the answer if it exists
    _answerController.text = _answers[answerKey] ?? '';
  }

  void _goToFinalQuestion() {
    if (!mounted || _isDisposed || sections.isEmpty) return;

    _ttsHelper.stop();

    setState(() {
      final lastSectionIndex = sections.length - 1;

      if (lastSectionIndex >= 0 && lastSectionIndex < sections.length) {
        final lastQuestionIndex =
            sections[lastSectionIndex]['questions'].length - 1;

        if (lastQuestionIndex >= 0 &&
            lastQuestionIndex <
                sections[lastSectionIndex]['questions'].length) {
          final lastSubQuestionIndex = sections[lastSectionIndex]['questions']
                      [lastQuestionIndex]['subQuestions']
                  .length -
              1;

          _currentSectionIndex = lastSectionIndex;
          _currentQuestionIndex = lastQuestionIndex;
          _currentSubQuestionIndex = lastSubQuestionIndex;

          // Load the answer for this question if it exists
          _loadCurrentAnswer();
        }
      }
    });
  }

  void _goToFirstQuestion() {
    if (!mounted || _isDisposed || sections.isEmpty) return;

    _ttsHelper.stop();

    setState(() {
      _currentSectionIndex = 0;
      _currentQuestionIndex = 0;
      _currentSubQuestionIndex = 0;

      // Load the answer for this question if it exists
      _loadCurrentAnswer();
    });

    Future.delayed(Duration(milliseconds: 500), () {
      _announceCurrentPosition();
      _repeatCurrentQuestion();
    });
  }

  void _startExam() {
    if (!mounted || _isDisposed) return;

    setState(() {
      _currentState = ExamState.inProgress;
    });

    Future.delayed(Duration(milliseconds: 500), () {
      _speakVoiceCommands();
    });
  }

  Future<void> _submitExam() async {
    if (!mounted || _isDisposed || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    _speak('Submitting your exam. Please wait.');

    try {
      // 1. Save current answer before submission
      _saveCurrentAnswer();

      // 2. Get current user ID
      final studentId = await Student().getCurrentStudentId();

      // 3. Show progress indicator
      if (mounted) {
        setState(() {
          _isSubmitting = true;
        });
      }

      // 4. Process all text answers first
      for (final entry in _answers.entries) {
        final questionKey = entry.key;
        final textAnswer = entry.value;

        // Parse question components from key (format: section_question_subquestion)
        final parts = questionKey.split('_');
        if (parts.length != 3) continue;

        final sectionIndex = int.parse(parts[0]);
        final questionIndex = int.parse(parts[1]);
        final subQuestionIndex = int.parse(parts[2]);

        // Check if there's an audio recording for this question
        final audioPath = _audioRecordings[questionKey];

        if (audioPath != null) {
          // If there's audio, save both audio and text together
          await _examService.saveStudentAudioResponse(
            examId: widget.examData['id'],
            studentId: studentId,
            questionId: questionKey,
            sectionIndex: sectionIndex,
            questionIndex: questionIndex,
            subQuestionIndex: subQuestionIndex,
            audioFilePath: audioPath,
            textResponse: textAnswer,
          );
        } else {
          // If no audio, save just the text response
          await _examService.saveStudentTextResponse(
            examId: widget.examData['id'],
            studentId: studentId,
            questionId: questionKey,
            sectionIndex: sectionIndex,
            questionIndex: questionIndex,
            subQuestionIndex: subQuestionIndex,
            textResponse: textAnswer,
          );
        }
      }

      // 5. Process any audio recordings that don't have text answers
      for (final entry in _audioRecordings.entries) {
        final questionKey = entry.key;
        final audioPath = entry.value;

        // Skip if we've already processed this as part of a text answer
        if (_answers.containsKey(questionKey)) continue;

        final parts = questionKey.split('_');
        if (parts.length != 3) continue;

        final sectionIndex = int.parse(parts[0]);
        final questionIndex = int.parse(parts[1]);
        final subQuestionIndex = int.parse(parts[2]);

        // Save audio-only response
        await _examService.saveStudentAudioResponse(
          examId: widget.examData['id'],
          studentId: studentId,
          questionId: questionKey,
          sectionIndex: sectionIndex,
          questionIndex: questionIndex,
          subQuestionIndex: subQuestionIndex,
          audioFilePath: audioPath,
          textResponse: '', // No text for this answer
        );
      }

      // 6. Mark exam as submitted once all answers are processed
      await _examService.submitExamResponses(
        examId: widget.examData['id'],
        studentId: studentId,
      );

      // 7. Clean up local audio files
      for (final filePath in _audioRecordings.values) {
        try {
          await File(filePath).delete();
        } catch (e) {
          print('Error deleting local file: $e');
          // Continue with other files even if one fails
        }
      }

      // 8. Update UI state
      if (mounted && !_isDisposed) {
        setState(() {
          _currentState = ExamState.ended;
          _isSubmitting = false;
        });
        _speak('Exam submitted successfully!');
      }
    } catch (e) {
      print('Error submitting exam: $e');

      if (mounted && !_isDisposed) {
        setState(() {
          _isSubmitting = false;
        });
        _speak('Submission failed. Please try again.');

        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Submission Error'),
            content: Text(
                'There was a problem submitting your exam. Please try again or contact support.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _navigateToHome() {
    if (!mounted || _isDisposed) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => StudentHome()),
      (route) => false, // This removes all previous routes
    );
  }

  Future<void> _speakText(String text) async {
    if (!mounted || _isDisposed) return;

    await _ttsHelper.initTTS(
        language: "en-US", rate: 0.5, pitch: 1.0, volume: 1.0);
    await _ttsHelper.speak(text);
  }

  // Create a unified speaking method to avoid code duplication
  Future<void> _speak(String text) => _speakText(text);

  @override
  Widget build(BuildContext context) {
    final screen = _getScreenForState();

    // Check if the screen needs scrolling
    // (Ready screen shouldn't be scrollable due to Spacer usage)
    final isReadyScreen = _currentState == ExamState.ready;
    final isEndedScreen = _currentState == ExamState.ended;

    return Scaffold(
      body: SafeArea(
        child: isReadyScreen || isEndedScreen
            ? screen // No scroll view for screens with Spacer
            : SingleChildScrollView(child: screen),
      ),
    );
  }

  Widget _getScreenForState() {
    // Show loading indicator while submitting
    if (_isSubmitting) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Submitting your exam...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    // If exam is manually ended or time is up, show ended screen
    if (_currentState == ExamState.ended) {
      return _buildExamEndedScreen();
    }

    // If exam hasn't started yet and it's before exam time
    if (_currentState == ExamState.ready) {
      return _buildReadyScreen();
    }

    // If exam is in progress
    if (_currentState == ExamState.inProgress) {
      // If we're at the very beginning, show the section intro
      if (_currentQuestionIndex == -1 && _currentSubQuestionIndex == -1) {
        return _buildSectionIntroScreen();
      } else {
        return _buildQuestionScreen();
      }
    }

    // Fallback case
    return _buildExamEndedScreen();
  }

  Widget _buildReadyScreen() {
    Future.microtask(() {
      _speak('STAY READY');
      _speak(widget.examData['name']);
      _speak('Your exam will start in ');
    });

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              SizedBox(width: 16),
              Text(
                'STAY READY',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'sans-serif',
                ),
              ),
            ],
          ),
          SizedBox(height: 32),
          Text(
            widget.examData['name'],
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'sans-serif',
            ),
          ),
          SizedBox(height: 64),
          Center(
            child: Column(
              children: [
                Text(
                  'Your exam will start in',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'sans-serif',
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TimerCountdown(
                    format: CountDownTimerFormat.hoursMinutesSeconds,
                    timeTextStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    descriptionTextStyle: TextStyle(
                      fontSize: 0,
                      color: Colors.transparent,
                      fontFamily: 'sans-serif',
                    ),
                    colonsTextStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'sans-serif',
                    ),
                    endTime: convertFirebaseTimestampAndTimeString(
                        widget.examData['examDateTime'],
                        widget.examData['startTime']),
                    onEnd: () {
                      if (mounted && !_isDisposed) {
                        _startExam();
                      }
                    },
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Say "I am ready for exam" to begin',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'sans-serif',
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Voice Commands:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'sans-serif',
                  ),
                ),
                Text(
                  '"I am ready for exam" - Start the exam\n"Help" - Hear available commands',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'sans-serif',
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }

  Widget _buildSectionIntroScreen() {
    Future.microtask(() {
      final String introText = widget.examData['guidelines'];
      _speak(introText);
    });

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, color: Colors.transparent),
              ),
              Text(
                sections.isNotEmpty
                    ? sections[_currentSectionIndex]['title']
                    : 'Exam',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'sans-serif',
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_forward, color: Colors.transparent),
              ),
            ],
          ),
          SizedBox(height: 16),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: TimerCountdown(
                format: CountDownTimerFormat.hoursMinutesSeconds,
                timeTextStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                descriptionTextStyle: TextStyle(
                  fontSize: 0,
                  color: Colors.transparent,
                  fontFamily: 'sans-serif',
                ),
                colonsTextStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'sans-serif',
                ),
                endTime: convertFirebaseTimestampAndTimeString(
                    widget.examData['examDateTime'],
                    widget.examData['endTime']),
                onEnd: () {
                  if (mounted && !_isDisposed) {
                    _submitExam();
                  }
                },
              ),
            ),
          ),
          SizedBox(height: 24),
          Text(
            widget.examData['guidelines'],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'sans-serif',
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Say,',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'sans-serif',
            ),
          ),
          Text(
            '"I am ready for exam"',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'sans-serif',
            ),
          ),
          Text(
            'to start the exam',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'sans-serif',
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Voice Commands:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'sans-serif',
            ),
          ),
          Text(
            '"Next question" - Move to the next question\n' +
                '"Previous question" - Go back to the previous question\n' +
                '"Repeat question" - Hear the current question again\n' +
                '"Which question" - Hear your current position\n' +
                '"Start recording" - Begin recording your answer\n' +
                '"Stop recording" - Finish recording your answer\n' +
                '"Submit exam" - Finish and submit the exam\n' +
                '"Help" - Hear available commands',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'sans-serif',
            ),
          ),
          SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: () {
                if (mounted && !_isDisposed) {
                  _goToFirstQuestion();
                }
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: const Size(100, 100),
              ),
              child: const Text(
                'START',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'sans-serif',
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQuestionScreen() {
    if (sections.isEmpty ||
        _currentSectionIndex >= sections.length ||
        _currentQuestionIndex >=
            sections[_currentSectionIndex]['questions'].length ||
        _currentSubQuestionIndex >=
            sections[_currentSectionIndex]['questions'][_currentQuestionIndex]
                    ['subQuestions']
                .length) {
      return Center(child: Text('Question data not available'));
    }

    final question =
        sections[_currentSectionIndex]['questions'][_currentQuestionIndex];
    final subQuestion = question['subQuestions'][_currentSubQuestionIndex];

    Future.microtask(() {
      // First speak the main question if this is the first subquestion
      if (_currentSubQuestionIndex == 0) {
        _speak(question['title']);
      }

      // Then speak the subquestion after a short delay
      Future.delayed(
          Duration(milliseconds: _currentSubQuestionIndex == 0 ? 2000 : 0), () {
        _speak(subQuestion['text']);
        _speak('Worth ${subQuestion["marks"]} marks.');

        // Announce recording instructions
        Future.delayed(Duration(milliseconds: 1500), () {
          _speak(
              'Say "start recording" to begin your answer, or use the text field or audio button.');
        });
      });
    });

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _previousQuestion,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              Text(
                sections[_currentSectionIndex]['title'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'sans-serif',
                ),
              ),
              GestureDetector(
                onTap: _nextQuestion,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: TimerCountdown(
                format: CountDownTimerFormat.hoursMinutesSeconds,
                timeTextStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                descriptionTextStyle: TextStyle(
                  fontSize: 0,
                  color: Colors.transparent,
                  fontFamily: 'sans-serif',
                ),
                colonsTextStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'sans-serif',
                ),
                endTime: convertFirebaseTimestampAndTimeString(
                    widget.examData['examDateTime'],
                    widget.examData['endTime']),
                onEnd: () {
                  if (mounted && !_isDisposed) {
                    _submitExam();
                  }
                },
              ),
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            color: Colors.grey[800],
            child: Text(
              'QUESTION ${_currentQuestionIndex + 1}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'sans-serif',
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            question['title'],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'sans-serif',
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8),
            color: Colors.grey[700],
            child: Text(
              'SUB QUESTION ${_currentQuestionIndex + 1}.${_currentSubQuestionIndex + 1}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'sans-serif',
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(subQuestion['text'], style: TextStyle(fontSize: 16)),
          Text(
            '(${subQuestion['marks']} Marks)',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              fontFamily: 'sans-serif',
            ),
          ),
          SizedBox(height: 25),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Audio Record Button
              GestureDetector(
                onTap: () {
                  // Check if we're currently recording
                  if (_isRecordingAnswer) {
                    _stopAnswerRecording();
                  } else {
                    _startAnswerRecording();
                  }
                },
                child: AudioRecordButton(
                  questionId:
                      '${_currentSectionIndex}_${_currentQuestionIndex}_${_currentSubQuestionIndex}', // Pass question ID
                  onNewRecording: (questionId, filePath) {
                    _audioRecordings[questionId] = filePath; // Store recording
                  },
                ),
              ),
              SizedBox(width: 16),
              // Voice Command Status Indicator
            ],
          ),
          SizedBox(height: 16),
          // Recording status indicator, only shown when actively recording an answer
          if (_isRecordingAnswer)
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fiber_manual_record, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    "Recording Answer...",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Say 'stop recording' when finished",
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 16),
          Container(
            height: 200,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _answerController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText:
                    "Enter your text or say 'start recording' to answer by voice...",
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              expands: true,
              onChanged: (value) {
                // Update the answers map whenever the text changes manually
                _saveCurrentAnswer();
              },
            ),
          ),
          SizedBox(height: 16),
          // Voice command hints at the bottom
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voice Commands:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '"Next question" - Move to next\n' +
                      '"Previous question" - Go back\n' +
                      '"Repeat question" - Hear again\n' +
                      '"Which question" - Current position\n' +
                      '"Submit exam" - Finish exam',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamEndedScreen() {
    Future.microtask(() {
      _speak('Your exam has been submitted');
    });

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  color: Colors.white,
                  onPressed: () {
                    if (mounted && !_isDisposed) {
                      setState(() {
                        _currentState = ExamState.inProgress;
                      });
                      _goToFinalQuestion();
                    }
                  },
                ),
              ),
              SizedBox(width: 16),
              Text(
                'EXAM ENDED',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'sans-serif',
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: TimerCountdown(
                format: CountDownTimerFormat.hoursMinutesSeconds,
                timeTextStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                descriptionTextStyle: TextStyle(
                  fontSize: 0,
                  color: Colors.transparent,
                  fontFamily: 'sans-serif',
                ),
                colonsTextStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'sans-serif',
                ),
                endTime: DateTime.now().add(
                  Duration(
                    hours: 00,
                    minutes: 00,
                    seconds: 30,
                  ),
                ),
                onEnd: () {
                  if (mounted && !_isDisposed) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => StudentHome()));
                  }
                },
              ),
            ),
          ),
          Spacer(),
          Center(
            child: Text(
              'Your exam has been submitted',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'sans-serif',
              ),
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
