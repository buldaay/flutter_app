import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/library_provider.dart';
import 'screens/category_screen.dart';
import 'screens/details_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const TvMediaApp());
}

class TvMediaApp extends StatelessWidget {
  const TvMediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LibraryProvider()..initialize(),
      child: Consumer<LibraryProvider>(
        builder: (context, library, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Cinema Shelf',
            theme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: const Color(0xFF090A0F),
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent, brightness: Brightness.dark),
              textTheme: ThemeData.dark().textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              ),
            ),
            home: Builder(
              builder: (context) {
                if (!library.initialized) {
                  return const SplashScreen();
                }
                if (!library.permissionGranted || !library.vlcInstalled || library.mainFolderPath == null || library.mainFolderPath!.isEmpty) {
                  return const SetupScreen();
                }
                return const HomeScreen();
              },
            ),
            routes: {
              SettingsScreen.routeName: (_) => const SettingsScreen(),
              CategoryScreen.routeName: (_) => const CategoryScreen(),
              DetailsScreen.routeName: (_) => const DetailsScreen(),
            },
          );
        },
      ),
    );
  }
}
