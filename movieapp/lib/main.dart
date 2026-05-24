import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:permission_handler/permission_handler.dart';
import 'movie_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Ku qasbi app-ka inuu ahaado Landscape (Jiif) kaliya mar kasta
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TV Movie Browser',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212), // Dark Theme saafi ah
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedFolderPath;
  List<MovieCategory> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedFolder();
  }

  // Soo rishada folder-kii hore u kaydsanaa
  Future<void> _loadSavedFolder() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString('movie_folder_path');
    if (savedPath != null) {
      setState(() {
        _selectedFolderPath = savedPath;
      });
      _refreshLibrary();
    }
  }

  // Baarista feylasha
  Future<void> _refreshLibrary() async {
    if (_selectedFolderPath == null) return;
    setState(() => _isLoading = true);
    
    final data = await scanSelectedFolder(_selectedFolderPath!);
    
    setState(() {
      _categories = data;
      _isLoading = false;
    });
  }

  // Ku furista VLC Player
  Future<void> _playInVLC(String videoPath) async {
    final intent = AndroidIntent(
      action: 'action_view',
      data: 'file://$videoPath',
      type: 'video/*',
      package: 'org.videolan.vlc', // Wuxuu si toos ah u raadinayaa VLC App
    );
    try {
      await intent.launch();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fadlan soo dejiso VLC Player marka hore!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Navigation Bar-ka Bidix (TV Menu)
          Container(
            width: 80,
            color: const Color(0xFF1E1E1E),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.home, color: Colors.amber),
                  onPressed: () {},
                ),
                const SizedBox(height: 20),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                    _loadSavedFolder(); // Dib u soo cusboonaysii marka la soo laabto
                  },
                ),
              ],
            ),
          ),
          
          // Qaybta Midig (Filimada)
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _selectedFolderPath == null
                    ? const Center(child: Text('Fadlan tag Settings si aad u dooratid Folder.'))
                    : _categories.isEmpty
                        ? const Center(child: Text('Wax filim ah lagama helin folder-ka la doortay.'))
                        : ListView.builder(
                            itemCount: _categories.length,
                            itemBuilder: (context, catIndex) {
                              final category = _categories[catIndex];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      category.name,
                                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 200,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: category.movies.length,
                                      itemBuilder: (context, movieIndex) {
                                        final movie = category.movies[movieIndex];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: InkWell(
                                            onTap: () => _playInVLC(movie.videoPath),
                                            focusColor: Colors.amber.withOpacity(0.4), // Meesha Remote-ka ku jiro (Focus UI)
                                            borderRadius: BorderRadius.circular(8),
                                            child: Container(
                                              width: 130,
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey.shade800),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Column(
                                                children: [
                                                  Expanded(
                                                    child: movie.posterPath != null
                                                        ? Image.file(File(movie.posterPath!), fit: BoxFit.cover, width: double.infinity)
                                                        : Container(
                                                            color: Colors.grey.shade900,
                                                            child: const Icon(Icons.movie, size: 50, color: Colors.grey),
                                                          ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(4.0),
                                                    child: Text(
                                                      movie.title,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: const TextStyle(fontSize: 12),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                ],
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

// --- SCREEN-KA SETTINGS-KA ---
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentPath = "Ma jiro folder la doortay";

  @override
  void initState() {
    super.initState();
    _loadPath();
  }

  Future<void> _loadPath() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentPath = prefs.getString('movie_folder_path') ?? "Ma jiro folder la doortay";
    });
  }

  Future<void> _pickFolder() async {
      // Weydiiso ogolaansho ka hor inta aan la furin File Picker
    if (await Permission.storage.request().isGranted || await Permission.manageExternalStorage.request().isGranted) {
      String? selectedDirectory = await FilePicker.getDirectoryPath();

      if (selectedDirectory != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('movie_folder_path', selectedDirectory);
        setState(() {
          _currentPath = selectedDirectory;
        });
      }
    }
  }

  Future<void> _clearLibrary() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('movie_folder_path');
    setState(() {
      _currentPath = "Ma jiro folder la doortay";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Folder-ka hadda dooran: $_currentPath", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
              onPressed: _pickFolder,
              child: const Text('Dooro Main Folder-ka Filimada'),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: _clearLibrary,
              child: const Text('Sifee Library-ga (Clear)'),
            ),
          ],
        ),
      ),
    );
  }
}