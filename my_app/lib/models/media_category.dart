import 'media_item.dart';

class MediaCategory {
  final int? id;
  final String name;
  final String folderPath;
  final String? bannerPath;
  final DateTime createdAt;
  final List<MediaItem> items;

  MediaCategory({
    this.id,
    required this.name,
    required this.folderPath,
    this.bannerPath,
    required this.createdAt,
    this.items = const [],
  });

  MediaCategory copyWith({
    int? id,
    String? name,
    String? folderPath,
    String? bannerPath,
    DateTime? createdAt,
    List<MediaItem>? items,
  }) {
    return MediaCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      folderPath: folderPath ?? this.folderPath,
      bannerPath: bannerPath ?? this.bannerPath,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'folderPath': folderPath,
      'bannerPath': bannerPath,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory MediaCategory.fromMap(Map<String, dynamic> map) {
    return MediaCategory(
      id: map['id'] as int?,
      name: map['name'] as String,
      folderPath: map['folderPath'] as String,
      bannerPath: map['bannerPath'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      items: const [],
    );
  }
}
