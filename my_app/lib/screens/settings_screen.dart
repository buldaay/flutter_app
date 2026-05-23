import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/library_provider.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Settings', style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.white)),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                _settingsItem(
                  title: 'Main media folder',
                  subtitle: library.mainFolderPath ?? 'No folder selected',
                  actionLabel: library.mainFolderPath != null ? 'Change' : 'Choose',
                  onAction: () => library.chooseFolder(),
                ),
                const SizedBox(height: 18),
                _settingsItem(
                  title: 'VLC status',
                  subtitle: library.vlcInstalled ? 'VLC is installed' : 'VLC is not detected',
                  actionLabel: 'Install',
                  onAction: () {},
                ),
                const SizedBox(height: 18),
                _settingsItem(
                  title: 'Storage access',
                  subtitle: library.permissionGranted ? 'Granted' : 'Not granted',
                  actionLabel: 'Grant',
                  onAction: () => library.requestStoragePermission(),
                ),
                const SizedBox(height: 18),
                _settingsItem(
                  title: 'Grid layout',
                  subtitle: '${library.gridColumns} columns',
                  actionLabel: 'Adjust',
                  onAction: () => _showGridSlider(context, library),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: library.scanning ? null : library.scanLibrary,
                  icon: const Icon(Icons.refresh),
                  label: Text(library.scanning ? 'Rescanning library…' : 'Rescan library'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18)),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => library.clearLibrary(),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Clear library'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2A2E3B), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18)),
                ),
                const SizedBox(height: 32),
                const Text('App preferences', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white70)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(color: const Color(0xFF10131A), borderRadius: BorderRadius.circular(22)),
                  child: const Text(
                    'Cinema Shelf is built for Android TV. It scans one selected folder and organizes your videos into clean category rows. Streaming is disabled — videos open in VLC for playback.',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _settingsItem({
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF10131A), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 15)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _showGridSlider(BuildContext context, LibraryProvider library) async {
    final value = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        int current = library.gridColumns;
        return AlertDialog(
          backgroundColor: const Color(0xFF11131A),
          title: const Text('Grid size', style: TextStyle(color: Colors.white)),
          content: StatefulBuilder(builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  min: 3,
                  max: 6,
                  divisions: 3,
                  label: '$current columns',
                  value: current.toDouble(),
                  activeColor: Colors.redAccent,
                  inactiveColor: Colors.white24,
                  onChanged: (valueChanged) => setState(() => current = valueChanged.round()),
                ),
                Text('$current columns', style: const TextStyle(color: Colors.white70)),
              ],
            );
          }),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
            ElevatedButton(onPressed: () => Navigator.pop(dialogContext, current), child: const Text('Save')),
          ],
        );
      },
    );

    if (value != null) {
      await library.setGridColumns(value);
    }
  }
}
