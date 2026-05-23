import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/media_category.dart';
import '../models/media_item.dart';
import '../services/database_service.dart';
import '../services/library_scanner.dart';
import '../services/vlc_intent_service.dart';

class LibraryProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  final LibraryScanner _scanner = LibraryScanner();

  bool initialized = false;
  bool scanning = false;
  bool permissionGranted = false;
  bool vlcInstalled = false;
  String? mainFolderPath;
  int gridColumns = 4;

  List<MediaCategory> categories = [];
  List<MediaItem> items = [];

  Future<void> initialize() async {
    await _databaseService.init();
    permissionGranted = await requestStoragePermission();
    vlcInstalled = await VlcIntentService.isVlcInstalled();
    mainFolderPath = await _databaseService.getSetting('media_path');
    gridColumns = int.tryParse(await _databaseService.getSetting('grid_columns') ?? '4') ?? 4;
    await loadLibrary();
    initialized = true;
    notifyListeners();
  }

  Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) {
      return true;
    }

    final status = await Permission.storage.request();
    if (status.isGranted) {
      permissionGranted = true;
      notifyListeners();
      return true;
    }

    final manageStorageStatus = await Permission.manageExternalStorage.request();
    permissionGranted = manageStorageStatus.isGranted;
    notifyListeners();
    return permissionGranted;
  }

  Future<void> chooseFolder() async {
    final result = await FilePicker.getDirectoryPath();
    if (result != null && result.isNotEmpty) {
      mainFolderPath = result;
      await _databaseService.setSetting('media_path', result);
      await scanLibrary();
    }
  }

  Future<void> loadLibrary() async {
    categories = await _databaseService.loadCategories();
    items = await _databaseService.loadItems();
    notifyListeners();
  }

  Future<void> scanLibrary() async {
    if (mainFolderPath == null || mainFolderPath!.isEmpty) {
      return;
    }

    scanning = true;
    notifyListeners();

    final scannedCategories = await _scanner.scanFolder(mainFolderPath!);
    await _databaseService.clearLibrary(keepSettings: true);

    for (final category in scannedCategories) {
      await _databaseService.saveCategory(category);
      for (final item in category.items) {
        await _databaseService.saveItem(item);
      }
    }

    await _databaseService.setSetting('media_path', mainFolderPath!);
    await loadLibrary();
    scanning = false;
    notifyListeners();
  }

  Future<void> clearLibrary() async {
    await _databaseService.clearLibrary(keepSettings: false);
    categories = [];
    items = [];
    mainFolderPath = null;
    notifyListeners();
  }

  Future<void> toggleFavorite(MediaItem item) async {
    final updated = item.copyWith(isFavorite: !item.isFavorite);
    await _databaseService.saveItem(updated);
    await loadLibrary();
  }

  Future<void> playItem(MediaItem item) async {
    final updated = item.copyWith(lastPlayedAt: DateTime.now());
    await _databaseService.saveItem(updated);
    await loadLibrary();
    await VlcIntentService.openVideoWithVlc(item.videoPath);
  }

  Future<void> setGridColumns(int value) async {
    gridColumns = value;
    await _databaseService.setSetting('grid_columns', value.toString());
    notifyListeners();
  }

  List<MediaCategory> get visibleCategories {
    final grouped = <String, List<MediaItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.categoryPath, () => []).add(item);
    }
    return categories.where((category) => grouped[category.folderPath]?.isNotEmpty == true).toList();
  }

  List<MediaItem> categoryItems(MediaCategory category) {
    return items.where((item) => item.categoryPath == category.folderPath).toList();
  }

  List<MediaItem> get favorites {
    return items.where((item) => item.isFavorite).toList();
  }

  List<MediaItem> get recentlyAdded {
    final sorted = items.toList();
    sorted.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return sorted.take(10).toList();
  }

  List<MediaItem> get continueWatching {
    final withLastPlayed = items.where((item) => item.lastPlayedAt != null).toList();
    withLastPlayed.sort((a, b) => b.lastPlayedAt!.compareTo(a.lastPlayedAt!));
    return withLastPlayed.take(10).toList();
  }
}
