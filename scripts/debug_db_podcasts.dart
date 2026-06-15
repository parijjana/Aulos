import 'package:aulos/data/database/app_database.dart';
import 'package:drift/native.dart';
import 'dart:io';

void main() async {
  final file = File('C:/Users/anime/AppData/Roaming/localaudio.sqlite');
  if (!file.existsSync()) {
    print('Database not found at ${file.path}');
    return;
  }

  final db = AppDatabase.testing(NativeDatabase(file));
  
  final podcasts = await db.getAllPodcasts();
  print('SUBSCRIBED PODCASTS: ${podcasts.length}');
  for (var p in podcasts) {
    print('- ${p.title} (ID: ${p.id})');
  }

  final episodes = await db.select(db.episodes).get();
  print('\nTOTAL EPISODES: ${episodes.length}');

  final tracks = await db.select(db.tracks).get();
  print('\nTOTAL TRACKS: ${tracks.length}');
  
  final books = await db.getAudiobooks();
  print('\nAUDIOBOOKS: ${books.length}');

  await db.close();
}
