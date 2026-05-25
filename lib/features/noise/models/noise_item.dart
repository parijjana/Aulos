import 'package:flutter/material.dart';

enum NoiseCategory { nature, urban, industrial, binaural }

class NoiseItem {
  final String id;
  final String title;
  final String url;
  final NoiseCategory category;
  final IconData icon;
  final Color? color;
  final String source;
  final String? author;

  const NoiseItem({
    required this.id,
    required this.title,
    required this.url,
    required this.category,
    required this.icon,
    required this.source,
    this.author,
    this.color,
  });
}
