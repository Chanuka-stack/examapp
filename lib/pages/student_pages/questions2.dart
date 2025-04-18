import 'package:app1/data/exam.dart';
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

  bool _isInitialized = false;
  bool _isDisposed = false;
  String _lastWords = '';

  ExamState _currentState = ExamState.ready;

  int _currentSectionIndex = 0;
  int _currentQuestionIndex = -1;
  int _currentSubQuestionIndex = -1;

  // Question list without formal data models
  List<Map<String, dynamic>> sections = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _determineExamState();
    await _loadExamQuestions(widget.examData['id']);
    await _initSpeechAndStart();
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

    await _speechService.startListening(onResult: _processResult);

    // Set up a timer to check if listening has stopped
    Future.delayed(Duration(seconds: 5), () {
      if (mounted && !_isDisposed) {
        _speechService.checkAndRestartListening(_startListening);
      }
    });
  }

  void _processResult(SpeechRecognitionResult result) {
    if (!mounted || _isDisposed) return;

    setState(() {
      _lastWords = result.recognizedWords.toLowerCase();

      if (_currentState == ExamState.inProgress) {
        if (_lastWords.contains('i am ready for exam')) {
          _goToFirstQuestion();
        } else if (_lastWords.contains('next question')) {
          _nextQuestion();
        } else if (_lastWords.contains('previous question')) {
          _previousQuestion();
        }
      } else if (_currentState == ExamState.ended &&
          _lastWords.contains('end exam')) {
        // Handle end exam command
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _speechService.stopListening();
    _ttsHelper.stop();
    super.dispose();
  }

  void _nextQuestion() {
    if (!mounted || _isDisposed) return;

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
              _endExam();
              return;
            }
          }
        }
      } else if (_currentQuestionIndex == -1) {
        // First question
        _goToFirstQuestion();
      }
    });
  }

  void _previousQuestion() {
    if (!mounted || _isDisposed) return;

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
    });
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
    });
  }

  void _startExam() {
    if (!mounted || _isDisposed) return;

    setState(() {
      _currentState = ExamState.inProgress;
    });
  }

  void _endExam() {
    if (!mounted || _isDisposed) return;

    setState(() {
      _currentState = ExamState.ended;
    });
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
    return Scaffold(body: SafeArea(child: _getScreenForState()));
  }

  Widget _getScreenForState() {
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
                    _endExam();
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
          SizedBox(height: 48),
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
                    _endExam();
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
          Center(child: AudioRecordButton()),
          SizedBox(height: 25),
          Container(
            height: 200,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Enter your text...",
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              expands: true,
            ),
          )
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
                    seconds: 34,
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
