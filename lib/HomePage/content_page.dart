import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ContentPage extends StatefulWidget {
  const ContentPage({Key? key}) : super(key: key);

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  late Future<ListResult> futureFiles;
  Map<int, double> downloadProgress = {};

  @override
  void initState() {
    super.initState();
    futureFiles = FirebaseStorage.instance.ref('/files').listAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Page'),
      ),
      body: FutureBuilder<ListResult>(
        future: futureFiles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final files = snapshot.data!.items;

            return ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                double? progress = downloadProgress[index];

                return ListTile(
                  title: Text(file.name),
                  subtitle: progress != null
                      ? LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.black26,
                        )
                      : null,
                  onTap: () => openOrDownloadFile(context, index, file),
                  trailing: IconButton(
                    onPressed: () => downloadFile(context, index, file),
                    icon: const Icon(
                      Icons.download,
                      color: Colors.black,
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No files found.'));
          }
        },
      ),
    );
  }

  Future<void> downloadFile(BuildContext context, int index, Reference ref) async {
    final url = await ref.getDownloadURL();
    final PermissionStatus status = await Permission.storage.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Storage permission denied',
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
      );
      return;
    }

    final Directory? appDir = await getExternalStorageDirectory();
    if (appDir == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to access external storage',
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
      );
      return;
    }

    final String filePath = '${appDir.path}/${ref.name}';
    final File file = File(filePath);

    try {
      if (!await file.exists()) {
        await Dio().download(
          url,
          filePath,
          onReceiveProgress: (received, total) {
            double progress = received / total;
            setState(() {
              downloadProgress[index] = progress;
            });
          },
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloaded ${ref.name}'),
        ),
      );
    } catch (e) {
      print('Error downloading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error downloading file',
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
      );
    }
  }

  Future<void> openOrDownloadFile(BuildContext context, int index, Reference ref) async {
    final PermissionStatus status = await Permission.storage.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Storage permission denied',
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
      );
      return;
    }

    final Directory? appDir = await getExternalStorageDirectory();
    if (appDir == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to access external storage',
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
      );
      return;
    }

    final String filePath = '${appDir.path}/${ref.name}';
    final File file = File(filePath);

    if (await file.exists()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('File Downloaded'),
          content: const Text('Do you want to open the file?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await OpenFile.open(filePath);
              },
              child: const Text('Open'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    } else {
      await downloadFile(context, index, ref);
    }
  }
}
