// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discovery_database.dart';

// ignore_for_file: type=lint
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

abstract class _$DiscoveryDatabase extends GeneratedDatabase {
  _$DiscoveryDatabase(QueryExecutor e) : super(e);
  $DiscoveryDatabaseManager get managers => $DiscoveryDatabaseManager(this);
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
    discoveredPodcasts,
    discoveredEpisodes,
    discoveryCategoryRelations,
    discoveryLogs,
  ];
}

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
          _$DiscoveryDatabase,
          $DiscoveredPodcastsTable,
          DiscoveredPodcast
        > {
  $$DiscoveredPodcastsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$DiscoveredEpisodesTable, List<DiscoveredEpisode>>
  _discoveredEpisodesRefsTable(_$DiscoveryDatabase db) =>
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
  _discoveryCategoryRelationsRefsTable(_$DiscoveryDatabase db) =>
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
    extends Composer<_$DiscoveryDatabase, $DiscoveredPodcastsTable> {
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
    extends Composer<_$DiscoveryDatabase, $DiscoveredPodcastsTable> {
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
    extends Composer<_$DiscoveryDatabase, $DiscoveredPodcastsTable> {
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
          _$DiscoveryDatabase,
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
    _$DiscoveryDatabase db,
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
      _$DiscoveryDatabase,
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
          _$DiscoveryDatabase,
          $DiscoveredEpisodesTable,
          DiscoveredEpisode
        > {
  $$DiscoveredEpisodesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DiscoveredPodcastsTable _iTunesIdTable(_$DiscoveryDatabase db) =>
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
    extends Composer<_$DiscoveryDatabase, $DiscoveredEpisodesTable> {
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
    extends Composer<_$DiscoveryDatabase, $DiscoveredEpisodesTable> {
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
    extends Composer<_$DiscoveryDatabase, $DiscoveredEpisodesTable> {
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
          _$DiscoveryDatabase,
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
    _$DiscoveryDatabase db,
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
      _$DiscoveryDatabase,
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
          _$DiscoveryDatabase,
          $DiscoveryCategoryRelationsTable,
          DiscoveryCategoryRelation
        > {
  $$DiscoveryCategoryRelationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DiscoveredPodcastsTable _iTunesIdTable(_$DiscoveryDatabase db) =>
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
    extends Composer<_$DiscoveryDatabase, $DiscoveryCategoryRelationsTable> {
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
    extends Composer<_$DiscoveryDatabase, $DiscoveryCategoryRelationsTable> {
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
    extends Composer<_$DiscoveryDatabase, $DiscoveryCategoryRelationsTable> {
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
          _$DiscoveryDatabase,
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
    _$DiscoveryDatabase db,
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
      _$DiscoveryDatabase,
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
    extends Composer<_$DiscoveryDatabase, $DiscoveryLogsTable> {
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
    extends Composer<_$DiscoveryDatabase, $DiscoveryLogsTable> {
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
    extends Composer<_$DiscoveryDatabase, $DiscoveryLogsTable> {
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
          _$DiscoveryDatabase,
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
              _$DiscoveryDatabase,
              $DiscoveryLogsTable,
              DiscoveryLog
            >,
          ),
          DiscoveryLog,
          PrefetchHooks Function()
        > {
  $$DiscoveryLogsTableTableManager(
    _$DiscoveryDatabase db,
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
      _$DiscoveryDatabase,
      $DiscoveryLogsTable,
      DiscoveryLog,
      $$DiscoveryLogsTableFilterComposer,
      $$DiscoveryLogsTableOrderingComposer,
      $$DiscoveryLogsTableAnnotationComposer,
      $$DiscoveryLogsTableCreateCompanionBuilder,
      $$DiscoveryLogsTableUpdateCompanionBuilder,
      (
        DiscoveryLog,
        BaseReferences<_$DiscoveryDatabase, $DiscoveryLogsTable, DiscoveryLog>,
      ),
      DiscoveryLog,
      PrefetchHooks Function()
    >;

class $DiscoveryDatabaseManager {
  final _$DiscoveryDatabase _db;
  $DiscoveryDatabaseManager(this._db);
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
