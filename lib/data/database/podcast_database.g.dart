// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_database.dart';

// ignore_for_file: type=lint
class $PodcastsTable extends Podcasts with TableInfo<$PodcastsTable, Podcast> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PodcastsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feedUrlMeta = const VerificationMeta(
    'feedUrl',
  );
  @override
  late final GeneratedColumn<String> feedUrl = GeneratedColumn<String>(
    'feed_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<Uint8List> image = GeneratedColumn<Uint8List>(
    'image',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subscribedAtMeta = const VerificationMeta(
    'subscribedAt',
  );
  @override
  late final GeneratedColumn<DateTime> subscribedAt = GeneratedColumn<DateTime>(
    'subscribed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _playCountMeta = const VerificationMeta(
    'playCount',
  );
  @override
  late final GeneratedColumn<int> playCount = GeneratedColumn<int>(
    'play_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastPlayedMeta = const VerificationMeta(
    'lastPlayed',
  );
  @override
  late final GeneratedColumn<DateTime> lastPlayed = GeneratedColumn<DateTime>(
    'last_played',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    feedUrl,
    title,
    description,
    author,
    imageUrl,
    image,
    subscribedAt,
    isFavorite,
    playCount,
    lastPlayed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'podcasts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Podcast> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('feed_url')) {
      context.handle(
        _feedUrlMeta,
        feedUrl.isAcceptableOrUnknown(data['feed_url']!, _feedUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_feedUrlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('image')) {
      context.handle(
        _imageMeta,
        image.isAcceptableOrUnknown(data['image']!, _imageMeta),
      );
    }
    if (data.containsKey('subscribed_at')) {
      context.handle(
        _subscribedAtMeta,
        subscribedAt.isAcceptableOrUnknown(
          data['subscribed_at']!,
          _subscribedAtMeta,
        ),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('play_count')) {
      context.handle(
        _playCountMeta,
        playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta),
      );
    }
    if (data.containsKey('last_played')) {
      context.handle(
        _lastPlayedMeta,
        lastPlayed.isAcceptableOrUnknown(data['last_played']!, _lastPlayedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Podcast map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Podcast(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      feedUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_url'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      image: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}image'],
      ),
      subscribedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}subscribed_at'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      playCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_count'],
      )!,
      lastPlayed: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_played'],
      ),
    );
  }

  @override
  $PodcastsTable createAlias(String alias) {
    return $PodcastsTable(attachedDatabase, alias);
  }
}

class Podcast extends DataClass implements Insertable<Podcast> {
  final String id;
  final String feedUrl;
  final String title;
  final String? description;
  final String? author;
  final String? imageUrl;
  final Uint8List? image;
  final DateTime subscribedAt;
  final bool isFavorite;
  final int playCount;
  final DateTime? lastPlayed;
  const Podcast({
    required this.id,
    required this.feedUrl,
    required this.title,
    this.description,
    this.author,
    this.imageUrl,
    this.image,
    required this.subscribedAt,
    required this.isFavorite,
    required this.playCount,
    this.lastPlayed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['feed_url'] = Variable<String>(feedUrl);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || image != null) {
      map['image'] = Variable<Uint8List>(image);
    }
    map['subscribed_at'] = Variable<DateTime>(subscribedAt);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['play_count'] = Variable<int>(playCount);
    if (!nullToAbsent || lastPlayed != null) {
      map['last_played'] = Variable<DateTime>(lastPlayed);
    }
    return map;
  }

