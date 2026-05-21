import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'podcast_dao.g.dart';

@DriftAccessor(tables: [Podcasts, Episodes])
class PodcastDao extends DatabaseAccessor<AppDatabase> with _$PodcastDaoMixin {
  PodcastDao(AppDatabase db) : super(db);

  Future<int> addPodcast(PodcastsCompanion podcast) =>
      into(podcasts).insert(podcast, mode: InsertMode.insertOrIgnore);

  Future<void> updatePodcast(int id, PodcastsCompanion podcast) =>
      (update(podcasts)..where((p) => p.id.equals(id))).write(podcast);

  Future<void> deletePodcast(int id) async {
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
      b.insertAll(episodes, companions, mode: InsertMode.insertOrIgnore);
    });
  }

  Future<List<Episode>> getEpisodesForPodcast(int podcastId) =>
      (select(episodes)
            ..where((e) => e.podcastId.equals(podcastId))
            ..orderBy([
              (e) => OrderingTerm(expression: e.pubDate, mode: OrderingMode.desc),
            ]))
          .get();

  Future<void> updateEpisodePlayback(
    int id, {
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
}
