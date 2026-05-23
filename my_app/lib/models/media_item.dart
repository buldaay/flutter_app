class MediaItem {
  final int? id;
  final String title;
  final String videoPath;
  final String? posterPath;
  final String categoryPath;
  final String duration;
  final bool isFavorite;
  final DateTime addedAt;
  final DateTime? lastPlayedAt;
  final int continuePosition;

  MediaItem({
    this.id,
    required this.title,
    required this.videoPath,
    this.posterPath,
    required this.categoryPath,
    required this.duration,
    required this.isFavorite,
    required this.addedAt,
    this.lastPlayedAt,
    this.continuePosition = 0,
  });

  MediaItem copyWith({
    int? id,
    String? title,
    String? videoPath,
    String? posterPath,
    String? categoryPath,
    String? duration,
    bool? isFavorite,
    DateTime? addedAt,
    DateTime? lastPlayedAt,
    int? continuePosition,
  }) {
    return MediaItem(
      id: id ?? this.id,
      title: title ?? this.title,
      videoPath: videoPath ?? this.videoPath,
      posterPath: posterPath ?? this.posterPath,
      categoryPath: categoryPath ?? this.categoryPath,
      duration: duration ?? this.duration,
      isFavorite: isFavorite ?? this.isFavorite,
      addedAt: addedAt ?? this.addedAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      continuePosition: continuePosition ?? this.continuePosition,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'videoPath': videoPath,
      'posterPath': posterPath,
      'categoryPath': categoryPath,
      'duration': duration,
      'isFavorite': isFavorite ? 1 : 0,
      'addedAt': addedAt.millisecondsSinceEpoch,
      'lastPlayedAt': lastPlayedAt?.millisecondsSinceEpoch,
      'continuePosition': continuePosition,
    };
  }

  factory MediaItem.fromMap(Map<String, dynamic> map) {
    return MediaItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      videoPath: map['videoPath'] as String,
      posterPath: map['posterPath'] as String?,
      categoryPath: map['categoryPath'] as String,
      duration: map['duration'] as String,
      isFavorite: (map['isFavorite'] as int) == 1,
      addedAt: DateTime.fromMillisecondsSinceEpoch(map['addedAt'] as int),
      lastPlayedAt: map['lastPlayedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['lastPlayedAt'] as int) : null,
      continuePosition: map['continuePosition'] as int? ?? 0,
    );
  }
}
