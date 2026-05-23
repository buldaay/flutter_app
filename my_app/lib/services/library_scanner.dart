import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../models/media_category.dart';
import '../models/media_item.dart';

class LibraryScanner {
  static const supportedExtensions = ['.mp4', '.mkv', '.avi', '.mov'];

  Future<List<MediaCategory>> scanFolder(String rootPath) async {
    final rootDirectory = Directory(rootPath);
    if (!await rootDirectory.exists()) {
      return [];
    }

    final tempDir = await getTemporaryDirectory();
    final children = rootDirectory.listSync(followLinks: false)..sort((a, b) => a.path.compareTo(b.path));
    final List<MediaCategory> categories = [];
    final List<MediaItem> uncategorizedItems = [];

    for (final entity in children) {
      if (entity is Directory) {
        final category = await _scanCategoryDirectory(entity, tempDir.path);
        if (category.items.isNotEmpty) {
          categories.add(category);
        }
      } else if (entity is File && _isVideo(entity.path)) {
        uncategorizedItems.add(await _buildMediaItem(entity, rootPath, tempDir.path));
      }
    }

    if (uncategorizedItems.isNotEmpty) {
      categories.add(MediaCategory(
        name: 'Uncategorized',
        folderPath: rootPath,
        bannerPath: null,
        createdAt: DateTime.now(),
        items: uncategorizedItems,
      ));
    }

    return categories;
  }

  bool _isVideo(String path) {
    final lower = path.toLowerCase();
    return supportedExtensions.any(lower.endsWith);
  }

  Future<MediaCategory> _scanCategoryDirectory(Directory directory, String cachePath) async {
    final folderName = _folderNameFromPath(directory.path);
    final banner = await _findBanner(directory);
    final items = <MediaItem>[];
    for (final entity in directory.listSync(followLinks: false)..sort((a, b) => a.path.compareTo(b.path))) {
      if (entity is File && _isVideo(entity.path)) {
        items.add(await _buildMediaItem(entity, directory.path, cachePath));
      }
    }

    return MediaCategory(
      name: folderName,
      folderPath: directory.path,
      bannerPath: banner,
      createdAt: DateTime.now(),
      items: items,
    );
  }

  Future<String?> _findBanner(Directory categoryDirectory) async {
    final candidateJpg = File('${categoryDirectory.path}${Platform.pathSeparator}folder.jpg');
    if (await candidateJpg.exists()) {
      return candidateJpg.path;
    }

    final candidatePng = File('${categoryDirectory.path}${Platform.pathSeparator}folder.png');
    if (await candidatePng.exists()) {
      return candidatePng.path;
    }

    return null;
  }

  Future<MediaItem> _buildMediaItem(File videoFile, String categoryPath, String cachePath) async {
    final title = _titleFromPath(videoFile.path);
    final posterPath = await _findPoster(videoFile, cachePath);
    final addedAt = await videoFile.lastModified();

    return MediaItem(
      title: title,
      videoPath: videoFile.path,
      posterPath: posterPath,
      categoryPath: categoryPath,
      duration: 'Unknown',
      isFavorite: false,
      addedAt: addedAt,
    );
  }

  Future<String?> _findPoster(File videoFile, String cachePath) async {
    final baseName = _baseNameFromPath(videoFile.path);
    final parentPath = videoFile.parent.path;

    for (final ext in ['.jpg', '.png']) {
      final posterFile = File('$parentPath${Platform.pathSeparator}$baseName$ext');
      if (await posterFile.exists()) {
        return posterFile.path;
      }
    }

    try {
      return await VideoThumbnail.thumbnailFile(
        video: videoFile.path,
        thumbnailPath: cachePath,
        imageFormat: ImageFormat.JPEG,
        quality: 75,
        maxHeight: 360,
      );
    } catch (_) {
      return null;
    }
  }

  String _titleFromPath(String path) {
    final fileName = File(path).uri.pathSegments.last;
    final dotIndex = fileName.lastIndexOf('.');
    return dotIndex >= 0 ? fileName.substring(0, dotIndex) : fileName;
  }

  String _baseNameFromPath(String path) {
    return _titleFromPath(path);
  }

  String _folderNameFromPath(String path) {
    final normalized = path.replaceAll(RegExp(r'[/\\]+$'), '');
    final segments = normalized.split(RegExp(r'[\/]+'));
    return segments.isNotEmpty ? segments.last : normalized;
  }
}
