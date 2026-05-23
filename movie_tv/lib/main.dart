import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const MovieTVApp());
}

class MovieTVApp extends StatelessWidget {
  const MovieTVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movie TV',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}