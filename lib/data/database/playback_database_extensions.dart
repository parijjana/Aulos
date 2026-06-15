import 'package:aulos/domain/library/bookmark.dart' as dom_bookmark;
import 'playback_database.dart';

extension BookmarkToDomain on Bookmark {
  dom_bookmark.Bookmark toDomain() {
    return dom_bookmark.Bookmark(
      id: id,
      trackPath: trackPath,
      title: title,
      startTimeMs: startTimeMs,
      endTimeMs: endTimeMs,
      tags: tags,
      notes: notes,
      contextType: contextType,
    );
  }
}
