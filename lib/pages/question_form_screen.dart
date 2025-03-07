import 'package:flutter/material.dart';

class QuestionFormScreen extends StatefulWidget {
  const QuestionFormScreen({super.key});

  @override
  State<QuestionFormScreen> createState() => _QuestionFormScreenState();
}

class _QuestionFormScreenState extends State<QuestionFormScreen> {
  List<Map<String, dynamic>> questions =
      []; // List to hold questions & subquestions

  // Function to add a new Question (Level 1)
  void _addNewQuestion() {
    setState(() {
      questions.add({
        "title": "Question ${questions.length + 1}",
        "subquestions": [] // Initially, no subquestions
      });
    });
  }

  // Function to add a new Subquestion (Level 2)
  void _addNewSubquestion(int index) {
    setState(() {
      questions[index]["subquestions"]
          .add("Subquestion ${questions[index]["subquestions"].length + 1}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create New Exam")),
      body: ListView(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.all(5), // Make the button take full width
              child: FilledButton(
                onPressed: _addNewQuestion,
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(4), // Small border radius
                  ),
                ),
                child: Text("Add New Question"),
              ),
            ),
          ),
          ...questions.asMap().entries.map((entry) {
            int questionIndex = entry.key;
            var question = entry.value;

            return ExpansionTile(
              title: Text(question["title"]),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _addNewSubquestion(questionIndex),
                        child: Text("Add New Subquestion"),
                      ),
                    ),
                    Expanded(
                      child: FilledButton(
                        onPressed: _addNewQuestion,
                        child: Text("Add New Question"),
                      ),
                    )
                  ],
                ),
                ...question["subquestions"].map<Widget>((subquestion) {
                  return ExpansionTile(
                    title: Text(subquestion),
                    children: [
                      ListTile(title: Text("Details for $subquestion")),
                    ],
                  );
                }).toList(),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}
