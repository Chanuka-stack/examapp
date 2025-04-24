import 'dart:io';
import 'package:app1/data/exam.dart';
import 'package:app1/data/student.dart';
import 'package:app1/pages/components/audio_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'sudent_home2.dart';

class Qesutions extends StatefulWidget {
  final Map<String, dynamic> examData;

  const Qesutions({Key? key, required this.examData}) : super(key: key);

  @override
  State<Qesutions> createState() => _QesutionsState();
}

enum ExamState { ready, inProgress, ended }

class _QesutionsState extends State<Qesutions> {
  // Services
  final ExamFirebaseService _examService = ExamFirebaseService();

  // UI Controllers
  final TextEditingController _answerController = TextEditingController();
  final GlobalKey<AudioRecordButtonState> _audioButtonKey =
      GlobalKey<AudioRecordButtonState>();

  SpeechToText _speechToText = SpeechToText();

  bool _speechEnabled = false;
  String _lastWords = '';
  // State variables
  bool _isInitialized = false;
  bool _isDisposed = false;
  bool _isListening = false;
  bool _isSubmitting = false;
  bool _isRecordingAnswer = false;

  String _currentRecordedAnswer = '';

  ExamState _currentState = ExamState.ready;

  // Navigation indices
  int _currentSectionIndex = 0;
  int _currentQuestionIndex = -1;
  int _currentSubQuestionIndex = -1;

  // Exam data
  List<Map<String, dynamic>> sections = [];
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

    // Only start listening when exam is in progress
    if (_currentState == ExamState.inProgress) {
      _startListening();
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

  void _determineExamState() {
    final DateTime now = DateTime.now();
    final DateTime examStartTime = _convertTimestamp(
        widget.examData['examDateTime'], widget.examData['startTime']);
    final DateTime examEndTime = _convertTimestamp(
        widget.examData['examDateTime'], widget.examData['endTime']);

    if (now.isBefore(examStartTime)) {
      _currentState = ExamState.ready;
    } else if (now.isAfter(examEndTime)) {
      _currentState = ExamState.ended;
    } else {
      _currentState = ExamState.inProgress;
    }
  }

  DateTime _convertTimestamp(Timestamp timestamp, String timeString) {
    final DateTime date = timestamp.toDate();
    final List<String> timeParts = timeString.split(":");
    final int hours = int.parse(timeParts[0]);
    final int minutes = int.parse(timeParts[1]);

    return DateTime(date.year, date.month, date.day, hours, minutes);
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

  void _safeSetState(VoidCallback fn) {
    if (mounted && !_isDisposed) {
      setState(fn);
    }
  }

  Future<void> _initSpeechAndStart() async {
    try {
      // Check microphone permission
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        print('Microphone permission denied');
        return;
      }

      // Initialize speech recognition
      _speechEnabled = await _speechToText.initialize(
        onStatus: (status) => print('Status: $status'),
        onError: (error) => print('Error: $error'),
        debugLogging: true,
      );

      if (_speechEnabled) {
        // Don't start listening yet
      }
    } catch (e) {
      print('Speech init error: $e');
    }
  }

  void _startListening() async {
    if (!_speechEnabled || _speechToText.isListening) return;

    try {
      await _speechToText.listen(
        onResult: _processResult,
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 3),
        listenMode: ListenMode.confirmation,
        cancelOnError: false,
        partialResults: true,
      );
    } catch (e) {
      print('Listen error: $e');
      // Attempt to restart after delay if not disposed
      if (mounted && !_isDisposed) {
        Future.delayed(Duration(seconds: 1), _startListening);
      }
    }
  }

