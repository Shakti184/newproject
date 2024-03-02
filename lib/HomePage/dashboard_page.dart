import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  final Animation<Offset> offsetAnimation;
  final String userEmail;
  final String userName; // Add userName parameter

  const DashboardPage({
    Key? key,
    required this.offsetAnimation,
    required this.userEmail,
    required this.userName, // Add userName parameter
  }) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SlideTransition(
            position: widget.offsetAnimation,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.blue,
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30.0,
                    child: Icon(
                      Icons.person,
                      size: 40.0,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName, // Display user's name
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        widget.userEmail,
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Spacer to create some space between profile and boxes
          const SizedBox(height: 20.0),

          // Boxes with Images and Text
          buildBoxRow('Manage Parents', Icons.people),
          const SizedBox(height: 10.0),
          buildBoxRow('Homework', Icons.assignment),
          const SizedBox(height: 10.0),
          buildBoxRow('Clear Student Doubts', Icons.question_answer),
          const SizedBox(height: 10.0),
          buildBoxRow('Maintain Attendance', Icons.event_available),
          const SizedBox(height: 10.0),
          buildBoxRow('Organize Events', Icons.event),
          const SizedBox(height: 10.0),
          buildBoxRow('Complaints', Icons.warning),
        ],
      ),
    );
  }

  Widget buildBoxRow(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[200],
      child: Row(
        children: [
          Icon(
            icon,
            size: 40.0,
            color: Colors.blue,
          ),
          const SizedBox(width: 16.0),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15.0,
              // fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
