// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'radio_database.dart';

// ignore_for_file: type=lint
class $RadioStationsTable extends RadioStations
    with TableInfo<$RadioStationsTable, RadioStation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RadioStationsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _stationUuidMeta = const VerificationMeta(
    'stationUuid',
  );
  @override
  late final GeneratedColumn<String> stationUuid = GeneratedColumn<String>(
    'station_uuid',
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
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _homepageMeta = const VerificationMeta(
    'homepage',
  );
  @override
  late final GeneratedColumn<String> homepage = GeneratedColumn<String>(
    'homepage',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _faviconMeta = const VerificationMeta(
    'favicon',
  );
  @override
  late final GeneratedColumn<String> favicon = GeneratedColumn<String>(
    'favicon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _votesMeta = const VerificationMeta('votes');
  @override
  late final GeneratedColumn<int> votes = GeneratedColumn<int>(
    'votes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bitrateMeta = const VerificationMeta(
    'bitrate',
  );
  @override
  late final GeneratedColumn<int> bitrate = GeneratedColumn<int>(
    'bitrate',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _codecMeta = const VerificationMeta('codec');
  @override
  late final GeneratedColumn<String> codec = GeneratedColumn<String>(
    'codec',
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
  static const VerificationMeta _lastCheckMeta = const VerificationMeta(
    'lastCheck',
  );
  @override
  late final GeneratedColumn<DateTime> lastCheck = GeneratedColumn<DateTime>(
    'last_check',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    stationUuid,
    name,
    url,
    homepage,
    favicon,
    tags,
    country,
    language,
    votes,
    bitrate,
    codec,
    isFavorite,
    lastCheck,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'radio_stations';
  @override
  VerificationContext validateIntegrity(
    Insertable<RadioStation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('station_uuid')) {
      context.handle(
        _stationUuidMeta,
        stationUuid.isAcceptableOrUnknown(
          data['station_uuid']!,
          _stationUuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stationUuidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('homepage')) {
      context.handle(
        _homepageMeta,
        homepage.isAcceptableOrUnknown(data['homepage']!, _homepageMeta),
      );
    }
    if (data.containsKey('favicon')) {
      context.handle(
        _faviconMeta,
        favicon.isAcceptableOrUnknown(data['favicon']!, _faviconMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('votes')) {
      context.handle(
        _votesMeta,
        votes.isAcceptableOrUnknown(data['votes']!, _votesMeta),
      );
    }
    if (data.containsKey('bitrate')) {
      context.handle(
        _bitrateMeta,
        bitrate.isAcceptableOrUnknown(data['bitrate']!, _bitrateMeta),
      );
    }
    if (data.containsKey('codec')) {
      context.handle(
        _codecMeta,
        codec.isAcceptableOrUnknown(data['codec']!, _codecMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('last_check')) {
      context.handle(
        _lastCheckMeta,
        lastCheck.isAcceptableOrUnknown(data['last_check']!, _lastCheckMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RadioStation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RadioStation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      stationUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}station_uuid'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      homepage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}homepage'],
      ),
      favicon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}favicon'],
      ),
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      ),
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      ),
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      ),
      votes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}votes'],
      )!,
      bitrate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bitrate'],
      )!,
      codec: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codec'],
      ),
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      lastCheck: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_check'],
      ),
    );
  }

  @override
  $RadioStationsTable createAlias(String alias) {
    return $RadioStationsTable(attachedDatabase, alias);
  }
}

