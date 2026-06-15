class Bookmark {
  final String id;
  final String trackPath;
  final String title;
  final int startTimeMs;
  final int? endTimeMs;
  final String? tags;
  final String? notes;
  final int? contextType;

  Bookmark({
    required this.id,
    required this.trackPath,
    required this.title,
    required this.startTimeMs,
    this.endTimeMs,
    this.tags,
    this.notes,
    this.contextType,
  });
}
