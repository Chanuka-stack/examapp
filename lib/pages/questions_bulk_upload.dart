/*import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class QuestionsBulkUpload extends StatefulWidget {
  const QuestionsBulkUpload({super.key});

  @override
  State<QuestionsBulkUpload> createState() => _QuestionsBulkUploadState();
}

class _QuestionsBulkUploadState extends State<QuestionsBulkUpload> {
  @override
  List<Map<String, dynamic>> questions = [];

  // Function to pick and read the file
  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String content = await file.readAsString();
      parseQuestions(content);
    }
  }

  // Function to parse TXT content
  void parseQuestions(String content) {
    List<String> lines = content.split("\n");

    List<Map<String, dynamic>> parsedQuestions = [];
    Map<String, dynamic>? currentQuestion;

    for (String line in lines) {
      line = line.trim();

      if (line.startsWith("Q:")) {
        currentQuestion = {
          "question": line.substring(2).trim(),
          "sub_questions": []
        };
        parsedQuestions.add(currentQuestion);
      } else if (line.startsWith("-") && currentQuestion != null) {
        currentQuestion["sub_questions"].add(line.substring(1).trim());
      }
    }

    setState(() {
      questions = parsedQuestions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Exam File")),
      body: Column(
        children: [
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: pickFile,
            child: Text("Upload TXT File"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: questions.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(8),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(questions[index]["question"],
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        ...questions[index]["sub_questions"]
                            .map<Widget>((subQ) => Padding(
                                  padding: EdgeInsets.only(left: 12, top: 4),
                                  child: Text("- $subQ"),
                                ))
                            .toList()
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
*/
