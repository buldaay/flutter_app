class MovieModel {
  final String title;
  final String path;
  final String category;
  final String? poster;

  MovieModel({
    required this.title,
    required this.path,
    required this.category,
    this.poster,
  });
}