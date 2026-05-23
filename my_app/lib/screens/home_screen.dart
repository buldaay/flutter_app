import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/media_category.dart';
import '../models/media_item.dart';
import '../providers/library_provider.dart';
import '../screens/category_screen.dart';
import '../screens/details_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/media_row.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final categories = library.visibleCategories;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF040509), Color(0xFF12151F)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      if (library.continueWatching.isNotEmpty)
                        _buildSection(context, 'Continue Watching', library.continueWatching),
                      if (library.favorites.isNotEmpty)
                        _buildSection(context, 'Favorites', library.favorites),
                      if (library.recentlyAdded.isNotEmpty)
                        _buildSection(context, 'Recently Added', library.recentlyAdded),
                      for (final category in categories)
                        _buildCategorySection(context, category, library.categoryItems(category)),
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Text(
            'Cinema Shelf',
            style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, SettingsScreen.routeName),
          icon: const Icon(Icons.settings),
          label: const Text('Settings'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1F1F28),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, List<MediaItem> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: MediaRow(
        title: title,
        items: items,
        onPressed: (item) => Navigator.pushNamed(context, DetailsScreen.routeName, arguments: item),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, MediaCategory category, List<MediaItem> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, CategoryScreen.routeName, arguments: category),
                child: const Text('See all', style: TextStyle(color: Colors.redAccent, fontSize: 16)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          MediaRow(
            title: category.name,
            items: items,
            onPressed: (item) => Navigator.pushNamed(context, DetailsScreen.routeName, arguments: item),
          ),
        ],
      ),
    );
  }
}
