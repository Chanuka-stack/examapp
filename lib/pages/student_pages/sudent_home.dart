import 'package:app1/data/exam.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import '../../services/voice_recongintion_service.dart';
import '../../services/text_to_speech_service.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'questions.dart';

class StudentHome extends StatefulWidget {
  StudentHome({Key? key}) : super(key: key);

  @override
  _StudentHomeState createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  final SpeechRecognitionService _speechService = SpeechRecognitionService();
  final TextToSpeechHelper ttsHelper = TextToSpeechHelper();
  final ExamFirebaseService _examService = ExamFirebaseService(); // Add this
  bool _isFirstInit = true;

  List<Map<String, dynamic>> upcomingExams = [];

  String _lastWords = '';
  bool _isInitialized = false;
  bool isStartExam = false;

  @override
  void initState() {
    super.initState();

    _initSpeak();

    _initSpeechAndStart();
    _fetchUpcomingExams();
  }

  void dispose() {
    _speechService.stopListening();
    super.dispose();
  }

  Future<void> _fetchUpcomingExams() async {
    try {
      // Replace 'currentStudentId' with the actual student ID
      //final exams = await _examService.getUpcomingExams(studentId: 'currentStudentId');
      final exams = await _examService.getUpcomingExams();

      setState(() {
        upcomingExams = exams.map((exam) {
          // Convert Firestore data to your expected format
          return {
            'id': exam['id'],
            'name': exam['name'],
            'date': _formatDate(exam['examDate'] as Timestamp),
            'startTime': exam['startTime'],
            'endTime': exam['endTime'],
            'examDateTime': exam['examDateTime'],

            // Add any other fields you need
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching exams: $e');
      // Optionally show an error to the user
    }
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  DateTime convertFirebaseTimestampAndTimeString(
      Timestamp firebaseTimestamp, String timeString) {
    // Convert Firebase Timestamp to DateTime
    DateTime date = firebaseTimestamp.toDate();

    // Parse the time string
    List<String> timeParts = timeString.split(":");
    int hours = int.parse(timeParts[0]);
    int minutes = int.parse(timeParts[1]);

    // Create a new DateTime with the date from Firebase and time from string
    return DateTime(
      date.year,
      date.month,
      date.day,
      hours,
      minutes,
    );
  }

  void _initSpeak() async {
    await ttsHelper.initTTS(
        language: "en-US", rate: 0.5, pitch: 1.0, volume: 1.0);
    await ttsHelper.speak(
        "Hello, welcome to the Exam App. Your current exam is start at 9 am. Say Start Exam to Start the Exam");
    //await ttsHelper.stop();
  }

  void _stopSpeak() async {
    await ttsHelper.stop();
  }

  void _initSpeechAndStart() async {
    await _speechService.initSpeech();
    setState(() {
      _isInitialized = true;
    });
    // Start listening automatically
    _startListening();
  }

  void _startListening() async {
    if (!mounted) return;
    await _speechService.startListening(onResult: _processResult);
    setState(() {});

    // Set up a timer to check if listening has stopped
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        _speechService.checkAndRestartListening(_startListening);
      }
    });
  }

  void _processResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;

      if (_lastWords.toLowerCase().contains('start exam')) {
        _speechService.stopListening();
        _navigateToHomePage();
      }
    });
  }

