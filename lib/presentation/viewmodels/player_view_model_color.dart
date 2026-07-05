import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'player_view_model.dart';

extension PlayerViewModelColor on PlayerViewModel {
  Future<void> extractColorFromMemory(Uint8List art) async {
    final provider = MemoryImage(art);
    currentPalette = await PaletteGenerator.fromImageProvider(provider, maximumColorCount: 10);
    extractedColor = currentPalette?.vibrantColor?.color ?? currentPalette?.dominantColor?.color;
    triggerNotify();
  }

  Future<void> extractColorFromUrl(String url) async {
    final provider = NetworkImage(url);
    currentPalette = await PaletteGenerator.fromImageProvider(provider, maximumColorCount: 10);
    extractedColor = currentPalette?.vibrantColor?.color ?? currentPalette?.dominantColor?.color;
    triggerNotify();
  }
}
