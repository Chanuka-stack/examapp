import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class QuestionFormScreen extends StatefulWidget {
  @override
  _QuestionFormScreenState createState() => _QuestionFormScreenState();
}

class _QuestionFormScreenState extends State<QuestionFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Question Form"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Section 01",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              FormBuilderTextField(
                name: 'question_number',
                decoration: InputDecoration(labelText: "Question Number"),
              ),
              SizedBox(height: 10),
              FormBuilderRadioGroup(
                name: 'question_type',
                decoration: InputDecoration(labelText: "Question Type"),
                options: [
                  FormBuilderFieldOption(value: "True"),
                  FormBuilderFieldOption(value: "Multiple"),
                ],
              ),
              SizedBox(height: 10),
              FormBuilderTextField(
                name: 'question_text',
                decoration: InputDecoration(labelText: "Question Statement"),
              ),
              SizedBox(height: 10),
              Text("Sub Questions",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              buildSubQuestionField(
                  "Discuss how equilibrium price is determined in a competitive market."),
              buildSubQuestionField(
                  "Define demand & supply with relevant examples."),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.saveAndValidate()) {
                    print(_formKey.currentState!.value);
                  }
                },
                child: Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSubQuestionField(String hint) {
    return Column(
      children: [
        FormBuilderTextField(
          name: hint,
          decoration: InputDecoration(labelText: hint),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
