import 'package:flutter/material.dart';

class ExamFormScreen extends StatefulWidget {
  @override
  _ExamFormScreenState createState() => _ExamFormScreenState();
}

class _ExamFormScreenState extends State<ExamFormScreen> {
  int _currentStep = 0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _examDateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Multi-Step Form")),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 3) {
            setState(() {
              _currentStep++;
            });
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep--;
            });
          }
        },
        steps: [
          _buildStep(
            title: "Basic",
            content: _buildBasicForm(),
            isActive: _currentStep >= 0,
          ),
          _buildStep(
            title: "Students",
            content: _buildStudentsForm(),
            isActive: _currentStep >= 1,
          ),
          _buildStep(
            title: "Guidelines",
            content: _buildGuidelinesForm(),
            isActive: _currentStep >= 2,
          ),
          _buildStep(
            title: "Questions",
            content: _buildQuestionsForm(),
            isActive: _currentStep >= 3,
          ),
        ],
      ),
    );
  }

  Step _buildStep(
      {required String title,
      required Widget content,
      required bool isActive}) {
    return Step(
      title: Column(
        children: [
          Text(title, textAlign: TextAlign.center),
        ],
      ),
      content: content,
      isActive: isActive,
    );
  }

  Widget _buildBasicForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField("Name", _nameController),
        _buildDropdown("Division", ["Faculty of Management (FOM)"]),
        _buildDropdown("Subject", ["Economics"]),
        _buildDatePicker("Exam Date", _examDateController),
        _buildTimePicker("Start Time", _startTimeController),
        _buildTimePicker("End Time", _endTimeController),
        _buildButtons(),
      ],
    );
  }

  Widget _buildStudentsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown("Students", ["AR/21/3638", "AR/21/3639"]),
        _buildButtons(),
      ],
    );
  }

  Widget _buildGuidelinesForm() {
    return Column(
      children: [
        Text("Add guidelines here..."),
        _buildButtons(),
      ],
    );
  }

  Widget _buildQuestionsForm() {
    return Column(
      children: [
        Text("Add questions here..."),
        _buildButtons(),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (newValue) {},
      ),
    );
  }

  Widget _buildDatePicker(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(),
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          );
          if (pickedDate != null) {
            setState(() {
              controller.text =
                  "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
            });
          }
        },
      ),
    );
  }

  Widget _buildTimePicker(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: Icon(Icons.access_time),
          border: OutlineInputBorder(),
        ),
        onTap: () async {
          TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (pickedTime != null) {
            setState(() {
              controller.text = pickedTime.format(context);
            });
          }
        },
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: EdgeInsets.symmetric(vertical: 12),
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            if (_currentStep < 3) {
              setState(() {
                _currentStep++;
              });
            }
          },
          child: Center(child: Text("Next")),
        ),
        TextButton(
          onPressed: () {},
          child: Text("Save as Draft"),
        ),
      ],
    );
  }
}
