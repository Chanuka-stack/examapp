import 'package:app1/services/text_to_speech_service.dart';
import 'package:flutter/material.dart';
import '../components/audio_button.dart';
import '../../services/timer.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';

class Qesutions extends StatefulWidget {
  const Qesutions({super.key});

  @override
  State<Qesutions> createState() => _QesutionsState();
}

enum ExamState { ready, inProgress, ended }

class _QesutionsState extends State<Qesutions> {
  final TextToSpeechHelper ttsHelper = TextToSpeechHelper();

  /// Example: Exam is from 10:00 AM to 12:00 PM
  final DateTime startTime = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    11,
    47,
    30,
  );
  final DateTime endTime = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    11,
    55,
    0,
  );

  ExamState _currentState = ExamState.ready;

  int _currentSectionIndex = 0;
  int _currentQuestionIndex = -1;
  int _currentSubQuestionIndex = -1;

  // Question list without formal data models
  late List<Map<String, dynamic>> sections;

  @override
  void initState() {
    super.initState();
    // Initialize question data
    if (DateTime.now().isBefore(startTime)) {
      _currentState = ExamState.ready;
    } else if (DateTime.now().isAfter(endTime)) {
      _currentState = ExamState.ended;
    } else {
      _currentState = ExamState.inProgress;
    }

    sections = [
      {
        'title': 'SECTION 01',
        'questions': [
          {
            'title': 'Explain the concept of supply and demand.',
            'subQuestions': [
              {
                'text':
                    'Discuss how equilibrium price is determined in a competitive market.',
                'marks': 25,
              },
              {
                'text': 'Define demand and supply with relevant examples.',
                'marks': 20,
              },
            ],
          },
          {
            'title': 'Second question title',
            'subQuestions': [
              {'text': 'Second question subquestion 1', 'marks': 15},
              {'text': 'Second question subquestion 2', 'marks': 10},
            ],
          },
        ],
      },
      {
        'title': 'SECTION 02',
        'questions': [
          {
            'title': 'Sample Question for Section 2',
            'subQuestions': [
              {'text': 'Sample subquestion for section 2', 'marks': 15},
            ],
          },
        ],
      },
    ];
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _nextQuestion() {
    ttsHelper.stop();
    setState(() {
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
            return; // Added return to prevent further execution
          }
        }
      }
    });
  }

  void _previousQuestion() {
    ttsHelper.stop();
    setState(() {
      if (_currentSubQuestionIndex == 0 &&
          _currentQuestionIndex == 0 &&
          _currentSectionIndex == 0) {
        setState(() {
          _currentSubQuestionIndex = -1;
          _currentQuestionIndex = -1;
        });
      }
      if (_currentSubQuestionIndex > 0) {
        // Go to previous subquestion
        _currentSubQuestionIndex--;
      } else {
        // Go to previous question
        if (_currentQuestionIndex > 0) {
          _currentQuestionIndex--;
          final prevQuestion = sections[_currentSectionIndex]['questions']
              [_currentQuestionIndex];
          _currentSubQuestionIndex = prevQuestion['subQuestions'].length - 1;
        } else {
          // Go to previous section
          if (_currentSectionIndex > 0) {
            _currentSectionIndex--;
            _currentQuestionIndex =
                sections[_currentSectionIndex]['questions'].length - 1;
            final prevQuestion = sections[_currentSectionIndex]['questions']
                [_currentQuestionIndex];
            _currentSubQuestionIndex = prevQuestion['subQuestions'].length - 1;
          }
          // Added else condition to handle edge case when at first question
          else {
            // Already at first question, do nothing or optionally show a message
            // You could add: ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Already at first question')));
          }
        }
      }
    });
  }

  void _goToFinalQuestion() {
    ttsHelper.stop();
    setState(() {
      final lastSectionIndex = sections.length - 1;
      final lastQuestionIndex =
          sections[lastSectionIndex]['questions'].length - 1;
      final lastSubQuestionIndex = sections[lastSectionIndex]['questions']
                  [lastQuestionIndex]['subQuestions']
              .length -
          1;

      _currentSectionIndex = lastSectionIndex;
      _currentQuestionIndex = lastQuestionIndex;
      _currentSubQuestionIndex = lastSubQuestionIndex;
    });
  }

  void _goToFirstQuestion() {
    ttsHelper.stop();
    setState(() {
      _currentSectionIndex = 0;
      _currentQuestionIndex = 0;
      _currentSubQuestionIndex = 0;
    });
  }

  void _startExam() {
    setState(() {
      _currentState = ExamState.inProgress;
    });
  }

  void _endExam() {
    setState(() {
      _currentState = ExamState.ended;
    });
  }

  void _speakSection(String text) async {
    await ttsHelper.initTTS(
        language: "en-US", rate: 0.5, pitch: 1.0, volume: 1.0);
    await ttsHelper.speak(text);
  }

  void _speakR(String text) async {
    await ttsHelper.initTTS(
        language: "en-US", rate: 0.5, pitch: 1.0, volume: 1.0);
    await ttsHelper.speak(text);
  }

  void _speakMainQuestion(String text) async {
    await ttsHelper.initTTS(
        language: "en-US", rate: 0.5, pitch: 1.0, volume: 1.0);
    await ttsHelper.speak(text);
  }

  void _speakSubQuestion(String text) async {
    await ttsHelper.initTTS(
        language: "en-US", rate: 0.5, pitch: 1.0, volume: 1.0);
    await ttsHelper.speak(text);
  }

  void _speakIntro(String text) async {
    await ttsHelper.initTTS(
        language: "en-US", rate: 0.5, pitch: 1.0, volume: 1.0);
    await ttsHelper.speak(text);
  }

  void _speakOutro(String text) async {
    await ttsHelper.initTTS(
        language: "en-US", rate: 0.5, pitch: 1.0, volume: 1.0);
    await ttsHelper.speak(text);
  }

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
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakR('STAY READY');
      _speakR('SINHALA LITERATURE PART II - [YIS2-SL-9282]');
      _speakR('Your exam will start in ');
    });*/
    Future.microtask(() {
      _speakR('STAY READY');
      _speakR('SINHALA LITERATURE PART II - [YIS2-SL-9282]');
      _speakR('Your exam will start in ');
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
                child: Icon(Icons.arrow_back, color: Colors.white),
              ),
              SizedBox(width: 16),
              Text(
                'STAY READY',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 32),
          Text(
            'SINHALA LITERATURE PART II - [YIS2-SL-9282]',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 64),
          Center(
            child: Column(
              children: [
                Text('Your exam will start in', style: TextStyle(fontSize: 18)),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TimerCountdown(
                    format: CountDownTimerFormat.hoursMinutesSeconds,
                    endTime: startTime,
                    onEnd: () {
                      _startExam();
                    },
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          /*Center(
            child: ElevatedButton(
              onPressed: _startExam,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text('Start Exam', style: TextStyle(fontSize: 18)),
            ),
          ),*/
        ],
      ),
    );
  }

  Widget _buildSectionIntroScreen() {
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      final String introText =
          'This exam has two sections: Section 1 requires answering all questions, while in Section 2, you may choose any two questions out of five. The total duration is 2 hours.';
      _speakIntro(introText);
    });*/
    Future.microtask(() {
      final String introText =
          'This exam has two sections: Section 1 requires answering all questions, while in Section 2, you may choose any two questions out of five. The total duration is 2 hours.';
      _speakIntro(introText);
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
                sections[_currentSectionIndex]['title'],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                endTime: endTime,
                onEnd: () {
                  _endExam();
                },
              ),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'This exam has two sections:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'Section 1 requires answering all questions,',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'while in Section 2, you may choose any two questions out of five.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          Text(
            'The total duration is 2 hours.',
            style: TextStyle(fontSize: 16),
          ),
          Spacer(),
          Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  // Go to first actual question (not just the section intro)
                  /*_currentSubQuestionIndex = 0;
                  _currentQuestionIndex = 0;
                  _nextQuestion();*/
                  _goToFirstQuestion();
                });
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text('Start Section', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionScreen() {
    final question =
        sections[_currentSectionIndex]['questions'][_currentQuestionIndex];
    final subQuestion = question['subQuestions'][_currentSubQuestionIndex];

    Future.microtask(() {
      // First speak the main question if this is the first subquestion
      if (_currentSubQuestionIndex == 0) {
        _speakMainQuestion(question['title']);
      }

      // Then speak the subquestion after a short delay
      Future.delayed(
          Duration(milliseconds: _currentSubQuestionIndex == 0 ? 2000 : 0), () {
        _speakSubQuestion(subQuestion['text']);
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                endTime: endTime,
                onEnd: () {
                  _endExam;
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
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            question['title'],
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(subQuestion['text'], style: TextStyle(fontSize: 16)),
          Text(
            '(${subQuestion['marks']} Marks)',
            style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
          ),
          SizedBox(height: 25),
          Center(child: AudioRecordButton()),
        ],
      ),
    );
  }

  Widget _buildExamEndedScreen() {
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakOutro('Your exam has been submitted');
    });*/
    Future.microtask(() {
      _speakOutro('Your exam has been submitted');
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
                    setState(() {
                      _currentState = ExamState.inProgress;
                    });
                    _goToFinalQuestion();
                  },
                ),
              ),
              SizedBox(width: 16),
              Text(
                'EXAM ENDED',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                endTime: DateTime.now().add(
                  Duration(
                    days: 5,
                    hours: 14,
                    minutes: 27,
                    seconds: 34,
                  ),
                ),
                onEnd: () {
                  print("Timer finished");
                },
              ),
            ),
          ),
          Spacer(),
          Center(
            child: Text(
              'Your exam has been submitted',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