  void _processResult(SpeechRecognitionResult result) {
    if (!mounted) return;

    setState(() {
      _lastWords = result.recognizedWords.toLowerCase();
      _processVoiceCommands();
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _processVoiceCommands() {
    final words = _lastWords.toLowerCase();

    if (_currentState == ExamState.ready) {
      if (words.contains('start exam')) {
        _goToFirstQuestion();
      }
      return;
    }

    if (_currentState == ExamState.inProgress) {
      if (words.contains('next question')) {
        _nextQuestion();
      } else if (words.contains('previous question')) {
        _previousQuestion();
      } else if (words.contains('submit exam')) {
        _submitExam();
      } else if (words.contains('which question')) {
        _announceCurrentPosition();
      } else if (words.contains('start recording')) {
        _startAnswerRecording();
      } else if (words.contains('stop recording')) {
        _stopAnswerRecording();
      } else if (words.contains('help')) {
        _speakVoiceCommands();
      }
      return;
    }

    // Ended state commands
    if (_currentState == ExamState.ended) {
      if (words.contains('go to home')) {
        _navigateToHome();
      } else if (words.contains('help')) {
        _speakVoiceCommands();
      }
    }
  }

  void _speakVoiceCommands() {
    if (_currentState == ExamState.ready) {
      // No TTS announcement
    } else if (_currentState == ExamState.inProgress) {
      // No TTS announcement
    } else if (_currentState == ExamState.ended) {
      // No TTS announcement
    }
  }

  void _announceCurrentPosition() {
    // No TTS announcement
  }

  void _repeatCurrentQuestion() {
    // No TTS repetition
  }

  void _startAnswerRecording() {
    if (!mounted || _isDisposed) return;

    setState(() {
      _isRecordingAnswer = true;
      _currentRecordedAnswer = '';
    });

    _stopListening();
    Future.delayed(Duration(milliseconds: 500), () {
      _startListening();
    });
  }

  void _processAnswerRecording(SpeechRecognitionResult result) {
    if (!mounted || _isDisposed || !_isRecordingAnswer) return;

    final words = result.recognizedWords.toLowerCase();
    if (words.contains('stop recording')) {
      _stopAnswerRecording();
      return;
    }

    _currentRecordedAnswer += ' ' + result.recognizedWords;
    _answerController.text = _currentRecordedAnswer.trim();
    _saveCurrentAnswer();
  }

  void _stopAnswerRecording() {
    if (!mounted || _isDisposed) return;

    setState(() => _isRecordingAnswer = false);

    _stopListening();
    Future.delayed(Duration(milliseconds: 500), () {
      _startListening();
    });
  }

  void _saveCurrentAnswer() {
    if (_currentQuestionIndex == -1 || _currentSubQuestionIndex == -1) return;

    final answerKey =
        '${_currentSectionIndex}_${_currentQuestionIndex}_${_currentSubQuestionIndex}';
    _answers[answerKey] = _answerController.text;
  }

  void _loadCurrentAnswer() {
    if (_currentQuestionIndex == -1 || _currentSubQuestionIndex == -1) {
      _answerController.text = '';
      return;
    }

    final answerKey =
        '${_currentSectionIndex}_${_currentQuestionIndex}_${_currentSubQuestionIndex}';
    _answerController.text = _answers[answerKey] ?? '';
  }

  void _nextQuestion() {
    if (!mounted || _isDisposed) return;

    _saveCurrentAnswer();
    // No TTS announcement

    if (_isLastQuestion()) {
      _showSubmitConfirmationDialog();
      return;
    }

    setState(() {
      if (sections.isEmpty) return;

      if (_currentQuestionIndex >= 0) {
        final currentQuestion =
            sections[_currentSectionIndex]['questions'][_currentQuestionIndex];

        if (_currentSubQuestionIndex <
            currentQuestion['subQuestions'].length - 1) {
          // Next subquestion
          _currentSubQuestionIndex++;
        } else if (_currentQuestionIndex <
            sections[_currentSectionIndex]['questions'].length - 1) {
          // Next question
          _currentQuestionIndex++;
          _currentSubQuestionIndex = 0;
        } else if (_currentSectionIndex < sections.length - 1) {
          // Next section
          _currentSectionIndex++;
          _currentQuestionIndex = 0;
          _currentSubQuestionIndex = 0;
        } else {
          // End of exam
          _submitExam();
          return;
        }
      } else {
        // First question
        _goToFirstQuestion();
      }

      _loadCurrentAnswer();
    });
  }

  void _previousQuestion() {
    if (!mounted || _isDisposed) return;

    _saveCurrentAnswer();
    // No TTS announcement

    setState(() {
      // Check if at beginning
      if (_currentSubQuestionIndex == 0 &&
          _currentQuestionIndex == 0 &&
          _currentSectionIndex == 0) {
        _currentSubQuestionIndex = -1;
        _currentQuestionIndex = -1;
        return;
      }

      if (sections.isEmpty) return;

      if (_currentSubQuestionIndex > 0) {
        // Previous subquestion
        _currentSubQuestionIndex--;
      } else if (_currentQuestionIndex > 0) {
        // Previous question
        _currentQuestionIndex--;
        final prevQuestion =
            sections[_currentSectionIndex]['questions'][_currentQuestionIndex];
        _currentSubQuestionIndex = prevQuestion['subQuestions'].length - 1;
      } else if (_currentSectionIndex > 0) {
        // Previous section
        _currentSectionIndex--;
        _currentQuestionIndex =
            sections[_currentSectionIndex]['questions'].length - 1;
        final prevQuestion =
            sections[_currentSectionIndex]['questions'][_currentQuestionIndex];
        _currentSubQuestionIndex = prevQuestion['subQuestions'].length - 1;
      }

      _loadCurrentAnswer();
    });
  }

  bool _isLastQuestion() {
    if (sections.isEmpty) return false;

    final lastSectionIndex = sections.length - 1;
    if (_currentSectionIndex < lastSectionIndex) return false;

    final lastQuestionIndex =
        sections[lastSectionIndex]['questions'].length - 1;
    if (_currentQuestionIndex < lastQuestionIndex) return false;

    final lastSubQuestionIndex = sections[lastSectionIndex]['questions']
                [lastQuestionIndex]['subQuestions']
            .length -
        1;
    return _currentSubQuestionIndex >= lastSubQuestionIndex;
  }

  void _goToFinalQuestion() {
    if (!mounted || _isDisposed || sections.isEmpty) return;

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

    setState(() {
      _currentSectionIndex = 0;
      _currentQuestionIndex = 0;
      _currentSubQuestionIndex = 0;
      _loadCurrentAnswer();
    });

    Future.delayed(Duration(milliseconds: 500), () {
      _announceCurrentPosition();
      _repeatCurrentQuestion();
    });
  }

  void _startExam() {
    if (!mounted || _isDisposed) return;
    setState(() => _currentState = ExamState.inProgress);
    _startListening(); // Now start listening when exam begins
  }

  void _showSubmitConfirmationDialog() {
    // No TTS announcement

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Submit Exam?'),
        content: Text(
            'You have reached the end of the exam. Do you want to submit now?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No, Review Answers'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _submitExam();
            },
            child: Text('Yes, Submit Exam'),
            style: TextButton.styleFrom(backgroundColor: Colors.deepPurple),
          ),
        ],
      ),
    );
  }

  Future<void> _submitExam() async {
    if (!mounted || _isDisposed || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    // No TTS announcement

    try {
      // Save current answer
      _saveCurrentAnswer();

      // Get student ID
      final studentId = await Student().getCurrentStudentId();

      // Process text answers
      for (final entry in _answers.entries) {
        final questionKey = entry.key;
        final textAnswer = entry.value;

        final parts = questionKey.split('_');
        if (parts.length != 3) continue;

        final sectionIndex = int.parse(parts[0]);
        final questionIndex = int.parse(parts[1]);
        final subQuestionIndex = int.parse(parts[2]);

        // Check for audio recording
        final audioPath = _audioRecordings[questionKey];

        if (audioPath != null) {
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

      // Process audio-only recordings
      for (final entry in _audioRecordings.entries) {
        final questionKey = entry.key;
        if (_answers.containsKey(questionKey)) continue;

        final audioPath = entry.value;
        final parts = questionKey.split('_');
        if (parts.length != 3) continue;

        final sectionIndex = int.parse(parts[0]);
        final questionIndex = int.parse(parts[1]);
        final subQuestionIndex = int.parse(parts[2]);

        await _examService.saveStudentAudioResponse(
          examId: widget.examData['id'],
          studentId: studentId,
          questionId: questionKey,
          sectionIndex: sectionIndex,
          questionIndex: questionIndex,
          subQuestionIndex: subQuestionIndex,
          audioFilePath: audioPath,
          textResponse: '',
        );
      }

      // Mark exam as submitted
      await _examService.submitExamResponses(
        examId: widget.examData['id'],
        studentId: studentId,
      );

      // Clean up audio files
      for (final filePath in _audioRecordings.values) {
        try {
          await File(filePath).delete();
        } catch (e) {
          print('Error deleting audio file: $e');
        }
      }

      // Update UI
      if (mounted && !_isDisposed) {
        setState(() {
          _currentState = ExamState.ended;
          _isSubmitting = false;
        });
        // No TTS announcement
      }
    } catch (e) {
      print('Error submitting exam: $e');

      if (mounted && !_isDisposed) {
        setState(() => _isSubmitting = false);
        // No TTS announcement

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Submission Error'),
            content: Text(
                'There was a problem submitting your exam. Please try again.'),
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
      (route) => false,
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _stopListening();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = _getScreenForState();
    final isReadyScreen = _currentState == ExamState.ready;
    final isEndedScreen = _currentState == ExamState.ended;

    return Scaffold(
      body: SafeArea(
        child: isReadyScreen || isEndedScreen
            ? screen
            : SingleChildScrollView(child: screen),
      ),
    );
  }

  Widget _getScreenForState() {
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

    if (_currentState == ExamState.ended) {
      return _buildExamEndedScreen();
    }

    if (_currentState == ExamState.ready) {
      return _buildReadyScreen();
    }

    if (_currentState == ExamState.inProgress) {
      if (_currentQuestionIndex == -1 && _currentSubQuestionIndex == -1) {
        return _buildSectionIntroScreen();
      } else {
        return _buildQuestionScreen();
      }
    }

    return _buildExamEndedScreen();
  }

  Widget _buildReadyScreen() {
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
                  'Say "start exam" to begin',
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
                  '"Start exam" - Start the exam\n"Help" - Hear available commands',
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
            '"Start exam"',
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

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: () {
              _startListening();
            },
            child: Text("Test Speech"),
          ),
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
                onEnd: () async {
                  if (mounted && !_isDisposed) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text('Time expired - finalizing recording...')));

                    // Handle any ongoing recording
                    if (_isRecordingAnswer) {
                      _stopAnswerRecording();
                      Future.delayed(
                          Duration(seconds: 1)); // Ensure save completes
                    }

                    final audioButtonState = _audioButtonKey.currentState;
                    if (audioButtonState != null &&
                        audioButtonState.isRecording) {
                      final path =
                          await audioButtonState.stopAndSaveRecording();
                      if (path != null) {
                        final questionId =
                            '${_currentSectionIndex}_${_currentQuestionIndex}_${_currentSubQuestionIndex}';
                        _audioRecordings[questionId] = path;
                      }
                      // Give time for the recording to be processed
                      await Future.delayed(Duration(seconds: 1));
                    }

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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Audio Record Button
                GestureDetector(
                  onTap: () {
                    if (_isRecordingAnswer) {
                      _stopAnswerRecording();
                    } else {
                      _startAnswerRecording();
                    }
                  },
                  child: AudioRecordButton(
                    key: _audioButtonKey,
                    questionId:
                        '${_currentSectionIndex}_${_currentQuestionIndex}_${_currentSubQuestionIndex}',
                    onNewRecording: (questionId, filePath) {
                      _audioRecordings[questionId] = filePath;
                    },
                  ),
                ),
                SizedBox(height: 16),
                // Voice Command Status Indicator can be added here if needed
              ],
            ),
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
                    if (mounted) {
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
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StudentHome()),
                    );
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
