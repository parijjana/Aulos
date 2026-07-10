// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audiobook_database.dart';

// ignore_for_file: type=lint
class $AudiobookFoldersTable extends AudiobookFolders
    with TableInfo<$AudiobookFoldersTable, AudiobookFolder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudiobookFoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES audiobook_folders (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, path, name, parentId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audiobook_folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudiobookFolder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  AudiobookFolder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudiobookFolder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
    );
  }

  @override
  $AudiobookFoldersTable createAlias(String alias) {
    return $AudiobookFoldersTable(attachedDatabase, alias);
  }
}

class AudiobookFolder extends DataClass implements Insertable<AudiobookFolder> {
  final String id;
  final String path;
  final String name;
  final String? parentId;
  const AudiobookFolder({
    required this.id,
    required this.path,
    required this.name,
    this.parentId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['path'] = Variable<String>(path);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    return map;
  }

  AudiobookFoldersCompanion toCompanion(bool nullToAbsent) {
    return AudiobookFoldersCompanion(
      id: Value(id),
      path: Value(path),
      name: Value(name),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
    );
  }

  factory AudiobookFolder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudiobookFolder(
      id: serializer.fromJson<String>(json['id']),
      path: serializer.fromJson<String>(json['path']),
      name: serializer.fromJson<String>(json['name']),
      parentId: serializer.fromJson<String?>(json['parentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'path': serializer.toJson<String>(path),
      'name': serializer.toJson<String>(name),
      'parentId': serializer.toJson<String?>(parentId),
    };
  }

  AudiobookFolder copyWith({
    String? id,
    String? path,
    String? name,
    Value<String?> parentId = const Value.absent(),
  }) => AudiobookFolder(
    id: id ?? this.id,
    path: path ?? this.path,
    name: name ?? this.name,
    parentId: parentId.present ? parentId.value : this.parentId,
  );
  AudiobookFolder copyWithCompanion(AudiobookFoldersCompanion data) {
    return AudiobookFolder(
      id: data.id.present ? data.id.value : this.id,
      path: data.path.present ? data.path.value : this.path,
      name: data.name.present ? data.name.value : this.name,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudiobookFolder(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, path, name, parentId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudiobookFolder &&
          other.id == this.id &&
          other.path == this.path &&
          other.name == this.name &&
          other.parentId == this.parentId);
}

class AudiobookFoldersCompanion extends UpdateCompanion<AudiobookFolder> {
  final Value<String> id;
  final Value<String> path;
  final Value<String> name;
  final Value<String?> parentId;
  final Value<int> rowid;
  const AudiobookFoldersCompanion({
    this.id = const Value.absent(),
    this.path = const Value.absent(),
    this.name = const Value.absent(),
    this.parentId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AudiobookFoldersCompanion.insert({
    required String id,
    required String path,
    required String name,
    this.parentId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       path = Value(path),
       name = Value(name);
  static Insertable<AudiobookFolder> custom({
    Expression<String>? id,
    Expression<String>? path,
    Expression<String>? name,
    Expression<String>? parentId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (path != null) 'path': path,
      if (name != null) 'name': name,
      if (parentId != null) 'parent_id': parentId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AudiobookFoldersCompanion copyWith({
    Value<String>? id,
    Value<String>? path,
    Value<String>? name,
    Value<String?>? parentId,
    Value<int>? rowid,
  }) {
    return AudiobookFoldersCompanion(
      id: id ?? this.id,
      path: path ?? this.path,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudiobookFoldersCompanion(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AudiobookArtistsTable extends AudiobookArtists
    with TableInfo<$AudiobookArtistsTable, AudiobookArtist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudiobookArtistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _photoMeta = const VerificationMeta('photo');
  @override
  late final GeneratedColumn<Uint8List> photo = GeneratedColumn<Uint8List>(
    'photo',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localArtPathMeta = const VerificationMeta(
    'localArtPath',
  );
  @override
  late final GeneratedColumn<String> localArtPath = GeneratedColumn<String>(
    'local_art_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bioMeta = const VerificationMeta('bio');
  @override
  late final GeneratedColumn<String> bio = GeneratedColumn<String>(
    'bio',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoUrlMeta = const VerificationMeta(
    'photoUrl',
  );
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
    'photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    name,
    photo,
    localArtPath,
    bio,
    photoUrl,
    isFavorite,
    playCount,
    lastPlayed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audiobook_artists';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudiobookArtist> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('photo')) {
      context.handle(
        _photoMeta,
        photo.isAcceptableOrUnknown(data['photo']!, _photoMeta),
      );
    }
    if (data.containsKey('local_art_path')) {
      context.handle(
        _localArtPathMeta,
        localArtPath.isAcceptableOrUnknown(
          data['local_art_path']!,
          _localArtPathMeta,
        ),
      );
    }
    if (data.containsKey('bio')) {
      context.handle(
        _bioMeta,
        bio.isAcceptableOrUnknown(data['bio']!, _bioMeta),
      );
    }
    if (data.containsKey('photo_url')) {
      context.handle(
        _photoUrlMeta,
        photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta),
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
  AudiobookArtist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudiobookArtist(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      photo: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}photo'],
      ),
      localArtPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_art_path'],
      ),
      bio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bio'],
      ),
      photoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_url'],
      ),
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
  $AudiobookArtistsTable createAlias(String alias) {
    return $AudiobookArtistsTable(attachedDatabase, alias);
  }
}

class AudiobookArtist extends DataClass implements Insertable<AudiobookArtist> {
  final String id;
  final String name;
  final Uint8List? photo;
  final String? localArtPath;
  final String? bio;
  final String? photoUrl;
  final bool isFavorite;
  final int playCount;
  final DateTime? lastPlayed;
  const AudiobookArtist({
    required this.id,
    required this.name,
    this.photo,
    this.localArtPath,
    this.bio,
    this.photoUrl,
    required this.isFavorite,
    required this.playCount,
    this.lastPlayed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || photo != null) {
      map['photo'] = Variable<Uint8List>(photo);
    }
    if (!nullToAbsent || localArtPath != null) {
      map['local_art_path'] = Variable<String>(localArtPath);
    }
    if (!nullToAbsent || bio != null) {
      map['bio'] = Variable<String>(bio);
    }
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['play_count'] = Variable<int>(playCount);
    if (!nullToAbsent || lastPlayed != null) {
      map['last_played'] = Variable<DateTime>(lastPlayed);
    }
    return map;
  }

  AudiobookArtistsCompanion toCompanion(bool nullToAbsent) {
    return AudiobookArtistsCompanion(
      id: Value(id),
      name: Value(name),
      photo: photo == null && nullToAbsent
          ? const Value.absent()
          : Value(photo),
      localArtPath: localArtPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localArtPath),
      bio: bio == null && nullToAbsent ? const Value.absent() : Value(bio),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      isFavorite: Value(isFavorite),
      playCount: Value(playCount),
      lastPlayed: lastPlayed == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayed),
    );
  }

  factory AudiobookArtist.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudiobookArtist(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      photo: serializer.fromJson<Uint8List?>(json['photo']),
      localArtPath: serializer.fromJson<String?>(json['localArtPath']),
      bio: serializer.fromJson<String?>(json['bio']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
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
      'name': serializer.toJson<String>(name),
      'photo': serializer.toJson<Uint8List?>(photo),
      'localArtPath': serializer.toJson<String?>(localArtPath),
      'bio': serializer.toJson<String?>(bio),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'playCount': serializer.toJson<int>(playCount),
      'lastPlayed': serializer.toJson<DateTime?>(lastPlayed),
    };
  }

  AudiobookArtist copyWith({
    String? id,
    String? name,
    Value<Uint8List?> photo = const Value.absent(),
    Value<String?> localArtPath = const Value.absent(),
    Value<String?> bio = const Value.absent(),
    Value<String?> photoUrl = const Value.absent(),
    bool? isFavorite,
    int? playCount,
    Value<DateTime?> lastPlayed = const Value.absent(),
  }) => AudiobookArtist(
    id: id ?? this.id,
    name: name ?? this.name,
    photo: photo.present ? photo.value : this.photo,
    localArtPath: localArtPath.present ? localArtPath.value : this.localArtPath,
    bio: bio.present ? bio.value : this.bio,
    photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
    isFavorite: isFavorite ?? this.isFavorite,
    playCount: playCount ?? this.playCount,
    lastPlayed: lastPlayed.present ? lastPlayed.value : this.lastPlayed,
  );
  AudiobookArtist copyWithCompanion(AudiobookArtistsCompanion data) {
    return AudiobookArtist(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      photo: data.photo.present ? data.photo.value : this.photo,
      localArtPath: data.localArtPath.present
          ? data.localArtPath.value
          : this.localArtPath,
      bio: data.bio.present ? data.bio.value : this.bio,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
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
    return (StringBuffer('AudiobookArtist(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('photo: $photo, ')
          ..write('localArtPath: $localArtPath, ')
          ..write('bio: $bio, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('playCount: $playCount, ')
          ..write('lastPlayed: $lastPlayed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    $driftBlobEquality.hash(photo),
    localArtPath,
    bio,
    photoUrl,
    isFavorite,
    playCount,
    lastPlayed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudiobookArtist &&
          other.id == this.id &&
          other.name == this.name &&
          $driftBlobEquality.equals(other.photo, this.photo) &&
          other.localArtPath == this.localArtPath &&
          other.bio == this.bio &&
          other.photoUrl == this.photoUrl &&
          other.isFavorite == this.isFavorite &&
          other.playCount == this.playCount &&
          other.lastPlayed == this.lastPlayed);
}

class AudiobookArtistsCompanion extends UpdateCompanion<AudiobookArtist> {
  final Value<String> id;
  final Value<String> name;
  final Value<Uint8List?> photo;
  final Value<String?> localArtPath;
  final Value<String?> bio;
  final Value<String?> photoUrl;
  final Value<bool> isFavorite;
  final Value<int> playCount;
  final Value<DateTime?> lastPlayed;
  final Value<int> rowid;
  const AudiobookArtistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.photo = const Value.absent(),
    this.localArtPath = const Value.absent(),
    this.bio = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.playCount = const Value.absent(),
    this.lastPlayed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AudiobookArtistsCompanion.insert({
    required String id,
    required String name,
    this.photo = const Value.absent(),
    this.localArtPath = const Value.absent(),
    this.bio = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.playCount = const Value.absent(),
    this.lastPlayed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<AudiobookArtist> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<Uint8List>? photo,
    Expression<String>? localArtPath,
    Expression<String>? bio,
    Expression<String>? photoUrl,
    Expression<bool>? isFavorite,
    Expression<int>? playCount,
    Expression<DateTime>? lastPlayed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (photo != null) 'photo': photo,
      if (localArtPath != null) 'local_art_path': localArtPath,
      if (bio != null) 'bio': bio,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (playCount != null) 'play_count': playCount,
      if (lastPlayed != null) 'last_played': lastPlayed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AudiobookArtistsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<Uint8List?>? photo,
    Value<String?>? localArtPath,
    Value<String?>? bio,
    Value<String?>? photoUrl,
    Value<bool>? isFavorite,
    Value<int>? playCount,
    Value<DateTime?>? lastPlayed,
    Value<int>? rowid,
  }) {
    return AudiobookArtistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      photo: photo ?? this.photo,
      localArtPath: localArtPath ?? this.localArtPath,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (photo.present) {
      map['photo'] = Variable<Uint8List>(photo.value);
    }
    if (localArtPath.present) {
      map['local_art_path'] = Variable<String>(localArtPath.value);
    }
    if (bio.present) {
      map['bio'] = Variable<String>(bio.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
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
    return (StringBuffer('AudiobookArtistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('photo: $photo, ')
          ..write('localArtPath: $localArtPath, ')
          ..write('bio: $bio, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('playCount: $playCount, ')
          ..write('lastPlayed: $lastPlayed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AudiobooksTable extends Audiobooks
    with TableInfo<$AudiobooksTable, Audiobook> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudiobooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistIdMeta = const VerificationMeta(
    'artistId',
  );
  @override
  late final GeneratedColumn<String> artistId = GeneratedColumn<String>(
    'artist_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES audiobook_artists (id)',
    ),
  );
  static const VerificationMeta _coverArtMeta = const VerificationMeta(
    'coverArt',
  );
  @override
  late final GeneratedColumn<Uint8List> coverArt = GeneratedColumn<Uint8List>(
    'cover_art',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localArtPathMeta = const VerificationMeta(
    'localArtPath',
  );
  @override
  late final GeneratedColumn<String> localArtPath = GeneratedColumn<String>(
    'local_art_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverArtUrlMeta = const VerificationMeta(
    'coverArtUrl',
  );
  @override
  late final GeneratedColumn<String> coverArtUrl = GeneratedColumn<String>(
    'cover_art_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _asinMeta = const VerificationMeta('asin');
  @override
  late final GeneratedColumn<String> asin = GeneratedColumn<String>(
    'asin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subtitleMeta = const VerificationMeta(
    'subtitle',
  );
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
    'subtitle',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seriesNameMeta = const VerificationMeta(
    'seriesName',
  );
  @override
  late final GeneratedColumn<String> seriesName = GeneratedColumn<String>(
    'series_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seriesPositionMeta = const VerificationMeta(
    'seriesPosition',
  );
  @override
  late final GeneratedColumn<int> seriesPosition = GeneratedColumn<int>(
    'series_position',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _narratorMeta = const VerificationMeta(
    'narrator',
  );
  @override
  late final GeneratedColumn<String> narrator = GeneratedColumn<String>(
    'narrator',
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
  static const VerificationMeta _publisherMeta = const VerificationMeta(
    'publisher',
  );
  @override
  late final GeneratedColumn<String> publisher = GeneratedColumn<String>(
    'publisher',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publishedDateMeta = const VerificationMeta(
    'publishedDate',
  );
  @override
  late final GeneratedColumn<DateTime> publishedDate =
      GeneratedColumn<DateTime>(
        'published_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
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
  static const VerificationMeta _librivoxIdMeta = const VerificationMeta(
    'librivoxId',
  );
  @override
  late final GeneratedColumn<String> librivoxId = GeneratedColumn<String>(
    'librivox_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDownloadedViaAulosMeta =
      const VerificationMeta('isDownloadedViaAulos');
  @override
  late final GeneratedColumn<bool> isDownloadedViaAulos = GeneratedColumn<bool>(
    'is_downloaded_via_aulos',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_downloaded_via_aulos" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    artistId,
    coverArt,
    localArtPath,
    coverArtUrl,
    isFavorite,
    playCount,
    lastPlayed,
    asin,
    subtitle,
    seriesName,
    seriesPosition,
    narrator,
    description,
    publisher,
    publishedDate,
    isPlayed,
    librivoxId,
    isDownloadedViaAulos,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audiobooks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Audiobook> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('artist_id')) {
      context.handle(
        _artistIdMeta,
        artistId.isAcceptableOrUnknown(data['artist_id']!, _artistIdMeta),
      );
    }
    if (data.containsKey('cover_art')) {
      context.handle(
        _coverArtMeta,
        coverArt.isAcceptableOrUnknown(data['cover_art']!, _coverArtMeta),
      );
    }
    if (data.containsKey('local_art_path')) {
      context.handle(
        _localArtPathMeta,
        localArtPath.isAcceptableOrUnknown(
          data['local_art_path']!,
          _localArtPathMeta,
        ),
      );
    }
    if (data.containsKey('cover_art_url')) {
      context.handle(
        _coverArtUrlMeta,
        coverArtUrl.isAcceptableOrUnknown(
          data['cover_art_url']!,
          _coverArtUrlMeta,
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
    if (data.containsKey('asin')) {
      context.handle(
        _asinMeta,
        asin.isAcceptableOrUnknown(data['asin']!, _asinMeta),
      );
    }
    if (data.containsKey('subtitle')) {
      context.handle(
        _subtitleMeta,
        subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta),
      );
    }
    if (data.containsKey('series_name')) {
      context.handle(
        _seriesNameMeta,
        seriesName.isAcceptableOrUnknown(data['series_name']!, _seriesNameMeta),
      );
    }
    if (data.containsKey('series_position')) {
      context.handle(
        _seriesPositionMeta,
        seriesPosition.isAcceptableOrUnknown(
          data['series_position']!,
          _seriesPositionMeta,
        ),
      );
    }
    if (data.containsKey('narrator')) {
      context.handle(
        _narratorMeta,
        narrator.isAcceptableOrUnknown(data['narrator']!, _narratorMeta),
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
    if (data.containsKey('publisher')) {
      context.handle(
        _publisherMeta,
        publisher.isAcceptableOrUnknown(data['publisher']!, _publisherMeta),
      );
    }
    if (data.containsKey('published_date')) {
      context.handle(
        _publishedDateMeta,
        publishedDate.isAcceptableOrUnknown(
          data['published_date']!,
          _publishedDateMeta,
        ),
      );
    }
    if (data.containsKey('is_played')) {
      context.handle(
        _isPlayedMeta,
        isPlayed.isAcceptableOrUnknown(data['is_played']!, _isPlayedMeta),
      );
    }
    if (data.containsKey('librivox_id')) {
      context.handle(
        _librivoxIdMeta,
        librivoxId.isAcceptableOrUnknown(data['librivox_id']!, _librivoxIdMeta),
      );
    }
    if (data.containsKey('is_downloaded_via_aulos')) {
      context.handle(
        _isDownloadedViaAulosMeta,
        isDownloadedViaAulos.isAcceptableOrUnknown(
          data['is_downloaded_via_aulos']!,
          _isDownloadedViaAulosMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {name, artistId},
  ];
  @override
  Audiobook map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Audiobook(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      artistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_id'],
      ),
      coverArt: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}cover_art'],
      ),
      localArtPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_art_path'],
      ),
      coverArtUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_art_url'],
      ),
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
      asin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asin'],
      ),
      subtitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtitle'],
      ),
      seriesName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_name'],
      ),
      seriesPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}series_position'],
      ),
      narrator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}narrator'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      publisher: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}publisher'],
      ),
      publishedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}published_date'],
      ),
      isPlayed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_played'],
      )!,
      librivoxId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}librivox_id'],
      ),
      isDownloadedViaAulos: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_downloaded_via_aulos'],
      )!,
    );
  }

  @override
  $AudiobooksTable createAlias(String alias) {
    return $AudiobooksTable(attachedDatabase, alias);
  }
}

class Audiobook extends DataClass implements Insertable<Audiobook> {
  final String id;
  final String name;
  final String? artistId;
  final Uint8List? coverArt;
  final String? localArtPath;
  final String? coverArtUrl;
  final bool isFavorite;
  final int playCount;
  final DateTime? lastPlayed;
  final String? asin;
  final String? subtitle;
  final String? seriesName;
  final int? seriesPosition;
  final String? narrator;
  final String? description;
  final String? publisher;
  final DateTime? publishedDate;
  final bool isPlayed;
  final String? librivoxId;
  final bool isDownloadedViaAulos;
  const Audiobook({
    required this.id,
    required this.name,
    this.artistId,
    this.coverArt,
    this.localArtPath,
    this.coverArtUrl,
    required this.isFavorite,
    required this.playCount,
    this.lastPlayed,
    this.asin,
    this.subtitle,
    this.seriesName,
    this.seriesPosition,
    this.narrator,
    this.description,
    this.publisher,
    this.publishedDate,
    required this.isPlayed,
    this.librivoxId,
    required this.isDownloadedViaAulos,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || artistId != null) {
      map['artist_id'] = Variable<String>(artistId);
    }
    if (!nullToAbsent || coverArt != null) {
      map['cover_art'] = Variable<Uint8List>(coverArt);
    }
    if (!nullToAbsent || localArtPath != null) {
      map['local_art_path'] = Variable<String>(localArtPath);
    }
    if (!nullToAbsent || coverArtUrl != null) {
      map['cover_art_url'] = Variable<String>(coverArtUrl);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['play_count'] = Variable<int>(playCount);
    if (!nullToAbsent || lastPlayed != null) {
      map['last_played'] = Variable<DateTime>(lastPlayed);
    }
    if (!nullToAbsent || asin != null) {
      map['asin'] = Variable<String>(asin);
    }
    if (!nullToAbsent || subtitle != null) {
      map['subtitle'] = Variable<String>(subtitle);
    }
    if (!nullToAbsent || seriesName != null) {
      map['series_name'] = Variable<String>(seriesName);
    }
    if (!nullToAbsent || seriesPosition != null) {
      map['series_position'] = Variable<int>(seriesPosition);
    }
    if (!nullToAbsent || narrator != null) {
      map['narrator'] = Variable<String>(narrator);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || publisher != null) {
      map['publisher'] = Variable<String>(publisher);
    }
    if (!nullToAbsent || publishedDate != null) {
      map['published_date'] = Variable<DateTime>(publishedDate);
    }
    map['is_played'] = Variable<bool>(isPlayed);
    if (!nullToAbsent || librivoxId != null) {
      map['librivox_id'] = Variable<String>(librivoxId);
    }
    map['is_downloaded_via_aulos'] = Variable<bool>(isDownloadedViaAulos);
    return map;
  }

  AudiobooksCompanion toCompanion(bool nullToAbsent) {
    return AudiobooksCompanion(
      id: Value(id),
      name: Value(name),
      artistId: artistId == null && nullToAbsent
          ? const Value.absent()
          : Value(artistId),
      coverArt: coverArt == null && nullToAbsent
          ? const Value.absent()
          : Value(coverArt),
      localArtPath: localArtPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localArtPath),
      coverArtUrl: coverArtUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverArtUrl),
      isFavorite: Value(isFavorite),
      playCount: Value(playCount),
      lastPlayed: lastPlayed == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayed),
      asin: asin == null && nullToAbsent ? const Value.absent() : Value(asin),
      subtitle: subtitle == null && nullToAbsent
          ? const Value.absent()
          : Value(subtitle),
      seriesName: seriesName == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesName),
      seriesPosition: seriesPosition == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesPosition),
      narrator: narrator == null && nullToAbsent
          ? const Value.absent()
          : Value(narrator),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      publisher: publisher == null && nullToAbsent
          ? const Value.absent()
          : Value(publisher),
      publishedDate: publishedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(publishedDate),
      isPlayed: Value(isPlayed),
      librivoxId: librivoxId == null && nullToAbsent
          ? const Value.absent()
          : Value(librivoxId),
      isDownloadedViaAulos: Value(isDownloadedViaAulos),
    );
  }

  factory Audiobook.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Audiobook(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      artistId: serializer.fromJson<String?>(json['artistId']),
      coverArt: serializer.fromJson<Uint8List?>(json['coverArt']),
      localArtPath: serializer.fromJson<String?>(json['localArtPath']),
      coverArtUrl: serializer.fromJson<String?>(json['coverArtUrl']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      playCount: serializer.fromJson<int>(json['playCount']),
      lastPlayed: serializer.fromJson<DateTime?>(json['lastPlayed']),
      asin: serializer.fromJson<String?>(json['asin']),
      subtitle: serializer.fromJson<String?>(json['subtitle']),
      seriesName: serializer.fromJson<String?>(json['seriesName']),
      seriesPosition: serializer.fromJson<int?>(json['seriesPosition']),
      narrator: serializer.fromJson<String?>(json['narrator']),
      description: serializer.fromJson<String?>(json['description']),
      publisher: serializer.fromJson<String?>(json['publisher']),
      publishedDate: serializer.fromJson<DateTime?>(json['publishedDate']),
      isPlayed: serializer.fromJson<bool>(json['isPlayed']),
      librivoxId: serializer.fromJson<String?>(json['librivoxId']),
      isDownloadedViaAulos: serializer.fromJson<bool>(
        json['isDownloadedViaAulos'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'artistId': serializer.toJson<String?>(artistId),
      'coverArt': serializer.toJson<Uint8List?>(coverArt),
      'localArtPath': serializer.toJson<String?>(localArtPath),
      'coverArtUrl': serializer.toJson<String?>(coverArtUrl),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'playCount': serializer.toJson<int>(playCount),
      'lastPlayed': serializer.toJson<DateTime?>(lastPlayed),
      'asin': serializer.toJson<String?>(asin),
      'subtitle': serializer.toJson<String?>(subtitle),
      'seriesName': serializer.toJson<String?>(seriesName),
      'seriesPosition': serializer.toJson<int?>(seriesPosition),
      'narrator': serializer.toJson<String?>(narrator),
      'description': serializer.toJson<String?>(description),
      'publisher': serializer.toJson<String?>(publisher),
      'publishedDate': serializer.toJson<DateTime?>(publishedDate),
      'isPlayed': serializer.toJson<bool>(isPlayed),
      'librivoxId': serializer.toJson<String?>(librivoxId),
      'isDownloadedViaAulos': serializer.toJson<bool>(isDownloadedViaAulos),
    };
  }

  Audiobook copyWith({
    String? id,
    String? name,
    Value<String?> artistId = const Value.absent(),
    Value<Uint8List?> coverArt = const Value.absent(),
    Value<String?> localArtPath = const Value.absent(),
    Value<String?> coverArtUrl = const Value.absent(),
    bool? isFavorite,
    int? playCount,
    Value<DateTime?> lastPlayed = const Value.absent(),
    Value<String?> asin = const Value.absent(),
    Value<String?> subtitle = const Value.absent(),
    Value<String?> seriesName = const Value.absent(),
    Value<int?> seriesPosition = const Value.absent(),
    Value<String?> narrator = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> publisher = const Value.absent(),
    Value<DateTime?> publishedDate = const Value.absent(),
    bool? isPlayed,
    Value<String?> librivoxId = const Value.absent(),
    bool? isDownloadedViaAulos,
  }) => Audiobook(
    id: id ?? this.id,
    name: name ?? this.name,
    artistId: artistId.present ? artistId.value : this.artistId,
    coverArt: coverArt.present ? coverArt.value : this.coverArt,
    localArtPath: localArtPath.present ? localArtPath.value : this.localArtPath,
    coverArtUrl: coverArtUrl.present ? coverArtUrl.value : this.coverArtUrl,
    isFavorite: isFavorite ?? this.isFavorite,
    playCount: playCount ?? this.playCount,
    lastPlayed: lastPlayed.present ? lastPlayed.value : this.lastPlayed,
    asin: asin.present ? asin.value : this.asin,
    subtitle: subtitle.present ? subtitle.value : this.subtitle,
    seriesName: seriesName.present ? seriesName.value : this.seriesName,
    seriesPosition: seriesPosition.present
        ? seriesPosition.value
        : this.seriesPosition,
    narrator: narrator.present ? narrator.value : this.narrator,
    description: description.present ? description.value : this.description,
    publisher: publisher.present ? publisher.value : this.publisher,
    publishedDate: publishedDate.present
        ? publishedDate.value
        : this.publishedDate,
    isPlayed: isPlayed ?? this.isPlayed,
    librivoxId: librivoxId.present ? librivoxId.value : this.librivoxId,
    isDownloadedViaAulos: isDownloadedViaAulos ?? this.isDownloadedViaAulos,
  );
  Audiobook copyWithCompanion(AudiobooksCompanion data) {
    return Audiobook(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      artistId: data.artistId.present ? data.artistId.value : this.artistId,
      coverArt: data.coverArt.present ? data.coverArt.value : this.coverArt,
      localArtPath: data.localArtPath.present
          ? data.localArtPath.value
          : this.localArtPath,
      coverArtUrl: data.coverArtUrl.present
          ? data.coverArtUrl.value
          : this.coverArtUrl,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
      lastPlayed: data.lastPlayed.present
          ? data.lastPlayed.value
          : this.lastPlayed,
      asin: data.asin.present ? data.asin.value : this.asin,
      subtitle: data.subtitle.present ? data.subtitle.value : this.subtitle,
      seriesName: data.seriesName.present
          ? data.seriesName.value
          : this.seriesName,
      seriesPosition: data.seriesPosition.present
          ? data.seriesPosition.value
          : this.seriesPosition,
      narrator: data.narrator.present ? data.narrator.value : this.narrator,
      description: data.description.present
          ? data.description.value
          : this.description,
      publisher: data.publisher.present ? data.publisher.value : this.publisher,
      publishedDate: data.publishedDate.present
          ? data.publishedDate.value
          : this.publishedDate,
      isPlayed: data.isPlayed.present ? data.isPlayed.value : this.isPlayed,
      librivoxId: data.librivoxId.present
          ? data.librivoxId.value
          : this.librivoxId,
      isDownloadedViaAulos: data.isDownloadedViaAulos.present
          ? data.isDownloadedViaAulos.value
          : this.isDownloadedViaAulos,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Audiobook(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('artistId: $artistId, ')
          ..write('coverArt: $coverArt, ')
          ..write('localArtPath: $localArtPath, ')
          ..write('coverArtUrl: $coverArtUrl, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('playCount: $playCount, ')
          ..write('lastPlayed: $lastPlayed, ')
          ..write('asin: $asin, ')
          ..write('subtitle: $subtitle, ')
          ..write('seriesName: $seriesName, ')
          ..write('seriesPosition: $seriesPosition, ')
          ..write('narrator: $narrator, ')
          ..write('description: $description, ')
          ..write('publisher: $publisher, ')
          ..write('publishedDate: $publishedDate, ')
          ..write('isPlayed: $isPlayed, ')
          ..write('librivoxId: $librivoxId, ')
          ..write('isDownloadedViaAulos: $isDownloadedViaAulos')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    artistId,
    $driftBlobEquality.hash(coverArt),
    localArtPath,
    coverArtUrl,
    isFavorite,
    playCount,
    lastPlayed,
    asin,
    subtitle,
    seriesName,
    seriesPosition,
    narrator,
    description,
    publisher,
    publishedDate,
    isPlayed,
    librivoxId,
    isDownloadedViaAulos,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Audiobook &&
          other.id == this.id &&
          other.name == this.name &&
          other.artistId == this.artistId &&
          $driftBlobEquality.equals(other.coverArt, this.coverArt) &&
          other.localArtPath == this.localArtPath &&
          other.coverArtUrl == this.coverArtUrl &&
          other.isFavorite == this.isFavorite &&
          other.playCount == this.playCount &&
          other.lastPlayed == this.lastPlayed &&
          other.asin == this.asin &&
          other.subtitle == this.subtitle &&
          other.seriesName == this.seriesName &&
          other.seriesPosition == this.seriesPosition &&
          other.narrator == this.narrator &&
          other.description == this.description &&
          other.publisher == this.publisher &&
          other.publishedDate == this.publishedDate &&
          other.isPlayed == this.isPlayed &&
          other.librivoxId == this.librivoxId &&
          other.isDownloadedViaAulos == this.isDownloadedViaAulos);
}

class AudiobooksCompanion extends UpdateCompanion<Audiobook> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> artistId;
  final Value<Uint8List?> coverArt;
  final Value<String?> localArtPath;
  final Value<String?> coverArtUrl;
  final Value<bool> isFavorite;
  final Value<int> playCount;
  final Value<DateTime?> lastPlayed;
  final Value<String?> asin;
  final Value<String?> subtitle;
  final Value<String?> seriesName;
  final Value<int?> seriesPosition;
  final Value<String?> narrator;
  final Value<String?> description;
  final Value<String?> publisher;
  final Value<DateTime?> publishedDate;
  final Value<bool> isPlayed;
  final Value<String?> librivoxId;
  final Value<bool> isDownloadedViaAulos;
  final Value<int> rowid;
  const AudiobooksCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.artistId = const Value.absent(),
    this.coverArt = const Value.absent(),
    this.localArtPath = const Value.absent(),
    this.coverArtUrl = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.playCount = const Value.absent(),
    this.lastPlayed = const Value.absent(),
    this.asin = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.seriesName = const Value.absent(),
    this.seriesPosition = const Value.absent(),
    this.narrator = const Value.absent(),
    this.description = const Value.absent(),
    this.publisher = const Value.absent(),
    this.publishedDate = const Value.absent(),
    this.isPlayed = const Value.absent(),
    this.librivoxId = const Value.absent(),
    this.isDownloadedViaAulos = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AudiobooksCompanion.insert({
    required String id,
    required String name,
    this.artistId = const Value.absent(),
    this.coverArt = const Value.absent(),
    this.localArtPath = const Value.absent(),
    this.coverArtUrl = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.playCount = const Value.absent(),
    this.lastPlayed = const Value.absent(),
    this.asin = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.seriesName = const Value.absent(),
    this.seriesPosition = const Value.absent(),
    this.narrator = const Value.absent(),
    this.description = const Value.absent(),
    this.publisher = const Value.absent(),
    this.publishedDate = const Value.absent(),
    this.isPlayed = const Value.absent(),
    this.librivoxId = const Value.absent(),
    this.isDownloadedViaAulos = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Audiobook> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? artistId,
    Expression<Uint8List>? coverArt,
    Expression<String>? localArtPath,
    Expression<String>? coverArtUrl,
    Expression<bool>? isFavorite,
    Expression<int>? playCount,
    Expression<DateTime>? lastPlayed,
    Expression<String>? asin,
    Expression<String>? subtitle,
    Expression<String>? seriesName,
    Expression<int>? seriesPosition,
    Expression<String>? narrator,
    Expression<String>? description,
    Expression<String>? publisher,
    Expression<DateTime>? publishedDate,
    Expression<bool>? isPlayed,
    Expression<String>? librivoxId,
    Expression<bool>? isDownloadedViaAulos,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (artistId != null) 'artist_id': artistId,
      if (coverArt != null) 'cover_art': coverArt,
      if (localArtPath != null) 'local_art_path': localArtPath,
      if (coverArtUrl != null) 'cover_art_url': coverArtUrl,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (playCount != null) 'play_count': playCount,
      if (lastPlayed != null) 'last_played': lastPlayed,
      if (asin != null) 'asin': asin,
      if (subtitle != null) 'subtitle': subtitle,
      if (seriesName != null) 'series_name': seriesName,
      if (seriesPosition != null) 'series_position': seriesPosition,
      if (narrator != null) 'narrator': narrator,
      if (description != null) 'description': description,
      if (publisher != null) 'publisher': publisher,
      if (publishedDate != null) 'published_date': publishedDate,
      if (isPlayed != null) 'is_played': isPlayed,
      if (librivoxId != null) 'librivox_id': librivoxId,
      if (isDownloadedViaAulos != null)
        'is_downloaded_via_aulos': isDownloadedViaAulos,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AudiobooksCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? artistId,
    Value<Uint8List?>? coverArt,
    Value<String?>? localArtPath,
    Value<String?>? coverArtUrl,
    Value<bool>? isFavorite,
    Value<int>? playCount,
    Value<DateTime?>? lastPlayed,
    Value<String?>? asin,
    Value<String?>? subtitle,
    Value<String?>? seriesName,
    Value<int?>? seriesPosition,
    Value<String?>? narrator,
    Value<String?>? description,
    Value<String?>? publisher,
    Value<DateTime?>? publishedDate,
    Value<bool>? isPlayed,
    Value<String?>? librivoxId,
    Value<bool>? isDownloadedViaAulos,
    Value<int>? rowid,
  }) {
    return AudiobooksCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      artistId: artistId ?? this.artistId,
      coverArt: coverArt ?? this.coverArt,
      localArtPath: localArtPath ?? this.localArtPath,
      coverArtUrl: coverArtUrl ?? this.coverArtUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      playCount: playCount ?? this.playCount,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      asin: asin ?? this.asin,
      subtitle: subtitle ?? this.subtitle,
      seriesName: seriesName ?? this.seriesName,
      seriesPosition: seriesPosition ?? this.seriesPosition,
      narrator: narrator ?? this.narrator,
      description: description ?? this.description,
      publisher: publisher ?? this.publisher,
      publishedDate: publishedDate ?? this.publishedDate,
      isPlayed: isPlayed ?? this.isPlayed,
      librivoxId: librivoxId ?? this.librivoxId,
      isDownloadedViaAulos: isDownloadedViaAulos ?? this.isDownloadedViaAulos,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (artistId.present) {
      map['artist_id'] = Variable<String>(artistId.value);
    }
    if (coverArt.present) {
      map['cover_art'] = Variable<Uint8List>(coverArt.value);
    }
    if (localArtPath.present) {
      map['local_art_path'] = Variable<String>(localArtPath.value);
    }
    if (coverArtUrl.present) {
      map['cover_art_url'] = Variable<String>(coverArtUrl.value);
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
    if (asin.present) {
      map['asin'] = Variable<String>(asin.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (seriesName.present) {
      map['series_name'] = Variable<String>(seriesName.value);
    }
    if (seriesPosition.present) {
      map['series_position'] = Variable<int>(seriesPosition.value);
    }
    if (narrator.present) {
      map['narrator'] = Variable<String>(narrator.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (publisher.present) {
      map['publisher'] = Variable<String>(publisher.value);
    }
    if (publishedDate.present) {
      map['published_date'] = Variable<DateTime>(publishedDate.value);
    }
    if (isPlayed.present) {
      map['is_played'] = Variable<bool>(isPlayed.value);
    }
    if (librivoxId.present) {
      map['librivox_id'] = Variable<String>(librivoxId.value);
    }
    if (isDownloadedViaAulos.present) {
      map['is_downloaded_via_aulos'] = Variable<bool>(
        isDownloadedViaAulos.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudiobooksCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('artistId: $artistId, ')
          ..write('coverArt: $coverArt, ')
          ..write('localArtPath: $localArtPath, ')
          ..write('coverArtUrl: $coverArtUrl, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('playCount: $playCount, ')
          ..write('lastPlayed: $lastPlayed, ')
          ..write('asin: $asin, ')
          ..write('subtitle: $subtitle, ')
          ..write('seriesName: $seriesName, ')
          ..write('seriesPosition: $seriesPosition, ')
          ..write('narrator: $narrator, ')
          ..write('description: $description, ')
          ..write('publisher: $publisher, ')
          ..write('publishedDate: $publishedDate, ')
          ..write('isPlayed: $isPlayed, ')
          ..write('librivoxId: $librivoxId, ')
          ..write('isDownloadedViaAulos: $isDownloadedViaAulos, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AudiobookTracksTable extends AudiobookTracks
    with TableInfo<$AudiobookTracksTable, AudiobookTrack> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudiobookTracksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
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
  static const VerificationMeta _artistIdMeta = const VerificationMeta(
    'artistId',
  );
  @override
  late final GeneratedColumn<String> artistId = GeneratedColumn<String>(
    'artist_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES audiobook_artists (id)',
    ),
  );
  static const VerificationMeta _audiobookIdMeta = const VerificationMeta(
    'audiobookId',
  );
  @override
  late final GeneratedColumn<String> audiobookId = GeneratedColumn<String>(
    'audiobook_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES audiobooks (id)',
    ),
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
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _coverArtMeta = const VerificationMeta(
    'coverArt',
  );
  @override
  late final GeneratedColumn<Uint8List> coverArt = GeneratedColumn<Uint8List>(
    'cover_art',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localArtPathMeta = const VerificationMeta(
    'localArtPath',
  );
  @override
  late final GeneratedColumn<String> localArtPath = GeneratedColumn<String>(
    'local_art_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _isStreamMeta = const VerificationMeta(
    'isStream',
  );
  @override
  late final GeneratedColumn<bool> isStream = GeneratedColumn<bool>(
    'is_stream',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_stream" IN (0, 1))',
    ),
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
    path,
    title,
    artistId,
    audiobookId,
    durationSeconds,
    rating,
    coverArt,
    localArtPath,
    isFavorite,
    playCount,
    lastPlayed,
    isPlayed,
    isStream,
    duplicateOf,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audiobook_tracks';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudiobookTrack> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist_id')) {
      context.handle(
        _artistIdMeta,
        artistId.isAcceptableOrUnknown(data['artist_id']!, _artistIdMeta),
      );
    }
    if (data.containsKey('audiobook_id')) {
      context.handle(
        _audiobookIdMeta,
        audiobookId.isAcceptableOrUnknown(
          data['audiobook_id']!,
          _audiobookIdMeta,
        ),
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
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('cover_art')) {
      context.handle(
        _coverArtMeta,
        coverArt.isAcceptableOrUnknown(data['cover_art']!, _coverArtMeta),
      );
    }
    if (data.containsKey('local_art_path')) {
      context.handle(
        _localArtPathMeta,
        localArtPath.isAcceptableOrUnknown(
          data['local_art_path']!,
          _localArtPathMeta,
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
    if (data.containsKey('is_played')) {
      context.handle(
        _isPlayedMeta,
        isPlayed.isAcceptableOrUnknown(data['is_played']!, _isPlayedMeta),
      );
    }
    if (data.containsKey('is_stream')) {
      context.handle(
        _isStreamMeta,
        isStream.isAcceptableOrUnknown(data['is_stream']!, _isStreamMeta),
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
  AudiobookTrack map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudiobookTrack(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_id'],
      ),
      audiobookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audiobook_id'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      )!,
      coverArt: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}cover_art'],
      ),
      localArtPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_art_path'],
      ),
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
      isPlayed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_played'],
      )!,
      isStream: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_stream'],
      ),
      duplicateOf: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}duplicate_of'],
      ),
    );
  }

  @override
  $AudiobookTracksTable createAlias(String alias) {
    return $AudiobookTracksTable(attachedDatabase, alias);
  }
}

class AudiobookTrack extends DataClass implements Insertable<AudiobookTrack> {
  final String id;
  final String path;
  final String title;
  final String? artistId;
  final String? audiobookId;
  final int? durationSeconds;
  final int rating;
  final Uint8List? coverArt;
  final String? localArtPath;
  final bool isFavorite;
  final int playCount;
  final DateTime? lastPlayed;
  final bool isPlayed;
  final bool? isStream;
  final String? duplicateOf;
  const AudiobookTrack({
    required this.id,
    required this.path,
    required this.title,
    this.artistId,
    this.audiobookId,
    this.durationSeconds,
    required this.rating,
    this.coverArt,
    this.localArtPath,
    required this.isFavorite,
    required this.playCount,
    this.lastPlayed,
    required this.isPlayed,
    this.isStream,
    this.duplicateOf,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['path'] = Variable<String>(path);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || artistId != null) {
      map['artist_id'] = Variable<String>(artistId);
    }
    if (!nullToAbsent || audiobookId != null) {
      map['audiobook_id'] = Variable<String>(audiobookId);
    }
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    map['rating'] = Variable<int>(rating);
    if (!nullToAbsent || coverArt != null) {
      map['cover_art'] = Variable<Uint8List>(coverArt);
    }
    if (!nullToAbsent || localArtPath != null) {
      map['local_art_path'] = Variable<String>(localArtPath);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['play_count'] = Variable<int>(playCount);
    if (!nullToAbsent || lastPlayed != null) {
      map['last_played'] = Variable<DateTime>(lastPlayed);
    }
    map['is_played'] = Variable<bool>(isPlayed);
    if (!nullToAbsent || isStream != null) {
      map['is_stream'] = Variable<bool>(isStream);
    }
    if (!nullToAbsent || duplicateOf != null) {
      map['duplicate_of'] = Variable<String>(duplicateOf);
    }
    return map;
  }

  AudiobookTracksCompanion toCompanion(bool nullToAbsent) {
    return AudiobookTracksCompanion(
      id: Value(id),
      path: Value(path),
      title: Value(title),
      artistId: artistId == null && nullToAbsent
          ? const Value.absent()
          : Value(artistId),
      audiobookId: audiobookId == null && nullToAbsent
          ? const Value.absent()
          : Value(audiobookId),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      rating: Value(rating),
      coverArt: coverArt == null && nullToAbsent
          ? const Value.absent()
          : Value(coverArt),
      localArtPath: localArtPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localArtPath),
      isFavorite: Value(isFavorite),
      playCount: Value(playCount),
      lastPlayed: lastPlayed == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayed),
      isPlayed: Value(isPlayed),
      isStream: isStream == null && nullToAbsent
          ? const Value.absent()
          : Value(isStream),
      duplicateOf: duplicateOf == null && nullToAbsent
          ? const Value.absent()
          : Value(duplicateOf),
    );
  }

  factory AudiobookTrack.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudiobookTrack(
      id: serializer.fromJson<String>(json['id']),
      path: serializer.fromJson<String>(json['path']),
      title: serializer.fromJson<String>(json['title']),
      artistId: serializer.fromJson<String?>(json['artistId']),
      audiobookId: serializer.fromJson<String?>(json['audiobookId']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      rating: serializer.fromJson<int>(json['rating']),
      coverArt: serializer.fromJson<Uint8List?>(json['coverArt']),
      localArtPath: serializer.fromJson<String?>(json['localArtPath']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      playCount: serializer.fromJson<int>(json['playCount']),
      lastPlayed: serializer.fromJson<DateTime?>(json['lastPlayed']),
      isPlayed: serializer.fromJson<bool>(json['isPlayed']),
      isStream: serializer.fromJson<bool?>(json['isStream']),
      duplicateOf: serializer.fromJson<String?>(json['duplicateOf']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'path': serializer.toJson<String>(path),
      'title': serializer.toJson<String>(title),
      'artistId': serializer.toJson<String?>(artistId),
      'audiobookId': serializer.toJson<String?>(audiobookId),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'rating': serializer.toJson<int>(rating),
      'coverArt': serializer.toJson<Uint8List?>(coverArt),
      'localArtPath': serializer.toJson<String?>(localArtPath),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'playCount': serializer.toJson<int>(playCount),
      'lastPlayed': serializer.toJson<DateTime?>(lastPlayed),
      'isPlayed': serializer.toJson<bool>(isPlayed),
      'isStream': serializer.toJson<bool?>(isStream),
      'duplicateOf': serializer.toJson<String?>(duplicateOf),
    };
  }

  AudiobookTrack copyWith({
    String? id,
    String? path,
    String? title,
    Value<String?> artistId = const Value.absent(),
    Value<String?> audiobookId = const Value.absent(),
    Value<int?> durationSeconds = const Value.absent(),
    int? rating,
    Value<Uint8List?> coverArt = const Value.absent(),
    Value<String?> localArtPath = const Value.absent(),
    bool? isFavorite,
    int? playCount,
    Value<DateTime?> lastPlayed = const Value.absent(),
    bool? isPlayed,
    Value<bool?> isStream = const Value.absent(),
    Value<String?> duplicateOf = const Value.absent(),
  }) => AudiobookTrack(
    id: id ?? this.id,
    path: path ?? this.path,
    title: title ?? this.title,
    artistId: artistId.present ? artistId.value : this.artistId,
    audiobookId: audiobookId.present ? audiobookId.value : this.audiobookId,
    durationSeconds: durationSeconds.present
        ? durationSeconds.value
        : this.durationSeconds,
    rating: rating ?? this.rating,
    coverArt: coverArt.present ? coverArt.value : this.coverArt,
    localArtPath: localArtPath.present ? localArtPath.value : this.localArtPath,
    isFavorite: isFavorite ?? this.isFavorite,
    playCount: playCount ?? this.playCount,
    lastPlayed: lastPlayed.present ? lastPlayed.value : this.lastPlayed,
    isPlayed: isPlayed ?? this.isPlayed,
    isStream: isStream.present ? isStream.value : this.isStream,
    duplicateOf: duplicateOf.present ? duplicateOf.value : this.duplicateOf,
  );
  AudiobookTrack copyWithCompanion(AudiobookTracksCompanion data) {
    return AudiobookTrack(
      id: data.id.present ? data.id.value : this.id,
      path: data.path.present ? data.path.value : this.path,
      title: data.title.present ? data.title.value : this.title,
      artistId: data.artistId.present ? data.artistId.value : this.artistId,
      audiobookId: data.audiobookId.present
          ? data.audiobookId.value
          : this.audiobookId,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      rating: data.rating.present ? data.rating.value : this.rating,
      coverArt: data.coverArt.present ? data.coverArt.value : this.coverArt,
      localArtPath: data.localArtPath.present
          ? data.localArtPath.value
          : this.localArtPath,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
      lastPlayed: data.lastPlayed.present
          ? data.lastPlayed.value
          : this.lastPlayed,
      isPlayed: data.isPlayed.present ? data.isPlayed.value : this.isPlayed,
      isStream: data.isStream.present ? data.isStream.value : this.isStream,
      duplicateOf: data.duplicateOf.present
          ? data.duplicateOf.value
          : this.duplicateOf,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudiobookTrack(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('title: $title, ')
          ..write('artistId: $artistId, ')
          ..write('audiobookId: $audiobookId, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('rating: $rating, ')
          ..write('coverArt: $coverArt, ')
          ..write('localArtPath: $localArtPath, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('playCount: $playCount, ')
          ..write('lastPlayed: $lastPlayed, ')
          ..write('isPlayed: $isPlayed, ')
          ..write('isStream: $isStream, ')
          ..write('duplicateOf: $duplicateOf')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    path,
    title,
    artistId,
    audiobookId,
    durationSeconds,
    rating,
    $driftBlobEquality.hash(coverArt),
    localArtPath,
    isFavorite,
    playCount,
    lastPlayed,
    isPlayed,
    isStream,
    duplicateOf,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudiobookTrack &&
          other.id == this.id &&
          other.path == this.path &&
          other.title == this.title &&
          other.artistId == this.artistId &&
          other.audiobookId == this.audiobookId &&
          other.durationSeconds == this.durationSeconds &&
          other.rating == this.rating &&
          $driftBlobEquality.equals(other.coverArt, this.coverArt) &&
          other.localArtPath == this.localArtPath &&
          other.isFavorite == this.isFavorite &&
          other.playCount == this.playCount &&
          other.lastPlayed == this.lastPlayed &&
          other.isPlayed == this.isPlayed &&
          other.isStream == this.isStream &&
          other.duplicateOf == this.duplicateOf);
}

class AudiobookTracksCompanion extends UpdateCompanion<AudiobookTrack> {
  final Value<String> id;
  final Value<String> path;
  final Value<String> title;
  final Value<String?> artistId;
  final Value<String?> audiobookId;
  final Value<int?> durationSeconds;
  final Value<int> rating;
  final Value<Uint8List?> coverArt;
  final Value<String?> localArtPath;
  final Value<bool> isFavorite;
  final Value<int> playCount;
  final Value<DateTime?> lastPlayed;
  final Value<bool> isPlayed;
  final Value<bool?> isStream;
  final Value<String?> duplicateOf;
  final Value<int> rowid;
  const AudiobookTracksCompanion({
    this.id = const Value.absent(),
    this.path = const Value.absent(),
    this.title = const Value.absent(),
    this.artistId = const Value.absent(),
    this.audiobookId = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.rating = const Value.absent(),
    this.coverArt = const Value.absent(),
    this.localArtPath = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.playCount = const Value.absent(),
    this.lastPlayed = const Value.absent(),
    this.isPlayed = const Value.absent(),
    this.isStream = const Value.absent(),
    this.duplicateOf = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AudiobookTracksCompanion.insert({
    required String id,
    required String path,
    required String title,
    this.artistId = const Value.absent(),
    this.audiobookId = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.rating = const Value.absent(),
    this.coverArt = const Value.absent(),
    this.localArtPath = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.playCount = const Value.absent(),
    this.lastPlayed = const Value.absent(),
    this.isPlayed = const Value.absent(),
    this.isStream = const Value.absent(),
    this.duplicateOf = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       path = Value(path),
       title = Value(title);
  static Insertable<AudiobookTrack> custom({
    Expression<String>? id,
    Expression<String>? path,
    Expression<String>? title,
    Expression<String>? artistId,
    Expression<String>? audiobookId,
    Expression<int>? durationSeconds,
    Expression<int>? rating,
    Expression<Uint8List>? coverArt,
    Expression<String>? localArtPath,
    Expression<bool>? isFavorite,
    Expression<int>? playCount,
    Expression<DateTime>? lastPlayed,
    Expression<bool>? isPlayed,
    Expression<bool>? isStream,
    Expression<String>? duplicateOf,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (path != null) 'path': path,
      if (title != null) 'title': title,
      if (artistId != null) 'artist_id': artistId,
      if (audiobookId != null) 'audiobook_id': audiobookId,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (rating != null) 'rating': rating,
      if (coverArt != null) 'cover_art': coverArt,
      if (localArtPath != null) 'local_art_path': localArtPath,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (playCount != null) 'play_count': playCount,
      if (lastPlayed != null) 'last_played': lastPlayed,
      if (isPlayed != null) 'is_played': isPlayed,
      if (isStream != null) 'is_stream': isStream,
      if (duplicateOf != null) 'duplicate_of': duplicateOf,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AudiobookTracksCompanion copyWith({
    Value<String>? id,
    Value<String>? path,
    Value<String>? title,
    Value<String?>? artistId,
    Value<String?>? audiobookId,
    Value<int?>? durationSeconds,
    Value<int>? rating,
    Value<Uint8List?>? coverArt,
    Value<String?>? localArtPath,
    Value<bool>? isFavorite,
    Value<int>? playCount,
    Value<DateTime?>? lastPlayed,
    Value<bool>? isPlayed,
    Value<bool?>? isStream,
    Value<String?>? duplicateOf,
    Value<int>? rowid,
  }) {
    return AudiobookTracksCompanion(
      id: id ?? this.id,
      path: path ?? this.path,
      title: title ?? this.title,
      artistId: artistId ?? this.artistId,
      audiobookId: audiobookId ?? this.audiobookId,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      rating: rating ?? this.rating,
      coverArt: coverArt ?? this.coverArt,
      localArtPath: localArtPath ?? this.localArtPath,
      isFavorite: isFavorite ?? this.isFavorite,
      playCount: playCount ?? this.playCount,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      isPlayed: isPlayed ?? this.isPlayed,
      isStream: isStream ?? this.isStream,
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
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artistId.present) {
      map['artist_id'] = Variable<String>(artistId.value);
    }
    if (audiobookId.present) {
      map['audiobook_id'] = Variable<String>(audiobookId.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (coverArt.present) {
      map['cover_art'] = Variable<Uint8List>(coverArt.value);
    }
    if (localArtPath.present) {
      map['local_art_path'] = Variable<String>(localArtPath.value);
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
    if (isPlayed.present) {
      map['is_played'] = Variable<bool>(isPlayed.value);
    }
    if (isStream.present) {
      map['is_stream'] = Variable<bool>(isStream.value);
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
    return (StringBuffer('AudiobookTracksCompanion(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('title: $title, ')
          ..write('artistId: $artistId, ')
          ..write('audiobookId: $audiobookId, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('rating: $rating, ')
          ..write('coverArt: $coverArt, ')
          ..write('localArtPath: $localArtPath, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('playCount: $playCount, ')
          ..write('lastPlayed: $lastPlayed, ')
          ..write('isPlayed: $isPlayed, ')
          ..write('isStream: $isStream, ')
          ..write('duplicateOf: $duplicateOf, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AudiobookChaptersTable extends AudiobookChapters
    with TableInfo<$AudiobookChaptersTable, AudiobookChapter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudiobookChaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _audiobookTrackIdMeta = const VerificationMeta(
    'audiobookTrackId',
  );
  @override
  late final GeneratedColumn<String> audiobookTrackId = GeneratedColumn<String>(
    'audiobook_track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES audiobook_tracks (id)',
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
  static const VerificationMeta _startTimeMsMeta = const VerificationMeta(
    'startTimeMs',
  );
  @override
  late final GeneratedColumn<int> startTimeMs = GeneratedColumn<int>(
    'start_time_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    audiobookTrackId,
    title,
    startTimeMs,
    durationMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audiobook_chapters';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudiobookChapter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('audiobook_track_id')) {
      context.handle(
        _audiobookTrackIdMeta,
        audiobookTrackId.isAcceptableOrUnknown(
          data['audiobook_track_id']!,
          _audiobookTrackIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_audiobookTrackIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('start_time_ms')) {
      context.handle(
        _startTimeMsMeta,
        startTimeMs.isAcceptableOrUnknown(
          data['start_time_ms']!,
          _startTimeMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startTimeMsMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  AudiobookChapter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudiobookChapter(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      audiobookTrackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audiobook_track_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      startTimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_time_ms'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
    );
  }

  @override
  $AudiobookChaptersTable createAlias(String alias) {
    return $AudiobookChaptersTable(attachedDatabase, alias);
  }
}

class AudiobookChapter extends DataClass
    implements Insertable<AudiobookChapter> {
  final String id;
  final String audiobookTrackId;
  final String title;
  final int startTimeMs;
  final int? durationMs;
  const AudiobookChapter({
    required this.id,
    required this.audiobookTrackId,
    required this.title,
    required this.startTimeMs,
    this.durationMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['audiobook_track_id'] = Variable<String>(audiobookTrackId);
    map['title'] = Variable<String>(title);
    map['start_time_ms'] = Variable<int>(startTimeMs);
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    return map;
  }

  AudiobookChaptersCompanion toCompanion(bool nullToAbsent) {
    return AudiobookChaptersCompanion(
      id: Value(id),
      audiobookTrackId: Value(audiobookTrackId),
      title: Value(title),
      startTimeMs: Value(startTimeMs),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
    );
  }

  factory AudiobookChapter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudiobookChapter(
      id: serializer.fromJson<String>(json['id']),
      audiobookTrackId: serializer.fromJson<String>(json['audiobookTrackId']),
      title: serializer.fromJson<String>(json['title']),
      startTimeMs: serializer.fromJson<int>(json['startTimeMs']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'audiobookTrackId': serializer.toJson<String>(audiobookTrackId),
      'title': serializer.toJson<String>(title),
      'startTimeMs': serializer.toJson<int>(startTimeMs),
      'durationMs': serializer.toJson<int?>(durationMs),
    };
  }

  AudiobookChapter copyWith({
    String? id,
    String? audiobookTrackId,
    String? title,
    int? startTimeMs,
    Value<int?> durationMs = const Value.absent(),
  }) => AudiobookChapter(
    id: id ?? this.id,
    audiobookTrackId: audiobookTrackId ?? this.audiobookTrackId,
    title: title ?? this.title,
    startTimeMs: startTimeMs ?? this.startTimeMs,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
  );
  AudiobookChapter copyWithCompanion(AudiobookChaptersCompanion data) {
    return AudiobookChapter(
      id: data.id.present ? data.id.value : this.id,
      audiobookTrackId: data.audiobookTrackId.present
          ? data.audiobookTrackId.value
          : this.audiobookTrackId,
      title: data.title.present ? data.title.value : this.title,
      startTimeMs: data.startTimeMs.present
          ? data.startTimeMs.value
          : this.startTimeMs,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudiobookChapter(')
          ..write('id: $id, ')
          ..write('audiobookTrackId: $audiobookTrackId, ')
          ..write('title: $title, ')
          ..write('startTimeMs: $startTimeMs, ')
          ..write('durationMs: $durationMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, audiobookTrackId, title, startTimeMs, durationMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudiobookChapter &&
          other.id == this.id &&
          other.audiobookTrackId == this.audiobookTrackId &&
          other.title == this.title &&
          other.startTimeMs == this.startTimeMs &&
          other.durationMs == this.durationMs);
}

class AudiobookChaptersCompanion extends UpdateCompanion<AudiobookChapter> {
  final Value<String> id;
  final Value<String> audiobookTrackId;
  final Value<String> title;
  final Value<int> startTimeMs;
  final Value<int?> durationMs;
  final Value<int> rowid;
  const AudiobookChaptersCompanion({
    this.id = const Value.absent(),
    this.audiobookTrackId = const Value.absent(),
    this.title = const Value.absent(),
    this.startTimeMs = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AudiobookChaptersCompanion.insert({
    required String id,
    required String audiobookTrackId,
    required String title,
    required int startTimeMs,
    this.durationMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       audiobookTrackId = Value(audiobookTrackId),
       title = Value(title),
       startTimeMs = Value(startTimeMs);
  static Insertable<AudiobookChapter> custom({
    Expression<String>? id,
    Expression<String>? audiobookTrackId,
    Expression<String>? title,
    Expression<int>? startTimeMs,
    Expression<int>? durationMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (audiobookTrackId != null) 'audiobook_track_id': audiobookTrackId,
      if (title != null) 'title': title,
      if (startTimeMs != null) 'start_time_ms': startTimeMs,
      if (durationMs != null) 'duration_ms': durationMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AudiobookChaptersCompanion copyWith({
    Value<String>? id,
    Value<String>? audiobookTrackId,
    Value<String>? title,
    Value<int>? startTimeMs,
    Value<int?>? durationMs,
    Value<int>? rowid,
  }) {
    return AudiobookChaptersCompanion(
      id: id ?? this.id,
      audiobookTrackId: audiobookTrackId ?? this.audiobookTrackId,
      title: title ?? this.title,
      startTimeMs: startTimeMs ?? this.startTimeMs,
      durationMs: durationMs ?? this.durationMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (audiobookTrackId.present) {
      map['audiobook_track_id'] = Variable<String>(audiobookTrackId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (startTimeMs.present) {
      map['start_time_ms'] = Variable<int>(startTimeMs.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudiobookChaptersCompanion(')
          ..write('id: $id, ')
          ..write('audiobookTrackId: $audiobookTrackId, ')
          ..write('title: $title, ')
          ..write('startTimeMs: $startTimeMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AudiobookDatabase extends GeneratedDatabase {
  _$AudiobookDatabase(QueryExecutor e) : super(e);
  $AudiobookDatabaseManager get managers => $AudiobookDatabaseManager(this);
  late final $AudiobookFoldersTable audiobookFolders = $AudiobookFoldersTable(
    this,
  );
  late final $AudiobookArtistsTable audiobookArtists = $AudiobookArtistsTable(
    this,
  );
  late final $AudiobooksTable audiobooks = $AudiobooksTable(this);
  late final $AudiobookTracksTable audiobookTracks = $AudiobookTracksTable(
    this,
  );
  late final $AudiobookChaptersTable audiobookChapters =
      $AudiobookChaptersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    audiobookFolders,
    audiobookArtists,
    audiobooks,
    audiobookTracks,
    audiobookChapters,
  ];
}

typedef $$AudiobookFoldersTableCreateCompanionBuilder =
    AudiobookFoldersCompanion Function({
      required String id,
      required String path,
      required String name,
      Value<String?> parentId,
      Value<int> rowid,
    });
typedef $$AudiobookFoldersTableUpdateCompanionBuilder =
    AudiobookFoldersCompanion Function({
      Value<String> id,
      Value<String> path,
      Value<String> name,
      Value<String?> parentId,
      Value<int> rowid,
    });

final class $$AudiobookFoldersTableReferences
    extends
        BaseReferences<
          _$AudiobookDatabase,
          $AudiobookFoldersTable,
          AudiobookFolder
        > {
  $$AudiobookFoldersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AudiobookFoldersTable _parentIdTable(_$AudiobookDatabase db) => db
      .audiobookFolders
      .createAlias('audiobook_folders__parent_id__audiobook_folders__id');

  $$AudiobookFoldersTableProcessedTableManager? get parentId {
    final $_column = $_itemColumn<String>('parent_id');
    if ($_column == null) return null;
    final manager = $$AudiobookFoldersTableTableManager(
      $_db,
      $_db.audiobookFolders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AudiobookFoldersTableFilterComposer
    extends Composer<_$AudiobookDatabase, $AudiobookFoldersTable> {
  $$AudiobookFoldersTableFilterComposer({
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

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  $$AudiobookFoldersTableFilterComposer get parentId {
    final $$AudiobookFoldersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.audiobookFolders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudiobookFoldersTableFilterComposer(
            $db: $db,
            $table: $db.audiobookFolders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AudiobookFoldersTableOrderingComposer
    extends Composer<_$AudiobookDatabase, $AudiobookFoldersTable> {
  $$AudiobookFoldersTableOrderingComposer({
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

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  $$AudiobookFoldersTableOrderingComposer get parentId {
    final $$AudiobookFoldersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.audiobookFolders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudiobookFoldersTableOrderingComposer(
            $db: $db,
            $table: $db.audiobookFolders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AudiobookFoldersTableAnnotationComposer
    extends Composer<_$AudiobookDatabase, $AudiobookFoldersTable> {
  $$AudiobookFoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  $$AudiobookFoldersTableAnnotationComposer get parentId {
    final $$AudiobookFoldersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.audiobookFolders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudiobookFoldersTableAnnotationComposer(
            $db: $db,
            $table: $db.audiobookFolders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AudiobookFoldersTableTableManager
    extends
        RootTableManager<
          _$AudiobookDatabase,
          $AudiobookFoldersTable,
          AudiobookFolder,
          $$AudiobookFoldersTableFilterComposer,
          $$AudiobookFoldersTableOrderingComposer,
          $$AudiobookFoldersTableAnnotationComposer,
          $$AudiobookFoldersTableCreateCompanionBuilder,
          $$AudiobookFoldersTableUpdateCompanionBuilder,
          (AudiobookFolder, $$AudiobookFoldersTableReferences),
          AudiobookFolder,
          PrefetchHooks Function({bool parentId})
        > {
  $$AudiobookFoldersTableTableManager(
    _$AudiobookDatabase db,
    $AudiobookFoldersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudiobookFoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudiobookFoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudiobookFoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudiobookFoldersCompanion(
                id: id,
                path: path,
                name: name,
                parentId: parentId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String path,
                required String name,
                Value<String?> parentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudiobookFoldersCompanion.insert(
                id: id,
                path: path,
                name: name,
                parentId: parentId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AudiobookFoldersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({parentId = false}) {
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
                    if (parentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.parentId,
                                referencedTable:
                                    $$AudiobookFoldersTableReferences
                                        ._parentIdTable(db),
                                referencedColumn:
                                    $$AudiobookFoldersTableReferences
                                        ._parentIdTable(db)
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

typedef $$AudiobookFoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$AudiobookDatabase,
      $AudiobookFoldersTable,
      AudiobookFolder,
      $$AudiobookFoldersTableFilterComposer,
      $$AudiobookFoldersTableOrderingComposer,
      $$AudiobookFoldersTableAnnotationComposer,
      $$AudiobookFoldersTableCreateCompanionBuilder,
      $$AudiobookFoldersTableUpdateCompanionBuilder,
      (AudiobookFolder, $$AudiobookFoldersTableReferences),
      AudiobookFolder,
      PrefetchHooks Function({bool parentId})
    >;
typedef $$AudiobookArtistsTableCreateCompanionBuilder =
    AudiobookArtistsCompanion Function({
      required String id,
      required String name,
      Value<Uint8List?> photo,
      Value<String?> localArtPath,
      Value<String?> bio,
      Value<String?> photoUrl,
      Value<bool> isFavorite,
      Value<int> playCount,
      Value<DateTime?> lastPlayed,
      Value<int> rowid,
    });
typedef $$AudiobookArtistsTableUpdateCompanionBuilder =
    AudiobookArtistsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<Uint8List?> photo,
      Value<String?> localArtPath,
      Value<String?> bio,
      Value<String?> photoUrl,
      Value<bool> isFavorite,
      Value<int> playCount,
      Value<DateTime?> lastPlayed,
      Value<int> rowid,
    });

final class $$AudiobookArtistsTableReferences
    extends
        BaseReferences<
          _$AudiobookDatabase,
          $AudiobookArtistsTable,
          AudiobookArtist
        > {
  $$AudiobookArtistsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$AudiobooksTable, List<Audiobook>>
  _audiobooksRefsTable(_$AudiobookDatabase db) => MultiTypedResultKey.fromTable(
    db.audiobooks,
    aliasName: 'audiobook_artists__id__audiobooks__artist_id',
  );

  $$AudiobooksTableProcessedTableManager get audiobooksRefs {
    final manager = $$AudiobooksTableTableManager(
      $_db,
      $_db.audiobooks,
    ).filter((f) => f.artistId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_audiobooksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AudiobookTracksTable, List<AudiobookTrack>>
  _audiobookTracksRefsTable(_$AudiobookDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.audiobookTracks,
        aliasName: 'audiobook_artists__id__audiobook_tracks__artist_id',
      );

  $$AudiobookTracksTableProcessedTableManager get audiobookTracksRefs {
    final manager = $$AudiobookTracksTableTableManager(
      $_db,
      $_db.audiobookTracks,
    ).filter((f) => f.artistId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _audiobookTracksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AudiobookArtistsTableFilterComposer
    extends Composer<_$AudiobookDatabase, $AudiobookArtistsTable> {
  $$AudiobookArtistsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get photo => $composableBuilder(
    column: $table.photo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localArtPath => $composableBuilder(
    column: $table.localArtPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bio => $composableBuilder(
    column: $table.bio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
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

  Expression<bool> audiobooksRefs(
    Expression<bool> Function($$AudiobooksTableFilterComposer f) f,
  ) {
    final $$AudiobooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audiobooks,
      getReferencedColumn: (t) => t.artistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudiobooksTableFilterComposer(
            $db: $db,
            $table: $db.audiobooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> audiobookTracksRefs(
    Expression<bool> Function($$AudiobookTracksTableFilterComposer f) f,
  ) {
    final $$AudiobookTracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audiobookTracks,
      getReferencedColumn: (t) => t.artistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudiobookTracksTableFilterComposer(
            $db: $db,
            $table: $db.audiobookTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AudiobookArtistsTableOrderingComposer
    extends Composer<_$AudiobookDatabase, $AudiobookArtistsTable> {
  $$AudiobookArtistsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get photo => $composableBuilder(
    column: $table.photo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localArtPath => $composableBuilder(
    column: $table.localArtPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bio => $composableBuilder(
    column: $table.bio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
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

class $$AudiobookArtistsTableAnnotationComposer
    extends Composer<_$AudiobookDatabase, $AudiobookArtistsTable> {
  $$AudiobookArtistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<Uint8List> get photo =>
      $composableBuilder(column: $table.photo, builder: (column) => column);

  GeneratedColumn<String> get localArtPath => $composableBuilder(
    column: $table.localArtPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bio =>
      $composableBuilder(column: $table.bio, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

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

  Expression<T> audiobooksRefs<T extends Object>(
    Expression<T> Function($$AudiobooksTableAnnotationComposer a) f,
  ) {
    final $$AudiobooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audiobooks,
      getReferencedColumn: (t) => t.artistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudiobooksTableAnnotationComposer(
            $db: $db,
            $table: $db.audiobooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> audiobookTracksRefs<T extends Object>(
    Expression<T> Function($$AudiobookTracksTableAnnotationComposer a) f,
  ) {
    final $$AudiobookTracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audiobookTracks,
      getReferencedColumn: (t) => t.artistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudiobookTracksTableAnnotationComposer(
            $db: $db,
            $table: $db.audiobookTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AudiobookArtistsTableTableManager
    extends
        RootTableManager<
          _$AudiobookDatabase,
          $AudiobookArtistsTable,
          AudiobookArtist,
          $$AudiobookArtistsTableFilterComposer,
          $$AudiobookArtistsTableOrderingComposer,
          $$AudiobookArtistsTableAnnotationComposer,
          $$AudiobookArtistsTableCreateCompanionBuilder,
          $$AudiobookArtistsTableUpdateCompanionBuilder,
          (AudiobookArtist, $$AudiobookArtistsTableReferences),
          AudiobookArtist,
          PrefetchHooks Function({
            bool audiobooksRefs,
            bool audiobookTracksRefs,
          })
        > {
  $$AudiobookArtistsTableTableManager(
    _$AudiobookDatabase db,
    $AudiobookArtistsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudiobookArtistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudiobookArtistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudiobookArtistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<Uint8List?> photo = const Value.absent(),
                Value<String?> localArtPath = const Value.absent(),
                Value<String?> bio = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<DateTime?> lastPlayed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudiobookArtistsCompanion(
                id: id,
                name: name,
                photo: photo,
                localArtPath: localArtPath,
                bio: bio,
                photoUrl: photoUrl,
                isFavorite: isFavorite,
                playCount: playCount,
                lastPlayed: lastPlayed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<Uint8List?> photo = const Value.absent(),
                Value<String?> localArtPath = const Value.absent(),
                Value<String?> bio = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<DateTime?> lastPlayed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudiobookArtistsCompanion.insert(
                id: id,
                name: name,
                photo: photo,
                localArtPath: localArtPath,
                bio: bio,
                photoUrl: photoUrl,
                isFavorite: isFavorite,
                playCount: playCount,
                lastPlayed: lastPlayed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AudiobookArtistsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({audiobooksRefs = false, audiobookTracksRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (audiobooksRefs) db.audiobooks,
                    if (audiobookTracksRefs) db.audiobookTracks,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (audiobooksRefs)
                        await $_getPrefetchedData<
                          AudiobookArtist,
                          $AudiobookArtistsTable,
                          Audiobook
                        >(
                          currentTable: table,
                          referencedTable: $$AudiobookArtistsTableReferences
                              ._audiobooksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AudiobookArtistsTableReferences(
                                db,
                                table,
                                p0,
                              ).audiobooksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.artistId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (audiobookTracksRefs)
                        await $_getPrefetchedData<
                          AudiobookArtist,
                          $AudiobookArtistsTable,
                          AudiobookTrack
                        >(
                          currentTable: table,
                          referencedTable: $$AudiobookArtistsTableReferences
                              ._audiobookTracksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AudiobookArtistsTableReferences(
                                db,
                                table,
                                p0,
                              ).audiobookTracksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.artistId == item.id,
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

typedef $$AudiobookArtistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AudiobookDatabase,
      $AudiobookArtistsTable,
      AudiobookArtist,
      $$AudiobookArtistsTableFilterComposer,
      $$AudiobookArtistsTableOrderingComposer,
      $$AudiobookArtistsTableAnnotationComposer,
      $$AudiobookArtistsTableCreateCompanionBuilder,
      $$AudiobookArtistsTableUpdateCompanionBuilder,
      (AudiobookArtist, $$AudiobookArtistsTableReferences),
      AudiobookArtist,
      PrefetchHooks Function({bool audiobooksRefs, bool audiobookTracksRefs})
    >;
typedef $$AudiobooksTableCreateCompanionBuilder =
    AudiobooksCompanion Function({
      required String id,
      required String name,
      Value<String?> artistId,
      Value<Uint8List?> coverArt,
      Value<String?> localArtPath,
      Value<String?> coverArtUrl,
      Value<bool> isFavorite,
      Value<int> playCount,
      Value<DateTime?> lastPlayed,
      Value<String?> asin,
      Value<String?> subtitle,
      Value<String?> seriesName,
      Value<int?> seriesPosition,
      Value<String?> narrator,
      Value<String?> description,
      Value<String?> publisher,
      Value<DateTime?> publishedDate,
      Value<bool> isPlayed,
      Value<String?> librivoxId,
      Value<bool> isDownloadedViaAulos,
      Value<int> rowid,
    });
typedef $$AudiobooksTableUpdateCompanionBuilder =
    AudiobooksCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> artistId,
      Value<Uint8List?> coverArt,
      Value<String?> localArtPath,
      Value<String?> coverArtUrl,
      Value<bool> isFavorite,
      Value<int> playCount,
      Value<DateTime?> lastPlayed,
      Value<String?> asin,
      Value<String?> subtitle,
      Value<String?> seriesName,
      Value<int?> seriesPosition,
      Value<String?> narrator,
      Value<String?> description,
      Value<String?> publisher,
      Value<DateTime?> publishedDate,
      Value<bool> isPlayed,
      Value<String?> librivoxId,
      Value<bool> isDownloadedViaAulos,
      Value<int> rowid,
    });

final class $$AudiobooksTableReferences
    extends BaseReferences<_$AudiobookDatabase, $AudiobooksTable, Audiobook> {
  $$AudiobooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AudiobookArtistsTable _artistIdTable(_$AudiobookDatabase db) => db
      .audiobookArtists
      .createAlias('audiobooks__artist_id__audiobook_artists__id');

  $$AudiobookArtistsTableProcessedTableManager? get artistId {
    final $_column = $_itemColumn<String>('artist_id');
    if ($_column == null) return null;
    final manager = $$AudiobookArtistsTableTableManager(
      $_db,
      $_db.audiobookArtists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_artistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AudiobookTracksTable, List<AudiobookTrack>>
  _audiobookTracksRefsTable(_$AudiobookDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.audiobookTracks,
        aliasName: 'audiobooks__id__audiobook_tracks__audiobook_id',
      );

  $$AudiobookTracksTableProcessedTableManager get audiobookTracksRefs {
    final manager = $$AudiobookTracksTableTableManager(
      $_db,
      $_db.audiobookTracks,
    ).filter((f) => f.audiobookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _audiobookTracksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AudiobooksTableFilterComposer
    extends Composer<_$AudiobookDatabase, $AudiobooksTable> {
  $$AudiobooksTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get coverArt => $composableBuilder(
    column: $table.coverArt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localArtPath => $composableBuilder(
    column: $table.localArtPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverArtUrl => $composableBuilder(
    column: $table.coverArtUrl,
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

  ColumnFilters<String> get asin => $composableBuilder(
    column: $table.asin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seriesName => $composableBuilder(
    column: $table.seriesName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seriesPosition => $composableBuilder(
    column: $table.seriesPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get narrator => $composableBuilder(
    column: $table.narrator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publisher => $composableBuilder(
    column: $table.publisher,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get publishedDate => $composableBuilder(
    column: $table.publishedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPlayed => $composableBuilder(
    column: $table.isPlayed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get librivoxId => $composableBuilder(
    column: $table.librivoxId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDownloadedViaAulos => $composableBuilder(
    column: $table.isDownloadedViaAulos,
    builder: (column) => ColumnFilters(column),
  );

  $$AudiobookArtistsTableFilterComposer get artistId {
    final $$AudiobookArtistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artistId,
      referencedTable: $db.audiobookArtists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudiobookArtistsTableFilterComposer(
            $db: $db,
            $table: $db.audiobookArtists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> audiobookTracksRefs(
    Expression<bool> Function($$AudiobookTracksTableFilterComposer f) f,
  ) {
    final $$AudiobookTracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audiobookTracks,
      getReferencedColumn: (t) => t.audiobookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudiobookTracksTableFilterComposer(
            $db: $db,
            $table: $db.audiobookTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AudiobooksTableOrderingComposer
    extends Composer<_$AudiobookDatabase, $AudiobooksTable> {
  $$AudiobooksTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get coverArt => $composableBuilder(
    column: $table.coverArt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localArtPath => $composableBuilder(
    column: $table.localArtPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverArtUrl => $composableBuilder(
    column: $table.coverArtUrl,
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

  ColumnOrderings<String> get asin => $composableBuilder(
    column: $table.asin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seriesName => $composableBuilder(
    column: $table.seriesName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seriesPosition => $composableBuilder(
    column: $table.seriesPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get narrator => $composableBuilder(
    column: $table.narrator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publisher => $composableBuilder(
    column: $table.publisher,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get publishedDate => $composableBuilder(
    column: $table.publishedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPlayed => $composableBuilder(
    column: $table.isPlayed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get librivoxId => $composableBuilder(
    column: $table.librivoxId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDownloadedViaAulos => $composableBuilder(
    column: $table.isDownloadedViaAulos,
    builder: (column) => ColumnOrderings(column),
  );

  $$AudiobookArtistsTableOrderingComposer get artistId {
    final $$AudiobookArtistsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artistId,
      referencedTable: $db.audiobookArtists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudiobookArtistsTableOrderingComposer(
            $db: $db,
            $table: $db.audiobookArtists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AudiobooksTableAnnotationComposer
    extends Composer<_$AudiobookDatabase, $AudiobooksTable> {
  $$AudiobooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<Uint8List> get coverArt =>
      $composableBuilder(column: $table.coverArt, builder: (column) => column);

  GeneratedColumn<String> get localArtPath => $composableBuilder(
    column: $table.localArtPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverArtUrl => $composableBuilder(
    column: $table.coverArtUrl,
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

  GeneratedColumn<String> get asin =>
      $composableBuilder(column: $table.asin, builder: (column) => column);

  GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  GeneratedColumn<String> get seriesName => $composableBuilder(
    column: $table.seriesName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seriesPosition => $composableBuilder(
    column: $table.seriesPosition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get narrator =>
      $composableBuilder(column: $table.narrator, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get publisher =>
      $composableBuilder(column: $table.publisher, builder: (column) => column);

  GeneratedColumn<DateTime> get publishedDate => $composableBuilder(
    column: $table.publishedDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPlayed =>
      $composableBuilder(column: $table.isPlayed, builder: (column) => column);

  GeneratedColumn<String> get librivoxId => $composableBuilder(
    column: $table.librivoxId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDownloadedViaAulos => $composableBuilder(
    column: $table.isDownloadedViaAulos,
    builder: (column) => column,
  );

  $$AudiobookArtistsTableAnnotationComposer get artistId {
    final $$AudiobookArtistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artistId,
      referencedTable: $db.audiobookArtists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudiobookArtistsTableAnnotationComposer(
            $db: $db,
            $table: $db.audiobookArtists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> audiobookTracksRefs<T extends Object>(
    Expression<T> Function($$AudiobookTracksTableAnnotationComposer a) f,
  ) {
    final $$AudiobookTracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audiobookTracks,
      getReferencedColumn: (t) => t.audiobookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudiobookTracksTableAnnotationComposer(
            $db: $db,
            $table: $db.audiobookTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AudiobooksTableTableManager
    extends
        RootTableManager<
          _$AudiobookDatabase,
          $AudiobooksTable,
          Audiobook,
          $$AudiobooksTableFilterComposer,
          $$AudiobooksTableOrderingComposer,
          $$AudiobooksTableAnnotationComposer,
          $$AudiobooksTableCreateCompanionBuilder,
          $$AudiobooksTableUpdateCompanionBuilder,
          (Audiobook, $$AudiobooksTableReferences),
          Audiobook,
          PrefetchHooks Function({bool artistId, bool audiobookTracksRefs})
        > {
  $$AudiobooksTableTableManager(_$AudiobookDatabase db, $AudiobooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudiobooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudiobooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudiobooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> artistId = const Value.absent(),
                Value<Uint8List?> coverArt = const Value.absent(),
                Value<String?> localArtPath = const Value.absent(),
                Value<String?> coverArtUrl = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<DateTime?> lastPlayed = const Value.absent(),
                Value<String?> asin = const Value.absent(),
                Value<String?> subtitle = const Value.absent(),
                Value<String?> seriesName = const Value.absent(),
                Value<int?> seriesPosition = const Value.absent(),
                Value<String?> narrator = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> publisher = const Value.absent(),
                Value<DateTime?> publishedDate = const Value.absent(),
                Value<bool> isPlayed = const Value.absent(),
                Value<String?> librivoxId = const Value.absent(),
                Value<bool> isDownloadedViaAulos = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudiobooksCompanion(
                id: id,
                name: name,
                artistId: artistId,
                coverArt: coverArt,
                localArtPath: localArtPath,
                coverArtUrl: coverArtUrl,
                isFavorite: isFavorite,
                playCount: playCount,
                lastPlayed: lastPlayed,
                asin: asin,
                subtitle: subtitle,
                seriesName: seriesName,
                seriesPosition: seriesPosition,
                narrator: narrator,
                description: description,
                publisher: publisher,
                publishedDate: publishedDate,
                isPlayed: isPlayed,
                librivoxId: librivoxId,
                isDownloadedViaAulos: isDownloadedViaAulos,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> artistId = const Value.absent(),
                Value<Uint8List?> coverArt = const Value.absent(),
                Value<String?> localArtPath = const Value.absent(),
                Value<String?> coverArtUrl = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<DateTime?> lastPlayed = const Value.absent(),
                Value<String?> asin = const Value.absent(),
                Value<String?> subtitle = const Value.absent(),
                Value<String?> seriesName = const Value.absent(),
                Value<int?> seriesPosition = const Value.absent(),
                Value<String?> narrator = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> publisher = const Value.absent(),
                Value<DateTime?> publishedDate = const Value.absent(),
                Value<bool> isPlayed = const Value.absent(),
                Value<String?> librivoxId = const Value.absent(),
                Value<bool> isDownloadedViaAulos = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudiobooksCompanion.insert(
                id: id,
                name: name,
                artistId: artistId,
                coverArt: coverArt,
                localArtPath: localArtPath,
                coverArtUrl: coverArtUrl,
                isFavorite: isFavorite,
                playCount: playCount,
                lastPlayed: lastPlayed,
                asin: asin,
                subtitle: subtitle,
                seriesName: seriesName,
                seriesPosition: seriesPosition,
                narrator: narrator,
                description: description,
                publisher: publisher,
                publishedDate: publishedDate,
                isPlayed: isPlayed,
                librivoxId: librivoxId,
                isDownloadedViaAulos: isDownloadedViaAulos,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AudiobooksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({artistId = false, audiobookTracksRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (audiobookTracksRefs) db.audiobookTracks,
                  ],
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
                        if (artistId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.artistId,
                                    referencedTable: $$AudiobooksTableReferences
                                        ._artistIdTable(db),
                                    referencedColumn:
                                        $$AudiobooksTableReferences
                                            ._artistIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (audiobookTracksRefs)
                        await $_getPrefetchedData<
                          Audiobook,
                          $AudiobooksTable,
                          AudiobookTrack
                        >(
                          currentTable: table,
                          referencedTable: $$AudiobooksTableReferences
                              ._audiobookTracksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AudiobooksTableReferences(
                                db,
                                table,
                                p0,
                              ).audiobookTracksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.audiobookId == item.id,
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

typedef $$AudiobooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AudiobookDatabase,
      $AudiobooksTable,
      Audiobook,
      $$AudiobooksTableFilterComposer,
      $$AudiobooksTableOrderingComposer,
      $$AudiobooksTableAnnotationComposer,
      $$AudiobooksTableCreateCompanionBuilder,
      $$AudiobooksTableUpdateCompanionBuilder,
      (Audiobook, $$AudiobooksTableReferences),
      Audiobook,
      PrefetchHooks Function({bool artistId, bool audiobookTracksRefs})
    >;
typedef $$AudiobookTracksTableCreateCompanionBuilder =
    AudiobookTracksCompanion Function({
      required String id,
      required String path,
      required String title,
      Value<String?> artistId,
      Value<String?> audiobookId,
      Value<int?> durationSeconds,
      Value<int> rating,
      Value<Uint8List?> coverArt,
      Value<String?> localArtPath,
      Value<bool> isFavorite,
      Value<int> playCount,
      Value<DateTime?> lastPlayed,
      Value<bool> isPlayed,
      Value<bool?> isStream,
      Value<String?> duplicateOf,
      Value<int> rowid,
    });
typedef $$AudiobookTracksTableUpdateCompanionBuilder =
    AudiobookTracksCompanion Function({
      Value<String> id,
      Value<String> path,
      Value<String> title,
      Value<String?> artistId,
      Value<String?> audiobookId,
      Value<int?> durationSeconds,
      Value<int> rating,
      Value<Uint8List?> coverArt,
      Value<String?> localArtPath,
      Value<bool> isFavorite,
      Value<int> playCount,
      Value<DateTime?> lastPlayed,
      Value<bool> isPlayed,
      Value<bool?> isStream,
      Value<String?> duplicateOf,
      Value<int> rowid,
    });

final class $$AudiobookTracksTableReferences
    extends
        BaseReferences<
          _$AudiobookDatabase,
          $AudiobookTracksTable,
          AudiobookTrack
        > {
  $$AudiobookTracksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AudiobookArtistsTable _artistIdTable(_$AudiobookDatabase db) => db
      .audiobookArtists
      .createAlias('audiobook_tracks__artist_id__audiobook_artists__id');

  $$AudiobookArtistsTableProcessedTableManager? get artistId {
    final $_column = $_itemColumn<String>('artist_id');
    if ($_column == null) return null;
    final manager = $$AudiobookArtistsTableTableManager(
      $_db,
      $_db.audiobookArtists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_artistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AudiobooksTable _audiobookIdTable(_$AudiobookDatabase db) => db
      .audiobooks
      .createAlias('audiobook_tracks__audiobook_id__audiobooks__id');

  $$AudiobooksTableProcessedTableManager? get audiobookId {
    final $_column = $_itemColumn<String>('audiobook_id');
    if ($_column == null) return null;
    final manager = $$AudiobooksTableTableManager(
      $_db,
      $_db.audiobooks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_audiobookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AudiobookChaptersTable, List<AudiobookChapter>>
  _audiobookChaptersRefsTable(_$AudiobookDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.audiobookChapters,
        aliasName:
            'audiobook_tracks__id__audiobook_chapters__audiobook_track_id',
      );

  $$AudiobookChaptersTableProcessedTableManager get audiobookChaptersRefs {
    final manager =
        $$AudiobookChaptersTableTableManager(
          $_db,
          $_db.audiobookChapters,
        ).filter(
          (f) => f.audiobookTrackId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _audiobookChaptersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AudiobookTracksTableFilterComposer
    extends Composer<_$AudiobookDatabase, $AudiobookTracksTable> {
  $$AudiobookTracksTableFilterComposer({
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

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get coverArt => $composableBuilder(
    column: $table.coverArt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localArtPath => $composableBuilder(
    column: $table.localArtPath,
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

  ColumnFilters<bool> get isPlayed => $composableBuilder(
    column: $table.isPlayed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isStream => $composableBuilder(
    column: $table.isStream,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get duplicateOf => $composableBuilder(
    column: $table.duplicateOf,
    builder: (column) => ColumnFilters(column),
  );

  $$AudiobookArtistsTableFilterComposer get artistId {
    final $$AudiobookArtistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artistId,
      referencedTable: $db.audiobookArtists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudiobookArtistsTableFilterComposer(
            $db: $db,
            $table: $db.audiobookArtists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AudiobooksTableFilterComposer get audiobookId {
    final $$AudiobooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.audiobookId,
      referencedTable: $db.audiobooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudiobooksTableFilterComposer(
            $db: $db,
            $table: $db.audiobooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> audiobookChaptersRefs(
    Expression<bool> Function($$AudiobookChaptersTableFilterComposer f) f,
  ) {
    final $$AudiobookChaptersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audiobookChapters,
      getReferencedColumn: (t) => t.audiobookTrackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudiobookChaptersTableFilterComposer(
            $db: $db,
            $table: $db.audiobookChapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AudiobookTracksTableOrderingComposer
    extends Composer<_$AudiobookDatabase, $AudiobookTracksTable> {
  $$AudiobookTracksTableOrderingComposer({
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

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get coverArt => $composableBuilder(
    column: $table.coverArt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localArtPath => $composableBuilder(
    column: $table.localArtPath,
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

  ColumnOrderings<bool> get isPlayed => $composableBuilder(
    column: $table.isPlayed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isStream => $composableBuilder(
    column: $table.isStream,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get duplicateOf => $composableBuilder(
    column: $table.duplicateOf,
    builder: (column) => ColumnOrderings(column),
  );

  $$AudiobookArtistsTableOrderingComposer get artistId {
    final $$AudiobookArtistsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artistId,
      referencedTable: $db.audiobookArtists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudiobookArtistsTableOrderingComposer(
            $db: $db,
            $table: $db.audiobookArtists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AudiobooksTableOrderingComposer get audiobookId {
    final $$AudiobooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.audiobookId,
      referencedTable: $db.audiobooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudiobooksTableOrderingComposer(
            $db: $db,
            $table: $db.audiobooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AudiobookTracksTableAnnotationComposer
    extends Composer<_$AudiobookDatabase, $AudiobookTracksTable> {
  $$AudiobookTracksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<Uint8List> get coverArt =>
      $composableBuilder(column: $table.coverArt, builder: (column) => column);

  GeneratedColumn<String> get localArtPath => $composableBuilder(
    column: $table.localArtPath,
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

  GeneratedColumn<bool> get isPlayed =>
      $composableBuilder(column: $table.isPlayed, builder: (column) => column);

  GeneratedColumn<bool> get isStream =>
      $composableBuilder(column: $table.isStream, builder: (column) => column);

  GeneratedColumn<String> get duplicateOf => $composableBuilder(
    column: $table.duplicateOf,
    builder: (column) => column,
  );

  $$AudiobookArtistsTableAnnotationComposer get artistId {
    final $$AudiobookArtistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artistId,
      referencedTable: $db.audiobookArtists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudiobookArtistsTableAnnotationComposer(
            $db: $db,
            $table: $db.audiobookArtists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AudiobooksTableAnnotationComposer get audiobookId {
    final $$AudiobooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.audiobookId,
      referencedTable: $db.audiobooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudiobooksTableAnnotationComposer(
            $db: $db,
            $table: $db.audiobooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> audiobookChaptersRefs<T extends Object>(
    Expression<T> Function($$AudiobookChaptersTableAnnotationComposer a) f,
  ) {
    final $$AudiobookChaptersTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.audiobookChapters,
          getReferencedColumn: (t) => t.audiobookTrackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AudiobookChaptersTableAnnotationComposer(
                $db: $db,
                $table: $db.audiobookChapters,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AudiobookTracksTableTableManager
    extends
        RootTableManager<
          _$AudiobookDatabase,
          $AudiobookTracksTable,
          AudiobookTrack,
          $$AudiobookTracksTableFilterComposer,
          $$AudiobookTracksTableOrderingComposer,
          $$AudiobookTracksTableAnnotationComposer,
          $$AudiobookTracksTableCreateCompanionBuilder,
          $$AudiobookTracksTableUpdateCompanionBuilder,
          (AudiobookTrack, $$AudiobookTracksTableReferences),
          AudiobookTrack,
          PrefetchHooks Function({
            bool artistId,
            bool audiobookId,
            bool audiobookChaptersRefs,
          })
        > {
  $$AudiobookTracksTableTableManager(
    _$AudiobookDatabase db,
    $AudiobookTracksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudiobookTracksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudiobookTracksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudiobookTracksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> artistId = const Value.absent(),
                Value<String?> audiobookId = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<Uint8List?> coverArt = const Value.absent(),
                Value<String?> localArtPath = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<DateTime?> lastPlayed = const Value.absent(),
                Value<bool> isPlayed = const Value.absent(),
                Value<bool?> isStream = const Value.absent(),
                Value<String?> duplicateOf = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudiobookTracksCompanion(
                id: id,
                path: path,
                title: title,
                artistId: artistId,
                audiobookId: audiobookId,
                durationSeconds: durationSeconds,
                rating: rating,
                coverArt: coverArt,
                localArtPath: localArtPath,
                isFavorite: isFavorite,
                playCount: playCount,
                lastPlayed: lastPlayed,
                isPlayed: isPlayed,
                isStream: isStream,
                duplicateOf: duplicateOf,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String path,
                required String title,
                Value<String?> artistId = const Value.absent(),
                Value<String?> audiobookId = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<Uint8List?> coverArt = const Value.absent(),
                Value<String?> localArtPath = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<DateTime?> lastPlayed = const Value.absent(),
                Value<bool> isPlayed = const Value.absent(),
                Value<bool?> isStream = const Value.absent(),
                Value<String?> duplicateOf = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudiobookTracksCompanion.insert(
                id: id,
                path: path,
                title: title,
                artistId: artistId,
                audiobookId: audiobookId,
                durationSeconds: durationSeconds,
                rating: rating,
                coverArt: coverArt,
                localArtPath: localArtPath,
                isFavorite: isFavorite,
                playCount: playCount,
                lastPlayed: lastPlayed,
                isPlayed: isPlayed,
                isStream: isStream,
                duplicateOf: duplicateOf,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AudiobookTracksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                artistId = false,
                audiobookId = false,
                audiobookChaptersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (audiobookChaptersRefs) db.audiobookChapters,
                  ],
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
                        if (artistId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.artistId,
                                    referencedTable:
                                        $$AudiobookTracksTableReferences
                                            ._artistIdTable(db),
                                    referencedColumn:
                                        $$AudiobookTracksTableReferences
                                            ._artistIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (audiobookId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.audiobookId,
                                    referencedTable:
                                        $$AudiobookTracksTableReferences
                                            ._audiobookIdTable(db),
                                    referencedColumn:
                                        $$AudiobookTracksTableReferences
                                            ._audiobookIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (audiobookChaptersRefs)
                        await $_getPrefetchedData<
                          AudiobookTrack,
                          $AudiobookTracksTable,
                          AudiobookChapter
                        >(
                          currentTable: table,
                          referencedTable: $$AudiobookTracksTableReferences
                              ._audiobookChaptersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AudiobookTracksTableReferences(
                                db,
                                table,
                                p0,
                              ).audiobookChaptersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.audiobookTrackId == item.id,
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

typedef $$AudiobookTracksTableProcessedTableManager =
    ProcessedTableManager<
      _$AudiobookDatabase,
      $AudiobookTracksTable,
      AudiobookTrack,
      $$AudiobookTracksTableFilterComposer,
      $$AudiobookTracksTableOrderingComposer,
      $$AudiobookTracksTableAnnotationComposer,
      $$AudiobookTracksTableCreateCompanionBuilder,
      $$AudiobookTracksTableUpdateCompanionBuilder,
      (AudiobookTrack, $$AudiobookTracksTableReferences),
      AudiobookTrack,
      PrefetchHooks Function({
        bool artistId,
        bool audiobookId,
        bool audiobookChaptersRefs,
      })
    >;
typedef $$AudiobookChaptersTableCreateCompanionBuilder =
    AudiobookChaptersCompanion Function({
      required String id,
      required String audiobookTrackId,
      required String title,
      required int startTimeMs,
      Value<int?> durationMs,
      Value<int> rowid,
    });
typedef $$AudiobookChaptersTableUpdateCompanionBuilder =
    AudiobookChaptersCompanion Function({
      Value<String> id,
      Value<String> audiobookTrackId,
      Value<String> title,
      Value<int> startTimeMs,
      Value<int?> durationMs,
      Value<int> rowid,
    });

final class $$AudiobookChaptersTableReferences
    extends
        BaseReferences<
          _$AudiobookDatabase,
          $AudiobookChaptersTable,
          AudiobookChapter
        > {
  $$AudiobookChaptersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AudiobookTracksTable _audiobookTrackIdTable(_$AudiobookDatabase db) =>
      db.audiobookTracks.createAlias(
        'audiobook_chapters__audiobook_track_id__audiobook_tracks__id',
      );

  $$AudiobookTracksTableProcessedTableManager get audiobookTrackId {
    final $_column = $_itemColumn<String>('audiobook_track_id')!;

    final manager = $$AudiobookTracksTableTableManager(
      $_db,
      $_db.audiobookTracks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_audiobookTrackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AudiobookChaptersTableFilterComposer
    extends Composer<_$AudiobookDatabase, $AudiobookChaptersTable> {
  $$AudiobookChaptersTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startTimeMs => $composableBuilder(
    column: $table.startTimeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  $$AudiobookTracksTableFilterComposer get audiobookTrackId {
    final $$AudiobookTracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.audiobookTrackId,
      referencedTable: $db.audiobookTracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudiobookTracksTableFilterComposer(
            $db: $db,
            $table: $db.audiobookTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AudiobookChaptersTableOrderingComposer
    extends Composer<_$AudiobookDatabase, $AudiobookChaptersTable> {
  $$AudiobookChaptersTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startTimeMs => $composableBuilder(
    column: $table.startTimeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$AudiobookTracksTableOrderingComposer get audiobookTrackId {
    final $$AudiobookTracksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.audiobookTrackId,
      referencedTable: $db.audiobookTracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudiobookTracksTableOrderingComposer(
            $db: $db,
            $table: $db.audiobookTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AudiobookChaptersTableAnnotationComposer
    extends Composer<_$AudiobookDatabase, $AudiobookChaptersTable> {
  $$AudiobookChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get startTimeMs => $composableBuilder(
    column: $table.startTimeMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  $$AudiobookTracksTableAnnotationComposer get audiobookTrackId {
    final $$AudiobookTracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.audiobookTrackId,
      referencedTable: $db.audiobookTracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudiobookTracksTableAnnotationComposer(
            $db: $db,
            $table: $db.audiobookTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AudiobookChaptersTableTableManager
    extends
        RootTableManager<
          _$AudiobookDatabase,
          $AudiobookChaptersTable,
          AudiobookChapter,
          $$AudiobookChaptersTableFilterComposer,
          $$AudiobookChaptersTableOrderingComposer,
          $$AudiobookChaptersTableAnnotationComposer,
          $$AudiobookChaptersTableCreateCompanionBuilder,
          $$AudiobookChaptersTableUpdateCompanionBuilder,
          (AudiobookChapter, $$AudiobookChaptersTableReferences),
          AudiobookChapter,
          PrefetchHooks Function({bool audiobookTrackId})
        > {
  $$AudiobookChaptersTableTableManager(
    _$AudiobookDatabase db,
    $AudiobookChaptersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudiobookChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudiobookChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudiobookChaptersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> audiobookTrackId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> startTimeMs = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudiobookChaptersCompanion(
                id: id,
                audiobookTrackId: audiobookTrackId,
                title: title,
                startTimeMs: startTimeMs,
                durationMs: durationMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String audiobookTrackId,
                required String title,
                required int startTimeMs,
                Value<int?> durationMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudiobookChaptersCompanion.insert(
                id: id,
                audiobookTrackId: audiobookTrackId,
                title: title,
                startTimeMs: startTimeMs,
                durationMs: durationMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AudiobookChaptersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({audiobookTrackId = false}) {
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
                    if (audiobookTrackId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.audiobookTrackId,
                                referencedTable:
                                    $$AudiobookChaptersTableReferences
                                        ._audiobookTrackIdTable(db),
                                referencedColumn:
                                    $$AudiobookChaptersTableReferences
                                        ._audiobookTrackIdTable(db)
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

typedef $$AudiobookChaptersTableProcessedTableManager =
    ProcessedTableManager<
      _$AudiobookDatabase,
      $AudiobookChaptersTable,
      AudiobookChapter,
      $$AudiobookChaptersTableFilterComposer,
      $$AudiobookChaptersTableOrderingComposer,
      $$AudiobookChaptersTableAnnotationComposer,
      $$AudiobookChaptersTableCreateCompanionBuilder,
      $$AudiobookChaptersTableUpdateCompanionBuilder,
      (AudiobookChapter, $$AudiobookChaptersTableReferences),
      AudiobookChapter,
      PrefetchHooks Function({bool audiobookTrackId})
    >;

class $AudiobookDatabaseManager {
  final _$AudiobookDatabase _db;
  $AudiobookDatabaseManager(this._db);
  $$AudiobookFoldersTableTableManager get audiobookFolders =>
      $$AudiobookFoldersTableTableManager(_db, _db.audiobookFolders);
  $$AudiobookArtistsTableTableManager get audiobookArtists =>
      $$AudiobookArtistsTableTableManager(_db, _db.audiobookArtists);
  $$AudiobooksTableTableManager get audiobooks =>
      $$AudiobooksTableTableManager(_db, _db.audiobooks);
  $$AudiobookTracksTableTableManager get audiobookTracks =>
      $$AudiobookTracksTableTableManager(_db, _db.audiobookTracks);
  $$AudiobookChaptersTableTableManager get audiobookChapters =>
      $$AudiobookChaptersTableTableManager(_db, _db.audiobookChapters);
}
