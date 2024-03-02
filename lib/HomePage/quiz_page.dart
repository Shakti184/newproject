import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:newproject/services/generate_zoom_link.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  PlatformFile? pickedFile;
  UploadTask? uploadTask;

  Future<void> uploadFile() async {
    if (pickedFile == null) return;

    final path = 'files/${pickedFile!.name}';
    final file = File(pickedFile!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);

    setState(() {
      uploadTask = ref.putFile(File(pickedFile!.path!));
    });

    final snapshot = await uploadTask!.whenComplete(() {});

    final urlDownload = await snapshot.ref.getDownloadURL();
    print('Download Link: $urlDownload');
  }

  Future<void> selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    setState(() {
      pickedFile = result.files.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Page'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              if (pickedFile != null && pickedFile!.path != null)
                SizedBox(
                  height: 300, // Define height for the PDFView
                  width: 300, // Define width for the PDFView
                  child: Container(
                    color: Colors.blue[100],
                    child: PDFView(
                      filePath: pickedFile!.path!,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: selectFile,
                child: const Text('Select File'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: uploadFile,
                child: const Text('Upload File'),
              ),
              const SizedBox(height: 10),
              buildProgress(),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed:()=> Navigator.push(context,MaterialPageRoute(builder: (context)=>const MeetingLinkPage())),
                child: const Text('Generate Meeting Link'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  

  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
        stream: uploadTask?.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            double progress = data.bytesTransferred / data.totalBytes;

            return SizedBox(
              height: 50,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey,
                    color: Colors.green,
                  ),
                  Center(
                    child: Text(
                      '${(100 * progress).roundToDouble()}%',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const SizedBox(height: 20);
          }
        },
      );
}
