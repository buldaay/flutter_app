import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/library_provider.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF07080D), Color(0xFF151826)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.tv, size: 92, color: Colors.redAccent),
                const SizedBox(height: 22),
                const Text('Cinema Shelf Setup', textAlign: TextAlign.center, style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 14),
                const Text(
                  'Select a local media folder and launch videos with VLC. The app will automatically create categories from subfolders and generate posters for your movie collection.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                const SizedBox(height: 34),
                if (!library.permissionGranted) ...[
                  const SetupCard(title: 'Storage access required', description: 'Grant storage permission so the app can scan your TV folders.', icon: Icons.storage),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: library.requestStoragePermission,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18)),
                    child: const Text('Grant permission', style: TextStyle(fontSize: 18)),
                  ),
                ] else if (!library.vlcInstalled) ...[
                  const SetupCard(title: 'VLC not installed', description: 'Install VLC for Android TV to play your videos from Cinema Shelf.', icon: Icons.play_circle_fill),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18)),
                    child: const Text('Install VLC from Play Store', style: TextStyle(fontSize: 18)),
                  ),
                ] else ...[
                  const SetupCard(title: 'Choose your library folder', description: 'Pick the main folder that contains category subfolders like Action, Horror, or Anime.', icon: Icons.folder_open),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: library.scanning ? null : library.chooseFolder,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18)),
                    child: Text(library.scanning ? 'Scanning library…' : 'Select folder', style: const TextStyle(fontSize: 18)),
                  ),
                  if (library.mainFolderPath != null) ...[
                    const SizedBox(height: 14),
                    Text('Current folder: ${library.mainFolderPath}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60)),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SetupCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const SetupCard({super.key, required this.title, required this.description, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF12151F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color.fromRGBO(255, 0, 0, 0.18), borderRadius: BorderRadius.circular(18)),
            child: Icon(icon, size: 36, color: Colors.redAccent),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                Text(description, style: const TextStyle(fontSize: 16, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
