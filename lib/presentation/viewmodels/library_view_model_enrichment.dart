import 'dart:async';
import 'package:drift/drift.dart' hide Column;
import 'package:http/http.dart' as http;
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/data/database/audiobook_database.dart';
import 'package:aulos/data/library/persistent_library_service.dart';
import 'package:aulos/core/utils/id_generator.dart';
import 'library_view_model.dart';

extension LibraryViewModelEnrichment on LibraryViewModel {
  Future<void> enrichAudiobook(Album book) async {
    isLoading = true;
    triggerNotify();
    try {
      // 1. Search if no ASIN
      String? asin = book.asin;
      if (asin == null || asin.isEmpty) {
        // CLEAN TITLE FOR BETTER SEARCH
        String cleanTitle = book.name
            .replaceAll(RegExp(r'\(.*?\)', caseSensitive: false), '') // Remove (Unabridged), (Cradle, Book 9)
            .replaceAll(RegExp(r'\[.*?\]', caseSensitive: false), '')
            .replaceAll(RegExp(r'unabridged', caseSensitive: false), '')
            .trim();
        
        String searchQuery = cleanTitle;
        
        // ADD AUTHOR TO SEARCH IF AVAILABLE
        final audiobookDb = (libraryService as PersistentLibraryServiceImpl).audiobookDb;
        if (book.artistId != null) {
          final artist = await (audiobookDb.select(audiobookDb.audiobookArtists)..where((a) => a.id.equals(book.artistId!))).getSingleOrNull();
          if (artist != null && artist.name != 'Unknown Artist') {
            searchQuery = '$cleanTitle ${artist.name}';
          }
        }

        log('AUDNEXUS: Optimized search query: "$searchQuery"');
        final searchResult = await audnexus.searchBook(searchQuery);
        asin = searchResult?['asin'] as String?;
      }

      if (asin == null) {
        log('AUDNEXUS: No ASIN found for "${book.name}". Enrichment aborted.');
        return;
      }

      // 2. Fetch Full Metadata
      final meta = await audnexus.getBookMetadata(asin);
      if (meta != null) {
        final description = meta['description'] as String?;
        final narrators = (meta['narrators'] as List?)?.join(', ');
        final subtitle = meta['subtitle'] as String?;
        final publisher = meta['publisher'] as String?;
        final publishedDate = meta['publishedDate'] != null ? DateTime.tryParse(meta['publishedDate'] as String) : null;
        
        // Series
        String? seriesName;
        int? seriesPosition;
        final seriesList = meta['series'] as List?;
        if (seriesList != null && seriesList.isNotEmpty) {
          final sMap = seriesList.first as Map;
          seriesName = sMap['name'] as String?;
          seriesPosition = int.tryParse(sMap['position']?.toString() ?? '') ?? int.tryParse(sMap['sequence']?.toString() ?? '');
        }

        final image = meta['image'] as String?;
        final audiobookDb = (libraryService as PersistentLibraryServiceImpl).audiobookDb;
        await (audiobookDb.update(audiobookDb.audiobooks)..where((a) => a.id.equals(book.id))).write(
          AudiobooksCompanion(
            asin: Value(asin),
            narrator: Value(narrators),
            subtitle: Value(subtitle),
            description: Value(description),
            publisher: Value(publisher),
            publishedDate: Value(publishedDate),
            seriesName: Value(seriesName),
            seriesPosition: Value(seriesPosition),
            coverArtUrl: Value(image),
          ),
        );

        // Fetch author details if available
        if (meta['authors'] != null && (meta['authors'] as List).isNotEmpty && book.artistId != null) {
          final authorName = (meta['authors'] as List).first as String;
          log('AUDNEXUS: Fetching metadata for author "$authorName"');
          final authorMeta = await audnexus.getAuthorMetadata(authorName);
          if (authorMeta != null) {
            final bio = authorMeta['description'] as String?;
            final photoUrl = authorMeta['image'] as String?;
            await (audiobookDb.update(audiobookDb.audiobookArtists)..where((a) => a.id.equals(book.artistId!))).write(
              AudiobookArtistsCompanion(
                bio: Value(bio),
                photoUrl: Value(photoUrl),
              ),
            );
            log('AUDNEXUS: Author metadata updated successfully.');
          }
        }

        // Fetch image if present and update audiobook cover art
        if (image != null && image.isNotEmpty) {
          log('AUDNEXUS: Fetching high-res cover art from $image');
          try {
            final response = await http.get(Uri.parse(image));
            if (response.statusCode == 200) {
              await (audiobookDb.update(audiobookDb.audiobooks)..where((a) => a.id.equals(book.id))).write(
                AudiobooksCompanion(
                  coverArt: Value(response.bodyBytes),
                  coverArtUrl: Value(image),
                ),
              );
              log('AUDNEXUS: Cover art updated successfully.');
            }
          } catch (e) {
            log('AUDNEXUS: Failed to download cover art: $e');
          }
        }

        // Fetch chapters if available
        final chs = await audnexus.getChapters(asin);
        if (chs.isNotEmpty) {
          log('AUDNEXUS: Enriching chapters/tracks from Audnexus API.');
          final existingTracks = await audiobookDb.getTracksForBook(book.id);
          if (existingTracks.isNotEmpty) {
            final List<AudiobookChaptersCompanion> companions = [];
            if (existingTracks.length == 1) {
              final track = existingTracks.first;
              for (final ch in chs) {
                final title = ch['title'] as String? ?? 'Unknown Chapter';
                final startMs = int.tryParse(ch['startOffsetMs']?.toString() ?? '') ?? 0;
                final durationMs = int.tryParse(ch['lengthMs']?.toString() ?? '');
                final chId = generateContentId('${track.id}|$title|$startMs');
                companions.add(
                  AudiobookChaptersCompanion.insert(
                    id: chId,
                    audiobookTrackId: track.id,
                    title: title,
                    startTimeMs: startMs,
                    durationMs: Value(durationMs),
                  ),
                );
              }
            } else if (existingTracks.length == chs.length) {
              for (int i = 0; i < chs.length; i++) {
                final ch = chs[i] as Map;
                final title = ch['title'] as String? ?? 'Chapter ${i + 1}';
                final startMs = int.tryParse(ch['startOffsetMs']?.toString() ?? '') ?? 0;
                final durationMs = int.tryParse(ch['lengthMs']?.toString() ?? '');
                final track = existingTracks[i];
                final chId = generateContentId('${track.id}|$title|$startMs');
                companions.add(
                  AudiobookChaptersCompanion.insert(
                    id: chId,
                    audiobookTrackId: track.id,
                    title: title,
                    startTimeMs: startMs,
                    durationMs: Value(durationMs),
                  ),
                );
                // Also update track title
                await (audiobookDb.update(audiobookDb.audiobookTracks)..where((t) => t.id.equals(track.id))).write(
                  AudiobookTracksCompanion(title: Value(title)),
                );
              }
            }
            if (companions.isNotEmpty) {
              await audiobookDb.addChapters(companions);
            }
          }
        }

        log('AUDNEXUS: Enrichment complete.');
        if (selectedItem?.id == book.id) {
          final booksList = await libraryService.getAudiobooks();
          final updated = booksList.firstWhere((b) => b.id == book.id, orElse: () => book);
          states[mode]?.selectedItem = updated;
        }
        await reloadLibrary();
      }
    } catch (e, stack) {
      print('AUDNEXUS_ERROR: Enrichment failed: $e');
      print(stack);
      log('AUDNEXUS_ERROR: Enrichment failed: $e');
    } finally {
      isLoading = false;
      triggerNotify();
    }
  }
}
