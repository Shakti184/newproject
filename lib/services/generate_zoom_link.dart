import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import the package for sharing functionality

class MeetingLinkPage extends StatefulWidget {
  const MeetingLinkPage({Key? key}) : super(key: key);

  @override
  _MeetingLinkPageState createState() => _MeetingLinkPageState();
}

class _MeetingLinkPageState extends State<MeetingLinkPage> {
  String _meetingID = '';

  // Function to generate a random alphanumeric meeting ID
  String _generateMeetingID() {
    // Generate a random 6-character alphanumeric string
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  // Function to construct meeting URLs
  String link="";
  String _constructMeetingURL(String meetingID) {
    link='https://meet.google.com/j/$meetingID';
    return 'https://meet.google.com/j/$meetingID';
  }

  void _copyMeetingLink() {
    
    final String meetingURL = _constructMeetingURL(_meetingID);
    Clipboard.setData(ClipboardData(text: meetingURL));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Meeting link copied to clipboard'),
      ),
    );
  }

  // Function to handle the "Generate" button press
  void _generateMeetingLink() {
    setState(() {
      _meetingID = _generateMeetingID();
      link = _constructMeetingURL(_meetingID);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Link Generator'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Meeting ID:',
              style: TextStyle(fontSize: 18.0),
            ),
            Text(
              _meetingID,
              style:
                  const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _generateMeetingLink,
              child: const Text('Generate Meeting ID'),
            ),
            const SizedBox(height: 20.0),
            Text(link,style: const TextStyle(color: Colors.black),),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _copyMeetingLink,
              child: const Text('Copy Meeting Link'),
            ),
          ],
        ),
      ),
    );
  }
}
