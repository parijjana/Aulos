import 'package:drift/drift.dart';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'podcast_database.g.dart';

class DiscoveredPodcasts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get iTunesId => text().unique()();
  TextColumn get title => text()();
  TextColumn get artist => text()();
  TextColumn get feedUrl => text()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get firstSeen => dateTime().withDefault(currentDateAndTime)();
}

class DiscoveredEpisodes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get iTunesId => text().references(DiscoveredPodcasts, #iTunesId)();
  TextColumn get title => text()();
  TextColumn get audioUrl => text()();
  DateTimeColumn get pubDate => dateTime().nullable()();
}

class DiscoveryCategoryRelations extends Table {
  TextColumn get iTunesId => text().references(DiscoveredPodcasts, #iTunesId)();
  TextColumn get categoryId => text()();
  
  @override
  Set<Column> get primaryKey => {iTunesId, categoryId};
}

class DiscoveryLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get lastRun => dateTime()();
  IntColumn get fetchCount => integer()();
  TextColumn get status => text()(); 
}

@DriftDatabase(tables: [Podcasts, Episodes, DiscoveredPodcasts, DiscoveredEpisodes, DiscoveryCategoryRelations, DiscoveryLogs])
class PodcastDatabase extends _$PodcastDatabase {
  PodcastDatabase([String? basePath]) : super(_openConnection(basePath));
  PodcastDatabase.testing(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        for (final table in allTables) {
          await m.deleteTable(table.actualTableName);
        }
        await m.createAll();
      }
    },
  );

  // Active Podcast Subscriptions CRUD
  Future<void> addPodcast(PodcastsCompanion podcast) =>
      into(podcasts).insert(podcast, mode: InsertMode.insertOrIgnore);

  Future<void> updatePodcast(String id, PodcastsCompanion podcast) =>
      (update(podcasts)..where((p) => p.id.equals(id))).write(podcast);

  Future<void> deletePodcast(String id) async {
    await transaction(() async {
      await (delete(episodes)..where((e) => e.podcastId.equals(id))).go();
      await (delete(podcasts)..where((p) => p.id.equals(id))).go();
    });
  }

  Future<List<Podcast>> getAllPodcasts() => select(podcasts).get();

  Future<Podcast?> getPodcastByFeedUrl(String url) =>
      (select(podcasts)..where((p) => p.feedUrl.equals(url))).getSingleOrNull();

  Future<void> addEpisodes(List<EpisodesCompanion> companions) async {
    await batch((b) {
      for (final companion in companions) {
        b.insert(
          episodes,
          companion,
          onConflict: DoUpdate(
            (old) => EpisodesCompanion(
              pubDate: companion.pubDate,
              title: companion.title,
              description: companion.description,
              durationSeconds: companion.durationSeconds,
            ),
            target: [episodes.guid],
          ),
        );
      }
    });
  }

  Future<List<Episode>> getEpisodesForPodcast(String podcastId) =>
      (select(episodes)
            ..where((e) => e.podcastId.equals(podcastId))
            ..orderBy([
              (e) => OrderingTerm(expression: e.pubDate, mode: OrderingMode.desc),
            ]))
          .get();

  Future<void> updateEpisodePlayback(
    String id, {
    int? positionSeconds,
    bool? isPlayed,
    int? downloadState,
    String? localFilePath,
    bool? isPinned,
  }) {
    return (update(episodes)..where((e) => e.id.equals(id))).write(
      EpisodesCompanion(
        playbackPositionSeconds: positionSeconds != null ? Value(positionSeconds) : const Value.absent(),
        isPlayed: isPlayed != null ? Value(isPlayed) : const Value.absent(),
        downloadState: downloadState != null ? Value(downloadState) : const Value.absent(),
        localFilePath: localFilePath != null ? Value(localFilePath) : const Value.absent(),
        isPinned: isPinned != null ? Value(isPinned) : const Value.absent(),
      ),
    );
  }

  Future<void> setPodcastFavorite(String id, bool favorite) =>
      (update(podcasts)..where((t) => t.id.equals(id)))
          .write(PodcastsCompanion(isFavorite: Value(favorite)));

  Stream<List<Podcast>> watchFavoritePodcasts() =>
      (select(podcasts)..where((t) => t.isFavorite.equals(true))).watch();


  // Podcast Discovery Cache CRUD (from DiscoveryDatabase)
  Future<void> upsertPodcasts(List<DiscoveredPodcastsCompanion> items, String categoryId) async {
    await (delete(discoveryCategoryRelations)..where((t) => t.categoryId.equals(categoryId))).go();
    await batch((b) {
      b.insertAll(discoveredPodcasts, items, mode: InsertMode.insertOrReplace);
    });
    await batch((b) {
      for (var p in items) {
        final id = p.iTunesId.value;
        b.insert(
          discoveryCategoryRelations,
          DiscoveryCategoryRelationsCompanion.insert(
            iTunesId: id,
            categoryId: categoryId,
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

  Future<void> upsertEpisodes(List<DiscoveredEpisodesCompanion> items) async {
    await batch((b) {
      b.insertAll(discoveredEpisodes, items, mode: InsertMode.insertOrReplace);
    });
  }

  Future<void> clearAll() async {
    await delete(discoveryCategoryRelations).go();
    await delete(discoveredEpisodes).go();
    await delete(discoveredPodcasts).go();
    await delete(discoveryLogs).go();
  }

  Stream<List<DiscoveredEpisode>> watchEpisodes(String iTunesId) {
    return (select(discoveredEpisodes)
          ..where((t) => t.iTunesId.equals(iTunesId))
          ..orderBy([(t) => OrderingTerm.desc(t.pubDate)])
          ..limit(5))
        .watch();
  }

  Stream<DiscoveredPodcast?> watchByITunesId(String id) {
    return (select(discoveredPodcasts)..where((t) => t.iTunesId.equals(id))).watchSingleOrNull();
  }

  Stream<List<DiscoveredPodcast>> watchByCategory(String catId, {int limit = 50}) {
    final query = select(discoveredPodcasts).join([
      innerJoin(discoveryCategoryRelations, discoveryCategoryRelations.iTunesId.equalsExp(discoveredPodcasts.iTunesId)),
    ])
      ..where(discoveryCategoryRelations.categoryId.equals(catId))
      ..orderBy([OrderingTerm.desc(discoveredPodcasts.id)])
      ..limit(limit);

    return query.watch().map((rows) => rows.map((r) => r.readTable(discoveredPodcasts)).toList());
  }

  Future<void> linkPodcastToCategories(String iTunesId, List<String> categories) async {
    await batch((b) {
      b.insertAll(
        discoveryCategoryRelations,
        categories.map((c) => DiscoveryCategoryRelationsCompanion.insert(iTunesId: iTunesId, categoryId: c)).toList(),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<List<String>> getCategoriesForPodcast(String iTunesId) async {
    final query = select(discoveryCategoryRelations)..where((t) => t.iTunesId.equals(iTunesId));
    final list = await query.get();
    return list.map((e) => e.categoryId).toList();
  }

  Future<List<DiscoveredPodcast>> getTrendingPodcasts() async {
    return (select(discoveredPodcasts)
          ..orderBy([(t) => OrderingTerm.desc(t.firstSeen)])
          ..limit(20))
        .get();
  }

  Future<List<DiscoveredPodcast>> getDiscoveredPodcasts(List<String> iTunesIds) {
    return (select(discoveredPodcasts)..where((t) => t.iTunesId.isIn(iTunesIds))).get();
  }

  Future<List<DiscoveredPodcast>> search(String query, {int limit = 20, int offset = 0}) {
    return (select(discoveredPodcasts)
          ..where((t) => t.title.contains(query) | t.artist.contains(query))
          ..limit(limit, offset: offset))
        .get();
  }

  Future<DiscoveredPodcast?> getByITunesId(String id) {
    return (select(discoveredPodcasts)..where((t) => t.iTunesId.equals(id))).getSingleOrNull();
  }

  Future<DiscoveryLog?> getLastSuccessfulRun() {
    return (select(discoveryLogs)
          ..where((t) => t.status.equals('success'))
          ..orderBy([(t) => OrderingTerm.desc(t.lastRun)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<int> logRun(DateTime time, int count, String status) {
    return into(discoveryLogs).insert(
      DiscoveryLogsCompanion.insert(
        lastRun: time,
        fetchCount: count,
        status: status,
      ),
    );
  }
}

LazyDatabase _openConnection(String? basePath) {
  return LazyDatabase(() async {
    final path = basePath ?? (await getApplicationSupportDirectory()).path;
    final file = File(p.join(path, 'podcast_database.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
