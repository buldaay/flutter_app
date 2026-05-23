import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/media_category.dart';
import '../providers/library_provider.dart';
import '../screens/details_screen.dart';
import '../widgets/poster_card.dart';

class CategoryScreen extends StatelessWidget {
  static const routeName = '/category';

  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final category = ModalRoute.of(context)!.settings.arguments as MediaCategory;
    final library = context.watch<LibraryProvider>();
    final items = library.categoryItems(category);

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(category.name, style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 10),
                          Text('${items.length} titles • ${category.folderPath}', style: const TextStyle(color: Colors.white60, fontSize: 16)),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return PosterCard(
                      title: item.title,
                      posterPath: item.posterPath,
                      subtitle: item.duration,
                      onPressed: () => Navigator.pushNamed(context, DetailsScreen.routeName, arguments: item),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
