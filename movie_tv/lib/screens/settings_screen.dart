import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? selectedFolder;

  Future<void> pickFolder() async {
    String? path = await FilePicker.platform.getDirectoryPath();

    if (path != null) {
      setState(() {
        selectedFolder = path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: pickFolder,
              child: const Text('Select Main Folder'),
            ),
            const SizedBox(height: 20),
            Text(
              selectedFolder ?? 'No folder selected',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}