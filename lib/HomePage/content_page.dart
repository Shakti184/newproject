import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

class ContentPage extends StatefulWidget {
  const ContentPage({Key? key}) : super(key: key);

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  late Future<ListResult> futureFiles;
  Map<String, double> downloadProgress = {}; // Changed index type to String

  late Database _database;

  @override
  void initState() {
    super.initState();
    futureFiles = FirebaseStorage.instance.ref('/files').listAll();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, 'files.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE files (
            id INTEGER PRIMARY KEY,
            name TEXT,
            path TEXT
          )
        ''');
      },
    );
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
                double? progress = downloadProgress[file.name]; // Changed to use file name as index

                return ListTile(
                  title: Text(file.name),
                  subtitle: progress != null
                      ? LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.black26,
                        )
                      : null,
                  onTap: () => openOrDownloadFile(context, file),
                  trailing: IconButton(
                    onPressed: () => downloadFile(context, file),
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

  Future<void> downloadFile(BuildContext context, Reference ref) async {
    final url = await ref.getDownloadURL();
    final PermissionStatus status = await Permission.storage.request();
    if (status != PermissionStatus.granted) {
      _showSnackBar(context, 'Storage permission denied');
      return;
    }

    final Directory? appDir = await getExternalStorageDirectory();
    if (appDir == null) {
      _showSnackBar(context, 'Failed to access external storage');
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
              downloadProgress[ref.name] = progress; // Update progress using file name
            });
          },
        );
      }

      _showSnackBar(context, 'Downloaded ${ref.name}');

      await _saveFileToDatabase(ref.name, filePath);
    } catch (e) {
      print('Error downloading file: $e');
      _showSnackBar(context, 'Error downloading file');
    }
  }

  Future<void> _saveFileToDatabase(String name, String path) async {
    await _database.insert(
      'files',
      {'name': name, 'path': path},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> openOrDownloadFile(BuildContext context, Reference ref) async {
    final PermissionStatus status = await Permission.storage.request();
    if (status != PermissionStatus.granted) {
      _showSnackBar(context, 'Storage permission denied');
      return;
    }

    final Directory? appDir = await getExternalStorageDirectory();
    if (appDir == null) {
      _showSnackBar(context, 'Failed to access external storage');
      return;
    }

    final String filePath = '${appDir.path}/${ref.name}';
    final File file = File(filePath);

    if (await file.exists()) {
      _showOpenDialog(context, filePath);
    } else {
      await downloadFile(context, ref);
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
    );
  }

  void _showOpenDialog(BuildContext context, String filePath) {
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
  }
}
