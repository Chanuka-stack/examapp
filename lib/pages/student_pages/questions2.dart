import 'package:flutter/material.dart';
import 'package:app1/data/exam.dart';
import '../../services/voice_recongintion_service.dart';
import '../../services/text_to_speech_service.dart';

class Qesutions extends StatefulWidget {
  final String? examId;

  Qesutions(Map<String, dynamic> exam, {Key? key, this.examId})
      : super(key: key);

  @override
  _QesutionsState createState() => _QesutionsState();
}

class _QesutionsState extends State<Qesutions> {
  final SpeechRecognitionService _speechService = SpeechRecognitionService();
  final TextToSpeechHelper ttsHelper = TextToSpeechHelper();
  final ExamFirebaseService _examService = ExamFirebaseService();

  bool _isLoading = true;
  Map<String, dynamic> examData = {};
  List<dynamic> sections = [];
  int currentSectionIndex = 0;
  int currentQuestionIndex = 0;
  int currentSubQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    String? examId = widget.examId;
    print('Exam ID in initState: $examId');

    // You can use it to initialize state or make API calls
    if (examId != null) {
      _loadExamQuestions(examId);
    }
  }

  Future<void> _loadExamQuestions(String examId) async {
    try {
      final data = await _examService.getExamWithQuestions(examId);
      setState(() {
        examData = data;
        sections = List<dynamic>.from(data['sections'] ?? []);
        _isLoading = false;
      });

      // Initialize TTS with exam title
      _initSpeak();
    } catch (e) {
      print('Error loading exam questions: $e');
      setState(() {
        _isLoading = false;
        // Handle error case
      });
    }
  }

  void _initSpeak() async {
    await ttsHelper.initTTS(
        language: "en-US", rate: 0.5, pitch: 1.0, volume: 1.0);

    String welcomeText = "Welcome to the exam: ${examData['name']}. ";

    if (sections.isNotEmpty &&
        sections[0]['questions'] != null &&
        sections[0]['questions'].isNotEmpty &&
        sections[0]['questions'][0]['subQuestions'] != null &&
        sections[0]['questions'][0]['subQuestions'].isNotEmpty) {
      welcomeText +=
          "First question is: ${sections[0]['questions'][0]['title']}. ";
      welcomeText +=
          "First sub-question: ${sections[0]['questions'][0]['subQuestions'][0]['text']}";
    }

    await ttsHelper.speak(welcomeText);
  }

  // Navigation methods for questions and sub-questions
  void goToNextSubQuestion() {
    if (currentSectionIndex < sections.length) {
      var currentSection = sections[currentSectionIndex];

      if (currentSection['questions'] != null &&
          currentQuestionIndex < currentSection['questions'].length) {
        var currentQuestion = currentSection['questions'][currentQuestionIndex];

        if (currentQuestion['subQuestions'] != null) {
          if (currentSubQuestionIndex <
              currentQuestion['subQuestions'].length - 1) {
            setState(() {
              currentSubQuestionIndex++;
            });
          } else {
            goToNextQuestion();
          }
        } else {
          goToNextQuestion();
        }
      } else {
        goToNextQuestion();
      }

      // Speak the new sub-question
      _speakCurrentSubQuestion();
    }
  }

  void goToNextQuestion() {
    if (currentSectionIndex < sections.length) {
      var currentSection = sections[currentSectionIndex];

      if (currentSection['questions'] != null &&
          currentQuestionIndex < currentSection['questions'].length - 1) {
        setState(() {
          currentQuestionIndex++;
          currentSubQuestionIndex = 0; // Reset sub-question index
        });
      } else if (currentSectionIndex < sections.length - 1) {
        setState(() {
          currentSectionIndex++;
          currentQuestionIndex = 0;
          currentSubQuestionIndex = 0;
        });
      }

      // Speak the new question
      _speakCurrentSubQuestion();
    }
  }

  void goToPreviousSubQuestion() {
    if (currentSubQuestionIndex > 0) {
      setState(() {
        currentSubQuestionIndex--;
      });
    } else {
      goToPreviousQuestion();
    }

    // Speak the new sub-question
    _speakCurrentSubQuestion();
  }

  void goToPreviousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;

        // Set sub-question index to the last sub-question of the previous question
        var currentSection = sections[currentSectionIndex];
        if (currentSection['questions'] != null &&
            currentSection['questions'][currentQuestionIndex]['subQuestions'] !=
                null) {
          currentSubQuestionIndex = currentSection['questions']
                      [currentQuestionIndex]['subQuestions']
                  .length -
              1;
        } else {
          currentSubQuestionIndex = 0;
        }
      });
    } else if (currentSectionIndex > 0) {
      setState(() {
        currentSectionIndex--;

        // Set question index to the last question of the previous section
        if (sections[currentSectionIndex]['questions'] != null) {
          currentQuestionIndex =
              sections[currentSectionIndex]['questions'].length - 1;

          // Set sub-question index to the last sub-question of the last question
          if (sections[currentSectionIndex]['questions'][currentQuestionIndex]
                  ['subQuestions'] !=
              null) {
            currentSubQuestionIndex = sections[currentSectionIndex]['questions']
                        [currentQuestionIndex]['subQuestions']
                    .length -
                1;
          } else {
            currentSubQuestionIndex = 0;
          }
        } else {
          currentQuestionIndex = 0;
          currentSubQuestionIndex = 0;
        }
      });
    }

    // Speak the new sub-question
    _speakCurrentSubQuestion();
  }

  void _speakCurrentSubQuestion() {
    try {
      if (currentSectionIndex < sections.length) {
        var currentSection = sections[currentSectionIndex];

        if (currentSection['questions'] != null &&
            currentQuestionIndex < currentSection['questions'].length) {
          var currentQuestion =
              currentSection['questions'][currentQuestionIndex];

          String textToSpeak =
              "Question: ${currentQuestion['title'] ?? 'Unnamed question'}. ";

          if (currentQuestion['subQuestions'] != null &&
              currentSubQuestionIndex <
                  currentQuestion['subQuestions'].length) {
            var subQuestion =
                currentQuestion['subQuestions'][currentSubQuestionIndex];
            textToSpeak += "Sub-question: ${subQuestion['text']}";
          }

          ttsHelper.speak(textToSpeak);
        }
      }
    } catch (e) {
      print("Error speaking current question: $e");
    }
  }

  // Process voice commands
  void processVoiceCommand(String command) {
    String lowerCommand = command.toLowerCase();

    if (lowerCommand.contains('next question')) {
      goToNextQuestion();
    } else if (lowerCommand.contains('previous question')) {
      goToPreviousQuestion();
    } else if (lowerCommand.contains('next sub-question') ||
        lowerCommand.contains('next subquestion')) {
      goToNextSubQuestion();
    } else if (lowerCommand.contains('previous sub-question') ||
        lowerCommand.contains('previous subquestion')) {
      goToPreviousSubQuestion();
    } else if (lowerCommand.contains('finish exam')) {
      // Handle exam completion
      _finishExam();
    }
  }

  void _finishExam() {
    // Show a confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Finish Exam'),
        content: Text('Are you sure you want to finish this exam?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to previous screen
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (sections.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Exam')),
        body: Center(child: Text('No questions available for this exam')),
      );
    }

    // Get current section, question, and sub-question
    Map<dynamic, dynamic> currentSection = sections[currentSectionIndex];

    Widget content;

    if (currentSection['questions'] == null ||
        currentSection['questions'].isEmpty) {
      content = Center(child: Text('No questions in this section'));
    } else {
      var currentQuestion = currentSection['questions'][currentQuestionIndex];

      if (currentQuestion['subQuestions'] == null ||
          currentQuestion['subQuestions'].isEmpty) {
        content = Center(child: Text('No sub-questions available'));
      } else {
        var subQuestion =
            currentQuestion['subQuestions'][currentSubQuestionIndex];

        content = SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section info
              Text(
                'Section: ${currentSection['title'] ?? 'Unnamed Section'}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),

              // Question
              Text(
                'Question: ${currentQuestion['title'] ?? 'Unnamed Question'}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),

              // Sub-question
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sub-question ${currentSubQuestionIndex + 1}:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subQuestion['text'] ?? 'No text available',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Marks: ${subQuestion['marks'] ?? 0}',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Answer field
              TextField(
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Enter your answer here...',
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 24),

              // Navigation buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: currentSectionIndex > 0 ||
                            currentQuestionIndex > 0 ||
                            currentSubQuestionIndex > 0
                        ? goToPreviousSubQuestion
                        : null,
                    child: Text('Previous'),
                  ),
                  ElevatedButton(
                    onPressed: _finishExam,
                    child: Text('Finish Exam'),
                  ),
                  ElevatedButton(
                    onPressed: _hasMoreContent() ? goToNextSubQuestion : null,
                    child: Text('Next'),
                  ),
                ],
              ),

              // Progress info
              SizedBox(height: 16),
              _buildProgressIndicator(),
            ],
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(examData['name'] ?? 'Exam'),
        actions: [
          // Add a timer widget here if needed
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.timer),
          ),
        ],
      ),
      body: content,
    );
  }

  bool _hasMoreContent() {
    // Check if there are more sub-questions, questions, or sections
    if (currentSectionIndex < sections.length) {
      var currentSection = sections[currentSectionIndex];

      if (currentSection['questions'] != null &&
          currentQuestionIndex < currentSection['questions'].length) {
        var currentQuestion = currentSection['questions'][currentQuestionIndex];

        if (currentQuestion['subQuestions'] != null &&
            currentSubQuestionIndex <
                currentQuestion['subQuestions'].length - 1) {
          return true; // More sub-questions in current question
        } else if (currentQuestionIndex <
            currentSection['questions'].length - 1) {
          return true; // More questions in current section
        } else if (currentSectionIndex < sections.length - 1) {
          return true; // More sections
        }
      }
    }

    return false; // No more content
  }

  Widget _buildProgressIndicator() {
    // Calculate total questions and current position
    int totalSections = sections.length;
    int totalQuestions = 0;
    int totalSubQuestions = 0;
    int currentPosition = 0;

    for (int s = 0; s < sections.length; s++) {
      var section = sections[s];
      if (section['questions'] != null) {
        for (int q = 0; q < section['questions'].length; q++) {
          var question = section['questions'][q];
          if (question['subQuestions'] != null) {
            int subQCount = question['subQuestions'].length;
            totalSubQuestions += subQCount;

            // Calculate current position
            if (s < currentSectionIndex ||
                (s == currentSectionIndex && q < currentQuestionIndex)) {
              currentPosition += subQCount;
            } else if (s == currentSectionIndex && q == currentQuestionIndex) {
              currentPosition += currentSubQuestionIndex + 1;
            }
          }
        }
        totalQuestions += (section['questions']?.length ?? 0) as int;
      }
    }

    return Column(
      children: [
        Text(
          'Question ${currentPosition} of ${totalSubQuestions}',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value:
              totalSubQuestions > 0 ? currentPosition / totalSubQuestions : 0,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _speechService.stopListening();
    ttsHelper.stop();
    super.dispose();
  }
}