  void _navigateToHomePage() {
    _speechService.stopListening();
    if (upcomingExams.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => Qesutions(examData: upcomingExams[0])),
      );
    } else {
      // If no exams available, navigate without an ID
      /*Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Qesutions()),
    );*/
    }
  }

  final DateTime startTime = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    20,
    22,
    30,
  );
  /*final List<Map<String, dynamic>> upcomingExams = [
    {
      'name': 'SINHALA LITERATURE PART II - [Y152-SL-9292]',
      'date': '2023-11-15',
      'startTime': '09:00',
      'endTime': '12:00',
    },
    {
      'name': 'MATHEMATICS PART I - [M101-MT-1254]',
      'date': '2023-11-17',
      'startTime': '10:00',
      'endTime': '13:00',
    },
    {
      'name': 'PHYSICS THEORY - [P203-PH-3840]',
      'date': '2023-11-20',
      'startTime': '14:00',
      'endTime': '17:00',
    },
  ];
*/

  final List<Map<String, dynamic>> practiceSessions = [
    {
      'name': 'PRACTICE EXAM - 01',
      'date': '2023-11-10',
      'startTime': '08:00',
      'endTime': '10:00',
      'shortQuestions': 5,
      'structuredQuestions': 5,
      'essayQuestions': 1,
      'duration': '30 MINUTES',
    },
    {
      'name': 'PRACTICE EXAM - 02',
      'date': '2023-11-12',
      'startTime': '09:00',
      'endTime': '11:00',
      'shortQuestions': 10,
      'structuredQuestions': 3,
      'essayQuestions': 2,
      'duration': '45 MINUTES',
    },
    {
      'name': 'PRACTICE EXAM - 03',
      'date': '2023-11-14',
      'startTime': '10:00',
      'endTime': '12:00',
      'shortQuestions': 8,
      'structuredQuestions': 4,
      'essayQuestions': 1,
      'duration': '60 MINUTES',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        leading: Padding(
          padding: EdgeInsets.only(left: 10),
          /*child: Image.network(
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTEDHJcTUiAddWFZ53pMbbKxp9hIZW4hAAnHg&s",
            fit: BoxFit.fitWidth,
          ),*/
        ),
        title: Row(
          children: [
            const SizedBox(width: 8),
            const Text(
              'EXAMAPP',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: 'sans-serif',
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              // Handle profile button tap
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Profile clicked')));
            },
            child: const CircleAvatar(
              backgroundColor: Colors.red,
              radius: 16,
              child: Text(
                'P',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'sans-serif',
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upcoming Exams',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'sans-serif',
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 250,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.97),
                itemCount: upcomingExams.length,
                itemBuilder: (context, index) {
                  return _buildExamCard(upcomingExams[index]);
                },
              ),
            ),
            const SizedBox(height: 24),

            // Voice Commands section
            const Text(
              'Voice Commands',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'sans-serif',
              ),
            ),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildVoiceCommandButton('Start Exam'),
                  buildVoiceCommandButton('Next Question'),
                  buildVoiceCommandButton('Previous Question'),
                  buildVoiceCommandButton('Question [Number]'),
                  buildVoiceCommandButton('Finish Exam'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Practice Sessions section
            const Text(
              'Practice Sessions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'sans-serif',
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 350,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.98),
                itemCount: practiceSessions.length,
                itemBuilder: (context, index) {
                  return _buildPracticeCard(practiceSessions[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamCard(Map<String, dynamic> exam) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exam title
            Text(
              exam['name'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: 'sans-serif',
              ),
            ),
            const SizedBox(height: 12),

            // Exam date and time
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFF1E3A8A),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    exam['date'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'sans-serif',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFFF00FF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${exam['startTime']} - ${exam['endTime']}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'sans-serif',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Timer and start button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /*const Text(
                  'Exam starts in 00:50s',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),*/
                Column(
                  children: [
                    Text(
                      'Exam Start in',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'sans-serif',
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: TimerCountdown(
                        format: CountDownTimerFormat.hoursMinutesSeconds,
                        endTime: convertFirebaseTimestampAndTimeString(
                            exam['examDateTime'], exam['startTime']),
                        timeTextStyle: TextStyle(
                          fontSize: 16, // Adjust size
                          fontWeight: FontWeight.bold,
                          color: Colors.red, // Change text color
                        ),
                        descriptionTextStyle: TextStyle(
                          // Hides labels by setting empty text
                          fontSize: 0, // Makes labels disappear
                          color: Colors.transparent,
                          fontFamily: 'sans-serif',
                        ),
                        colonsTextStyle: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'sans-serif',
                        ),
                        onEnd: () {
                          if (mounted) {
                            // Delay the navigation slightly to ensure the page is loaded
                            Future.delayed(Duration(milliseconds: 100), () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Qesutions(examData: exam)),
                              );
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    print(exam['id']);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Qesutions(examData: exam)));
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(80, 80),
                  ),
                  child: const Text(
                    'START',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'sans-serif',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeCard(Map<String, dynamic> session) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Practice exam title
          Text(
            session['name'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              fontFamily: 'sans-serif',
            ),
          ),
          const SizedBox(height: 16),

          // Question types
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Short Questions selected')),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${session['shortQuestions']} SHORT QUESTIONS',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.indigo,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'sans-serif',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Structured Questions selected')),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${session['structuredQuestions']} STRUCTURED QUESTIONS',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.indigo,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'sans-serif',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Essay Questions selected')),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${session['essayQuestions']} ESSAY QUESTIONS',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.indigo,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'sans-serif',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              session['duration'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontFamily: 'sans-serif',
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Start button
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Navigate to the practice screen
                /*Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PlaceholderPracticeScreen(),
                  ),
                );*/
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: const Size(80, 80),
              ),
              child: const Text(
                'START',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'sans-serif',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildVoiceCommandButton(String command) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: () {
          // Simulate voice command recognition
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Voice command: $command')));
        },
        child: Row(
          children: [
            const Icon(Icons.play_circle_outline, color: Colors.grey, size: 16),
            const SizedBox(width: 8),
            Text(
              '"$command"',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'sans-serif',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