class RadioStation extends DataClass implements Insertable<RadioStation> {
  final int id;
  final String stationUuid;
  final String name;
  final String url;
  final String? homepage;
  final String? favicon;
  final String? tags;
  final String? country;
  final String? language;
  final int votes;
  final int bitrate;
  final String? codec;
  final bool isFavorite;
  final DateTime? lastCheck;
  const RadioStation({
    required this.id,
    required this.stationUuid,
    required this.name,
    required this.url,
    this.homepage,
    this.favicon,
    this.tags,
    this.country,
    this.language,
    required this.votes,
    required this.bitrate,
    this.codec,
    required this.isFavorite,
    this.lastCheck,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['station_uuid'] = Variable<String>(stationUuid);
    map['name'] = Variable<String>(name);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || homepage != null) {
      map['homepage'] = Variable<String>(homepage);
    }
    if (!nullToAbsent || favicon != null) {
      map['favicon'] = Variable<String>(favicon);
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
    if (!nullToAbsent || language != null) {
      map['language'] = Variable<String>(language);
    }
    map['votes'] = Variable<int>(votes);
    map['bitrate'] = Variable<int>(bitrate);
    if (!nullToAbsent || codec != null) {
      map['codec'] = Variable<String>(codec);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    if (!nullToAbsent || lastCheck != null) {
      map['last_check'] = Variable<DateTime>(lastCheck);
    }
    return map;
  }

  RadioStationsCompanion toCompanion(bool nullToAbsent) {
    return RadioStationsCompanion(
      id: Value(id),
      stationUuid: Value(stationUuid),
      name: Value(name),
      url: Value(url),
      homepage: homepage == null && nullToAbsent
          ? const Value.absent()
          : Value(homepage),
      favicon: favicon == null && nullToAbsent
          ? const Value.absent()
          : Value(favicon),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
      language: language == null && nullToAbsent
          ? const Value.absent()
          : Value(language),
      votes: Value(votes),
      bitrate: Value(bitrate),
      codec: codec == null && nullToAbsent
          ? const Value.absent()
          : Value(codec),
      isFavorite: Value(isFavorite),
      lastCheck: lastCheck == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCheck),
    );
  }

  factory RadioStation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RadioStation(
      id: serializer.fromJson<int>(json['id']),
      stationUuid: serializer.fromJson<String>(json['stationUuid']),
      name: serializer.fromJson<String>(json['name']),
      url: serializer.fromJson<String>(json['url']),
      homepage: serializer.fromJson<String?>(json['homepage']),
      favicon: serializer.fromJson<String?>(json['favicon']),
      tags: serializer.fromJson<String?>(json['tags']),
      country: serializer.fromJson<String?>(json['country']),
      language: serializer.fromJson<String?>(json['language']),
      votes: serializer.fromJson<int>(json['votes']),
      bitrate: serializer.fromJson<int>(json['bitrate']),
      codec: serializer.fromJson<String?>(json['codec']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      lastCheck: serializer.fromJson<DateTime?>(json['lastCheck']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'stationUuid': serializer.toJson<String>(stationUuid),
      'name': serializer.toJson<String>(name),
      'url': serializer.toJson<String>(url),
      'homepage': serializer.toJson<String?>(homepage),
      'favicon': serializer.toJson<String?>(favicon),
      'tags': serializer.toJson<String?>(tags),
      'country': serializer.toJson<String?>(country),
      'language': serializer.toJson<String?>(language),
      'votes': serializer.toJson<int>(votes),
      'bitrate': serializer.toJson<int>(bitrate),
      'codec': serializer.toJson<String?>(codec),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'lastCheck': serializer.toJson<DateTime?>(lastCheck),
    };
  }

  RadioStation copyWith({
    int? id,
    String? stationUuid,
    String? name,
    String? url,
    Value<String?> homepage = const Value.absent(),
    Value<String?> favicon = const Value.absent(),
    Value<String?> tags = const Value.absent(),
    Value<String?> country = const Value.absent(),
    Value<String?> language = const Value.absent(),
    int? votes,
    int? bitrate,
    Value<String?> codec = const Value.absent(),
    bool? isFavorite,
    Value<DateTime?> lastCheck = const Value.absent(),
  }) => RadioStation(
    id: id ?? this.id,
    stationUuid: stationUuid ?? this.stationUuid,
    name: name ?? this.name,
    url: url ?? this.url,
    homepage: homepage.present ? homepage.value : this.homepage,
    favicon: favicon.present ? favicon.value : this.favicon,
    tags: tags.present ? tags.value : this.tags,
    country: country.present ? country.value : this.country,
    language: language.present ? language.value : this.language,
    votes: votes ?? this.votes,
    bitrate: bitrate ?? this.bitrate,
    codec: codec.present ? codec.value : this.codec,
    isFavorite: isFavorite ?? this.isFavorite,
    lastCheck: lastCheck.present ? lastCheck.value : this.lastCheck,
  );
  RadioStation copyWithCompanion(RadioStationsCompanion data) {
    return RadioStation(
      id: data.id.present ? data.id.value : this.id,
      stationUuid: data.stationUuid.present
          ? data.stationUuid.value
          : this.stationUuid,
      name: data.name.present ? data.name.value : this.name,
      url: data.url.present ? data.url.value : this.url,
      homepage: data.homepage.present ? data.homepage.value : this.homepage,
      favicon: data.favicon.present ? data.favicon.value : this.favicon,
      tags: data.tags.present ? data.tags.value : this.tags,
      country: data.country.present ? data.country.value : this.country,
      language: data.language.present ? data.language.value : this.language,
      votes: data.votes.present ? data.votes.value : this.votes,
      bitrate: data.bitrate.present ? data.bitrate.value : this.bitrate,
      codec: data.codec.present ? data.codec.value : this.codec,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      lastCheck: data.lastCheck.present ? data.lastCheck.value : this.lastCheck,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RadioStation(')
          ..write('id: $id, ')
          ..write('stationUuid: $stationUuid, ')
          ..write('name: $name, ')
          ..write('url: $url, ')
          ..write('homepage: $homepage, ')
          ..write('favicon: $favicon, ')
          ..write('tags: $tags, ')
          ..write('country: $country, ')
          ..write('language: $language, ')
          ..write('votes: $votes, ')
          ..write('bitrate: $bitrate, ')
          ..write('codec: $codec, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('lastCheck: $lastCheck')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    stationUuid,
    name,
    url,
    homepage,
    favicon,
    tags,
    country,
    language,
    votes,
    bitrate,
    codec,
    isFavorite,
    lastCheck,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RadioStation &&
          other.id == this.id &&
          other.stationUuid == this.stationUuid &&
          other.name == this.name &&
          other.url == this.url &&
          other.homepage == this.homepage &&
          other.favicon == this.favicon &&
          other.tags == this.tags &&
          other.country == this.country &&
          other.language == this.language &&
          other.votes == this.votes &&
          other.bitrate == this.bitrate &&
          other.codec == this.codec &&
          other.isFavorite == this.isFavorite &&
          other.lastCheck == this.lastCheck);
}

class RadioStationsCompanion extends UpdateCompanion<RadioStation> {
  final Value<int> id;
  final Value<String> stationUuid;
  final Value<String> name;
  final Value<String> url;
  final Value<String?> homepage;
  final Value<String?> favicon;
  final Value<String?> tags;
  final Value<String?> country;
  final Value<String?> language;
  final Value<int> votes;
  final Value<int> bitrate;
  final Value<String?> codec;
  final Value<bool> isFavorite;
  final Value<DateTime?> lastCheck;
  const RadioStationsCompanion({
    this.id = const Value.absent(),
    this.stationUuid = const Value.absent(),
    this.name = const Value.absent(),
    this.url = const Value.absent(),
    this.homepage = const Value.absent(),
    this.favicon = const Value.absent(),
    this.tags = const Value.absent(),
    this.country = const Value.absent(),
    this.language = const Value.absent(),
    this.votes = const Value.absent(),
    this.bitrate = const Value.absent(),
    this.codec = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.lastCheck = const Value.absent(),
  });
  RadioStationsCompanion.insert({
    this.id = const Value.absent(),
    required String stationUuid,
    required String name,
    required String url,
    this.homepage = const Value.absent(),
    this.favicon = const Value.absent(),
    this.tags = const Value.absent(),
    this.country = const Value.absent(),
    this.language = const Value.absent(),
    this.votes = const Value.absent(),
    this.bitrate = const Value.absent(),
    this.codec = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.lastCheck = const Value.absent(),
  }) : stationUuid = Value(stationUuid),
       name = Value(name),
       url = Value(url);
  static Insertable<RadioStation> custom({
    Expression<int>? id,
    Expression<String>? stationUuid,
    Expression<String>? name,
    Expression<String>? url,
    Expression<String>? homepage,
    Expression<String>? favicon,
    Expression<String>? tags,
    Expression<String>? country,
    Expression<String>? language,
    Expression<int>? votes,
    Expression<int>? bitrate,
    Expression<String>? codec,
    Expression<bool>? isFavorite,
    Expression<DateTime>? lastCheck,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (stationUuid != null) 'station_uuid': stationUuid,
      if (name != null) 'name': name,
      if (url != null) 'url': url,
      if (homepage != null) 'homepage': homepage,
      if (favicon != null) 'favicon': favicon,
      if (tags != null) 'tags': tags,
      if (country != null) 'country': country,
      if (language != null) 'language': language,
      if (votes != null) 'votes': votes,
      if (bitrate != null) 'bitrate': bitrate,
      if (codec != null) 'codec': codec,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (lastCheck != null) 'last_check': lastCheck,
    });
  }

  RadioStationsCompanion copyWith({
    Value<int>? id,
    Value<String>? stationUuid,
    Value<String>? name,
    Value<String>? url,
    Value<String?>? homepage,
    Value<String?>? favicon,
    Value<String?>? tags,
    Value<String?>? country,
    Value<String?>? language,
    Value<int>? votes,
    Value<int>? bitrate,
    Value<String?>? codec,
    Value<bool>? isFavorite,
    Value<DateTime?>? lastCheck,
  }) {
    return RadioStationsCompanion(
      id: id ?? this.id,
      stationUuid: stationUuid ?? this.stationUuid,
      name: name ?? this.name,
      url: url ?? this.url,
      homepage: homepage ?? this.homepage,
      favicon: favicon ?? this.favicon,
      tags: tags ?? this.tags,
      country: country ?? this.country,
      language: language ?? this.language,
      votes: votes ?? this.votes,
      bitrate: bitrate ?? this.bitrate,
      codec: codec ?? this.codec,
      isFavorite: isFavorite ?? this.isFavorite,
      lastCheck: lastCheck ?? this.lastCheck,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (stationUuid.present) {
      map['station_uuid'] = Variable<String>(stationUuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (homepage.present) {
      map['homepage'] = Variable<String>(homepage.value);
    }
    if (favicon.present) {
      map['favicon'] = Variable<String>(favicon.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (votes.present) {
      map['votes'] = Variable<int>(votes.value);
    }
    if (bitrate.present) {
      map['bitrate'] = Variable<int>(bitrate.value);
    }
    if (codec.present) {
      map['codec'] = Variable<String>(codec.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (lastCheck.present) {
      map['last_check'] = Variable<DateTime>(lastCheck.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RadioStationsCompanion(')
          ..write('id: $id, ')
          ..write('stationUuid: $stationUuid, ')
          ..write('name: $name, ')
          ..write('url: $url, ')
          ..write('homepage: $homepage, ')
          ..write('favicon: $favicon, ')
          ..write('tags: $tags, ')
          ..write('country: $country, ')
          ..write('language: $language, ')
          ..write('votes: $votes, ')
          ..write('bitrate: $bitrate, ')
          ..write('codec: $codec, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('lastCheck: $lastCheck')
          ..write(')'))
        .toString();
  }
}

class $RadioCategoriesTable extends RadioCategories
    with TableInfo<$RadioCategoriesTable, RadioCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RadioCategoriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _stationCountMeta = const VerificationMeta(
    'stationCount',
  );
  @override
  late final GeneratedColumn<int> stationCount = GeneratedColumn<int>(
    'station_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, stationCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'radio_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<RadioCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('station_count')) {
      context.handle(
        _stationCountMeta,
        stationCount.isAcceptableOrUnknown(
          data['station_count']!,
          _stationCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RadioCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RadioCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      stationCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}station_count'],
      )!,
    );
  }

  @override
  $RadioCategoriesTable createAlias(String alias) {
    return $RadioCategoriesTable(attachedDatabase, alias);
  }
}

class RadioCategory extends DataClass implements Insertable<RadioCategory> {
  final int id;
  final String name;
  final int stationCount;
  const RadioCategory({
    required this.id,
    required this.name,
    required this.stationCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['station_count'] = Variable<int>(stationCount);
    return map;
  }

  RadioCategoriesCompanion toCompanion(bool nullToAbsent) {
    return RadioCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      stationCount: Value(stationCount),
    );
  }

  factory RadioCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RadioCategory(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      stationCount: serializer.fromJson<int>(json['stationCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'stationCount': serializer.toJson<int>(stationCount),
    };
  }

  RadioCategory copyWith({int? id, String? name, int? stationCount}) =>
      RadioCategory(
        id: id ?? this.id,
        name: name ?? this.name,
        stationCount: stationCount ?? this.stationCount,
      );
  RadioCategory copyWithCompanion(RadioCategoriesCompanion data) {
    return RadioCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      stationCount: data.stationCount.present
          ? data.stationCount.value
          : this.stationCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RadioCategory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('stationCount: $stationCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, stationCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RadioCategory &&
          other.id == this.id &&
          other.name == this.name &&
          other.stationCount == this.stationCount);
}

class RadioCategoriesCompanion extends UpdateCompanion<RadioCategory> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> stationCount;
  const RadioCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.stationCount = const Value.absent(),
  });
  RadioCategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.stationCount = const Value.absent(),
  }) : name = Value(name);
  static Insertable<RadioCategory> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? stationCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (stationCount != null) 'station_count': stationCount,
    });
  }

  RadioCategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? stationCount,
  }) {
    return RadioCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      stationCount: stationCount ?? this.stationCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (stationCount.present) {
      map['station_count'] = Variable<int>(stationCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RadioCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('stationCount: $stationCount')
          ..write(')'))
        .toString();
  }
}

abstract class _$RadioDatabase extends GeneratedDatabase {
  _$RadioDatabase(QueryExecutor e) : super(e);
  $RadioDatabaseManager get managers => $RadioDatabaseManager(this);
  late final $RadioStationsTable radioStations = $RadioStationsTable(this);
  late final $RadioCategoriesTable radioCategories = $RadioCategoriesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    radioStations,
    radioCategories,
  ];
}

typedef $$RadioStationsTableCreateCompanionBuilder =
    RadioStationsCompanion Function({
      Value<int> id,
      required String stationUuid,
      required String name,
      required String url,
      Value<String?> homepage,
      Value<String?> favicon,
      Value<String?> tags,
      Value<String?> country,
      Value<String?> language,
      Value<int> votes,
      Value<int> bitrate,
      Value<String?> codec,
      Value<bool> isFavorite,
      Value<DateTime?> lastCheck,
    });
typedef $$RadioStationsTableUpdateCompanionBuilder =
    RadioStationsCompanion Function({
      Value<int> id,
      Value<String> stationUuid,
      Value<String> name,
      Value<String> url,
      Value<String?> homepage,
      Value<String?> favicon,
      Value<String?> tags,
      Value<String?> country,
      Value<String?> language,
      Value<int> votes,
      Value<int> bitrate,
      Value<String?> codec,
      Value<bool> isFavorite,
      Value<DateTime?> lastCheck,
    });

class $$RadioStationsTableFilterComposer
    extends Composer<_$RadioDatabase, $RadioStationsTable> {
  $$RadioStationsTableFilterComposer({
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

  ColumnFilters<String> get stationUuid => $composableBuilder(
    column: $table.stationUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get homepage => $composableBuilder(
    column: $table.homepage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get favicon => $composableBuilder(
    column: $table.favicon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get votes => $composableBuilder(
    column: $table.votes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bitrate => $composableBuilder(
    column: $table.bitrate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codec => $composableBuilder(
    column: $table.codec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastCheck => $composableBuilder(
    column: $table.lastCheck,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RadioStationsTableOrderingComposer
    extends Composer<_$RadioDatabase, $RadioStationsTable> {
  $$RadioStationsTableOrderingComposer({
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

  ColumnOrderings<String> get stationUuid => $composableBuilder(
    column: $table.stationUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get homepage => $composableBuilder(
    column: $table.homepage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get favicon => $composableBuilder(
    column: $table.favicon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get votes => $composableBuilder(
    column: $table.votes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bitrate => $composableBuilder(
    column: $table.bitrate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codec => $composableBuilder(
    column: $table.codec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastCheck => $composableBuilder(
    column: $table.lastCheck,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RadioStationsTableAnnotationComposer
    extends Composer<_$RadioDatabase, $RadioStationsTable> {
  $$RadioStationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get stationUuid => $composableBuilder(
    column: $table.stationUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get homepage =>
      $composableBuilder(column: $table.homepage, builder: (column) => column);

  GeneratedColumn<String> get favicon =>
      $composableBuilder(column: $table.favicon, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<int> get votes =>
      $composableBuilder(column: $table.votes, builder: (column) => column);

  GeneratedColumn<int> get bitrate =>
      $composableBuilder(column: $table.bitrate, builder: (column) => column);

  GeneratedColumn<String> get codec =>
      $composableBuilder(column: $table.codec, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastCheck =>
      $composableBuilder(column: $table.lastCheck, builder: (column) => column);
}

class $$RadioStationsTableTableManager
    extends
        RootTableManager<
          _$RadioDatabase,
          $RadioStationsTable,
          RadioStation,
          $$RadioStationsTableFilterComposer,
          $$RadioStationsTableOrderingComposer,
          $$RadioStationsTableAnnotationComposer,
          $$RadioStationsTableCreateCompanionBuilder,
          $$RadioStationsTableUpdateCompanionBuilder,
          (
            RadioStation,
            BaseReferences<_$RadioDatabase, $RadioStationsTable, RadioStation>,
          ),
          RadioStation,
          PrefetchHooks Function()
        > {
  $$RadioStationsTableTableManager(
    _$RadioDatabase db,
    $RadioStationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RadioStationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RadioStationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RadioStationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> stationUuid = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String?> homepage = const Value.absent(),
                Value<String?> favicon = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<String?> language = const Value.absent(),
                Value<int> votes = const Value.absent(),
                Value<int> bitrate = const Value.absent(),
                Value<String?> codec = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<DateTime?> lastCheck = const Value.absent(),
              }) => RadioStationsCompanion(
                id: id,
                stationUuid: stationUuid,
                name: name,
                url: url,
                homepage: homepage,
                favicon: favicon,
                tags: tags,
                country: country,
                language: language,
                votes: votes,
                bitrate: bitrate,
                codec: codec,
                isFavorite: isFavorite,
                lastCheck: lastCheck,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String stationUuid,
                required String name,
                required String url,
                Value<String?> homepage = const Value.absent(),
                Value<String?> favicon = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<String?> language = const Value.absent(),
                Value<int> votes = const Value.absent(),
                Value<int> bitrate = const Value.absent(),
                Value<String?> codec = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<DateTime?> lastCheck = const Value.absent(),
              }) => RadioStationsCompanion.insert(
                id: id,
                stationUuid: stationUuid,
                name: name,
                url: url,
                homepage: homepage,
                favicon: favicon,
                tags: tags,
                country: country,
                language: language,
                votes: votes,
                bitrate: bitrate,
                codec: codec,
                isFavorite: isFavorite,
                lastCheck: lastCheck,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RadioStationsTableProcessedTableManager =
    ProcessedTableManager<
      _$RadioDatabase,
      $RadioStationsTable,
      RadioStation,
      $$RadioStationsTableFilterComposer,
      $$RadioStationsTableOrderingComposer,
      $$RadioStationsTableAnnotationComposer,
      $$RadioStationsTableCreateCompanionBuilder,
      $$RadioStationsTableUpdateCompanionBuilder,
      (
        RadioStation,
        BaseReferences<_$RadioDatabase, $RadioStationsTable, RadioStation>,
      ),
      RadioStation,
      PrefetchHooks Function()
    >;
typedef $$RadioCategoriesTableCreateCompanionBuilder =
    RadioCategoriesCompanion Function({
      Value<int> id,
      required String name,
      Value<int> stationCount,
    });
typedef $$RadioCategoriesTableUpdateCompanionBuilder =
    RadioCategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> stationCount,
    });

class $$RadioCategoriesTableFilterComposer
    extends Composer<_$RadioDatabase, $RadioCategoriesTable> {
  $$RadioCategoriesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stationCount => $composableBuilder(
    column: $table.stationCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RadioCategoriesTableOrderingComposer
    extends Composer<_$RadioDatabase, $RadioCategoriesTable> {
  $$RadioCategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stationCount => $composableBuilder(
    column: $table.stationCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RadioCategoriesTableAnnotationComposer
    extends Composer<_$RadioDatabase, $RadioCategoriesTable> {
  $$RadioCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get stationCount => $composableBuilder(
    column: $table.stationCount,
    builder: (column) => column,
  );
}

class $$RadioCategoriesTableTableManager
    extends
        RootTableManager<
          _$RadioDatabase,
          $RadioCategoriesTable,
          RadioCategory,
          $$RadioCategoriesTableFilterComposer,
          $$RadioCategoriesTableOrderingComposer,
          $$RadioCategoriesTableAnnotationComposer,
          $$RadioCategoriesTableCreateCompanionBuilder,
          $$RadioCategoriesTableUpdateCompanionBuilder,
          (
            RadioCategory,
            BaseReferences<
              _$RadioDatabase,
              $RadioCategoriesTable,
              RadioCategory
            >,
          ),
          RadioCategory,
          PrefetchHooks Function()
        > {
  $$RadioCategoriesTableTableManager(
    _$RadioDatabase db,
    $RadioCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RadioCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RadioCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RadioCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> stationCount = const Value.absent(),
              }) => RadioCategoriesCompanion(
                id: id,
                name: name,
                stationCount: stationCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int> stationCount = const Value.absent(),
              }) => RadioCategoriesCompanion.insert(
                id: id,
                name: name,
                stationCount: stationCount,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RadioCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$RadioDatabase,
      $RadioCategoriesTable,
      RadioCategory,
      $$RadioCategoriesTableFilterComposer,
      $$RadioCategoriesTableOrderingComposer,
      $$RadioCategoriesTableAnnotationComposer,
      $$RadioCategoriesTableCreateCompanionBuilder,
      $$RadioCategoriesTableUpdateCompanionBuilder,
      (
        RadioCategory,
        BaseReferences<_$RadioDatabase, $RadioCategoriesTable, RadioCategory>,
      ),
      RadioCategory,
      PrefetchHooks Function()
    >;

class $RadioDatabaseManager {
  final _$RadioDatabase _db;
  $RadioDatabaseManager(this._db);
  $$RadioStationsTableTableManager get radioStations =>
      $$RadioStationsTableTableManager(_db, _db.radioStations);
  $$RadioCategoriesTableTableManager get radioCategories =>
      $$RadioCategoriesTableTableManager(_db, _db.radioCategories);
}
