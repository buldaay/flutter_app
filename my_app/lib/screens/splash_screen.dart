import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF050608), Color(0xFF14151D)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.movie, size: 96, color: Colors.redAccent),
              SizedBox(height: 16),
              Text('Cinema Shelf', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 12),
              CircularProgressIndicator(color: Colors.redAccent),
              SizedBox(height: 16),
              Text('Loading your local library…', style: TextStyle(fontSize: 16, color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}
