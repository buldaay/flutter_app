import 'dart:io';

import 'package:flutter/material.dart';

class PosterCard extends StatefulWidget {
  final String title;
  final String? posterPath;
  final String subtitle;
  final VoidCallback onPressed;

  const PosterCard({super.key, required this.title, this.posterPath, required this.subtitle, required this.onPressed});

  @override
  State<PosterCard> createState() => _PosterCardState();
}

class _PosterCardState extends State<PosterCard> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focus) => setState(() => _focused = focus),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          width: 210,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: _focused
                ? [BoxShadow(color: const Color.fromRGBO(255, 0, 0, 0.4), blurRadius: 24, offset: const Offset(0, 14))]
                : [BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.25), blurRadius: 16, offset: const Offset(0, 10))],
            border: Border.all(color: _focused ? Colors.redAccent : Colors.white12, width: _focused ? 2 : 1),
            color: const Color(0xFF141823),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: SizedBox(
                  height: 300,
                  child: widget.posterPath != null && widget.posterPath!.isNotEmpty
                      ? Image.file(File(widget.posterPath!), fit: BoxFit.cover)
                      : Container(
                          color: const Color(0xFF1F222F),
                          child: const Center(
                            child: Icon(Icons.movie, size: 64, color: Colors.white24),
                          ),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 6),
                    Text(widget.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
