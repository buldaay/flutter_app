import 'package:flutter/material.dart';

import '../models/media_item.dart';
import 'poster_card.dart';

class MediaRow extends StatelessWidget {
  final String title;
  final List<MediaItem> items;
  final void Function(MediaItem) onPressed;

  const MediaRow({super.key, required this.title, required this.items, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        SizedBox(
          height: 390,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (context, _) => const SizedBox(width: 18),
            itemBuilder: (context, index) {
              final item = items[index];
              return PosterCard(
                title: item.title,
                posterPath: item.posterPath,
                subtitle: item.duration,
                onPressed: () => onPressed(item),
              );
            },
          ),
        ),
      ],
    );
  }
}