  PodcastsCompanion toCompanion(bool nullToAbsent) {
    return PodcastsCompanion(
      id: Value(id),
      feedUrl: Value(feedUrl),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      author: author == null && nullToAbsent
          ? const Value.absent()
          : Value(author),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      image: image == null && nullToAbsent
          ? const Value.absent()
          : Value(image),
      subscribedAt: Value(subscribedAt),
      isFavorite: Value(isFavorite),
      playCount: Value(playCount),
      lastPlayed: lastPlayed == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayed),
    );
  }

  factory Podcast.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Podcast(
      id: serializer.fromJson<String>(json['id']),
      feedUrl: serializer.fromJson<String>(json['feedUrl']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      author: serializer.fromJson<String?>(json['author']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      image: serializer.fromJson<Uint8List?>(json['image']),
      subscribedAt: serializer.fromJson<DateTime>(json['subscribedAt']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      playCount: serializer.fromJson<int>(json['playCount']),
      lastPlayed: serializer.fromJson<DateTime?>(json['lastPlayed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'feedUrl': serializer.toJson<String>(feedUrl),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'author': serializer.toJson<String?>(author),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'image': serializer.toJson<Uint8List?>(image),
      'subscribedAt': serializer.toJson<DateTime>(subscribedAt),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'playCount': serializer.toJson<int>(playCount),
      'lastPlayed': serializer.toJson<DateTime?>(lastPlayed),
    };
  }

  Podcast copyWith({
    String? id,
    String? feedUrl,
    String? title,
    Value<String?> description = const Value.absent(),
    Value<String?> author = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    Value<Uint8List?> image = const Value.absent(),
    DateTime? subscribedAt,
    bool? isFavorite,
    int? playCount,
    Value<DateTime?> lastPlayed = const Value.absent(),
  }) => Podcast(
    id: id ?? this.id,
    feedUrl: feedUrl ?? this.feedUrl,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    author: author.present ? author.value : this.author,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    image: image.present ? image.value : this.image,
    subscribedAt: subscribedAt ?? this.subscribedAt,
    isFavorite: isFavorite ?? this.isFavorite,
    playCount: playCount ?? this.playCount,
    lastPlayed: lastPlayed.present ? lastPlayed.value : this.lastPlayed,
  );
  Podcast copyWithCompanion(PodcastsCompanion data) {
    return Podcast(
      id: data.id.present ? data.id.value : this.id,
      feedUrl: data.feedUrl.present ? data.feedUrl.value : this.feedUrl,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      author: data.author.present ? data.author.value : this.author,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      image: data.image.present ? data.image.value : this.image,
      subscribedAt: data.subscribedAt.present
          ? data.subscribedAt.value
          : this.subscribedAt,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
      lastPlayed: data.lastPlayed.present
          ? data.lastPlayed.value
          : this.lastPlayed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Podcast(')
          ..write('id: $id, ')
          ..write('feedUrl: $feedUrl, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('author: $author, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('image: $image, ')
          ..write('subscribedAt: $subscribedAt, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('playCount: $playCount, ')
          ..write('lastPlayed: $lastPlayed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    feedUrl,
    title,
    description,
    author,
    imageUrl,
    $driftBlobEquality.hash(image),
    subscribedAt,
    isFavorite,
    playCount,
    lastPlayed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Podcast &&
          other.id == this.id &&
          other.feedUrl == this.feedUrl &&
          other.title == this.title &&
          other.description == this.description &&
          other.author == this.author &&
          other.imageUrl == this.imageUrl &&
          $driftBlobEquality.equals(other.image, this.image) &&
          other.subscribedAt == this.subscribedAt &&
          other.isFavorite == this.isFavorite &&
          other.playCount == this.playCount &&
          other.lastPlayed == this.lastPlayed);
}

class PodcastsCompanion extends UpdateCompanion<Podcast> {
  final Value<String> id;
  final Value<String> feedUrl;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> author;
  final Value<String?> imageUrl;
  final Value<Uint8List?> image;
  final Value<DateTime> subscribedAt;
  final Value<bool> isFavorite;
  final Value<int> playCount;
  final Value<DateTime?> lastPlayed;
  final Value<int> rowid;
  const PodcastsCompanion({
    this.id = const Value.absent(),
    this.feedUrl = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.author = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.image = const Value.absent(),
    this.subscribedAt = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.playCount = const Value.absent(),
    this.lastPlayed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PodcastsCompanion.insert({
    required String id,
    required String feedUrl,
    required String title,
    this.description = const Value.absent(),
    this.author = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.image = const Value.absent(),
    this.subscribedAt = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.playCount = const Value.absent(),
    this.lastPlayed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       feedUrl = Value(feedUrl),
       title = Value(title);
  static Insertable<Podcast> custom({
    Expression<String>? id,
    Expression<String>? feedUrl,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? author,
    Expression<String>? imageUrl,
    Expression<Uint8List>? image,
    Expression<DateTime>? subscribedAt,
    Expression<bool>? isFavorite,
    Expression<int>? playCount,
    Expression<DateTime>? lastPlayed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (feedUrl != null) 'feed_url': feedUrl,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (author != null) 'author': author,
      if (imageUrl != null) 'image_url': imageUrl,
      if (image != null) 'image': image,
      if (subscribedAt != null) 'subscribed_at': subscribedAt,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (playCount != null) 'play_count': playCount,
      if (lastPlayed != null) 'last_played': lastPlayed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PodcastsCompanion copyWith({
    Value<String>? id,
    Value<String>? feedUrl,
    Value<String>? title,
    Value<String?>? description,
    Value<String?>? author,
    Value<String?>? imageUrl,
    Value<Uint8List?>? image,
    Value<DateTime>? subscribedAt,
    Value<bool>? isFavorite,
    Value<int>? playCount,
    Value<DateTime?>? lastPlayed,
    Value<int>? rowid,
  }) {
    return PodcastsCompanion(
      id: id ?? this.id,
      feedUrl: feedUrl ?? this.feedUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      author: author ?? this.author,
      imageUrl: imageUrl ?? this.imageUrl,
      image: image ?? this.image,
      subscribedAt: subscribedAt ?? this.subscribedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      playCount: playCount ?? this.playCount,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (feedUrl.present) {
      map['feed_url'] = Variable<String>(feedUrl.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (image.present) {
      map['image'] = Variable<Uint8List>(image.value);
    }
    if (subscribedAt.present) {
      map['subscribed_at'] = Variable<DateTime>(subscribedAt.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    if (lastPlayed.present) {
      map['last_played'] = Variable<DateTime>(lastPlayed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PodcastsCompanion(')
          ..write('id: $id, ')
          ..write('feedUrl: $feedUrl, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('author: $author, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('image: $image, ')
          ..write('subscribedAt: $subscribedAt, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('playCount: $playCount, ')
          ..write('lastPlayed: $lastPlayed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EpisodesTable extends Episodes with TableInfo<$EpisodesTable, Episode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EpisodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _podcastIdMeta = const VerificationMeta(
    'podcastId',
  );
  @override
  late final GeneratedColumn<String> podcastId = GeneratedColumn<String>(
    'podcast_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES podcasts (id)',
    ),
  );
  static const VerificationMeta _guidMeta = const VerificationMeta('guid');
  @override
  late final GeneratedColumn<String> guid = GeneratedColumn<String>(
    'guid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioUrlMeta = const VerificationMeta(
    'audioUrl',
  );
  @override
  late final GeneratedColumn<String> audioUrl = GeneratedColumn<String>(
    'audio_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localFilePathMeta = const VerificationMeta(
    'localFilePath',
  );
  @override
  late final GeneratedColumn<String> localFilePath = GeneratedColumn<String>(
    'local_file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _downloadStateMeta = const VerificationMeta(
    'downloadState',
  );
  @override
  late final GeneratedColumn<int> downloadState = GeneratedColumn<int>(
    'download_state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pubDateMeta = const VerificationMeta(
    'pubDate',
  );
  @override
  late final GeneratedColumn<DateTime> pubDate = GeneratedColumn<DateTime>(
    'pub_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPlayedMeta = const VerificationMeta(
    'isPlayed',
  );
  @override
  late final GeneratedColumn<bool> isPlayed = GeneratedColumn<bool>(
    'is_played',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_played" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isPinnedMeta = const VerificationMeta(
    'isPinned',
  );
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _playbackPositionSecondsMeta =
      const VerificationMeta('playbackPositionSeconds');
  @override
  late final GeneratedColumn<int> playbackPositionSeconds =
      GeneratedColumn<int>(
        'playback_position_seconds',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _playCountMeta = const VerificationMeta(
    'playCount',
  );
  @override
  late final GeneratedColumn<int> playCount = GeneratedColumn<int>(
    'play_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastPlayedMeta = const VerificationMeta(
    'lastPlayed',
  );
  @override
  late final GeneratedColumn<DateTime> lastPlayed = GeneratedColumn<DateTime>(
    'last_played',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _duplicateOfMeta = const VerificationMeta(
    'duplicateOf',
  );
  @override
  late final GeneratedColumn<String> duplicateOf = GeneratedColumn<String>(
    'duplicate_of',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    podcastId,
    guid,
    title,
    description,
    audioUrl,
    localFilePath,
    downloadState,
    pubDate,
    durationSeconds,
    isPlayed,
    isPinned,
    playbackPositionSeconds,
    playCount,
    lastPlayed,
    duplicateOf,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'episodes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Episode> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('podcast_id')) {
      context.handle(
        _podcastIdMeta,
        podcastId.isAcceptableOrUnknown(data['podcast_id']!, _podcastIdMeta),
      );
    } else if (isInserting) {
      context.missing(_podcastIdMeta);
    }
    if (data.containsKey('guid')) {
      context.handle(
        _guidMeta,
        guid.isAcceptableOrUnknown(data['guid']!, _guidMeta),
      );
    } else if (isInserting) {
      context.missing(_guidMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('audio_url')) {
      context.handle(
        _audioUrlMeta,
        audioUrl.isAcceptableOrUnknown(data['audio_url']!, _audioUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_audioUrlMeta);
    }
    if (data.containsKey('local_file_path')) {
      context.handle(
        _localFilePathMeta,
        localFilePath.isAcceptableOrUnknown(
          data['local_file_path']!,
          _localFilePathMeta,
        ),
      );
    }
    if (data.containsKey('download_state')) {
      context.handle(
        _downloadStateMeta,
        downloadState.isAcceptableOrUnknown(
          data['download_state']!,
          _downloadStateMeta,
        ),
      );
    }
    if (data.containsKey('pub_date')) {
      context.handle(
        _pubDateMeta,
        pubDate.isAcceptableOrUnknown(data['pub_date']!, _pubDateMeta),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('is_played')) {
      context.handle(
        _isPlayedMeta,
        isPlayed.isAcceptableOrUnknown(data['is_played']!, _isPlayedMeta),
      );
    }
    if (data.containsKey('is_pinned')) {
      context.handle(
        _isPinnedMeta,
        isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta),
      );
    }
    if (data.containsKey('playback_position_seconds')) {
      context.handle(
        _playbackPositionSecondsMeta,
        playbackPositionSeconds.isAcceptableOrUnknown(
          data['playback_position_seconds']!,
          _playbackPositionSecondsMeta,
        ),
      );
    }
    if (data.containsKey('play_count')) {
      context.handle(
        _playCountMeta,
        playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta),
      );
    }
    if (data.containsKey('last_played')) {
      context.handle(
        _lastPlayedMeta,
        lastPlayed.isAcceptableOrUnknown(data['last_played']!, _lastPlayedMeta),
      );
    }
    if (data.containsKey('duplicate_of')) {
      context.handle(
        _duplicateOfMeta,
        duplicateOf.isAcceptableOrUnknown(
          data['duplicate_of']!,
          _duplicateOfMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Episode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Episode(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      podcastId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}podcast_id'],
      )!,
      guid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guid'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      audioUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_url'],
      )!,
      localFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_file_path'],
      ),
      downloadState: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}download_state'],
      )!,
      pubDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}pub_date'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      isPlayed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_played'],
      )!,
      isPinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pinned'],
      )!,
      playbackPositionSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}playback_position_seconds'],
      )!,
      playCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_count'],
      )!,
      lastPlayed: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_played'],
      ),
      duplicateOf: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}duplicate_of'],
      ),
    );
  }

  @override
  $EpisodesTable createAlias(String alias) {
    return $EpisodesTable(attachedDatabase, alias);
  }
}

class Episode extends DataClass implements Insertable<Episode> {
  final String id;
  final String podcastId;
  final String guid;
  final String title;
  final String? description;
  final String audioUrl;
  final String? localFilePath;
  final int downloadState;
  final DateTime? pubDate;
  final int? durationSeconds;
  final bool isPlayed;
  final bool isPinned;
  final int playbackPositionSeconds;
  final int playCount;
  final DateTime? lastPlayed;
  final String? duplicateOf;
  const Episode({
    required this.id,
    required this.podcastId,
    required this.guid,
    required this.title,
    this.description,
    required this.audioUrl,
    this.localFilePath,
    required this.downloadState,
    this.pubDate,
    this.durationSeconds,
    required this.isPlayed,
    required this.isPinned,
    required this.playbackPositionSeconds,
    required this.playCount,
    this.lastPlayed,
    this.duplicateOf,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['podcast_id'] = Variable<String>(podcastId);
    map['guid'] = Variable<String>(guid);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['audio_url'] = Variable<String>(audioUrl);
    if (!nullToAbsent || localFilePath != null) {
      map['local_file_path'] = Variable<String>(localFilePath);
    }
    map['download_state'] = Variable<int>(downloadState);
    if (!nullToAbsent || pubDate != null) {
      map['pub_date'] = Variable<DateTime>(pubDate);
    }
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    map['is_played'] = Variable<bool>(isPlayed);
    map['is_pinned'] = Variable<bool>(isPinned);
    map['playback_position_seconds'] = Variable<int>(playbackPositionSeconds);
    map['play_count'] = Variable<int>(playCount);
    if (!nullToAbsent || lastPlayed != null) {
      map['last_played'] = Variable<DateTime>(lastPlayed);
    }
    if (!nullToAbsent || duplicateOf != null) {
      map['duplicate_of'] = Variable<String>(duplicateOf);
    }
    return map;
  }

  EpisodesCompanion toCompanion(bool nullToAbsent) {
    return EpisodesCompanion(
      id: Value(id),
      podcastId: Value(podcastId),
      guid: Value(guid),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      audioUrl: Value(audioUrl),
      localFilePath: localFilePath == null && nullToAbsent
          ? const Value.absent()
          : Value(localFilePath),
      downloadState: Value(downloadState),
      pubDate: pubDate == null && nullToAbsent
          ? const Value.absent()
          : Value(pubDate),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      isPlayed: Value(isPlayed),
      isPinned: Value(isPinned),
      playbackPositionSeconds: Value(playbackPositionSeconds),
      playCount: Value(playCount),
      lastPlayed: lastPlayed == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayed),
      duplicateOf: duplicateOf == null && nullToAbsent
          ? const Value.absent()
          : Value(duplicateOf),
    );
  }

  factory Episode.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Episode(
      id: serializer.fromJson<String>(json['id']),
      podcastId: serializer.fromJson<String>(json['podcastId']),
      guid: serializer.fromJson<String>(json['guid']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      audioUrl: serializer.fromJson<String>(json['audioUrl']),
      localFilePath: serializer.fromJson<String?>(json['localFilePath']),
      downloadState: serializer.fromJson<int>(json['downloadState']),
      pubDate: serializer.fromJson<DateTime?>(json['pubDate']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      isPlayed: serializer.fromJson<bool>(json['isPlayed']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      playbackPositionSeconds: serializer.fromJson<int>(
        json['playbackPositionSeconds'],
      ),
      playCount: serializer.fromJson<int>(json['playCount']),
      lastPlayed: serializer.fromJson<DateTime?>(json['lastPlayed']),
      duplicateOf: serializer.fromJson<String?>(json['duplicateOf']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'podcastId': serializer.toJson<String>(podcastId),
      'guid': serializer.toJson<String>(guid),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'audioUrl': serializer.toJson<String>(audioUrl),
      'localFilePath': serializer.toJson<String?>(localFilePath),
      'downloadState': serializer.toJson<int>(downloadState),
      'pubDate': serializer.toJson<DateTime?>(pubDate),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'isPlayed': serializer.toJson<bool>(isPlayed),
      'isPinned': serializer.toJson<bool>(isPinned),
      'playbackPositionSeconds': serializer.toJson<int>(
        playbackPositionSeconds,
      ),
      'playCount': serializer.toJson<int>(playCount),
      'lastPlayed': serializer.toJson<DateTime?>(lastPlayed),
      'duplicateOf': serializer.toJson<String?>(duplicateOf),
    };
  }

  Episode copyWith({
    String? id,
    String? podcastId,
    String? guid,
    String? title,
    Value<String?> description = const Value.absent(),
    String? audioUrl,
    Value<String?> localFilePath = const Value.absent(),
    int? downloadState,
    Value<DateTime?> pubDate = const Value.absent(),
    Value<int?> durationSeconds = const Value.absent(),
    bool? isPlayed,
    bool? isPinned,
    int? playbackPositionSeconds,
    int? playCount,
    Value<DateTime?> lastPlayed = const Value.absent(),
    Value<String?> duplicateOf = const Value.absent(),
  }) => Episode(
    id: id ?? this.id,
    podcastId: podcastId ?? this.podcastId,
    guid: guid ?? this.guid,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    audioUrl: audioUrl ?? this.audioUrl,
    localFilePath: localFilePath.present
        ? localFilePath.value
        : this.localFilePath,
    downloadState: downloadState ?? this.downloadState,
    pubDate: pubDate.present ? pubDate.value : this.pubDate,
    durationSeconds: durationSeconds.present
        ? durationSeconds.value
        : this.durationSeconds,
    isPlayed: isPlayed ?? this.isPlayed,
    isPinned: isPinned ?? this.isPinned,
    playbackPositionSeconds:
        playbackPositionSeconds ?? this.playbackPositionSeconds,
    playCount: playCount ?? this.playCount,
    lastPlayed: lastPlayed.present ? lastPlayed.value : this.lastPlayed,
    duplicateOf: duplicateOf.present ? duplicateOf.value : this.duplicateOf,
  );
  Episode copyWithCompanion(EpisodesCompanion data) {
    return Episode(
      id: data.id.present ? data.id.value : this.id,
      podcastId: data.podcastId.present ? data.podcastId.value : this.podcastId,
      guid: data.guid.present ? data.guid.value : this.guid,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      audioUrl: data.audioUrl.present ? data.audioUrl.value : this.audioUrl,
      localFilePath: data.localFilePath.present
          ? data.localFilePath.value
          : this.localFilePath,
      downloadState: data.downloadState.present
          ? data.downloadState.value
          : this.downloadState,
      pubDate: data.pubDate.present ? data.pubDate.value : this.pubDate,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      isPlayed: data.isPlayed.present ? data.isPlayed.value : this.isPlayed,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      playbackPositionSeconds: data.playbackPositionSeconds.present
          ? data.playbackPositionSeconds.value
          : this.playbackPositionSeconds,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
      lastPlayed: data.lastPlayed.present
          ? data.lastPlayed.value
          : this.lastPlayed,
      duplicateOf: data.duplicateOf.present
          ? data.duplicateOf.value
          : this.duplicateOf,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Episode(')
          ..write('id: $id, ')
          ..write('podcastId: $podcastId, ')
          ..write('guid: $guid, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('downloadState: $downloadState, ')
          ..write('pubDate: $pubDate, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('isPlayed: $isPlayed, ')
          ..write('isPinned: $isPinned, ')
          ..write('playbackPositionSeconds: $playbackPositionSeconds, ')
          ..write('playCount: $playCount, ')
          ..write('lastPlayed: $lastPlayed, ')
          ..write('duplicateOf: $duplicateOf')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    podcastId,
    guid,
    title,
    description,
    audioUrl,
    localFilePath,
    downloadState,
    pubDate,
    durationSeconds,
    isPlayed,
    isPinned,
    playbackPositionSeconds,
    playCount,
    lastPlayed,
    duplicateOf,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Episode &&
          other.id == this.id &&
          other.podcastId == this.podcastId &&
          other.guid == this.guid &&
          other.title == this.title &&
          other.description == this.description &&
          other.audioUrl == this.audioUrl &&
          other.localFilePath == this.localFilePath &&
          other.downloadState == this.downloadState &&
          other.pubDate == this.pubDate &&
          other.durationSeconds == this.durationSeconds &&
          other.isPlayed == this.isPlayed &&
          other.isPinned == this.isPinned &&
          other.playbackPositionSeconds == this.playbackPositionSeconds &&
          other.playCount == this.playCount &&
          other.lastPlayed == this.lastPlayed &&
          other.duplicateOf == this.duplicateOf);
}

class EpisodesCompanion extends UpdateCompanion<Episode> {
  final Value<String> id;
  final Value<String> podcastId;
  final Value<String> guid;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> audioUrl;
  final Value<String?> localFilePath;
  final Value<int> downloadState;
  final Value<DateTime?> pubDate;
  final Value<int?> durationSeconds;
  final Value<bool> isPlayed;
  final Value<bool> isPinned;
  final Value<int> playbackPositionSeconds;
  final Value<int> playCount;
  final Value<DateTime?> lastPlayed;
  final Value<String?> duplicateOf;
  final Value<int> rowid;
  const EpisodesCompanion({
    this.id = const Value.absent(),
    this.podcastId = const Value.absent(),
    this.guid = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.localFilePath = const Value.absent(),
    this.downloadState = const Value.absent(),
    this.pubDate = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.isPlayed = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.playbackPositionSeconds = const Value.absent(),
    this.playCount = const Value.absent(),
    this.lastPlayed = const Value.absent(),
    this.duplicateOf = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EpisodesCompanion.insert({
    required String id,
    required String podcastId,
    required String guid,
    required String title,
    this.description = const Value.absent(),
    required String audioUrl,
    this.localFilePath = const Value.absent(),
    this.downloadState = const Value.absent(),
    this.pubDate = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.isPlayed = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.playbackPositionSeconds = const Value.absent(),
    this.playCount = const Value.absent(),
    this.lastPlayed = const Value.absent(),
    this.duplicateOf = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       podcastId = Value(podcastId),
       guid = Value(guid),
       title = Value(title),
       audioUrl = Value(audioUrl);
  static Insertable<Episode> custom({
    Expression<String>? id,
    Expression<String>? podcastId,
    Expression<String>? guid,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? audioUrl,
    Expression<String>? localFilePath,
    Expression<int>? downloadState,
    Expression<DateTime>? pubDate,
    Expression<int>? durationSeconds,
    Expression<bool>? isPlayed,
    Expression<bool>? isPinned,
    Expression<int>? playbackPositionSeconds,
    Expression<int>? playCount,
    Expression<DateTime>? lastPlayed,
    Expression<String>? duplicateOf,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (podcastId != null) 'podcast_id': podcastId,
      if (guid != null) 'guid': guid,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (audioUrl != null) 'audio_url': audioUrl,
      if (localFilePath != null) 'local_file_path': localFilePath,
      if (downloadState != null) 'download_state': downloadState,
      if (pubDate != null) 'pub_date': pubDate,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (isPlayed != null) 'is_played': isPlayed,
      if (isPinned != null) 'is_pinned': isPinned,
      if (playbackPositionSeconds != null)
        'playback_position_seconds': playbackPositionSeconds,
      if (playCount != null) 'play_count': playCount,
      if (lastPlayed != null) 'last_played': lastPlayed,
      if (duplicateOf != null) 'duplicate_of': duplicateOf,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EpisodesCompanion copyWith({
    Value<String>? id,
    Value<String>? podcastId,
    Value<String>? guid,
    Value<String>? title,
    Value<String?>? description,
    Value<String>? audioUrl,
    Value<String?>? localFilePath,
    Value<int>? downloadState,
    Value<DateTime?>? pubDate,
    Value<int?>? durationSeconds,
    Value<bool>? isPlayed,
    Value<bool>? isPinned,
    Value<int>? playbackPositionSeconds,
    Value<int>? playCount,
    Value<DateTime?>? lastPlayed,
    Value<String?>? duplicateOf,
    Value<int>? rowid,
  }) {
    return EpisodesCompanion(
      id: id ?? this.id,
      podcastId: podcastId ?? this.podcastId,
      guid: guid ?? this.guid,
      title: title ?? this.title,
      description: description ?? this.description,
      audioUrl: audioUrl ?? this.audioUrl,
      localFilePath: localFilePath ?? this.localFilePath,
      downloadState: downloadState ?? this.downloadState,
      pubDate: pubDate ?? this.pubDate,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isPlayed: isPlayed ?? this.isPlayed,
      isPinned: isPinned ?? this.isPinned,
      playbackPositionSeconds:
          playbackPositionSeconds ?? this.playbackPositionSeconds,
      playCount: playCount ?? this.playCount,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      duplicateOf: duplicateOf ?? this.duplicateOf,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (podcastId.present) {
      map['podcast_id'] = Variable<String>(podcastId.value);
    }
    if (guid.present) {
      map['guid'] = Variable<String>(guid.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (audioUrl.present) {
      map['audio_url'] = Variable<String>(audioUrl.value);
    }
    if (localFilePath.present) {
      map['local_file_path'] = Variable<String>(localFilePath.value);
    }
    if (downloadState.present) {
      map['download_state'] = Variable<int>(downloadState.value);
    }
    if (pubDate.present) {
      map['pub_date'] = Variable<DateTime>(pubDate.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (isPlayed.present) {
      map['is_played'] = Variable<bool>(isPlayed.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (playbackPositionSeconds.present) {
      map['playback_position_seconds'] = Variable<int>(
        playbackPositionSeconds.value,
      );
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    if (lastPlayed.present) {
      map['last_played'] = Variable<DateTime>(lastPlayed.value);
    }
    if (duplicateOf.present) {
      map['duplicate_of'] = Variable<String>(duplicateOf.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EpisodesCompanion(')
          ..write('id: $id, ')
          ..write('podcastId: $podcastId, ')
          ..write('guid: $guid, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('downloadState: $downloadState, ')
          ..write('pubDate: $pubDate, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('isPlayed: $isPlayed, ')
          ..write('isPinned: $isPinned, ')
          ..write('playbackPositionSeconds: $playbackPositionSeconds, ')
          ..write('playCount: $playCount, ')
          ..write('lastPlayed: $lastPlayed, ')
          ..write('duplicateOf: $duplicateOf, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DiscoveredPodcastsTable extends DiscoveredPodcasts
    with TableInfo<$DiscoveredPodcastsTable, DiscoveredPodcast> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiscoveredPodcastsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _iTunesIdMeta = const VerificationMeta(
    'iTunesId',
  );
  @override
  late final GeneratedColumn<String> iTunesId = GeneratedColumn<String>(
    'i_tunes_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feedUrlMeta = const VerificationMeta(
    'feedUrl',
  );
  @override
  late final GeneratedColumn<String> feedUrl = GeneratedColumn<String>(
    'feed_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firstSeenMeta = const VerificationMeta(
    'firstSeen',
  );
  @override
  late final GeneratedColumn<DateTime> firstSeen = GeneratedColumn<DateTime>(
    'first_seen',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    iTunesId,
    title,
    artist,
    feedUrl,
    imageUrl,
    description,
    firstSeen,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'discovered_podcasts';
  @override
  VerificationContext validateIntegrity(
    Insertable<DiscoveredPodcast> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('i_tunes_id')) {
      context.handle(
        _iTunesIdMeta,
        iTunesId.isAcceptableOrUnknown(data['i_tunes_id']!, _iTunesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_iTunesIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    } else if (isInserting) {
      context.missing(_artistMeta);
    }
    if (data.containsKey('feed_url')) {
      context.handle(
        _feedUrlMeta,
        feedUrl.isAcceptableOrUnknown(data['feed_url']!, _feedUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_feedUrlMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('first_seen')) {
      context.handle(
        _firstSeenMeta,
        firstSeen.isAcceptableOrUnknown(data['first_seen']!, _firstSeenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DiscoveredPodcast map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiscoveredPodcast(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      iTunesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}i_tunes_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      )!,
      feedUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_url'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      firstSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_seen'],
      )!,
    );
  }

  @override
  $DiscoveredPodcastsTable createAlias(String alias) {
    return $DiscoveredPodcastsTable(attachedDatabase, alias);
  }
}

class DiscoveredPodcast extends DataClass
    implements Insertable<DiscoveredPodcast> {
  final int id;
  final String iTunesId;
  final String title;
  final String artist;
  final String feedUrl;
  final String? imageUrl;
  final String? description;
  final DateTime firstSeen;
  const DiscoveredPodcast({
    required this.id,
    required this.iTunesId,
    required this.title,
    required this.artist,
    required this.feedUrl,
    this.imageUrl,
    this.description,
    required this.firstSeen,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['i_tunes_id'] = Variable<String>(iTunesId);
    map['title'] = Variable<String>(title);
    map['artist'] = Variable<String>(artist);
    map['feed_url'] = Variable<String>(feedUrl);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['first_seen'] = Variable<DateTime>(firstSeen);
    return map;
  }

  DiscoveredPodcastsCompanion toCompanion(bool nullToAbsent) {
    return DiscoveredPodcastsCompanion(
      id: Value(id),
      iTunesId: Value(iTunesId),
      title: Value(title),
      artist: Value(artist),
      feedUrl: Value(feedUrl),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      firstSeen: Value(firstSeen),
    );
  }

  factory DiscoveredPodcast.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiscoveredPodcast(
      id: serializer.fromJson<int>(json['id']),
      iTunesId: serializer.fromJson<String>(json['iTunesId']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String>(json['artist']),
      feedUrl: serializer.fromJson<String>(json['feedUrl']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      description: serializer.fromJson<String?>(json['description']),
      firstSeen: serializer.fromJson<DateTime>(json['firstSeen']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'iTunesId': serializer.toJson<String>(iTunesId),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String>(artist),
      'feedUrl': serializer.toJson<String>(feedUrl),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'description': serializer.toJson<String?>(description),
      'firstSeen': serializer.toJson<DateTime>(firstSeen),
    };
  }

  DiscoveredPodcast copyWith({
    int? id,
    String? iTunesId,
    String? title,
    String? artist,
    String? feedUrl,
    Value<String?> imageUrl = const Value.absent(),
    Value<String?> description = const Value.absent(),
    DateTime? firstSeen,
  }) => DiscoveredPodcast(
    id: id ?? this.id,
    iTunesId: iTunesId ?? this.iTunesId,
    title: title ?? this.title,
    artist: artist ?? this.artist,
    feedUrl: feedUrl ?? this.feedUrl,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    description: description.present ? description.value : this.description,
    firstSeen: firstSeen ?? this.firstSeen,
  );
  DiscoveredPodcast copyWithCompanion(DiscoveredPodcastsCompanion data) {
    return DiscoveredPodcast(
      id: data.id.present ? data.id.value : this.id,
      iTunesId: data.iTunesId.present ? data.iTunesId.value : this.iTunesId,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      feedUrl: data.feedUrl.present ? data.feedUrl.value : this.feedUrl,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      description: data.description.present
          ? data.description.value
          : this.description,
      firstSeen: data.firstSeen.present ? data.firstSeen.value : this.firstSeen,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiscoveredPodcast(')
          ..write('id: $id, ')
          ..write('iTunesId: $iTunesId, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('feedUrl: $feedUrl, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('description: $description, ')
          ..write('firstSeen: $firstSeen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    iTunesId,
    title,
    artist,
    feedUrl,
    imageUrl,
    description,
    firstSeen,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiscoveredPodcast &&
          other.id == this.id &&
          other.iTunesId == this.iTunesId &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.feedUrl == this.feedUrl &&
          other.imageUrl == this.imageUrl &&
          other.description == this.description &&
          other.firstSeen == this.firstSeen);
}

class DiscoveredPodcastsCompanion extends UpdateCompanion<DiscoveredPodcast> {
  final Value<int> id;
  final Value<String> iTunesId;
  final Value<String> title;
  final Value<String> artist;
  final Value<String> feedUrl;
  final Value<String?> imageUrl;
  final Value<String?> description;
  final Value<DateTime> firstSeen;
  const DiscoveredPodcastsCompanion({
    this.id = const Value.absent(),
    this.iTunesId = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.feedUrl = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.firstSeen = const Value.absent(),
  });
  DiscoveredPodcastsCompanion.insert({
    this.id = const Value.absent(),
    required String iTunesId,
    required String title,
    required String artist,
    required String feedUrl,
    this.imageUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.firstSeen = const Value.absent(),
  }) : iTunesId = Value(iTunesId),
       title = Value(title),
       artist = Value(artist),
       feedUrl = Value(feedUrl);
  static Insertable<DiscoveredPodcast> custom({
    Expression<int>? id,
    Expression<String>? iTunesId,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? feedUrl,
    Expression<String>? imageUrl,
    Expression<String>? description,
    Expression<DateTime>? firstSeen,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (iTunesId != null) 'i_tunes_id': iTunesId,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (feedUrl != null) 'feed_url': feedUrl,
      if (imageUrl != null) 'image_url': imageUrl,
      if (description != null) 'description': description,
      if (firstSeen != null) 'first_seen': firstSeen,
    });
  }

  DiscoveredPodcastsCompanion copyWith({
    Value<int>? id,
    Value<String>? iTunesId,
    Value<String>? title,
    Value<String>? artist,
    Value<String>? feedUrl,
    Value<String?>? imageUrl,
    Value<String?>? description,
    Value<DateTime>? firstSeen,
  }) {
    return DiscoveredPodcastsCompanion(
      id: id ?? this.id,
      iTunesId: iTunesId ?? this.iTunesId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      feedUrl: feedUrl ?? this.feedUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      firstSeen: firstSeen ?? this.firstSeen,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (iTunesId.present) {
      map['i_tunes_id'] = Variable<String>(iTunesId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (feedUrl.present) {
      map['feed_url'] = Variable<String>(feedUrl.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (firstSeen.present) {
      map['first_seen'] = Variable<DateTime>(firstSeen.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiscoveredPodcastsCompanion(')
          ..write('id: $id, ')
          ..write('iTunesId: $iTunesId, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('feedUrl: $feedUrl, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('description: $description, ')
          ..write('firstSeen: $firstSeen')
          ..write(')'))
        .toString();
  }
}

class $DiscoveredEpisodesTable extends DiscoveredEpisodes
    with TableInfo<$DiscoveredEpisodesTable, DiscoveredEpisode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiscoveredEpisodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _iTunesIdMeta = const VerificationMeta(
    'iTunesId',
  );
  @override
  late final GeneratedColumn<String> iTunesId = GeneratedColumn<String>(
    'i_tunes_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES discovered_podcasts (i_tunes_id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _audioUrlMeta = const VerificationMeta(
    'audioUrl',
  );
  @override
  late final GeneratedColumn<String> audioUrl = GeneratedColumn<String>(
    'audio_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pubDateMeta = const VerificationMeta(
    'pubDate',
  );
  @override
  late final GeneratedColumn<DateTime> pubDate = GeneratedColumn<DateTime>(
    'pub_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    iTunesId,
    title,
    audioUrl,
    pubDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'discovered_episodes';
  @override
  VerificationContext validateIntegrity(
    Insertable<DiscoveredEpisode> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('i_tunes_id')) {
      context.handle(
        _iTunesIdMeta,
        iTunesId.isAcceptableOrUnknown(data['i_tunes_id']!, _iTunesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_iTunesIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('audio_url')) {
      context.handle(
        _audioUrlMeta,
        audioUrl.isAcceptableOrUnknown(data['audio_url']!, _audioUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_audioUrlMeta);
    }
    if (data.containsKey('pub_date')) {
      context.handle(
        _pubDateMeta,
        pubDate.isAcceptableOrUnknown(data['pub_date']!, _pubDateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DiscoveredEpisode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiscoveredEpisode(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      iTunesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}i_tunes_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      audioUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_url'],
      )!,
      pubDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}pub_date'],
      ),
    );
  }

  @override
  $DiscoveredEpisodesTable createAlias(String alias) {
    return $DiscoveredEpisodesTable(attachedDatabase, alias);
  }
}

class DiscoveredEpisode extends DataClass
    implements Insertable<DiscoveredEpisode> {
  final int id;
  final String iTunesId;
  final String title;
  final String audioUrl;
  final DateTime? pubDate;
  const DiscoveredEpisode({
    required this.id,
    required this.iTunesId,
    required this.title,
    required this.audioUrl,
    this.pubDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['i_tunes_id'] = Variable<String>(iTunesId);
    map['title'] = Variable<String>(title);
    map['audio_url'] = Variable<String>(audioUrl);
    if (!nullToAbsent || pubDate != null) {
      map['pub_date'] = Variable<DateTime>(pubDate);
    }
    return map;
  }

  DiscoveredEpisodesCompanion toCompanion(bool nullToAbsent) {
    return DiscoveredEpisodesCompanion(
      id: Value(id),
      iTunesId: Value(iTunesId),
      title: Value(title),
      audioUrl: Value(audioUrl),
      pubDate: pubDate == null && nullToAbsent
          ? const Value.absent()
          : Value(pubDate),
    );
  }

  factory DiscoveredEpisode.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiscoveredEpisode(
      id: serializer.fromJson<int>(json['id']),
      iTunesId: serializer.fromJson<String>(json['iTunesId']),
      title: serializer.fromJson<String>(json['title']),
      audioUrl: serializer.fromJson<String>(json['audioUrl']),
      pubDate: serializer.fromJson<DateTime?>(json['pubDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'iTunesId': serializer.toJson<String>(iTunesId),
      'title': serializer.toJson<String>(title),
      'audioUrl': serializer.toJson<String>(audioUrl),
      'pubDate': serializer.toJson<DateTime?>(pubDate),
    };
  }

  DiscoveredEpisode copyWith({
    int? id,
    String? iTunesId,
    String? title,
    String? audioUrl,
    Value<DateTime?> pubDate = const Value.absent(),
  }) => DiscoveredEpisode(
    id: id ?? this.id,
    iTunesId: iTunesId ?? this.iTunesId,
    title: title ?? this.title,
    audioUrl: audioUrl ?? this.audioUrl,
    pubDate: pubDate.present ? pubDate.value : this.pubDate,
  );
  DiscoveredEpisode copyWithCompanion(DiscoveredEpisodesCompanion data) {
    return DiscoveredEpisode(
      id: data.id.present ? data.id.value : this.id,
      iTunesId: data.iTunesId.present ? data.iTunesId.value : this.iTunesId,
      title: data.title.present ? data.title.value : this.title,
      audioUrl: data.audioUrl.present ? data.audioUrl.value : this.audioUrl,
      pubDate: data.pubDate.present ? data.pubDate.value : this.pubDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiscoveredEpisode(')
          ..write('id: $id, ')
          ..write('iTunesId: $iTunesId, ')
          ..write('title: $title, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('pubDate: $pubDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, iTunesId, title, audioUrl, pubDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiscoveredEpisode &&
          other.id == this.id &&
          other.iTunesId == this.iTunesId &&
          other.title == this.title &&
          other.audioUrl == this.audioUrl &&
          other.pubDate == this.pubDate);
}

class DiscoveredEpisodesCompanion extends UpdateCompanion<DiscoveredEpisode> {
  final Value<int> id;
  final Value<String> iTunesId;
  final Value<String> title;
  final Value<String> audioUrl;
  final Value<DateTime?> pubDate;
  const DiscoveredEpisodesCompanion({
    this.id = const Value.absent(),
    this.iTunesId = const Value.absent(),
    this.title = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.pubDate = const Value.absent(),
  });
  DiscoveredEpisodesCompanion.insert({
    this.id = const Value.absent(),
    required String iTunesId,
    required String title,
    required String audioUrl,
    this.pubDate = const Value.absent(),
  }) : iTunesId = Value(iTunesId),
       title = Value(title),
       audioUrl = Value(audioUrl);
  static Insertable<DiscoveredEpisode> custom({
    Expression<int>? id,
    Expression<String>? iTunesId,
    Expression<String>? title,
    Expression<String>? audioUrl,
    Expression<DateTime>? pubDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (iTunesId != null) 'i_tunes_id': iTunesId,
      if (title != null) 'title': title,
      if (audioUrl != null) 'audio_url': audioUrl,
      if (pubDate != null) 'pub_date': pubDate,
    });
  }

  DiscoveredEpisodesCompanion copyWith({
    Value<int>? id,
    Value<String>? iTunesId,
    Value<String>? title,
    Value<String>? audioUrl,
    Value<DateTime?>? pubDate,
  }) {
    return DiscoveredEpisodesCompanion(
      id: id ?? this.id,
      iTunesId: iTunesId ?? this.iTunesId,
      title: title ?? this.title,
      audioUrl: audioUrl ?? this.audioUrl,
      pubDate: pubDate ?? this.pubDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (iTunesId.present) {
      map['i_tunes_id'] = Variable<String>(iTunesId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (audioUrl.present) {
      map['audio_url'] = Variable<String>(audioUrl.value);
    }
    if (pubDate.present) {
      map['pub_date'] = Variable<DateTime>(pubDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiscoveredEpisodesCompanion(')
          ..write('id: $id, ')
          ..write('iTunesId: $iTunesId, ')
          ..write('title: $title, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('pubDate: $pubDate')
          ..write(')'))
        .toString();
  }
}

class $DiscoveryCategoryRelationsTable extends DiscoveryCategoryRelations
    with
        TableInfo<$DiscoveryCategoryRelationsTable, DiscoveryCategoryRelation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiscoveryCategoryRelationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _iTunesIdMeta = const VerificationMeta(
    'iTunesId',
  );
  @override
  late final GeneratedColumn<String> iTunesId = GeneratedColumn<String>(
    'i_tunes_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES discovered_podcasts (i_tunes_id)',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [iTunesId, categoryId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'discovery_category_relations';
  @override
  VerificationContext validateIntegrity(
    Insertable<DiscoveryCategoryRelation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('i_tunes_id')) {
      context.handle(
        _iTunesIdMeta,
        iTunesId.isAcceptableOrUnknown(data['i_tunes_id']!, _iTunesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_iTunesIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {iTunesId, categoryId};
  @override
  DiscoveryCategoryRelation map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiscoveryCategoryRelation(
      iTunesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}i_tunes_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
    );
  }

  @override
  $DiscoveryCategoryRelationsTable createAlias(String alias) {
    return $DiscoveryCategoryRelationsTable(attachedDatabase, alias);
  }
}

class DiscoveryCategoryRelation extends DataClass
    implements Insertable<DiscoveryCategoryRelation> {
  final String iTunesId;
  final String categoryId;
  const DiscoveryCategoryRelation({
    required this.iTunesId,
    required this.categoryId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['i_tunes_id'] = Variable<String>(iTunesId);
    map['category_id'] = Variable<String>(categoryId);
    return map;
  }

  DiscoveryCategoryRelationsCompanion toCompanion(bool nullToAbsent) {
    return DiscoveryCategoryRelationsCompanion(
      iTunesId: Value(iTunesId),
      categoryId: Value(categoryId),
    );
  }

  factory DiscoveryCategoryRelation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiscoveryCategoryRelation(
      iTunesId: serializer.fromJson<String>(json['iTunesId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'iTunesId': serializer.toJson<String>(iTunesId),
      'categoryId': serializer.toJson<String>(categoryId),
    };
  }

  DiscoveryCategoryRelation copyWith({String? iTunesId, String? categoryId}) =>
      DiscoveryCategoryRelation(
        iTunesId: iTunesId ?? this.iTunesId,
        categoryId: categoryId ?? this.categoryId,
      );
  DiscoveryCategoryRelation copyWithCompanion(
    DiscoveryCategoryRelationsCompanion data,
  ) {
    return DiscoveryCategoryRelation(
      iTunesId: data.iTunesId.present ? data.iTunesId.value : this.iTunesId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiscoveryCategoryRelation(')
          ..write('iTunesId: $iTunesId, ')
          ..write('categoryId: $categoryId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(iTunesId, categoryId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiscoveryCategoryRelation &&
          other.iTunesId == this.iTunesId &&
          other.categoryId == this.categoryId);
}

class DiscoveryCategoryRelationsCompanion
    extends UpdateCompanion<DiscoveryCategoryRelation> {
  final Value<String> iTunesId;
  final Value<String> categoryId;
  final Value<int> rowid;
  const DiscoveryCategoryRelationsCompanion({
    this.iTunesId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DiscoveryCategoryRelationsCompanion.insert({
    required String iTunesId,
    required String categoryId,
    this.rowid = const Value.absent(),
  }) : iTunesId = Value(iTunesId),
       categoryId = Value(categoryId);
  static Insertable<DiscoveryCategoryRelation> custom({
    Expression<String>? iTunesId,
    Expression<String>? categoryId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (iTunesId != null) 'i_tunes_id': iTunesId,
      if (categoryId != null) 'category_id': categoryId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DiscoveryCategoryRelationsCompanion copyWith({
    Value<String>? iTunesId,
    Value<String>? categoryId,
    Value<int>? rowid,
  }) {
    return DiscoveryCategoryRelationsCompanion(
      iTunesId: iTunesId ?? this.iTunesId,
      categoryId: categoryId ?? this.categoryId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (iTunesId.present) {
      map['i_tunes_id'] = Variable<String>(iTunesId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiscoveryCategoryRelationsCompanion(')
          ..write('iTunesId: $iTunesId, ')
          ..write('categoryId: $categoryId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DiscoveryLogsTable extends DiscoveryLogs
    with TableInfo<$DiscoveryLogsTable, DiscoveryLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiscoveryLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _lastRunMeta = const VerificationMeta(
    'lastRun',
  );
  @override
  late final GeneratedColumn<DateTime> lastRun = GeneratedColumn<DateTime>(
    'last_run',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchCountMeta = const VerificationMeta(
    'fetchCount',
  );
  @override
  late final GeneratedColumn<int> fetchCount = GeneratedColumn<int>(
    'fetch_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, lastRun, fetchCount, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'discovery_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DiscoveryLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('last_run')) {
      context.handle(
        _lastRunMeta,
        lastRun.isAcceptableOrUnknown(data['last_run']!, _lastRunMeta),
      );
    } else if (isInserting) {
      context.missing(_lastRunMeta);
    }
    if (data.containsKey('fetch_count')) {
      context.handle(
        _fetchCountMeta,
        fetchCount.isAcceptableOrUnknown(data['fetch_count']!, _fetchCountMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchCountMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DiscoveryLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiscoveryLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lastRun: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_run'],
      )!,
      fetchCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fetch_count'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $DiscoveryLogsTable createAlias(String alias) {
    return $DiscoveryLogsTable(attachedDatabase, alias);
  }
}

class DiscoveryLog extends DataClass implements Insertable<DiscoveryLog> {
  final int id;
  final DateTime lastRun;
  final int fetchCount;
  final String status;
  const DiscoveryLog({
    required this.id,
    required this.lastRun,
    required this.fetchCount,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['last_run'] = Variable<DateTime>(lastRun);
    map['fetch_count'] = Variable<int>(fetchCount);
    map['status'] = Variable<String>(status);
    return map;
  }

  DiscoveryLogsCompanion toCompanion(bool nullToAbsent) {
    return DiscoveryLogsCompanion(
      id: Value(id),
      lastRun: Value(lastRun),
      fetchCount: Value(fetchCount),
      status: Value(status),
    );
  }

  factory DiscoveryLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiscoveryLog(
      id: serializer.fromJson<int>(json['id']),
      lastRun: serializer.fromJson<DateTime>(json['lastRun']),
      fetchCount: serializer.fromJson<int>(json['fetchCount']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lastRun': serializer.toJson<DateTime>(lastRun),
      'fetchCount': serializer.toJson<int>(fetchCount),
      'status': serializer.toJson<String>(status),
    };
  }

  DiscoveryLog copyWith({
    int? id,
    DateTime? lastRun,
    int? fetchCount,
    String? status,
  }) => DiscoveryLog(
    id: id ?? this.id,
    lastRun: lastRun ?? this.lastRun,
    fetchCount: fetchCount ?? this.fetchCount,
    status: status ?? this.status,
  );
  DiscoveryLog copyWithCompanion(DiscoveryLogsCompanion data) {
    return DiscoveryLog(
      id: data.id.present ? data.id.value : this.id,
      lastRun: data.lastRun.present ? data.lastRun.value : this.lastRun,
      fetchCount: data.fetchCount.present
          ? data.fetchCount.value
          : this.fetchCount,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiscoveryLog(')
          ..write('id: $id, ')
          ..write('lastRun: $lastRun, ')
          ..write('fetchCount: $fetchCount, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, lastRun, fetchCount, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiscoveryLog &&
          other.id == this.id &&
          other.lastRun == this.lastRun &&
          other.fetchCount == this.fetchCount &&
          other.status == this.status);
}

class DiscoveryLogsCompanion extends UpdateCompanion<DiscoveryLog> {
  final Value<int> id;
  final Value<DateTime> lastRun;
  final Value<int> fetchCount;
  final Value<String> status;
  const DiscoveryLogsCompanion({
    this.id = const Value.absent(),
    this.lastRun = const Value.absent(),
    this.fetchCount = const Value.absent(),
    this.status = const Value.absent(),
  });
  DiscoveryLogsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime lastRun,
    required int fetchCount,
    required String status,
  }) : lastRun = Value(lastRun),
       fetchCount = Value(fetchCount),
       status = Value(status);
  static Insertable<DiscoveryLog> custom({
    Expression<int>? id,
    Expression<DateTime>? lastRun,
    Expression<int>? fetchCount,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastRun != null) 'last_run': lastRun,
      if (fetchCount != null) 'fetch_count': fetchCount,
      if (status != null) 'status': status,
    });
  }

  DiscoveryLogsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? lastRun,
    Value<int>? fetchCount,
    Value<String>? status,
  }) {
    return DiscoveryLogsCompanion(
      id: id ?? this.id,
      lastRun: lastRun ?? this.lastRun,
      fetchCount: fetchCount ?? this.fetchCount,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lastRun.present) {
      map['last_run'] = Variable<DateTime>(lastRun.value);
    }
    if (fetchCount.present) {
      map['fetch_count'] = Variable<int>(fetchCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiscoveryLogsCompanion(')
          ..write('id: $id, ')
          ..write('lastRun: $lastRun, ')
          ..write('fetchCount: $fetchCount, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

abstract class _$PodcastDatabase extends GeneratedDatabase {
  _$PodcastDatabase(QueryExecutor e) : super(e);
  $PodcastDatabaseManager get managers => $PodcastDatabaseManager(this);
  late final $PodcastsTable podcasts = $PodcastsTable(this);
  late final $EpisodesTable episodes = $EpisodesTable(this);
  late final $DiscoveredPodcastsTable discoveredPodcasts =
      $DiscoveredPodcastsTable(this);
  late final $DiscoveredEpisodesTable discoveredEpisodes =
      $DiscoveredEpisodesTable(this);
  late final $DiscoveryCategoryRelationsTable discoveryCategoryRelations =
      $DiscoveryCategoryRelationsTable(this);
  late final $DiscoveryLogsTable discoveryLogs = $DiscoveryLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    podcasts,
    episodes,
    discoveredPodcasts,
    discoveredEpisodes,
    discoveryCategoryRelations,
    discoveryLogs,
  ];
}

typedef $$PodcastsTableCreateCompanionBuilder =
    PodcastsCompanion Function({
      required String id,
      required String feedUrl,
      required String title,
      Value<String?> description,
      Value<String?> author,
      Value<String?> imageUrl,
      Value<Uint8List?> image,
      Value<DateTime> subscribedAt,
      Value<bool> isFavorite,
      Value<int> playCount,
      Value<DateTime?> lastPlayed,
      Value<int> rowid,
    });
typedef $$PodcastsTableUpdateCompanionBuilder =
    PodcastsCompanion Function({
      Value<String> id,
      Value<String> feedUrl,
      Value<String> title,
      Value<String?> description,
      Value<String?> author,
      Value<String?> imageUrl,
      Value<Uint8List?> image,
      Value<DateTime> subscribedAt,
      Value<bool> isFavorite,
      Value<int> playCount,
      Value<DateTime?> lastPlayed,
      Value<int> rowid,
    });

final class $$PodcastsTableReferences
    extends BaseReferences<_$PodcastDatabase, $PodcastsTable, Podcast> {
  $$PodcastsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EpisodesTable, List<Episode>> _episodesRefsTable(
    _$PodcastDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.episodes,
    aliasName: $_aliasNameGenerator(db.podcasts.id, db.episodes.podcastId),
  );

  $$EpisodesTableProcessedTableManager get episodesRefs {
    final manager = $$EpisodesTableTableManager(
      $_db,
      $_db.episodes,
    ).filter((f) => f.podcastId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_episodesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PodcastsTableFilterComposer
    extends Composer<_$PodcastDatabase, $PodcastsTable> {
  $$PodcastsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedUrl => $composableBuilder(
    column: $table.feedUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get subscribedAt => $composableBuilder(
    column: $table.subscribedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPlayed => $composableBuilder(
    column: $table.lastPlayed,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> episodesRefs(
    Expression<bool> Function($$EpisodesTableFilterComposer f) f,
  ) {
    final $$EpisodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.podcastId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableFilterComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PodcastsTableOrderingComposer
    extends Composer<_$PodcastDatabase, $PodcastsTable> {
  $$PodcastsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedUrl => $composableBuilder(
    column: $table.feedUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get subscribedAt => $composableBuilder(
    column: $table.subscribedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPlayed => $composableBuilder(
    column: $table.lastPlayed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PodcastsTableAnnotationComposer
    extends Composer<_$PodcastDatabase, $PodcastsTable> {
  $$PodcastsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get feedUrl =>
      $composableBuilder(column: $table.feedUrl, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<Uint8List> get image =>
      $composableBuilder(column: $table.image, builder: (column) => column);

  GeneratedColumn<DateTime> get subscribedAt => $composableBuilder(
    column: $table.subscribedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<int> get playCount =>
      $composableBuilder(column: $table.playCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPlayed => $composableBuilder(
    column: $table.lastPlayed,
    builder: (column) => column,
  );

  Expression<T> episodesRefs<T extends Object>(
    Expression<T> Function($$EpisodesTableAnnotationComposer a) f,
  ) {
    final $$EpisodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.podcastId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableAnnotationComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PodcastsTableTableManager
    extends
        RootTableManager<
          _$PodcastDatabase,
          $PodcastsTable,
          Podcast,
          $$PodcastsTableFilterComposer,
          $$PodcastsTableOrderingComposer,
          $$PodcastsTableAnnotationComposer,
          $$PodcastsTableCreateCompanionBuilder,
          $$PodcastsTableUpdateCompanionBuilder,
          (Podcast, $$PodcastsTableReferences),
          Podcast,
          PrefetchHooks Function({bool episodesRefs})
        > {
  $$PodcastsTableTableManager(_$PodcastDatabase db, $PodcastsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PodcastsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PodcastsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PodcastsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> feedUrl = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<Uint8List?> image = const Value.absent(),
                Value<DateTime> subscribedAt = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<DateTime?> lastPlayed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PodcastsCompanion(
                id: id,
                feedUrl: feedUrl,
                title: title,
                description: description,
                author: author,
                imageUrl: imageUrl,
                image: image,
                subscribedAt: subscribedAt,
                isFavorite: isFavorite,
                playCount: playCount,
                lastPlayed: lastPlayed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String feedUrl,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<Uint8List?> image = const Value.absent(),
                Value<DateTime> subscribedAt = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<DateTime?> lastPlayed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PodcastsCompanion.insert(
                id: id,
                feedUrl: feedUrl,
                title: title,
                description: description,
                author: author,
                imageUrl: imageUrl,
                image: image,
                subscribedAt: subscribedAt,
                isFavorite: isFavorite,
                playCount: playCount,
                lastPlayed: lastPlayed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PodcastsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({episodesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (episodesRefs) db.episodes],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (episodesRefs)
                    await $_getPrefetchedData<Podcast, $PodcastsTable, Episode>(
                      currentTable: table,
                      referencedTable: $$PodcastsTableReferences
                          ._episodesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PodcastsTableReferences(db, table, p0).episodesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.podcastId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PodcastsTableProcessedTableManager =
    ProcessedTableManager<
      _$PodcastDatabase,
      $PodcastsTable,
      Podcast,
      $$PodcastsTableFilterComposer,
      $$PodcastsTableOrderingComposer,
      $$PodcastsTableAnnotationComposer,
      $$PodcastsTableCreateCompanionBuilder,
      $$PodcastsTableUpdateCompanionBuilder,
      (Podcast, $$PodcastsTableReferences),
      Podcast,
      PrefetchHooks Function({bool episodesRefs})
    >;
typedef $$EpisodesTableCreateCompanionBuilder =
    EpisodesCompanion Function({
      required String id,
      required String podcastId,
      required String guid,
      required String title,
      Value<String?> description,
      required String audioUrl,
      Value<String?> localFilePath,
      Value<int> downloadState,
      Value<DateTime?> pubDate,
      Value<int?> durationSeconds,
      Value<bool> isPlayed,
      Value<bool> isPinned,
      Value<int> playbackPositionSeconds,
      Value<int> playCount,
      Value<DateTime?> lastPlayed,
      Value<String?> duplicateOf,
      Value<int> rowid,
    });
typedef $$EpisodesTableUpdateCompanionBuilder =
    EpisodesCompanion Function({
      Value<String> id,
      Value<String> podcastId,
      Value<String> guid,
      Value<String> title,
      Value<String?> description,
      Value<String> audioUrl,
      Value<String?> localFilePath,
      Value<int> downloadState,
      Value<DateTime?> pubDate,
      Value<int?> durationSeconds,
      Value<bool> isPlayed,
      Value<bool> isPinned,
      Value<int> playbackPositionSeconds,
      Value<int> playCount,
      Value<DateTime?> lastPlayed,
      Value<String?> duplicateOf,
      Value<int> rowid,
    });

final class $$EpisodesTableReferences
    extends BaseReferences<_$PodcastDatabase, $EpisodesTable, Episode> {
  $$EpisodesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PodcastsTable _podcastIdTable(_$PodcastDatabase db) => db.podcasts
      .createAlias($_aliasNameGenerator(db.episodes.podcastId, db.podcasts.id));

  $$PodcastsTableProcessedTableManager get podcastId {
    final $_column = $_itemColumn<String>('podcast_id')!;

    final manager = $$PodcastsTableTableManager(
      $_db,
      $_db.podcasts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_podcastIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EpisodesTableFilterComposer
    extends Composer<_$PodcastDatabase, $EpisodesTable> {
  $$EpisodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guid => $composableBuilder(
    column: $table.guid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get downloadState => $composableBuilder(
    column: $table.downloadState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pubDate => $composableBuilder(
    column: $table.pubDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPlayed => $composableBuilder(
    column: $table.isPlayed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playbackPositionSeconds => $composableBuilder(
    column: $table.playbackPositionSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPlayed => $composableBuilder(
    column: $table.lastPlayed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get duplicateOf => $composableBuilder(
    column: $table.duplicateOf,
    builder: (column) => ColumnFilters(column),
  );

  $$PodcastsTableFilterComposer get podcastId {
    final $$PodcastsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.podcastId,
      referencedTable: $db.podcasts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PodcastsTableFilterComposer(
            $db: $db,
            $table: $db.podcasts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EpisodesTableOrderingComposer
    extends Composer<_$PodcastDatabase, $EpisodesTable> {
  $$EpisodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guid => $composableBuilder(
    column: $table.guid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get downloadState => $composableBuilder(
    column: $table.downloadState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pubDate => $composableBuilder(
    column: $table.pubDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPlayed => $composableBuilder(
    column: $table.isPlayed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playbackPositionSeconds => $composableBuilder(
    column: $table.playbackPositionSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPlayed => $composableBuilder(
    column: $table.lastPlayed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get duplicateOf => $composableBuilder(
    column: $table.duplicateOf,
    builder: (column) => ColumnOrderings(column),
  );

  $$PodcastsTableOrderingComposer get podcastId {
    final $$PodcastsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.podcastId,
      referencedTable: $db.podcasts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PodcastsTableOrderingComposer(
            $db: $db,
            $table: $db.podcasts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EpisodesTableAnnotationComposer
    extends Composer<_$PodcastDatabase, $EpisodesTable> {
  $$EpisodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get guid =>
      $composableBuilder(column: $table.guid, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audioUrl =>
      $composableBuilder(column: $table.audioUrl, builder: (column) => column);

  GeneratedColumn<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get downloadState => $composableBuilder(
    column: $table.downloadState,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get pubDate =>
      $composableBuilder(column: $table.pubDate, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPlayed =>
      $composableBuilder(column: $table.isPlayed, builder: (column) => column);

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<int> get playbackPositionSeconds => $composableBuilder(
    column: $table.playbackPositionSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get playCount =>
      $composableBuilder(column: $table.playCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPlayed => $composableBuilder(
    column: $table.lastPlayed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get duplicateOf => $composableBuilder(
    column: $table.duplicateOf,
    builder: (column) => column,
  );

  $$PodcastsTableAnnotationComposer get podcastId {
    final $$PodcastsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.podcastId,
      referencedTable: $db.podcasts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PodcastsTableAnnotationComposer(
            $db: $db,
            $table: $db.podcasts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EpisodesTableTableManager
    extends
        RootTableManager<
          _$PodcastDatabase,
          $EpisodesTable,
          Episode,
          $$EpisodesTableFilterComposer,
          $$EpisodesTableOrderingComposer,
          $$EpisodesTableAnnotationComposer,
          $$EpisodesTableCreateCompanionBuilder,
          $$EpisodesTableUpdateCompanionBuilder,
          (Episode, $$EpisodesTableReferences),
          Episode,
          PrefetchHooks Function({bool podcastId})
        > {
  $$EpisodesTableTableManager(_$PodcastDatabase db, $EpisodesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EpisodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EpisodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EpisodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> podcastId = const Value.absent(),
                Value<String> guid = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> audioUrl = const Value.absent(),
                Value<String?> localFilePath = const Value.absent(),
                Value<int> downloadState = const Value.absent(),
                Value<DateTime?> pubDate = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<bool> isPlayed = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<int> playbackPositionSeconds = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<DateTime?> lastPlayed = const Value.absent(),
                Value<String?> duplicateOf = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EpisodesCompanion(
                id: id,
                podcastId: podcastId,
                guid: guid,
                title: title,
                description: description,
                audioUrl: audioUrl,
                localFilePath: localFilePath,
                downloadState: downloadState,
                pubDate: pubDate,
                durationSeconds: durationSeconds,
                isPlayed: isPlayed,
                isPinned: isPinned,
                playbackPositionSeconds: playbackPositionSeconds,
                playCount: playCount,
                lastPlayed: lastPlayed,
                duplicateOf: duplicateOf,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String podcastId,
                required String guid,
                required String title,
                Value<String?> description = const Value.absent(),
                required String audioUrl,
                Value<String?> localFilePath = const Value.absent(),
                Value<int> downloadState = const Value.absent(),
                Value<DateTime?> pubDate = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<bool> isPlayed = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<int> playbackPositionSeconds = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<DateTime?> lastPlayed = const Value.absent(),
                Value<String?> duplicateOf = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EpisodesCompanion.insert(
                id: id,
                podcastId: podcastId,
                guid: guid,
                title: title,
                description: description,
                audioUrl: audioUrl,
                localFilePath: localFilePath,
                downloadState: downloadState,
                pubDate: pubDate,
                durationSeconds: durationSeconds,
                isPlayed: isPlayed,
                isPinned: isPinned,
                playbackPositionSeconds: playbackPositionSeconds,
                playCount: playCount,
                lastPlayed: lastPlayed,
                duplicateOf: duplicateOf,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EpisodesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({podcastId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (podcastId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.podcastId,
                                referencedTable: $$EpisodesTableReferences
                                    ._podcastIdTable(db),
                                referencedColumn: $$EpisodesTableReferences
                                    ._podcastIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EpisodesTableProcessedTableManager =
    ProcessedTableManager<
      _$PodcastDatabase,
      $EpisodesTable,
      Episode,
      $$EpisodesTableFilterComposer,
      $$EpisodesTableOrderingComposer,
      $$EpisodesTableAnnotationComposer,
      $$EpisodesTableCreateCompanionBuilder,
      $$EpisodesTableUpdateCompanionBuilder,
      (Episode, $$EpisodesTableReferences),
      Episode,
      PrefetchHooks Function({bool podcastId})
    >;
typedef $$DiscoveredPodcastsTableCreateCompanionBuilder =
    DiscoveredPodcastsCompanion Function({
      Value<int> id,
      required String iTunesId,
      required String title,
      required String artist,
      required String feedUrl,
      Value<String?> imageUrl,
      Value<String?> description,
      Value<DateTime> firstSeen,
    });
typedef $$DiscoveredPodcastsTableUpdateCompanionBuilder =
    DiscoveredPodcastsCompanion Function({
      Value<int> id,
      Value<String> iTunesId,
      Value<String> title,
      Value<String> artist,
      Value<String> feedUrl,
      Value<String?> imageUrl,
      Value<String?> description,
      Value<DateTime> firstSeen,
    });

final class $$DiscoveredPodcastsTableReferences
    extends
        BaseReferences<
          _$PodcastDatabase,
          $DiscoveredPodcastsTable,
          DiscoveredPodcast
        > {
  $$DiscoveredPodcastsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$DiscoveredEpisodesTable, List<DiscoveredEpisode>>
  _discoveredEpisodesRefsTable(_$PodcastDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.discoveredEpisodes,
        aliasName: $_aliasNameGenerator(
          db.discoveredPodcasts.iTunesId,
          db.discoveredEpisodes.iTunesId,
        ),
      );

  $$DiscoveredEpisodesTableProcessedTableManager get discoveredEpisodesRefs {
    final manager =
        $$DiscoveredEpisodesTableTableManager(
          $_db,
          $_db.discoveredEpisodes,
        ).filter(
          (f) => f.iTunesId.iTunesId.sqlEquals(
            $_itemColumn<String>('i_tunes_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _discoveredEpisodesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $DiscoveryCategoryRelationsTable,
    List<DiscoveryCategoryRelation>
  >
  _discoveryCategoryRelationsRefsTable(_$PodcastDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.discoveryCategoryRelations,
        aliasName: $_aliasNameGenerator(
          db.discoveredPodcasts.iTunesId,
          db.discoveryCategoryRelations.iTunesId,
        ),
      );

  $$DiscoveryCategoryRelationsTableProcessedTableManager
  get discoveryCategoryRelationsRefs {
    final manager =
        $$DiscoveryCategoryRelationsTableTableManager(
          $_db,
          $_db.discoveryCategoryRelations,
        ).filter(
          (f) => f.iTunesId.iTunesId.sqlEquals(
            $_itemColumn<String>('i_tunes_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _discoveryCategoryRelationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DiscoveredPodcastsTableFilterComposer
    extends Composer<_$PodcastDatabase, $DiscoveredPodcastsTable> {
  $$DiscoveredPodcastsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iTunesId => $composableBuilder(
    column: $table.iTunesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedUrl => $composableBuilder(
    column: $table.feedUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstSeen => $composableBuilder(
    column: $table.firstSeen,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> discoveredEpisodesRefs(
    Expression<bool> Function($$DiscoveredEpisodesTableFilterComposer f) f,
  ) {
    final $$DiscoveredEpisodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.iTunesId,
      referencedTable: $db.discoveredEpisodes,
      getReferencedColumn: (t) => t.iTunesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DiscoveredEpisodesTableFilterComposer(
            $db: $db,
            $table: $db.discoveredEpisodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> discoveryCategoryRelationsRefs(
    Expression<bool> Function($$DiscoveryCategoryRelationsTableFilterComposer f)
    f,
  ) {
    final $$DiscoveryCategoryRelationsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.iTunesId,
          referencedTable: $db.discoveryCategoryRelations,
          getReferencedColumn: (t) => t.iTunesId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DiscoveryCategoryRelationsTableFilterComposer(
                $db: $db,
                $table: $db.discoveryCategoryRelations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$DiscoveredPodcastsTableOrderingComposer
    extends Composer<_$PodcastDatabase, $DiscoveredPodcastsTable> {
  $$DiscoveredPodcastsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iTunesId => $composableBuilder(
    column: $table.iTunesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedUrl => $composableBuilder(
    column: $table.feedUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstSeen => $composableBuilder(
    column: $table.firstSeen,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DiscoveredPodcastsTableAnnotationComposer
    extends Composer<_$PodcastDatabase, $DiscoveredPodcastsTable> {
  $$DiscoveredPodcastsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get iTunesId =>
      $composableBuilder(column: $table.iTunesId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get feedUrl =>
      $composableBuilder(column: $table.feedUrl, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get firstSeen =>
      $composableBuilder(column: $table.firstSeen, builder: (column) => column);

  Expression<T> discoveredEpisodesRefs<T extends Object>(
    Expression<T> Function($$DiscoveredEpisodesTableAnnotationComposer a) f,
  ) {
    final $$DiscoveredEpisodesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.iTunesId,
          referencedTable: $db.discoveredEpisodes,
          getReferencedColumn: (t) => t.iTunesId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DiscoveredEpisodesTableAnnotationComposer(
                $db: $db,
                $table: $db.discoveredEpisodes,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> discoveryCategoryRelationsRefs<T extends Object>(
    Expression<T> Function(
      $$DiscoveryCategoryRelationsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$DiscoveryCategoryRelationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.iTunesId,
          referencedTable: $db.discoveryCategoryRelations,
          getReferencedColumn: (t) => t.iTunesId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DiscoveryCategoryRelationsTableAnnotationComposer(
                $db: $db,
                $table: $db.discoveryCategoryRelations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$DiscoveredPodcastsTableTableManager
    extends
        RootTableManager<
          _$PodcastDatabase,
          $DiscoveredPodcastsTable,
          DiscoveredPodcast,
          $$DiscoveredPodcastsTableFilterComposer,
          $$DiscoveredPodcastsTableOrderingComposer,
          $$DiscoveredPodcastsTableAnnotationComposer,
          $$DiscoveredPodcastsTableCreateCompanionBuilder,
          $$DiscoveredPodcastsTableUpdateCompanionBuilder,
          (DiscoveredPodcast, $$DiscoveredPodcastsTableReferences),
          DiscoveredPodcast,
          PrefetchHooks Function({
            bool discoveredEpisodesRefs,
            bool discoveryCategoryRelationsRefs,
          })
        > {
  $$DiscoveredPodcastsTableTableManager(
    _$PodcastDatabase db,
    $DiscoveredPodcastsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiscoveredPodcastsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiscoveredPodcastsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiscoveredPodcastsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> iTunesId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> artist = const Value.absent(),
                Value<String> feedUrl = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> firstSeen = const Value.absent(),
              }) => DiscoveredPodcastsCompanion(
                id: id,
                iTunesId: iTunesId,
                title: title,
                artist: artist,
                feedUrl: feedUrl,
                imageUrl: imageUrl,
                description: description,
                firstSeen: firstSeen,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String iTunesId,
                required String title,
                required String artist,
                required String feedUrl,
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> firstSeen = const Value.absent(),
              }) => DiscoveredPodcastsCompanion.insert(
                id: id,
                iTunesId: iTunesId,
                title: title,
                artist: artist,
                feedUrl: feedUrl,
                imageUrl: imageUrl,
                description: description,
                firstSeen: firstSeen,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DiscoveredPodcastsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                discoveredEpisodesRefs = false,
                discoveryCategoryRelationsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (discoveredEpisodesRefs) db.discoveredEpisodes,
                    if (discoveryCategoryRelationsRefs)
                      db.discoveryCategoryRelations,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (discoveredEpisodesRefs)
                        await $_getPrefetchedData<
                          DiscoveredPodcast,
                          $DiscoveredPodcastsTable,
                          DiscoveredEpisode
                        >(
                          currentTable: table,
                          referencedTable: $$DiscoveredPodcastsTableReferences
                              ._discoveredEpisodesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DiscoveredPodcastsTableReferences(
                                db,
                                table,
                                p0,
                              ).discoveredEpisodesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.iTunesId == item.iTunesId,
                              ),
                          typedResults: items,
                        ),
                      if (discoveryCategoryRelationsRefs)
                        await $_getPrefetchedData<
                          DiscoveredPodcast,
                          $DiscoveredPodcastsTable,
                          DiscoveryCategoryRelation
                        >(
                          currentTable: table,
                          referencedTable: $$DiscoveredPodcastsTableReferences
                              ._discoveryCategoryRelationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DiscoveredPodcastsTableReferences(
                                db,
                                table,
                                p0,
                              ).discoveryCategoryRelationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.iTunesId == item.iTunesId,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DiscoveredPodcastsTableProcessedTableManager =
    ProcessedTableManager<
      _$PodcastDatabase,
      $DiscoveredPodcastsTable,
      DiscoveredPodcast,
      $$DiscoveredPodcastsTableFilterComposer,
      $$DiscoveredPodcastsTableOrderingComposer,
      $$DiscoveredPodcastsTableAnnotationComposer,
      $$DiscoveredPodcastsTableCreateCompanionBuilder,
      $$DiscoveredPodcastsTableUpdateCompanionBuilder,
      (DiscoveredPodcast, $$DiscoveredPodcastsTableReferences),
      DiscoveredPodcast,
      PrefetchHooks Function({
        bool discoveredEpisodesRefs,
        bool discoveryCategoryRelationsRefs,
      })
    >;
typedef $$DiscoveredEpisodesTableCreateCompanionBuilder =
    DiscoveredEpisodesCompanion Function({
      Value<int> id,
      required String iTunesId,
      required String title,
      required String audioUrl,
      Value<DateTime?> pubDate,
    });
typedef $$DiscoveredEpisodesTableUpdateCompanionBuilder =
    DiscoveredEpisodesCompanion Function({
      Value<int> id,
      Value<String> iTunesId,
      Value<String> title,
      Value<String> audioUrl,
      Value<DateTime?> pubDate,
    });

final class $$DiscoveredEpisodesTableReferences
    extends
        BaseReferences<
          _$PodcastDatabase,
          $DiscoveredEpisodesTable,
          DiscoveredEpisode
        > {
  $$DiscoveredEpisodesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DiscoveredPodcastsTable _iTunesIdTable(_$PodcastDatabase db) =>
      db.discoveredPodcasts.createAlias(
        $_aliasNameGenerator(
          db.discoveredEpisodes.iTunesId,
          db.discoveredPodcasts.iTunesId,
        ),
      );

  $$DiscoveredPodcastsTableProcessedTableManager get iTunesId {
    final $_column = $_itemColumn<String>('i_tunes_id')!;

    final manager = $$DiscoveredPodcastsTableTableManager(
      $_db,
      $_db.discoveredPodcasts,
    ).filter((f) => f.iTunesId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_iTunesIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DiscoveredEpisodesTableFilterComposer
    extends Composer<_$PodcastDatabase, $DiscoveredEpisodesTable> {
  $$DiscoveredEpisodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pubDate => $composableBuilder(
    column: $table.pubDate,
    builder: (column) => ColumnFilters(column),
  );

  $$DiscoveredPodcastsTableFilterComposer get iTunesId {
    final $$DiscoveredPodcastsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.iTunesId,
      referencedTable: $db.discoveredPodcasts,
      getReferencedColumn: (t) => t.iTunesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DiscoveredPodcastsTableFilterComposer(
            $db: $db,
            $table: $db.discoveredPodcasts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DiscoveredEpisodesTableOrderingComposer
    extends Composer<_$PodcastDatabase, $DiscoveredEpisodesTable> {
  $$DiscoveredEpisodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pubDate => $composableBuilder(
    column: $table.pubDate,
    builder: (column) => ColumnOrderings(column),
  );

  $$DiscoveredPodcastsTableOrderingComposer get iTunesId {
    final $$DiscoveredPodcastsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.iTunesId,
      referencedTable: $db.discoveredPodcasts,
      getReferencedColumn: (t) => t.iTunesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DiscoveredPodcastsTableOrderingComposer(
            $db: $db,
            $table: $db.discoveredPodcasts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DiscoveredEpisodesTableAnnotationComposer
    extends Composer<_$PodcastDatabase, $DiscoveredEpisodesTable> {
  $$DiscoveredEpisodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get audioUrl =>
      $composableBuilder(column: $table.audioUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get pubDate =>
      $composableBuilder(column: $table.pubDate, builder: (column) => column);

  $$DiscoveredPodcastsTableAnnotationComposer get iTunesId {
    final $$DiscoveredPodcastsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.iTunesId,
          referencedTable: $db.discoveredPodcasts,
          getReferencedColumn: (t) => t.iTunesId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DiscoveredPodcastsTableAnnotationComposer(
                $db: $db,
                $table: $db.discoveredPodcasts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$DiscoveredEpisodesTableTableManager
    extends
        RootTableManager<
          _$PodcastDatabase,
          $DiscoveredEpisodesTable,
          DiscoveredEpisode,
          $$DiscoveredEpisodesTableFilterComposer,
          $$DiscoveredEpisodesTableOrderingComposer,
          $$DiscoveredEpisodesTableAnnotationComposer,
          $$DiscoveredEpisodesTableCreateCompanionBuilder,
          $$DiscoveredEpisodesTableUpdateCompanionBuilder,
          (DiscoveredEpisode, $$DiscoveredEpisodesTableReferences),
          DiscoveredEpisode,
          PrefetchHooks Function({bool iTunesId})
        > {
  $$DiscoveredEpisodesTableTableManager(
    _$PodcastDatabase db,
    $DiscoveredEpisodesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiscoveredEpisodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiscoveredEpisodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiscoveredEpisodesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> iTunesId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> audioUrl = const Value.absent(),
                Value<DateTime?> pubDate = const Value.absent(),
              }) => DiscoveredEpisodesCompanion(
                id: id,
                iTunesId: iTunesId,
                title: title,
                audioUrl: audioUrl,
                pubDate: pubDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String iTunesId,
                required String title,
                required String audioUrl,
                Value<DateTime?> pubDate = const Value.absent(),
              }) => DiscoveredEpisodesCompanion.insert(
                id: id,
                iTunesId: iTunesId,
                title: title,
                audioUrl: audioUrl,
                pubDate: pubDate,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DiscoveredEpisodesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({iTunesId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (iTunesId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.iTunesId,
                                referencedTable:
                                    $$DiscoveredEpisodesTableReferences
                                        ._iTunesIdTable(db),
                                referencedColumn:
                                    $$DiscoveredEpisodesTableReferences
                                        ._iTunesIdTable(db)
                                        .iTunesId,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DiscoveredEpisodesTableProcessedTableManager =
    ProcessedTableManager<
      _$PodcastDatabase,
      $DiscoveredEpisodesTable,
      DiscoveredEpisode,
      $$DiscoveredEpisodesTableFilterComposer,
      $$DiscoveredEpisodesTableOrderingComposer,
      $$DiscoveredEpisodesTableAnnotationComposer,
      $$DiscoveredEpisodesTableCreateCompanionBuilder,
      $$DiscoveredEpisodesTableUpdateCompanionBuilder,
      (DiscoveredEpisode, $$DiscoveredEpisodesTableReferences),
      DiscoveredEpisode,
      PrefetchHooks Function({bool iTunesId})
    >;
typedef $$DiscoveryCategoryRelationsTableCreateCompanionBuilder =
    DiscoveryCategoryRelationsCompanion Function({
      required String iTunesId,
      required String categoryId,
      Value<int> rowid,
    });
typedef $$DiscoveryCategoryRelationsTableUpdateCompanionBuilder =
    DiscoveryCategoryRelationsCompanion Function({
      Value<String> iTunesId,
      Value<String> categoryId,
      Value<int> rowid,
    });

final class $$DiscoveryCategoryRelationsTableReferences
    extends
        BaseReferences<
          _$PodcastDatabase,
          $DiscoveryCategoryRelationsTable,
          DiscoveryCategoryRelation
        > {
  $$DiscoveryCategoryRelationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DiscoveredPodcastsTable _iTunesIdTable(_$PodcastDatabase db) =>
      db.discoveredPodcasts.createAlias(
        $_aliasNameGenerator(
          db.discoveryCategoryRelations.iTunesId,
          db.discoveredPodcasts.iTunesId,
        ),
      );

  $$DiscoveredPodcastsTableProcessedTableManager get iTunesId {
    final $_column = $_itemColumn<String>('i_tunes_id')!;

    final manager = $$DiscoveredPodcastsTableTableManager(
      $_db,
      $_db.discoveredPodcasts,
    ).filter((f) => f.iTunesId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_iTunesIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DiscoveryCategoryRelationsTableFilterComposer
    extends Composer<_$PodcastDatabase, $DiscoveryCategoryRelationsTable> {
  $$DiscoveryCategoryRelationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  $$DiscoveredPodcastsTableFilterComposer get iTunesId {
    final $$DiscoveredPodcastsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.iTunesId,
      referencedTable: $db.discoveredPodcasts,
      getReferencedColumn: (t) => t.iTunesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DiscoveredPodcastsTableFilterComposer(
            $db: $db,
            $table: $db.discoveredPodcasts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DiscoveryCategoryRelationsTableOrderingComposer
    extends Composer<_$PodcastDatabase, $DiscoveryCategoryRelationsTable> {
  $$DiscoveryCategoryRelationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  $$DiscoveredPodcastsTableOrderingComposer get iTunesId {
    final $$DiscoveredPodcastsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.iTunesId,
      referencedTable: $db.discoveredPodcasts,
      getReferencedColumn: (t) => t.iTunesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DiscoveredPodcastsTableOrderingComposer(
            $db: $db,
            $table: $db.discoveredPodcasts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DiscoveryCategoryRelationsTableAnnotationComposer
    extends Composer<_$PodcastDatabase, $DiscoveryCategoryRelationsTable> {
  $$DiscoveryCategoryRelationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  $$DiscoveredPodcastsTableAnnotationComposer get iTunesId {
    final $$DiscoveredPodcastsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.iTunesId,
          referencedTable: $db.discoveredPodcasts,
          getReferencedColumn: (t) => t.iTunesId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DiscoveredPodcastsTableAnnotationComposer(
                $db: $db,
                $table: $db.discoveredPodcasts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$DiscoveryCategoryRelationsTableTableManager
    extends
        RootTableManager<
          _$PodcastDatabase,
          $DiscoveryCategoryRelationsTable,
          DiscoveryCategoryRelation,
          $$DiscoveryCategoryRelationsTableFilterComposer,
          $$DiscoveryCategoryRelationsTableOrderingComposer,
          $$DiscoveryCategoryRelationsTableAnnotationComposer,
          $$DiscoveryCategoryRelationsTableCreateCompanionBuilder,
          $$DiscoveryCategoryRelationsTableUpdateCompanionBuilder,
          (
            DiscoveryCategoryRelation,
            $$DiscoveryCategoryRelationsTableReferences,
          ),
          DiscoveryCategoryRelation,
          PrefetchHooks Function({bool iTunesId})
        > {
  $$DiscoveryCategoryRelationsTableTableManager(
    _$PodcastDatabase db,
    $DiscoveryCategoryRelationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiscoveryCategoryRelationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$DiscoveryCategoryRelationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DiscoveryCategoryRelationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> iTunesId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DiscoveryCategoryRelationsCompanion(
                iTunesId: iTunesId,
                categoryId: categoryId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String iTunesId,
                required String categoryId,
                Value<int> rowid = const Value.absent(),
              }) => DiscoveryCategoryRelationsCompanion.insert(
                iTunesId: iTunesId,
                categoryId: categoryId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DiscoveryCategoryRelationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({iTunesId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (iTunesId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.iTunesId,
                                referencedTable:
                                    $$DiscoveryCategoryRelationsTableReferences
                                        ._iTunesIdTable(db),
                                referencedColumn:
                                    $$DiscoveryCategoryRelationsTableReferences
                                        ._iTunesIdTable(db)
                                        .iTunesId,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DiscoveryCategoryRelationsTableProcessedTableManager =
    ProcessedTableManager<
      _$PodcastDatabase,
      $DiscoveryCategoryRelationsTable,
      DiscoveryCategoryRelation,
      $$DiscoveryCategoryRelationsTableFilterComposer,
      $$DiscoveryCategoryRelationsTableOrderingComposer,
      $$DiscoveryCategoryRelationsTableAnnotationComposer,
      $$DiscoveryCategoryRelationsTableCreateCompanionBuilder,
      $$DiscoveryCategoryRelationsTableUpdateCompanionBuilder,
      (DiscoveryCategoryRelation, $$DiscoveryCategoryRelationsTableReferences),
      DiscoveryCategoryRelation,
      PrefetchHooks Function({bool iTunesId})
    >;
typedef $$DiscoveryLogsTableCreateCompanionBuilder =
    DiscoveryLogsCompanion Function({
      Value<int> id,
      required DateTime lastRun,
      required int fetchCount,
      required String status,
    });
typedef $$DiscoveryLogsTableUpdateCompanionBuilder =
    DiscoveryLogsCompanion Function({
      Value<int> id,
      Value<DateTime> lastRun,
      Value<int> fetchCount,
      Value<String> status,
    });

class $$DiscoveryLogsTableFilterComposer
    extends Composer<_$PodcastDatabase, $DiscoveryLogsTable> {
  $$DiscoveryLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastRun => $composableBuilder(
    column: $table.lastRun,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fetchCount => $composableBuilder(
    column: $table.fetchCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DiscoveryLogsTableOrderingComposer
    extends Composer<_$PodcastDatabase, $DiscoveryLogsTable> {
  $$DiscoveryLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastRun => $composableBuilder(
    column: $table.lastRun,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fetchCount => $composableBuilder(
    column: $table.fetchCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DiscoveryLogsTableAnnotationComposer
    extends Composer<_$PodcastDatabase, $DiscoveryLogsTable> {
  $$DiscoveryLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get lastRun =>
      $composableBuilder(column: $table.lastRun, builder: (column) => column);

  GeneratedColumn<int> get fetchCount => $composableBuilder(
    column: $table.fetchCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$DiscoveryLogsTableTableManager
    extends
        RootTableManager<
          _$PodcastDatabase,
          $DiscoveryLogsTable,
          DiscoveryLog,
          $$DiscoveryLogsTableFilterComposer,
          $$DiscoveryLogsTableOrderingComposer,
          $$DiscoveryLogsTableAnnotationComposer,
          $$DiscoveryLogsTableCreateCompanionBuilder,
          $$DiscoveryLogsTableUpdateCompanionBuilder,
          (
            DiscoveryLog,
            BaseReferences<
              _$PodcastDatabase,
              $DiscoveryLogsTable,
              DiscoveryLog
            >,
          ),
          DiscoveryLog,
          PrefetchHooks Function()
        > {
  $$DiscoveryLogsTableTableManager(
    _$PodcastDatabase db,
    $DiscoveryLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiscoveryLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiscoveryLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiscoveryLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> lastRun = const Value.absent(),
                Value<int> fetchCount = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => DiscoveryLogsCompanion(
                id: id,
                lastRun: lastRun,
                fetchCount: fetchCount,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime lastRun,
                required int fetchCount,
                required String status,
              }) => DiscoveryLogsCompanion.insert(
                id: id,
                lastRun: lastRun,
                fetchCount: fetchCount,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DiscoveryLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$PodcastDatabase,
      $DiscoveryLogsTable,
      DiscoveryLog,
      $$DiscoveryLogsTableFilterComposer,
      $$DiscoveryLogsTableOrderingComposer,
      $$DiscoveryLogsTableAnnotationComposer,
      $$DiscoveryLogsTableCreateCompanionBuilder,
      $$DiscoveryLogsTableUpdateCompanionBuilder,
      (
        DiscoveryLog,
        BaseReferences<_$PodcastDatabase, $DiscoveryLogsTable, DiscoveryLog>,
      ),
      DiscoveryLog,
      PrefetchHooks Function()
    >;

class $PodcastDatabaseManager {
  final _$PodcastDatabase _db;
  $PodcastDatabaseManager(this._db);
  $$PodcastsTableTableManager get podcasts =>
      $$PodcastsTableTableManager(_db, _db.podcasts);
  $$EpisodesTableTableManager get episodes =>
      $$EpisodesTableTableManager(_db, _db.episodes);
  $$DiscoveredPodcastsTableTableManager get discoveredPodcasts =>
      $$DiscoveredPodcastsTableTableManager(_db, _db.discoveredPodcasts);
  $$DiscoveredEpisodesTableTableManager get discoveredEpisodes =>
      $$DiscoveredEpisodesTableTableManager(_db, _db.discoveredEpisodes);
  $$DiscoveryCategoryRelationsTableTableManager
  get discoveryCategoryRelations =>
      $$DiscoveryCategoryRelationsTableTableManager(
        _db,
        _db.discoveryCategoryRelations,
      );
  $$DiscoveryLogsTableTableManager get discoveryLogs =>
      $$DiscoveryLogsTableTableManager(_db, _db.discoveryLogs);
}
