import 'package:flutter/material.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({Key? key}) : super(key: key);

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  // Timer variables
  int _secondsRemaining = 55; // Initial countdown value
  bool _examStarted = false;

  // Timer function to be implemented
  void _startCountdown() {
    // Add timer implementation here
    setState(() {
      _examStarted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 10),
          child: Image.network(
            "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/30e6638c-66dc-4f26-9c63-a18063356e7e",
            fit: BoxFit.fitWidth,
          ),
        ),
        title: Row(
          children: [
            const SizedBox(width: 8),
            const Text(
              'EXAMAPP',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              // Handle profile button tap
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile clicked')),
              );
            },
            child: const CircleAvatar(
              backgroundColor: Colors.red,
              radius: 16,
              child: Text(
                'P',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upcoming exam section
              const Text(
                'Upcoming Exam',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Exam card
              Container(
                width: double.infinity,
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
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Exam title
                    const Text(
                      'SINHALA LITERATURE PART II - [Y152-SL-9292]',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Exam date and time
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '2015-02-2024',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.indigo,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '10:00AM-12:30PM',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.indigo,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Timer and start button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Exam start in 00:${_secondsRemaining.toString().padLeft(2, '0')}s',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _examStarted
                              ? null
                              : () {
                                  _startCountdown();
                                  /*Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const PlaceholderExamScreen(),
                                    ),
                                  );*/
                                },
                          style: ElevatedButton.styleFrom(
                            shape:
                                const CircleBorder(), // Correct shape for a circular button
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(80, 80),
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child: const Text(
                            'START',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Voice Commands section
              const Text(
                'Voice Commands',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
                    const Text(
                      'PRACTISE EXAM - 01',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Question types
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Short Questions selected')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '05 SHORT QUESTIONS',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.indigo,
                                fontWeight: FontWeight.w500,
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
                          const SnackBar(
                              content: Text('Structured Questions selected')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '05 STRUCTURED QUESTIONS',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.indigo,
                                fontWeight: FontWeight.w500,
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
                          const SnackBar(
                              content: Text('Essay Questions selected')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '01 ESSAY QUESTIONS',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.indigo,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        '30 MINUTES',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Start button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          /*Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PlaceholderPracticeScreen(),
                            ),
                          );*/
                        },
                        style: ElevatedButton.styleFrom(
                          shape:
                              const CircleBorder(), // Correct shape for a circular button
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(80, 80),
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: const Text(
                          'START',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Add space at the bottom for scrolling
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildVoiceCommandButton(String command) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: () {
          // Simulate voice command recognition
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Voice command: $command')),
          );
        },
        child: Row(
          children: [
            const Icon(
              Icons.play_circle_outline,
              color: Colors.grey,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              '"$command"',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
