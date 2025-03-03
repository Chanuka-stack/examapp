import 'package:app1/pages/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'create_examiner.dart';

class Examiners extends StatefulWidget {
  const Examiners({super.key});

  @override
  State<Examiners> createState() => _ExaminersState();
}

class _ExaminersState extends State<Examiners> {
  int? value = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Examiners"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Handle search button tap
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 16),
          Center(
            child: CupertinoSlidingSegmentedControl<int>(
              children: {
                0: buildSegment('All'),
                1: buildSegment('Active'),
                2: buildSegment('Deleted')
              },
              thumbColor: CupertinoColors.systemPurple,
              groupValue: value,
              onValueChanged: (newValue) {
                setState(() {
                  value = newValue;
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: getSelectedContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExamScheduleScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Create Examiner"),
      ),
    );
  }

  Widget buildSegment(String text) => Container(
      padding: EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(fontSize: 12),
      ));

  Widget getSelectedContent() {
    List<String> allItems = ["Examiner A", "Examiner B", "Examiner C"];
    List<String> activeItems = ["Examiner A", "Examiner B"];
    List<String> deletedItems = ["Examiner C"];

    List<String> displayList;
    switch (value) {
      case 1:
        displayList = activeItems;
        break;
      case 2:
        displayList = deletedItems;
        break;
      default:
        displayList = allItems;
    }

    return ListView.builder(
      itemCount: displayList.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ExpansionTile(
            leading: const Icon(Icons.apartment, color: Colors.blue),
            title: Text(displayList[index]),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Additional details for ${displayList[index]}',
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
