import 'package:app1/data/division.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'create_division.dart';

class Divisions extends StatefulWidget {
  const Divisions({super.key});

  @override
  State<Divisions> createState() => _DivisionsState();
}

class _DivisionsState extends State<Divisions> {
  int? value = 0;

  String formatDateFromTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('yyyy/MM/dd')
          .format(dateTime); // Using intl's DateFormat
    }
    return timestamp.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Divisions"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search button tap
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // Sliding Segmented Control
          Center(
            child: CupertinoSlidingSegmentedControl<int>(
              children: {
                0: buildSegment("All"),
                1: buildSegment("Active"),
                2: buildSegment("Deleted")
              },
              thumbColor: Colors.white,
              groupValue: value,
              onValueChanged: (newValue) {
                setState(() {
                  value = newValue;
                });
              },
            ),
          ),
          const SizedBox(height: 20),

          // Division List
          Expanded(child: getSelectedContent()),
        ],
      ),

      // Floating Action Button for Creating a New Division
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DivisionFormScreen()),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Create Division",
            style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // UI for Sliding Segmented Tabs
  Widget buildSegment(String text) => Container(
        padding: const EdgeInsets.all(12),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      );

  // Function to Filter Content Based on Selection
  Widget getSelectedContent() {
    // This needs to be a FutureBuilder since you're dealing with asynchronous data
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Division().getAllDivisions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No divisions found'));
        }

        // Now we have the data and can work with it
        List<Map<String, dynamic>> allDivisions = snapshot.data!;
        List<Map<String, dynamic>> activeDivisions =
            allDivisions.where((div) => div["status"] == "Active").toList();
        List<Map<String, dynamic>> deletedDivisions =
            allDivisions.where((div) => div["status"] != "Active").toList();

        List<Map<String, dynamic>> displayList;
        switch (value) {
          case 1:
            displayList = activeDivisions;
            break;
          case 2:
            displayList = deletedDivisions;
            break;
          default:
            displayList = allDivisions;
        }

        return ListView.builder(
          itemCount: displayList.length,
          itemBuilder: (context, index) {
            var division = displayList[index];
            return buildDivisionCard(division);
          },
        );
      },
    );
  }

// Division Card Widget
  Widget buildDivisionCard(Map<String, dynamic> division) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            division["imageUrl"],
            height: 50,
            width: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 50,
                width: 50,
                color: Colors.grey,
                child: const Icon(Icons.broken_image),
              );
            },
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${division["name"]} (${division["code"]})",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              division["status"],
              style: TextStyle(
                color:
                    division["status"] == "Active" ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subjects
                const Text("Applicable Subjects",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8,
                  children: (division["subjects"] as List<dynamic>)
                      .map<Widget>((subject) => Chip(
                            label: Text(subject.toString()),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 10),

                // Created By & Created Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Created by\n${division["createdBy"]}",
                        style: const TextStyle(color: Colors.black54)),
                    Text(
                        "Created Date\n${formatDateFromTimestamp(division["createdAt"])}",
                        style: const TextStyle(color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 15),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () {},
                        child: const Text("View Examiners",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                        ),
                        onPressed: () {},
                        child: const Text("Delete",
                            style: TextStyle(color: Colors.red)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DivisionFormScreen(
                                divisionData: division,
                              ),
                            ),
                          );
                        },
                        child: const Text("Edit"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
