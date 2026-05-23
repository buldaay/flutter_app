import 'dart:io';
import 'package:path/path.dart' as p;

class Movie {
  final String title;
  final String videoPath;
  final String? posterPath; // Haddi uu jiro Movie.jpg

  Movie({required this.title, required this.videoPath, this.posterPath});
}

class MovieCategory {
  final String name; // Tusaale: Action, Horor, Somali
  final List<Movie> movies;

  MovieCategory({required this.name, required this.movies});
}

// Function-kan wuxuu baarayaa Folder-ka la doortay oo kaliya
Future<List<MovieCategory>> scanSelectedFolder(String rootPath) async {
  final rootDir = Directory(rootPath);
  List<MovieCategory> categories = [];
  final videoExtensions = ['.mp4', '.mkv', '.avi'];

  if (!rootDir.existsSync()) return categories;

  // Waxay soo saaraysaa sub-folders-ka (Categories)
  final entities = rootDir.listSync();
  for (var entity in entities) {
    if (entity is Directory) {
      final categoryName = p.basename(entity.path);
      List<Movie> moviesInFolder = [];

      // Baar feylasha ku jira folder-kaas gudihiisa
      final files = entity.listSync();
      for (var file in files) {
        if (file is File) {
          final ext = p.extension(file.path).toLowerCase();
          if (videoExtensions.contains(ext)) {
            final movieTitle = p.basenameWithoutExtension(file.path);
            
            // Hubi in sawir isku magac ah uu jiro (Tusaale: Movie.jpg)
            final possiblePoster = '${p.dirname(file.path)}/$movieTitle.jpg';
            final hasPoster = File(possiblePoster).existsSync();

            moviesInFolder.add(Movie(
              title: movieTitle,
              videoPath: file.path,
              posterPath: hasPoster ? possiblePoster : null,
            ));
          }
        }
      }

      if (moviesInFolder.isNotEmpty) {
        categories.add(MovieCategory(name: categoryName, movies: moviesInFolder));
      }
    }
  }
  return categories;
}