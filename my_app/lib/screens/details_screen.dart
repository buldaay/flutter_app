import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/media_item.dart';
import '../providers/library_provider.dart';

class DetailsScreen extends StatelessWidget {
  static const routeName = '/details';

  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final item = ModalRoute.of(context)!.settings.arguments as MediaItem;
    final library = context.watch<LibraryProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF050608), Color(0xFF12151F)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.title, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              const BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.45), blurRadius: 22, offset: Offset(0, 14)),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: item.posterPath != null && item.posterPath!.isNotEmpty
                                ? Image.file(File(item.posterPath!), fit: BoxFit.cover)
                                : Container(
                                    color: const Color(0xFF1E1F29),
                                    child: const Center(
                                      child: Icon(Icons.movie, size: 96, color: Colors.white24),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 28),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 14),
                            _detailRow('Duration', item.duration),
                            const SizedBox(height: 10),
                            _detailRow('Category', item.categoryPath.split(RegExp(r'[\\/]+')).last),
                            const SizedBox(height: 10),
                            _detailRow('Added', '${item.addedAt.year}-${item.addedAt.month.toString().padLeft(2, '0')}-${item.addedAt.day.toString().padLeft(2, '0')}'),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => library.playItem(item),
                              icon: const Icon(Icons.play_circle_fill),
                              label: const Text('Play with VLC', style: TextStyle(fontSize: 18)),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20)),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => library.toggleFavorite(item),
                              icon: Icon(item.isFavorite ? Icons.favorite : Icons.favorite_border),
                              label: Text(item.isFavorite ? 'Remove favorite' : 'Mark favorite', style: const TextStyle(fontSize: 18)),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1F1F28), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      children: [
        Text('$label:', style: const TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600))),
      ],
    );
  }
}
