// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PlayerProfilesTable extends PlayerProfiles
    with TableInfo<$PlayerProfilesTable, PlayerProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayerProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
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
  static const VerificationMeta _isGuestMeta = const VerificationMeta(
    'isGuest',
  );
  @override
  late final GeneratedColumn<bool> isGuest = GeneratedColumn<bool>(
    'is_guest',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_guest" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _initialSyncCompletedMeta =
      const VerificationMeta('initialSyncCompleted');
  @override
  late final GeneratedColumn<bool> initialSyncCompleted = GeneratedColumn<bool>(
    'initial_sync_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("initial_sync_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    username,
    displayName,
    photoUrl,
    isGuest,
    initialSyncCompleted,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'player_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlayerProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('photo_url')) {
      context.handle(
        _photoUrlMeta,
        photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta),
      );
    }
    if (data.containsKey('is_guest')) {
      context.handle(
        _isGuestMeta,
        isGuest.isAcceptableOrUnknown(data['is_guest']!, _isGuestMeta),
      );
    }
    if (data.containsKey('initial_sync_completed')) {
      context.handle(
        _initialSyncCompletedMeta,
        initialSyncCompleted.isAcceptableOrUnknown(
          data['initial_sync_completed']!,
          _initialSyncCompletedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayerProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayerProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      ),
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      photoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_url'],
      ),
      isGuest: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_guest'],
      )!,
      initialSyncCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}initial_sync_completed'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PlayerProfilesTable createAlias(String alias) {
    return $PlayerProfilesTable(attachedDatabase, alias);
  }
}

class PlayerProfileRow extends DataClass
    implements Insertable<PlayerProfileRow> {
  final int id;

  /// Backend user id (Guid) — set after first auth/snapshot.
  final String userId;
  final String? username;
  final String? displayName;
  final String? photoUrl;
  final bool isGuest;

  /// True once the one-time GET /sync/snapshot hydration ran for this
  /// account on this device. Never reset.
  final bool initialSyncCompleted;
  final int createdAt;
  final int updatedAt;
  const PlayerProfileRow({
    required this.id,
    required this.userId,
    this.username,
    this.displayName,
    this.photoUrl,
    required this.isGuest,
    required this.initialSyncCompleted,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || username != null) {
      map['username'] = Variable<String>(username);
    }
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    map['is_guest'] = Variable<bool>(isGuest);
    map['initial_sync_completed'] = Variable<bool>(initialSyncCompleted);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  PlayerProfilesCompanion toCompanion(bool nullToAbsent) {
    return PlayerProfilesCompanion(
      id: Value(id),
      userId: Value(userId),
      username: username == null && nullToAbsent
          ? const Value.absent()
          : Value(username),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      isGuest: Value(isGuest),
      initialSyncCompleted: Value(initialSyncCompleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PlayerProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayerProfileRow(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      username: serializer.fromJson<String?>(json['username']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      isGuest: serializer.fromJson<bool>(json['isGuest']),
      initialSyncCompleted: serializer.fromJson<bool>(
        json['initialSyncCompleted'],
      ),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'username': serializer.toJson<String?>(username),
      'displayName': serializer.toJson<String?>(displayName),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'isGuest': serializer.toJson<bool>(isGuest),
      'initialSyncCompleted': serializer.toJson<bool>(initialSyncCompleted),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  PlayerProfileRow copyWith({
    int? id,
    String? userId,
    Value<String?> username = const Value.absent(),
    Value<String?> displayName = const Value.absent(),
    Value<String?> photoUrl = const Value.absent(),
    bool? isGuest,
    bool? initialSyncCompleted,
    int? createdAt,
    int? updatedAt,
  }) => PlayerProfileRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    username: username.present ? username.value : this.username,
    displayName: displayName.present ? displayName.value : this.displayName,
    photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
    isGuest: isGuest ?? this.isGuest,
    initialSyncCompleted: initialSyncCompleted ?? this.initialSyncCompleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PlayerProfileRow copyWithCompanion(PlayerProfilesCompanion data) {
    return PlayerProfileRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      username: data.username.present ? data.username.value : this.username,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      isGuest: data.isGuest.present ? data.isGuest.value : this.isGuest,
      initialSyncCompleted: data.initialSyncCompleted.present
          ? data.initialSyncCompleted.value
          : this.initialSyncCompleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayerProfileRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('isGuest: $isGuest, ')
          ..write('initialSyncCompleted: $initialSyncCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    username,
    displayName,
    photoUrl,
    isGuest,
    initialSyncCompleted,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayerProfileRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.username == this.username &&
          other.displayName == this.displayName &&
          other.photoUrl == this.photoUrl &&
          other.isGuest == this.isGuest &&
          other.initialSyncCompleted == this.initialSyncCompleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PlayerProfilesCompanion extends UpdateCompanion<PlayerProfileRow> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String?> username;
  final Value<String?> displayName;
  final Value<String?> photoUrl;
  final Value<bool> isGuest;
  final Value<bool> initialSyncCompleted;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  const PlayerProfilesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.username = const Value.absent(),
    this.displayName = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.isGuest = const Value.absent(),
    this.initialSyncCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PlayerProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.username = const Value.absent(),
    this.displayName = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.isGuest = const Value.absent(),
    this.initialSyncCompleted = const Value.absent(),
    required int createdAt,
    required int updatedAt,
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PlayerProfileRow> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? username,
    Expression<String>? displayName,
    Expression<String>? photoUrl,
    Expression<bool>? isGuest,
    Expression<bool>? initialSyncCompleted,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (username != null) 'username': username,
      if (displayName != null) 'display_name': displayName,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (isGuest != null) 'is_guest': isGuest,
      if (initialSyncCompleted != null)
        'initial_sync_completed': initialSyncCompleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PlayerProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String?>? username,
    Value<String?>? displayName,
    Value<String?>? photoUrl,
    Value<bool>? isGuest,
    Value<bool>? initialSyncCompleted,
    Value<int>? createdAt,
    Value<int>? updatedAt,
  }) {
    return PlayerProfilesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isGuest: isGuest ?? this.isGuest,
      initialSyncCompleted: initialSyncCompleted ?? this.initialSyncCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (isGuest.present) {
      map['is_guest'] = Variable<bool>(isGuest.value);
    }
    if (initialSyncCompleted.present) {
      map['initial_sync_completed'] = Variable<bool>(
        initialSyncCompleted.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayerProfilesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('isGuest: $isGuest, ')
          ..write('initialSyncCompleted: $initialSyncCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PlayerStatsTableTable extends PlayerStatsTable
    with TableInfo<$PlayerStatsTableTable, PlayerStatsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayerStatsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _runsPlayedMeta = const VerificationMeta(
    'runsPlayed',
  );
  @override
  late final GeneratedColumn<int> runsPlayed = GeneratedColumn<int>(
    'runs_played',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalKillsMeta = const VerificationMeta(
    'totalKills',
  );
  @override
  late final GeneratedColumn<int> totalKills = GeneratedColumn<int>(
    'total_kills',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bestScoreMeta = const VerificationMeta(
    'bestScore',
  );
  @override
  late final GeneratedColumn<int> bestScore = GeneratedColumn<int>(
    'best_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bestChainMeta = const VerificationMeta(
    'bestChain',
  );
  @override
  late final GeneratedColumn<int> bestChain = GeneratedColumn<int>(
    'best_chain',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bestBounceKillMeta = const VerificationMeta(
    'bestBounceKill',
  );
  @override
  late final GeneratedColumn<int> bestBounceKill = GeneratedColumn<int>(
    'best_bounce_kill',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalWavesClearedMeta = const VerificationMeta(
    'totalWavesCleared',
  );
  @override
  late final GeneratedColumn<int> totalWavesCleared = GeneratedColumn<int>(
    'total_waves_cleared',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalCoinsEarnedMeta = const VerificationMeta(
    'totalCoinsEarned',
  );
  @override
  late final GeneratedColumn<int> totalCoinsEarned = GeneratedColumn<int>(
    'total_coins_earned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bestWaveMeta = const VerificationMeta(
    'bestWave',
  );
  @override
  late final GeneratedColumn<int> bestWave = GeneratedColumn<int>(
    'best_wave',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalPlayMsMeta = const VerificationMeta(
    'totalPlayMs',
  );
  @override
  late final GeneratedColumn<int> totalPlayMs = GeneratedColumn<int>(
    'total_play_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    runsPlayed,
    totalKills,
    bestScore,
    bestChain,
    bestBounceKill,
    totalWavesCleared,
    totalCoinsEarned,
    bestWave,
    totalPlayMs,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'player_stats';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlayerStatsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('runs_played')) {
      context.handle(
        _runsPlayedMeta,
        runsPlayed.isAcceptableOrUnknown(data['runs_played']!, _runsPlayedMeta),
      );
    }
    if (data.containsKey('total_kills')) {
      context.handle(
        _totalKillsMeta,
        totalKills.isAcceptableOrUnknown(data['total_kills']!, _totalKillsMeta),
      );
    }
    if (data.containsKey('best_score')) {
      context.handle(
        _bestScoreMeta,
        bestScore.isAcceptableOrUnknown(data['best_score']!, _bestScoreMeta),
      );
    }
    if (data.containsKey('best_chain')) {
      context.handle(
        _bestChainMeta,
        bestChain.isAcceptableOrUnknown(data['best_chain']!, _bestChainMeta),
      );
    }
    if (data.containsKey('best_bounce_kill')) {
      context.handle(
        _bestBounceKillMeta,
        bestBounceKill.isAcceptableOrUnknown(
          data['best_bounce_kill']!,
          _bestBounceKillMeta,
        ),
      );
    }
    if (data.containsKey('total_waves_cleared')) {
      context.handle(
        _totalWavesClearedMeta,
        totalWavesCleared.isAcceptableOrUnknown(
          data['total_waves_cleared']!,
          _totalWavesClearedMeta,
        ),
      );
    }
    if (data.containsKey('total_coins_earned')) {
      context.handle(
        _totalCoinsEarnedMeta,
        totalCoinsEarned.isAcceptableOrUnknown(
          data['total_coins_earned']!,
          _totalCoinsEarnedMeta,
        ),
      );
    }
    if (data.containsKey('best_wave')) {
      context.handle(
        _bestWaveMeta,
        bestWave.isAcceptableOrUnknown(data['best_wave']!, _bestWaveMeta),
      );
    }
    if (data.containsKey('total_play_ms')) {
      context.handle(
        _totalPlayMsMeta,
        totalPlayMs.isAcceptableOrUnknown(
          data['total_play_ms']!,
          _totalPlayMsMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayerStatsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayerStatsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      runsPlayed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}runs_played'],
      )!,
      totalKills: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_kills'],
      )!,
      bestScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_score'],
      )!,
      bestChain: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_chain'],
      )!,
      bestBounceKill: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_bounce_kill'],
      )!,
      totalWavesCleared: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_waves_cleared'],
      )!,
      totalCoinsEarned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_coins_earned'],
      )!,
      bestWave: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_wave'],
      )!,
      totalPlayMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_play_ms'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PlayerStatsTableTable createAlias(String alias) {
    return $PlayerStatsTableTable(attachedDatabase, alias);
  }
}

class PlayerStatsRow extends DataClass implements Insertable<PlayerStatsRow> {
  final int id;
  final int runsPlayed;
  final int totalKills;
  final int bestScore;
  final int bestChain;
  final int bestBounceKill;
  final int totalWavesCleared;
  final int totalCoinsEarned;
  final int bestWave;
  final int totalPlayMs;
  final int updatedAt;
  const PlayerStatsRow({
    required this.id,
    required this.runsPlayed,
    required this.totalKills,
    required this.bestScore,
    required this.bestChain,
    required this.bestBounceKill,
    required this.totalWavesCleared,
    required this.totalCoinsEarned,
    required this.bestWave,
    required this.totalPlayMs,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['runs_played'] = Variable<int>(runsPlayed);
    map['total_kills'] = Variable<int>(totalKills);
    map['best_score'] = Variable<int>(bestScore);
    map['best_chain'] = Variable<int>(bestChain);
    map['best_bounce_kill'] = Variable<int>(bestBounceKill);
    map['total_waves_cleared'] = Variable<int>(totalWavesCleared);
    map['total_coins_earned'] = Variable<int>(totalCoinsEarned);
    map['best_wave'] = Variable<int>(bestWave);
    map['total_play_ms'] = Variable<int>(totalPlayMs);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  PlayerStatsTableCompanion toCompanion(bool nullToAbsent) {
    return PlayerStatsTableCompanion(
      id: Value(id),
      runsPlayed: Value(runsPlayed),
      totalKills: Value(totalKills),
      bestScore: Value(bestScore),
      bestChain: Value(bestChain),
      bestBounceKill: Value(bestBounceKill),
      totalWavesCleared: Value(totalWavesCleared),
      totalCoinsEarned: Value(totalCoinsEarned),
      bestWave: Value(bestWave),
      totalPlayMs: Value(totalPlayMs),
      updatedAt: Value(updatedAt),
    );
  }

  factory PlayerStatsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayerStatsRow(
      id: serializer.fromJson<int>(json['id']),
      runsPlayed: serializer.fromJson<int>(json['runsPlayed']),
      totalKills: serializer.fromJson<int>(json['totalKills']),
      bestScore: serializer.fromJson<int>(json['bestScore']),
      bestChain: serializer.fromJson<int>(json['bestChain']),
      bestBounceKill: serializer.fromJson<int>(json['bestBounceKill']),
      totalWavesCleared: serializer.fromJson<int>(json['totalWavesCleared']),
      totalCoinsEarned: serializer.fromJson<int>(json['totalCoinsEarned']),
      bestWave: serializer.fromJson<int>(json['bestWave']),
      totalPlayMs: serializer.fromJson<int>(json['totalPlayMs']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'runsPlayed': serializer.toJson<int>(runsPlayed),
      'totalKills': serializer.toJson<int>(totalKills),
      'bestScore': serializer.toJson<int>(bestScore),
      'bestChain': serializer.toJson<int>(bestChain),
      'bestBounceKill': serializer.toJson<int>(bestBounceKill),
      'totalWavesCleared': serializer.toJson<int>(totalWavesCleared),
      'totalCoinsEarned': serializer.toJson<int>(totalCoinsEarned),
      'bestWave': serializer.toJson<int>(bestWave),
      'totalPlayMs': serializer.toJson<int>(totalPlayMs),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  PlayerStatsRow copyWith({
    int? id,
    int? runsPlayed,
    int? totalKills,
    int? bestScore,
    int? bestChain,
    int? bestBounceKill,
    int? totalWavesCleared,
    int? totalCoinsEarned,
    int? bestWave,
    int? totalPlayMs,
    int? updatedAt,
  }) => PlayerStatsRow(
    id: id ?? this.id,
    runsPlayed: runsPlayed ?? this.runsPlayed,
    totalKills: totalKills ?? this.totalKills,
    bestScore: bestScore ?? this.bestScore,
    bestChain: bestChain ?? this.bestChain,
    bestBounceKill: bestBounceKill ?? this.bestBounceKill,
    totalWavesCleared: totalWavesCleared ?? this.totalWavesCleared,
    totalCoinsEarned: totalCoinsEarned ?? this.totalCoinsEarned,
    bestWave: bestWave ?? this.bestWave,
    totalPlayMs: totalPlayMs ?? this.totalPlayMs,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PlayerStatsRow copyWithCompanion(PlayerStatsTableCompanion data) {
    return PlayerStatsRow(
      id: data.id.present ? data.id.value : this.id,
      runsPlayed: data.runsPlayed.present
          ? data.runsPlayed.value
          : this.runsPlayed,
      totalKills: data.totalKills.present
          ? data.totalKills.value
          : this.totalKills,
      bestScore: data.bestScore.present ? data.bestScore.value : this.bestScore,
      bestChain: data.bestChain.present ? data.bestChain.value : this.bestChain,
      bestBounceKill: data.bestBounceKill.present
          ? data.bestBounceKill.value
          : this.bestBounceKill,
      totalWavesCleared: data.totalWavesCleared.present
          ? data.totalWavesCleared.value
          : this.totalWavesCleared,
      totalCoinsEarned: data.totalCoinsEarned.present
          ? data.totalCoinsEarned.value
          : this.totalCoinsEarned,
      bestWave: data.bestWave.present ? data.bestWave.value : this.bestWave,
      totalPlayMs: data.totalPlayMs.present
          ? data.totalPlayMs.value
          : this.totalPlayMs,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayerStatsRow(')
          ..write('id: $id, ')
          ..write('runsPlayed: $runsPlayed, ')
          ..write('totalKills: $totalKills, ')
          ..write('bestScore: $bestScore, ')
          ..write('bestChain: $bestChain, ')
          ..write('bestBounceKill: $bestBounceKill, ')
          ..write('totalWavesCleared: $totalWavesCleared, ')
          ..write('totalCoinsEarned: $totalCoinsEarned, ')
          ..write('bestWave: $bestWave, ')
          ..write('totalPlayMs: $totalPlayMs, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    runsPlayed,
    totalKills,
    bestScore,
    bestChain,
    bestBounceKill,
    totalWavesCleared,
    totalCoinsEarned,
    bestWave,
    totalPlayMs,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayerStatsRow &&
          other.id == this.id &&
          other.runsPlayed == this.runsPlayed &&
          other.totalKills == this.totalKills &&
          other.bestScore == this.bestScore &&
          other.bestChain == this.bestChain &&
          other.bestBounceKill == this.bestBounceKill &&
          other.totalWavesCleared == this.totalWavesCleared &&
          other.totalCoinsEarned == this.totalCoinsEarned &&
          other.bestWave == this.bestWave &&
          other.totalPlayMs == this.totalPlayMs &&
          other.updatedAt == this.updatedAt);
}

class PlayerStatsTableCompanion extends UpdateCompanion<PlayerStatsRow> {
  final Value<int> id;
  final Value<int> runsPlayed;
  final Value<int> totalKills;
  final Value<int> bestScore;
  final Value<int> bestChain;
  final Value<int> bestBounceKill;
  final Value<int> totalWavesCleared;
  final Value<int> totalCoinsEarned;
  final Value<int> bestWave;
  final Value<int> totalPlayMs;
  final Value<int> updatedAt;
  const PlayerStatsTableCompanion({
    this.id = const Value.absent(),
    this.runsPlayed = const Value.absent(),
    this.totalKills = const Value.absent(),
    this.bestScore = const Value.absent(),
    this.bestChain = const Value.absent(),
    this.bestBounceKill = const Value.absent(),
    this.totalWavesCleared = const Value.absent(),
    this.totalCoinsEarned = const Value.absent(),
    this.bestWave = const Value.absent(),
    this.totalPlayMs = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PlayerStatsTableCompanion.insert({
    this.id = const Value.absent(),
    this.runsPlayed = const Value.absent(),
    this.totalKills = const Value.absent(),
    this.bestScore = const Value.absent(),
    this.bestChain = const Value.absent(),
    this.bestBounceKill = const Value.absent(),
    this.totalWavesCleared = const Value.absent(),
    this.totalCoinsEarned = const Value.absent(),
    this.bestWave = const Value.absent(),
    this.totalPlayMs = const Value.absent(),
    required int updatedAt,
  }) : updatedAt = Value(updatedAt);
  static Insertable<PlayerStatsRow> custom({
    Expression<int>? id,
    Expression<int>? runsPlayed,
    Expression<int>? totalKills,
    Expression<int>? bestScore,
    Expression<int>? bestChain,
    Expression<int>? bestBounceKill,
    Expression<int>? totalWavesCleared,
    Expression<int>? totalCoinsEarned,
    Expression<int>? bestWave,
    Expression<int>? totalPlayMs,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (runsPlayed != null) 'runs_played': runsPlayed,
      if (totalKills != null) 'total_kills': totalKills,
      if (bestScore != null) 'best_score': bestScore,
      if (bestChain != null) 'best_chain': bestChain,
      if (bestBounceKill != null) 'best_bounce_kill': bestBounceKill,
      if (totalWavesCleared != null) 'total_waves_cleared': totalWavesCleared,
      if (totalCoinsEarned != null) 'total_coins_earned': totalCoinsEarned,
      if (bestWave != null) 'best_wave': bestWave,
      if (totalPlayMs != null) 'total_play_ms': totalPlayMs,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PlayerStatsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? runsPlayed,
    Value<int>? totalKills,
    Value<int>? bestScore,
    Value<int>? bestChain,
    Value<int>? bestBounceKill,
    Value<int>? totalWavesCleared,
    Value<int>? totalCoinsEarned,
    Value<int>? bestWave,
    Value<int>? totalPlayMs,
    Value<int>? updatedAt,
  }) {
    return PlayerStatsTableCompanion(
      id: id ?? this.id,
      runsPlayed: runsPlayed ?? this.runsPlayed,
      totalKills: totalKills ?? this.totalKills,
      bestScore: bestScore ?? this.bestScore,
      bestChain: bestChain ?? this.bestChain,
      bestBounceKill: bestBounceKill ?? this.bestBounceKill,
      totalWavesCleared: totalWavesCleared ?? this.totalWavesCleared,
      totalCoinsEarned: totalCoinsEarned ?? this.totalCoinsEarned,
      bestWave: bestWave ?? this.bestWave,
      totalPlayMs: totalPlayMs ?? this.totalPlayMs,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (runsPlayed.present) {
      map['runs_played'] = Variable<int>(runsPlayed.value);
    }
    if (totalKills.present) {
      map['total_kills'] = Variable<int>(totalKills.value);
    }
    if (bestScore.present) {
      map['best_score'] = Variable<int>(bestScore.value);
    }
    if (bestChain.present) {
      map['best_chain'] = Variable<int>(bestChain.value);
    }
    if (bestBounceKill.present) {
      map['best_bounce_kill'] = Variable<int>(bestBounceKill.value);
    }
    if (totalWavesCleared.present) {
      map['total_waves_cleared'] = Variable<int>(totalWavesCleared.value);
    }
    if (totalCoinsEarned.present) {
      map['total_coins_earned'] = Variable<int>(totalCoinsEarned.value);
    }
    if (bestWave.present) {
      map['best_wave'] = Variable<int>(bestWave.value);
    }
    if (totalPlayMs.present) {
      map['total_play_ms'] = Variable<int>(totalPlayMs.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayerStatsTableCompanion(')
          ..write('id: $id, ')
          ..write('runsPlayed: $runsPlayed, ')
          ..write('totalKills: $totalKills, ')
          ..write('bestScore: $bestScore, ')
          ..write('bestChain: $bestChain, ')
          ..write('bestBounceKill: $bestBounceKill, ')
          ..write('totalWavesCleared: $totalWavesCleared, ')
          ..write('totalCoinsEarned: $totalCoinsEarned, ')
          ..write('bestWave: $bestWave, ')
          ..write('totalPlayMs: $totalPlayMs, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $StatCountersTable extends StatCounters
    with TableInfo<$StatCountersTable, StatCounterRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StatCountersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [kind, key, count];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stat_counters';
  @override
  VerificationContext validateIntegrity(
    Insertable<StatCounterRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {kind, key};
  @override
  StatCounterRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StatCounterRow(
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
    );
  }

  @override
  $StatCountersTable createAlias(String alias) {
    return $StatCountersTable(attachedDatabase, alias);
  }
}

class StatCounterRow extends DataClass implements Insertable<StatCounterRow> {
  final String kind;
  final String key;
  final int count;
  const StatCounterRow({
    required this.kind,
    required this.key,
    required this.count,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['kind'] = Variable<String>(kind);
    map['key'] = Variable<String>(key);
    map['count'] = Variable<int>(count);
    return map;
  }

  StatCountersCompanion toCompanion(bool nullToAbsent) {
    return StatCountersCompanion(
      kind: Value(kind),
      key: Value(key),
      count: Value(count),
    );
  }

  factory StatCounterRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StatCounterRow(
      kind: serializer.fromJson<String>(json['kind']),
      key: serializer.fromJson<String>(json['key']),
      count: serializer.fromJson<int>(json['count']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'kind': serializer.toJson<String>(kind),
      'key': serializer.toJson<String>(key),
      'count': serializer.toJson<int>(count),
    };
  }

  StatCounterRow copyWith({String? kind, String? key, int? count}) =>
      StatCounterRow(
        kind: kind ?? this.kind,
        key: key ?? this.key,
        count: count ?? this.count,
      );
  StatCounterRow copyWithCompanion(StatCountersCompanion data) {
    return StatCounterRow(
      kind: data.kind.present ? data.kind.value : this.kind,
      key: data.key.present ? data.key.value : this.key,
      count: data.count.present ? data.count.value : this.count,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StatCounterRow(')
          ..write('kind: $kind, ')
          ..write('key: $key, ')
          ..write('count: $count')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(kind, key, count);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StatCounterRow &&
          other.kind == this.kind &&
          other.key == this.key &&
          other.count == this.count);
}

class StatCountersCompanion extends UpdateCompanion<StatCounterRow> {
  final Value<String> kind;
  final Value<String> key;
  final Value<int> count;
  final Value<int> rowid;
  const StatCountersCompanion({
    this.kind = const Value.absent(),
    this.key = const Value.absent(),
    this.count = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StatCountersCompanion.insert({
    required String kind,
    required String key,
    this.count = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : kind = Value(kind),
       key = Value(key);
  static Insertable<StatCounterRow> custom({
    Expression<String>? kind,
    Expression<String>? key,
    Expression<int>? count,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (kind != null) 'kind': kind,
      if (key != null) 'key': key,
      if (count != null) 'count': count,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StatCountersCompanion copyWith({
    Value<String>? kind,
    Value<String>? key,
    Value<int>? count,
    Value<int>? rowid,
  }) {
    return StatCountersCompanion(
      kind: kind ?? this.kind,
      key: key ?? this.key,
      count: count ?? this.count,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StatCountersCompanion(')
          ..write('kind: $kind, ')
          ..write('key: $key, ')
          ..write('count: $count, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CoinLedgerEntriesTable extends CoinLedgerEntries
    with TableInfo<$CoinLedgerEntriesTable, CoinLedgerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoinLedgerEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<String> runId = GeneratedColumn<String>(
    'run_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, amount, reason, runId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'coin_ledger';
  @override
  VerificationContext validateIntegrity(
    Insertable<CoinLedgerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('run_id')) {
      context.handle(
        _runIdMeta,
        runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CoinLedgerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CoinLedgerRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      runId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}run_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CoinLedgerEntriesTable createAlias(String alias) {
    return $CoinLedgerEntriesTable(attachedDatabase, alias);
  }
}

class CoinLedgerRow extends DataClass implements Insertable<CoinLedgerRow> {
  /// Client-generated uuid v4 — also the sync idempotency key.
  final String id;

  /// Signed: positive = earned, negative = spent.
  final int amount;

  /// CoinReason enum name: runReward | coinPickup | waveBonus | chainBonus |
  /// dailyLogin | dailyChallenge | achievementClaim | snapshotRestore |
  /// adjustment.
  final String reason;
  final String? runId;
  final int createdAt;
  const CoinLedgerRow({
    required this.id,
    required this.amount,
    required this.reason,
    this.runId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['amount'] = Variable<int>(amount);
    map['reason'] = Variable<String>(reason);
    if (!nullToAbsent || runId != null) {
      map['run_id'] = Variable<String>(runId);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  CoinLedgerEntriesCompanion toCompanion(bool nullToAbsent) {
    return CoinLedgerEntriesCompanion(
      id: Value(id),
      amount: Value(amount),
      reason: Value(reason),
      runId: runId == null && nullToAbsent
          ? const Value.absent()
          : Value(runId),
      createdAt: Value(createdAt),
    );
  }

  factory CoinLedgerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CoinLedgerRow(
      id: serializer.fromJson<String>(json['id']),
      amount: serializer.fromJson<int>(json['amount']),
      reason: serializer.fromJson<String>(json['reason']),
      runId: serializer.fromJson<String?>(json['runId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'amount': serializer.toJson<int>(amount),
      'reason': serializer.toJson<String>(reason),
      'runId': serializer.toJson<String?>(runId),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  CoinLedgerRow copyWith({
    String? id,
    int? amount,
    String? reason,
    Value<String?> runId = const Value.absent(),
    int? createdAt,
  }) => CoinLedgerRow(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    reason: reason ?? this.reason,
    runId: runId.present ? runId.value : this.runId,
    createdAt: createdAt ?? this.createdAt,
  );
  CoinLedgerRow copyWithCompanion(CoinLedgerEntriesCompanion data) {
    return CoinLedgerRow(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      reason: data.reason.present ? data.reason.value : this.reason,
      runId: data.runId.present ? data.runId.value : this.runId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CoinLedgerRow(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('reason: $reason, ')
          ..write('runId: $runId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, amount, reason, runId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CoinLedgerRow &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.reason == this.reason &&
          other.runId == this.runId &&
          other.createdAt == this.createdAt);
}

class CoinLedgerEntriesCompanion extends UpdateCompanion<CoinLedgerRow> {
  final Value<String> id;
  final Value<int> amount;
  final Value<String> reason;
  final Value<String?> runId;
  final Value<int> createdAt;
  final Value<int> rowid;
  const CoinLedgerEntriesCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.reason = const Value.absent(),
    this.runId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CoinLedgerEntriesCompanion.insert({
    required String id,
    required int amount,
    required String reason,
    this.runId = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       amount = Value(amount),
       reason = Value(reason),
       createdAt = Value(createdAt);
  static Insertable<CoinLedgerRow> custom({
    Expression<String>? id,
    Expression<int>? amount,
    Expression<String>? reason,
    Expression<String>? runId,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (reason != null) 'reason': reason,
      if (runId != null) 'run_id': runId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CoinLedgerEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? amount,
    Value<String>? reason,
    Value<String?>? runId,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return CoinLedgerEntriesCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      runId: runId ?? this.runId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (runId.present) {
      map['run_id'] = Variable<String>(runId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoinLedgerEntriesCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('reason: $reason, ')
          ..write('runId: $runId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CoinBalancesTable extends CoinBalances
    with TableInfo<$CoinBalancesTable, CoinBalanceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoinBalancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _balanceMeta = const VerificationMeta(
    'balance',
  );
  @override
  late final GeneratedColumn<int> balance = GeneratedColumn<int>(
    'balance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastLedgerCreatedAtMeta =
      const VerificationMeta('lastLedgerCreatedAt');
  @override
  late final GeneratedColumn<int> lastLedgerCreatedAt = GeneratedColumn<int>(
    'last_ledger_created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, balance, lastLedgerCreatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'coin_balances';
  @override
  VerificationContext validateIntegrity(
    Insertable<CoinBalanceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('balance')) {
      context.handle(
        _balanceMeta,
        balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta),
      );
    }
    if (data.containsKey('last_ledger_created_at')) {
      context.handle(
        _lastLedgerCreatedAtMeta,
        lastLedgerCreatedAt.isAcceptableOrUnknown(
          data['last_ledger_created_at']!,
          _lastLedgerCreatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CoinBalanceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CoinBalanceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      balance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance'],
      )!,
      lastLedgerCreatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_ledger_created_at'],
      )!,
    );
  }

  @override
  $CoinBalancesTable createAlias(String alias) {
    return $CoinBalancesTable(attachedDatabase, alias);
  }
}

class CoinBalanceRow extends DataClass implements Insertable<CoinBalanceRow> {
  final int id;
  final int balance;
  final int lastLedgerCreatedAt;
  const CoinBalanceRow({
    required this.id,
    required this.balance,
    required this.lastLedgerCreatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['balance'] = Variable<int>(balance);
    map['last_ledger_created_at'] = Variable<int>(lastLedgerCreatedAt);
    return map;
  }

  CoinBalancesCompanion toCompanion(bool nullToAbsent) {
    return CoinBalancesCompanion(
      id: Value(id),
      balance: Value(balance),
      lastLedgerCreatedAt: Value(lastLedgerCreatedAt),
    );
  }

  factory CoinBalanceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CoinBalanceRow(
      id: serializer.fromJson<int>(json['id']),
      balance: serializer.fromJson<int>(json['balance']),
      lastLedgerCreatedAt: serializer.fromJson<int>(
        json['lastLedgerCreatedAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'balance': serializer.toJson<int>(balance),
      'lastLedgerCreatedAt': serializer.toJson<int>(lastLedgerCreatedAt),
    };
  }

  CoinBalanceRow copyWith({int? id, int? balance, int? lastLedgerCreatedAt}) =>
      CoinBalanceRow(
        id: id ?? this.id,
        balance: balance ?? this.balance,
        lastLedgerCreatedAt: lastLedgerCreatedAt ?? this.lastLedgerCreatedAt,
      );
  CoinBalanceRow copyWithCompanion(CoinBalancesCompanion data) {
    return CoinBalanceRow(
      id: data.id.present ? data.id.value : this.id,
      balance: data.balance.present ? data.balance.value : this.balance,
      lastLedgerCreatedAt: data.lastLedgerCreatedAt.present
          ? data.lastLedgerCreatedAt.value
          : this.lastLedgerCreatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CoinBalanceRow(')
          ..write('id: $id, ')
          ..write('balance: $balance, ')
          ..write('lastLedgerCreatedAt: $lastLedgerCreatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, balance, lastLedgerCreatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CoinBalanceRow &&
          other.id == this.id &&
          other.balance == this.balance &&
          other.lastLedgerCreatedAt == this.lastLedgerCreatedAt);
}

class CoinBalancesCompanion extends UpdateCompanion<CoinBalanceRow> {
  final Value<int> id;
  final Value<int> balance;
  final Value<int> lastLedgerCreatedAt;
  const CoinBalancesCompanion({
    this.id = const Value.absent(),
    this.balance = const Value.absent(),
    this.lastLedgerCreatedAt = const Value.absent(),
  });
  CoinBalancesCompanion.insert({
    this.id = const Value.absent(),
    this.balance = const Value.absent(),
    this.lastLedgerCreatedAt = const Value.absent(),
  });
  static Insertable<CoinBalanceRow> custom({
    Expression<int>? id,
    Expression<int>? balance,
    Expression<int>? lastLedgerCreatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (balance != null) 'balance': balance,
      if (lastLedgerCreatedAt != null)
        'last_ledger_created_at': lastLedgerCreatedAt,
    });
  }

  CoinBalancesCompanion copyWith({
    Value<int>? id,
    Value<int>? balance,
    Value<int>? lastLedgerCreatedAt,
  }) {
    return CoinBalancesCompanion(
      id: id ?? this.id,
      balance: balance ?? this.balance,
      lastLedgerCreatedAt: lastLedgerCreatedAt ?? this.lastLedgerCreatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (balance.present) {
      map['balance'] = Variable<int>(balance.value);
    }
    if (lastLedgerCreatedAt.present) {
      map['last_ledger_created_at'] = Variable<int>(lastLedgerCreatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoinBalancesCompanion(')
          ..write('id: $id, ')
          ..write('balance: $balance, ')
          ..write('lastLedgerCreatedAt: $lastLedgerCreatedAt')
          ..write(')'))
        .toString();
  }
}

class $RunsTable extends Runs with TableInfo<$RunsTable, RunRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _waveReachedMeta = const VerificationMeta(
    'waveReached',
  );
  @override
  late final GeneratedColumn<int> waveReached = GeneratedColumn<int>(
    'wave_reached',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _killsMeta = const VerificationMeta('kills');
  @override
  late final GeneratedColumn<int> kills = GeneratedColumn<int>(
    'kills',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bestChainMeta = const VerificationMeta(
    'bestChain',
  );
  @override
  late final GeneratedColumn<int> bestChain = GeneratedColumn<int>(
    'best_chain',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxBounceKillMeta = const VerificationMeta(
    'maxBounceKill',
  );
  @override
  late final GeneratedColumn<int> maxBounceKill = GeneratedColumn<int>(
    'max_bounce_kill',
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
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coinsEarnedMeta = const VerificationMeta(
    'coinsEarned',
  );
  @override
  late final GeneratedColumn<int> coinsEarned = GeneratedColumn<int>(
    'coins_earned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDailyChallengeMeta = const VerificationMeta(
    'isDailyChallenge',
  );
  @override
  late final GeneratedColumn<bool> isDailyChallenge = GeneratedColumn<bool>(
    'is_daily_challenge',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_daily_challenge" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _challengeDateMeta = const VerificationMeta(
    'challengeDate',
  );
  @override
  late final GeneratedColumn<String> challengeDate = GeneratedColumn<String>(
    'challenge_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tournamentIdMeta = const VerificationMeta(
    'tournamentId',
  );
  @override
  late final GeneratedColumn<String> tournamentId = GeneratedColumn<String>(
    'tournament_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _arenaIdMeta = const VerificationMeta(
    'arenaId',
  );
  @override
  late final GeneratedColumn<String> arenaId = GeneratedColumn<String>(
    'arena_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _upgradesPickedMeta = const VerificationMeta(
    'upgradesPicked',
  );
  @override
  late final GeneratedColumn<String> upgradesPicked = GeneratedColumn<String>(
    'upgrades_picked',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<int> endedAt = GeneratedColumn<int>(
    'ended_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    score,
    waveReached,
    kills,
    bestChain,
    maxBounceKill,
    durationMs,
    coinsEarned,
    isDailyChallenge,
    challengeDate,
    tournamentId,
    arenaId,
    upgradesPicked,
    endedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<RunRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('wave_reached')) {
      context.handle(
        _waveReachedMeta,
        waveReached.isAcceptableOrUnknown(
          data['wave_reached']!,
          _waveReachedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_waveReachedMeta);
    }
    if (data.containsKey('kills')) {
      context.handle(
        _killsMeta,
        kills.isAcceptableOrUnknown(data['kills']!, _killsMeta),
      );
    } else if (isInserting) {
      context.missing(_killsMeta);
    }
    if (data.containsKey('best_chain')) {
      context.handle(
        _bestChainMeta,
        bestChain.isAcceptableOrUnknown(data['best_chain']!, _bestChainMeta),
      );
    } else if (isInserting) {
      context.missing(_bestChainMeta);
    }
    if (data.containsKey('max_bounce_kill')) {
      context.handle(
        _maxBounceKillMeta,
        maxBounceKill.isAcceptableOrUnknown(
          data['max_bounce_kill']!,
          _maxBounceKillMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_maxBounceKillMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('coins_earned')) {
      context.handle(
        _coinsEarnedMeta,
        coinsEarned.isAcceptableOrUnknown(
          data['coins_earned']!,
          _coinsEarnedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_coinsEarnedMeta);
    }
    if (data.containsKey('is_daily_challenge')) {
      context.handle(
        _isDailyChallengeMeta,
        isDailyChallenge.isAcceptableOrUnknown(
          data['is_daily_challenge']!,
          _isDailyChallengeMeta,
        ),
      );
    }
    if (data.containsKey('challenge_date')) {
      context.handle(
        _challengeDateMeta,
        challengeDate.isAcceptableOrUnknown(
          data['challenge_date']!,
          _challengeDateMeta,
        ),
      );
    }
    if (data.containsKey('tournament_id')) {
      context.handle(
        _tournamentIdMeta,
        tournamentId.isAcceptableOrUnknown(
          data['tournament_id']!,
          _tournamentIdMeta,
        ),
      );
    }
    if (data.containsKey('arena_id')) {
      context.handle(
        _arenaIdMeta,
        arenaId.isAcceptableOrUnknown(data['arena_id']!, _arenaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_arenaIdMeta);
    }
    if (data.containsKey('upgrades_picked')) {
      context.handle(
        _upgradesPickedMeta,
        upgradesPicked.isAcceptableOrUnknown(
          data['upgrades_picked']!,
          _upgradesPickedMeta,
        ),
      );
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RunRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RunRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      waveReached: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wave_reached'],
      )!,
      kills: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kills'],
      )!,
      bestChain: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_chain'],
      )!,
      maxBounceKill: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_bounce_kill'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      coinsEarned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}coins_earned'],
      )!,
      isDailyChallenge: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_daily_challenge'],
      )!,
      challengeDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}challenge_date'],
      ),
      tournamentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tournament_id'],
      ),
      arenaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arena_id'],
      )!,
      upgradesPicked: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}upgrades_picked'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ended_at'],
      )!,
    );
  }

  @override
  $RunsTable createAlias(String alias) {
    return $RunsTable(attachedDatabase, alias);
  }
}

class RunRow extends DataClass implements Insertable<RunRow> {
  /// Client-generated uuid v4 — also the backend GameRun PK.
  final String id;
  final int score;
  final int waveReached;
  final int kills;
  final int bestChain;
  final int maxBounceKill;
  final int durationMs;
  final int coinsEarned;
  final bool isDailyChallenge;

  /// UTC date yyyy-MM-dd when this run was a daily challenge attempt.
  final String? challengeDate;

  /// Tournament id when this run was a tournament entry.
  final String? tournamentId;
  final String arenaId;

  /// JSON array of upgrade card ids picked during the run, in order.
  final String upgradesPicked;
  final int endedAt;
  const RunRow({
    required this.id,
    required this.score,
    required this.waveReached,
    required this.kills,
    required this.bestChain,
    required this.maxBounceKill,
    required this.durationMs,
    required this.coinsEarned,
    required this.isDailyChallenge,
    this.challengeDate,
    this.tournamentId,
    required this.arenaId,
    required this.upgradesPicked,
    required this.endedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['score'] = Variable<int>(score);
    map['wave_reached'] = Variable<int>(waveReached);
    map['kills'] = Variable<int>(kills);
    map['best_chain'] = Variable<int>(bestChain);
    map['max_bounce_kill'] = Variable<int>(maxBounceKill);
    map['duration_ms'] = Variable<int>(durationMs);
    map['coins_earned'] = Variable<int>(coinsEarned);
    map['is_daily_challenge'] = Variable<bool>(isDailyChallenge);
    if (!nullToAbsent || challengeDate != null) {
      map['challenge_date'] = Variable<String>(challengeDate);
    }
    if (!nullToAbsent || tournamentId != null) {
      map['tournament_id'] = Variable<String>(tournamentId);
    }
    map['arena_id'] = Variable<String>(arenaId);
    map['upgrades_picked'] = Variable<String>(upgradesPicked);
    map['ended_at'] = Variable<int>(endedAt);
    return map;
  }

  RunsCompanion toCompanion(bool nullToAbsent) {
    return RunsCompanion(
      id: Value(id),
      score: Value(score),
      waveReached: Value(waveReached),
      kills: Value(kills),
      bestChain: Value(bestChain),
      maxBounceKill: Value(maxBounceKill),
      durationMs: Value(durationMs),
      coinsEarned: Value(coinsEarned),
      isDailyChallenge: Value(isDailyChallenge),
      challengeDate: challengeDate == null && nullToAbsent
          ? const Value.absent()
          : Value(challengeDate),
      tournamentId: tournamentId == null && nullToAbsent
          ? const Value.absent()
          : Value(tournamentId),
      arenaId: Value(arenaId),
      upgradesPicked: Value(upgradesPicked),
      endedAt: Value(endedAt),
    );
  }

  factory RunRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RunRow(
      id: serializer.fromJson<String>(json['id']),
      score: serializer.fromJson<int>(json['score']),
      waveReached: serializer.fromJson<int>(json['waveReached']),
      kills: serializer.fromJson<int>(json['kills']),
      bestChain: serializer.fromJson<int>(json['bestChain']),
      maxBounceKill: serializer.fromJson<int>(json['maxBounceKill']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      coinsEarned: serializer.fromJson<int>(json['coinsEarned']),
      isDailyChallenge: serializer.fromJson<bool>(json['isDailyChallenge']),
      challengeDate: serializer.fromJson<String?>(json['challengeDate']),
      tournamentId: serializer.fromJson<String?>(json['tournamentId']),
      arenaId: serializer.fromJson<String>(json['arenaId']),
      upgradesPicked: serializer.fromJson<String>(json['upgradesPicked']),
      endedAt: serializer.fromJson<int>(json['endedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'score': serializer.toJson<int>(score),
      'waveReached': serializer.toJson<int>(waveReached),
      'kills': serializer.toJson<int>(kills),
      'bestChain': serializer.toJson<int>(bestChain),
      'maxBounceKill': serializer.toJson<int>(maxBounceKill),
      'durationMs': serializer.toJson<int>(durationMs),
      'coinsEarned': serializer.toJson<int>(coinsEarned),
      'isDailyChallenge': serializer.toJson<bool>(isDailyChallenge),
      'challengeDate': serializer.toJson<String?>(challengeDate),
      'tournamentId': serializer.toJson<String?>(tournamentId),
      'arenaId': serializer.toJson<String>(arenaId),
      'upgradesPicked': serializer.toJson<String>(upgradesPicked),
      'endedAt': serializer.toJson<int>(endedAt),
    };
  }

  RunRow copyWith({
    String? id,
    int? score,
    int? waveReached,
    int? kills,
    int? bestChain,
    int? maxBounceKill,
    int? durationMs,
    int? coinsEarned,
    bool? isDailyChallenge,
    Value<String?> challengeDate = const Value.absent(),
    Value<String?> tournamentId = const Value.absent(),
    String? arenaId,
    String? upgradesPicked,
    int? endedAt,
  }) => RunRow(
    id: id ?? this.id,
    score: score ?? this.score,
    waveReached: waveReached ?? this.waveReached,
    kills: kills ?? this.kills,
    bestChain: bestChain ?? this.bestChain,
    maxBounceKill: maxBounceKill ?? this.maxBounceKill,
    durationMs: durationMs ?? this.durationMs,
    coinsEarned: coinsEarned ?? this.coinsEarned,
    isDailyChallenge: isDailyChallenge ?? this.isDailyChallenge,
    challengeDate: challengeDate.present
        ? challengeDate.value
        : this.challengeDate,
    tournamentId: tournamentId.present ? tournamentId.value : this.tournamentId,
    arenaId: arenaId ?? this.arenaId,
    upgradesPicked: upgradesPicked ?? this.upgradesPicked,
    endedAt: endedAt ?? this.endedAt,
  );
  RunRow copyWithCompanion(RunsCompanion data) {
    return RunRow(
      id: data.id.present ? data.id.value : this.id,
      score: data.score.present ? data.score.value : this.score,
      waveReached: data.waveReached.present
          ? data.waveReached.value
          : this.waveReached,
      kills: data.kills.present ? data.kills.value : this.kills,
      bestChain: data.bestChain.present ? data.bestChain.value : this.bestChain,
      maxBounceKill: data.maxBounceKill.present
          ? data.maxBounceKill.value
          : this.maxBounceKill,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      coinsEarned: data.coinsEarned.present
          ? data.coinsEarned.value
          : this.coinsEarned,
      isDailyChallenge: data.isDailyChallenge.present
          ? data.isDailyChallenge.value
          : this.isDailyChallenge,
      challengeDate: data.challengeDate.present
          ? data.challengeDate.value
          : this.challengeDate,
      tournamentId: data.tournamentId.present
          ? data.tournamentId.value
          : this.tournamentId,
      arenaId: data.arenaId.present ? data.arenaId.value : this.arenaId,
      upgradesPicked: data.upgradesPicked.present
          ? data.upgradesPicked.value
          : this.upgradesPicked,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RunRow(')
          ..write('id: $id, ')
          ..write('score: $score, ')
          ..write('waveReached: $waveReached, ')
          ..write('kills: $kills, ')
          ..write('bestChain: $bestChain, ')
          ..write('maxBounceKill: $maxBounceKill, ')
          ..write('durationMs: $durationMs, ')
          ..write('coinsEarned: $coinsEarned, ')
          ..write('isDailyChallenge: $isDailyChallenge, ')
          ..write('challengeDate: $challengeDate, ')
          ..write('tournamentId: $tournamentId, ')
          ..write('arenaId: $arenaId, ')
          ..write('upgradesPicked: $upgradesPicked, ')
          ..write('endedAt: $endedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    score,
    waveReached,
    kills,
    bestChain,
    maxBounceKill,
    durationMs,
    coinsEarned,
    isDailyChallenge,
    challengeDate,
    tournamentId,
    arenaId,
    upgradesPicked,
    endedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RunRow &&
          other.id == this.id &&
          other.score == this.score &&
          other.waveReached == this.waveReached &&
          other.kills == this.kills &&
          other.bestChain == this.bestChain &&
          other.maxBounceKill == this.maxBounceKill &&
          other.durationMs == this.durationMs &&
          other.coinsEarned == this.coinsEarned &&
          other.isDailyChallenge == this.isDailyChallenge &&
          other.challengeDate == this.challengeDate &&
          other.tournamentId == this.tournamentId &&
          other.arenaId == this.arenaId &&
          other.upgradesPicked == this.upgradesPicked &&
          other.endedAt == this.endedAt);
}

class RunsCompanion extends UpdateCompanion<RunRow> {
  final Value<String> id;
  final Value<int> score;
  final Value<int> waveReached;
  final Value<int> kills;
  final Value<int> bestChain;
  final Value<int> maxBounceKill;
  final Value<int> durationMs;
  final Value<int> coinsEarned;
  final Value<bool> isDailyChallenge;
  final Value<String?> challengeDate;
  final Value<String?> tournamentId;
  final Value<String> arenaId;
  final Value<String> upgradesPicked;
  final Value<int> endedAt;
  final Value<int> rowid;
  const RunsCompanion({
    this.id = const Value.absent(),
    this.score = const Value.absent(),
    this.waveReached = const Value.absent(),
    this.kills = const Value.absent(),
    this.bestChain = const Value.absent(),
    this.maxBounceKill = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.coinsEarned = const Value.absent(),
    this.isDailyChallenge = const Value.absent(),
    this.challengeDate = const Value.absent(),
    this.tournamentId = const Value.absent(),
    this.arenaId = const Value.absent(),
    this.upgradesPicked = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RunsCompanion.insert({
    required String id,
    required int score,
    required int waveReached,
    required int kills,
    required int bestChain,
    required int maxBounceKill,
    required int durationMs,
    required int coinsEarned,
    this.isDailyChallenge = const Value.absent(),
    this.challengeDate = const Value.absent(),
    this.tournamentId = const Value.absent(),
    required String arenaId,
    this.upgradesPicked = const Value.absent(),
    required int endedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       score = Value(score),
       waveReached = Value(waveReached),
       kills = Value(kills),
       bestChain = Value(bestChain),
       maxBounceKill = Value(maxBounceKill),
       durationMs = Value(durationMs),
       coinsEarned = Value(coinsEarned),
       arenaId = Value(arenaId),
       endedAt = Value(endedAt);
  static Insertable<RunRow> custom({
    Expression<String>? id,
    Expression<int>? score,
    Expression<int>? waveReached,
    Expression<int>? kills,
    Expression<int>? bestChain,
    Expression<int>? maxBounceKill,
    Expression<int>? durationMs,
    Expression<int>? coinsEarned,
    Expression<bool>? isDailyChallenge,
    Expression<String>? challengeDate,
    Expression<String>? tournamentId,
    Expression<String>? arenaId,
    Expression<String>? upgradesPicked,
    Expression<int>? endedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (score != null) 'score': score,
      if (waveReached != null) 'wave_reached': waveReached,
      if (kills != null) 'kills': kills,
      if (bestChain != null) 'best_chain': bestChain,
      if (maxBounceKill != null) 'max_bounce_kill': maxBounceKill,
      if (durationMs != null) 'duration_ms': durationMs,
      if (coinsEarned != null) 'coins_earned': coinsEarned,
      if (isDailyChallenge != null) 'is_daily_challenge': isDailyChallenge,
      if (challengeDate != null) 'challenge_date': challengeDate,
      if (tournamentId != null) 'tournament_id': tournamentId,
      if (arenaId != null) 'arena_id': arenaId,
      if (upgradesPicked != null) 'upgrades_picked': upgradesPicked,
      if (endedAt != null) 'ended_at': endedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RunsCompanion copyWith({
    Value<String>? id,
    Value<int>? score,
    Value<int>? waveReached,
    Value<int>? kills,
    Value<int>? bestChain,
    Value<int>? maxBounceKill,
    Value<int>? durationMs,
    Value<int>? coinsEarned,
    Value<bool>? isDailyChallenge,
    Value<String?>? challengeDate,
    Value<String?>? tournamentId,
    Value<String>? arenaId,
    Value<String>? upgradesPicked,
    Value<int>? endedAt,
    Value<int>? rowid,
  }) {
    return RunsCompanion(
      id: id ?? this.id,
      score: score ?? this.score,
      waveReached: waveReached ?? this.waveReached,
      kills: kills ?? this.kills,
      bestChain: bestChain ?? this.bestChain,
      maxBounceKill: maxBounceKill ?? this.maxBounceKill,
      durationMs: durationMs ?? this.durationMs,
      coinsEarned: coinsEarned ?? this.coinsEarned,
      isDailyChallenge: isDailyChallenge ?? this.isDailyChallenge,
      challengeDate: challengeDate ?? this.challengeDate,
      tournamentId: tournamentId ?? this.tournamentId,
      arenaId: arenaId ?? this.arenaId,
      upgradesPicked: upgradesPicked ?? this.upgradesPicked,
      endedAt: endedAt ?? this.endedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (waveReached.present) {
      map['wave_reached'] = Variable<int>(waveReached.value);
    }
    if (kills.present) {
      map['kills'] = Variable<int>(kills.value);
    }
    if (bestChain.present) {
      map['best_chain'] = Variable<int>(bestChain.value);
    }
    if (maxBounceKill.present) {
      map['max_bounce_kill'] = Variable<int>(maxBounceKill.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (coinsEarned.present) {
      map['coins_earned'] = Variable<int>(coinsEarned.value);
    }
    if (isDailyChallenge.present) {
      map['is_daily_challenge'] = Variable<bool>(isDailyChallenge.value);
    }
    if (challengeDate.present) {
      map['challenge_date'] = Variable<String>(challengeDate.value);
    }
    if (tournamentId.present) {
      map['tournament_id'] = Variable<String>(tournamentId.value);
    }
    if (arenaId.present) {
      map['arena_id'] = Variable<String>(arenaId.value);
    }
    if (upgradesPicked.present) {
      map['upgrades_picked'] = Variable<String>(upgradesPicked.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<int>(endedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RunsCompanion(')
          ..write('id: $id, ')
          ..write('score: $score, ')
          ..write('waveReached: $waveReached, ')
          ..write('kills: $kills, ')
          ..write('bestChain: $bestChain, ')
          ..write('maxBounceKill: $maxBounceKill, ')
          ..write('durationMs: $durationMs, ')
          ..write('coinsEarned: $coinsEarned, ')
          ..write('isDailyChallenge: $isDailyChallenge, ')
          ..write('challengeDate: $challengeDate, ')
          ..write('tournamentId: $tournamentId, ')
          ..write('arenaId: $arenaId, ')
          ..write('upgradesPicked: $upgradesPicked, ')
          ..write('endedAt: $endedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AchievementStatesTable extends AchievementStates
    with TableInfo<$AchievementStatesTable, AchievementStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _achievementIdMeta = const VerificationMeta(
    'achievementId',
  );
  @override
  late final GeneratedColumn<String> achievementId = GeneratedColumn<String>(
    'achievement_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<int> progress = GeneratedColumn<int>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<int> unlockedAt = GeneratedColumn<int>(
    'unlocked_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _claimedAtMeta = const VerificationMeta(
    'claimedAt',
  );
  @override
  late final GeneratedColumn<int> claimedAt = GeneratedColumn<int>(
    'claimed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    achievementId,
    progress,
    unlockedAt,
    claimedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievement_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<AchievementStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('achievement_id')) {
      context.handle(
        _achievementIdMeta,
        achievementId.isAcceptableOrUnknown(
          data['achievement_id']!,
          _achievementIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_achievementIdMeta);
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    }
    if (data.containsKey('claimed_at')) {
      context.handle(
        _claimedAtMeta,
        claimedAt.isAcceptableOrUnknown(data['claimed_at']!, _claimedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {achievementId};
  @override
  AchievementStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AchievementStateRow(
      achievementId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}achievement_id'],
      )!,
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progress'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unlocked_at'],
      ),
      claimedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}claimed_at'],
      ),
    );
  }

  @override
  $AchievementStatesTable createAlias(String alias) {
    return $AchievementStatesTable(attachedDatabase, alias);
  }
}

class AchievementStateRow extends DataClass
    implements Insertable<AchievementStateRow> {
  final String achievementId;
  final int progress;

  /// Set when the requirement is met. Claiming (coin reward granted) is a
  /// separate step so the awards screen can run its claim animation.
  final int? unlockedAt;
  final int? claimedAt;
  const AchievementStateRow({
    required this.achievementId,
    required this.progress,
    this.unlockedAt,
    this.claimedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['achievement_id'] = Variable<String>(achievementId);
    map['progress'] = Variable<int>(progress);
    if (!nullToAbsent || unlockedAt != null) {
      map['unlocked_at'] = Variable<int>(unlockedAt);
    }
    if (!nullToAbsent || claimedAt != null) {
      map['claimed_at'] = Variable<int>(claimedAt);
    }
    return map;
  }

  AchievementStatesCompanion toCompanion(bool nullToAbsent) {
    return AchievementStatesCompanion(
      achievementId: Value(achievementId),
      progress: Value(progress),
      unlockedAt: unlockedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(unlockedAt),
      claimedAt: claimedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(claimedAt),
    );
  }

  factory AchievementStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AchievementStateRow(
      achievementId: serializer.fromJson<String>(json['achievementId']),
      progress: serializer.fromJson<int>(json['progress']),
      unlockedAt: serializer.fromJson<int?>(json['unlockedAt']),
      claimedAt: serializer.fromJson<int?>(json['claimedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'achievementId': serializer.toJson<String>(achievementId),
      'progress': serializer.toJson<int>(progress),
      'unlockedAt': serializer.toJson<int?>(unlockedAt),
      'claimedAt': serializer.toJson<int?>(claimedAt),
    };
  }

  AchievementStateRow copyWith({
    String? achievementId,
    int? progress,
    Value<int?> unlockedAt = const Value.absent(),
    Value<int?> claimedAt = const Value.absent(),
  }) => AchievementStateRow(
    achievementId: achievementId ?? this.achievementId,
    progress: progress ?? this.progress,
    unlockedAt: unlockedAt.present ? unlockedAt.value : this.unlockedAt,
    claimedAt: claimedAt.present ? claimedAt.value : this.claimedAt,
  );
  AchievementStateRow copyWithCompanion(AchievementStatesCompanion data) {
    return AchievementStateRow(
      achievementId: data.achievementId.present
          ? data.achievementId.value
          : this.achievementId,
      progress: data.progress.present ? data.progress.value : this.progress,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
      claimedAt: data.claimedAt.present ? data.claimedAt.value : this.claimedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AchievementStateRow(')
          ..write('achievementId: $achievementId, ')
          ..write('progress: $progress, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('claimedAt: $claimedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(achievementId, progress, unlockedAt, claimedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AchievementStateRow &&
          other.achievementId == this.achievementId &&
          other.progress == this.progress &&
          other.unlockedAt == this.unlockedAt &&
          other.claimedAt == this.claimedAt);
}

class AchievementStatesCompanion extends UpdateCompanion<AchievementStateRow> {
  final Value<String> achievementId;
  final Value<int> progress;
  final Value<int?> unlockedAt;
  final Value<int?> claimedAt;
  final Value<int> rowid;
  const AchievementStatesCompanion({
    this.achievementId = const Value.absent(),
    this.progress = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.claimedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AchievementStatesCompanion.insert({
    required String achievementId,
    this.progress = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.claimedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : achievementId = Value(achievementId);
  static Insertable<AchievementStateRow> custom({
    Expression<String>? achievementId,
    Expression<int>? progress,
    Expression<int>? unlockedAt,
    Expression<int>? claimedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (achievementId != null) 'achievement_id': achievementId,
      if (progress != null) 'progress': progress,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (claimedAt != null) 'claimed_at': claimedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AchievementStatesCompanion copyWith({
    Value<String>? achievementId,
    Value<int>? progress,
    Value<int?>? unlockedAt,
    Value<int?>? claimedAt,
    Value<int>? rowid,
  }) {
    return AchievementStatesCompanion(
      achievementId: achievementId ?? this.achievementId,
      progress: progress ?? this.progress,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      claimedAt: claimedAt ?? this.claimedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (achievementId.present) {
      map['achievement_id'] = Variable<String>(achievementId.value);
    }
    if (progress.present) {
      map['progress'] = Variable<int>(progress.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<int>(unlockedAt.value);
    }
    if (claimedAt.present) {
      map['claimed_at'] = Variable<int>(claimedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementStatesCompanion(')
          ..write('achievementId: $achievementId, ')
          ..write('progress: $progress, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('claimedAt: $claimedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyLoginClaimsTable extends DailyLoginClaims
    with TableInfo<$DailyLoginClaimsTable, DailyLoginClaimRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyLoginClaimsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _claimDateMeta = const VerificationMeta(
    'claimDate',
  );
  @override
  late final GeneratedColumn<String> claimDate = GeneratedColumn<String>(
    'claim_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayIndexMeta = const VerificationMeta(
    'dayIndex',
  );
  @override
  late final GeneratedColumn<int> dayIndex = GeneratedColumn<int>(
    'day_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coinsAwardedMeta = const VerificationMeta(
    'coinsAwarded',
  );
  @override
  late final GeneratedColumn<int> coinsAwarded = GeneratedColumn<int>(
    'coins_awarded',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _claimedAtMeta = const VerificationMeta(
    'claimedAt',
  );
  @override
  late final GeneratedColumn<int> claimedAt = GeneratedColumn<int>(
    'claimed_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    claimDate,
    dayIndex,
    coinsAwarded,
    claimedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_login_claims';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyLoginClaimRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('claim_date')) {
      context.handle(
        _claimDateMeta,
        claimDate.isAcceptableOrUnknown(data['claim_date']!, _claimDateMeta),
      );
    } else if (isInserting) {
      context.missing(_claimDateMeta);
    }
    if (data.containsKey('day_index')) {
      context.handle(
        _dayIndexMeta,
        dayIndex.isAcceptableOrUnknown(data['day_index']!, _dayIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_dayIndexMeta);
    }
    if (data.containsKey('coins_awarded')) {
      context.handle(
        _coinsAwardedMeta,
        coinsAwarded.isAcceptableOrUnknown(
          data['coins_awarded']!,
          _coinsAwardedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_coinsAwardedMeta);
    }
    if (data.containsKey('claimed_at')) {
      context.handle(
        _claimedAtMeta,
        claimedAt.isAcceptableOrUnknown(data['claimed_at']!, _claimedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_claimedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {claimDate};
  @override
  DailyLoginClaimRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyLoginClaimRow(
      claimDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}claim_date'],
      )!,
      dayIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_index'],
      )!,
      coinsAwarded: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}coins_awarded'],
      )!,
      claimedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}claimed_at'],
      )!,
    );
  }

  @override
  $DailyLoginClaimsTable createAlias(String alias) {
    return $DailyLoginClaimsTable(attachedDatabase, alias);
  }
}

class DailyLoginClaimRow extends DataClass
    implements Insertable<DailyLoginClaimRow> {
  final String claimDate;

  /// 1..7 position in the streak calendar (wraps after day 7).
  final int dayIndex;
  final int coinsAwarded;
  final int claimedAt;
  const DailyLoginClaimRow({
    required this.claimDate,
    required this.dayIndex,
    required this.coinsAwarded,
    required this.claimedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['claim_date'] = Variable<String>(claimDate);
    map['day_index'] = Variable<int>(dayIndex);
    map['coins_awarded'] = Variable<int>(coinsAwarded);
    map['claimed_at'] = Variable<int>(claimedAt);
    return map;
  }

  DailyLoginClaimsCompanion toCompanion(bool nullToAbsent) {
    return DailyLoginClaimsCompanion(
      claimDate: Value(claimDate),
      dayIndex: Value(dayIndex),
      coinsAwarded: Value(coinsAwarded),
      claimedAt: Value(claimedAt),
    );
  }

  factory DailyLoginClaimRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyLoginClaimRow(
      claimDate: serializer.fromJson<String>(json['claimDate']),
      dayIndex: serializer.fromJson<int>(json['dayIndex']),
      coinsAwarded: serializer.fromJson<int>(json['coinsAwarded']),
      claimedAt: serializer.fromJson<int>(json['claimedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'claimDate': serializer.toJson<String>(claimDate),
      'dayIndex': serializer.toJson<int>(dayIndex),
      'coinsAwarded': serializer.toJson<int>(coinsAwarded),
      'claimedAt': serializer.toJson<int>(claimedAt),
    };
  }

  DailyLoginClaimRow copyWith({
    String? claimDate,
    int? dayIndex,
    int? coinsAwarded,
    int? claimedAt,
  }) => DailyLoginClaimRow(
    claimDate: claimDate ?? this.claimDate,
    dayIndex: dayIndex ?? this.dayIndex,
    coinsAwarded: coinsAwarded ?? this.coinsAwarded,
    claimedAt: claimedAt ?? this.claimedAt,
  );
  DailyLoginClaimRow copyWithCompanion(DailyLoginClaimsCompanion data) {
    return DailyLoginClaimRow(
      claimDate: data.claimDate.present ? data.claimDate.value : this.claimDate,
      dayIndex: data.dayIndex.present ? data.dayIndex.value : this.dayIndex,
      coinsAwarded: data.coinsAwarded.present
          ? data.coinsAwarded.value
          : this.coinsAwarded,
      claimedAt: data.claimedAt.present ? data.claimedAt.value : this.claimedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyLoginClaimRow(')
          ..write('claimDate: $claimDate, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('coinsAwarded: $coinsAwarded, ')
          ..write('claimedAt: $claimedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(claimDate, dayIndex, coinsAwarded, claimedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyLoginClaimRow &&
          other.claimDate == this.claimDate &&
          other.dayIndex == this.dayIndex &&
          other.coinsAwarded == this.coinsAwarded &&
          other.claimedAt == this.claimedAt);
}

class DailyLoginClaimsCompanion extends UpdateCompanion<DailyLoginClaimRow> {
  final Value<String> claimDate;
  final Value<int> dayIndex;
  final Value<int> coinsAwarded;
  final Value<int> claimedAt;
  final Value<int> rowid;
  const DailyLoginClaimsCompanion({
    this.claimDate = const Value.absent(),
    this.dayIndex = const Value.absent(),
    this.coinsAwarded = const Value.absent(),
    this.claimedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyLoginClaimsCompanion.insert({
    required String claimDate,
    required int dayIndex,
    required int coinsAwarded,
    required int claimedAt,
    this.rowid = const Value.absent(),
  }) : claimDate = Value(claimDate),
       dayIndex = Value(dayIndex),
       coinsAwarded = Value(coinsAwarded),
       claimedAt = Value(claimedAt);
  static Insertable<DailyLoginClaimRow> custom({
    Expression<String>? claimDate,
    Expression<int>? dayIndex,
    Expression<int>? coinsAwarded,
    Expression<int>? claimedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (claimDate != null) 'claim_date': claimDate,
      if (dayIndex != null) 'day_index': dayIndex,
      if (coinsAwarded != null) 'coins_awarded': coinsAwarded,
      if (claimedAt != null) 'claimed_at': claimedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyLoginClaimsCompanion copyWith({
    Value<String>? claimDate,
    Value<int>? dayIndex,
    Value<int>? coinsAwarded,
    Value<int>? claimedAt,
    Value<int>? rowid,
  }) {
    return DailyLoginClaimsCompanion(
      claimDate: claimDate ?? this.claimDate,
      dayIndex: dayIndex ?? this.dayIndex,
      coinsAwarded: coinsAwarded ?? this.coinsAwarded,
      claimedAt: claimedAt ?? this.claimedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (claimDate.present) {
      map['claim_date'] = Variable<String>(claimDate.value);
    }
    if (dayIndex.present) {
      map['day_index'] = Variable<int>(dayIndex.value);
    }
    if (coinsAwarded.present) {
      map['coins_awarded'] = Variable<int>(coinsAwarded.value);
    }
    if (claimedAt.present) {
      map['claimed_at'] = Variable<int>(claimedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyLoginClaimsCompanion(')
          ..write('claimDate: $claimDate, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('coinsAwarded: $coinsAwarded, ')
          ..write('claimedAt: $claimedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChallengeAttemptsTable extends ChallengeAttempts
    with TableInfo<$ChallengeAttemptsTable, ChallengeAttemptRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChallengeAttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _challengeDateMeta = const VerificationMeta(
    'challengeDate',
  );
  @override
  late final GeneratedColumn<String> challengeDate = GeneratedColumn<String>(
    'challenge_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seedMeta = const VerificationMeta('seed');
  @override
  late final GeneratedColumn<int> seed = GeneratedColumn<int>(
    'seed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<String> runId = GeneratedColumn<String>(
    'run_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    challengeDate,
    seed,
    score,
    runId,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'challenge_attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChallengeAttemptRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('challenge_date')) {
      context.handle(
        _challengeDateMeta,
        challengeDate.isAcceptableOrUnknown(
          data['challenge_date']!,
          _challengeDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_challengeDateMeta);
    }
    if (data.containsKey('seed')) {
      context.handle(
        _seedMeta,
        seed.isAcceptableOrUnknown(data['seed']!, _seedMeta),
      );
    } else if (isInserting) {
      context.missing(_seedMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('run_id')) {
      context.handle(
        _runIdMeta,
        runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChallengeAttemptRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChallengeAttemptRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      challengeDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}challenge_date'],
      )!,
      seed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seed'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      runId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}run_id'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      )!,
    );
  }

  @override
  $ChallengeAttemptsTable createAlias(String alias) {
    return $ChallengeAttemptsTable(attachedDatabase, alias);
  }
}

class ChallengeAttemptRow extends DataClass
    implements Insertable<ChallengeAttemptRow> {
  final String id;
  final String challengeDate;
  final int seed;
  final int score;
  final String? runId;
  final int completedAt;
  const ChallengeAttemptRow({
    required this.id,
    required this.challengeDate,
    required this.seed,
    required this.score,
    this.runId,
    required this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['challenge_date'] = Variable<String>(challengeDate);
    map['seed'] = Variable<int>(seed);
    map['score'] = Variable<int>(score);
    if (!nullToAbsent || runId != null) {
      map['run_id'] = Variable<String>(runId);
    }
    map['completed_at'] = Variable<int>(completedAt);
    return map;
  }

  ChallengeAttemptsCompanion toCompanion(bool nullToAbsent) {
    return ChallengeAttemptsCompanion(
      id: Value(id),
      challengeDate: Value(challengeDate),
      seed: Value(seed),
      score: Value(score),
      runId: runId == null && nullToAbsent
          ? const Value.absent()
          : Value(runId),
      completedAt: Value(completedAt),
    );
  }

  factory ChallengeAttemptRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChallengeAttemptRow(
      id: serializer.fromJson<String>(json['id']),
      challengeDate: serializer.fromJson<String>(json['challengeDate']),
      seed: serializer.fromJson<int>(json['seed']),
      score: serializer.fromJson<int>(json['score']),
      runId: serializer.fromJson<String?>(json['runId']),
      completedAt: serializer.fromJson<int>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'challengeDate': serializer.toJson<String>(challengeDate),
      'seed': serializer.toJson<int>(seed),
      'score': serializer.toJson<int>(score),
      'runId': serializer.toJson<String?>(runId),
      'completedAt': serializer.toJson<int>(completedAt),
    };
  }

  ChallengeAttemptRow copyWith({
    String? id,
    String? challengeDate,
    int? seed,
    int? score,
    Value<String?> runId = const Value.absent(),
    int? completedAt,
  }) => ChallengeAttemptRow(
    id: id ?? this.id,
    challengeDate: challengeDate ?? this.challengeDate,
    seed: seed ?? this.seed,
    score: score ?? this.score,
    runId: runId.present ? runId.value : this.runId,
    completedAt: completedAt ?? this.completedAt,
  );
  ChallengeAttemptRow copyWithCompanion(ChallengeAttemptsCompanion data) {
    return ChallengeAttemptRow(
      id: data.id.present ? data.id.value : this.id,
      challengeDate: data.challengeDate.present
          ? data.challengeDate.value
          : this.challengeDate,
      seed: data.seed.present ? data.seed.value : this.seed,
      score: data.score.present ? data.score.value : this.score,
      runId: data.runId.present ? data.runId.value : this.runId,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChallengeAttemptRow(')
          ..write('id: $id, ')
          ..write('challengeDate: $challengeDate, ')
          ..write('seed: $seed, ')
          ..write('score: $score, ')
          ..write('runId: $runId, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, challengeDate, seed, score, runId, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChallengeAttemptRow &&
          other.id == this.id &&
          other.challengeDate == this.challengeDate &&
          other.seed == this.seed &&
          other.score == this.score &&
          other.runId == this.runId &&
          other.completedAt == this.completedAt);
}

class ChallengeAttemptsCompanion extends UpdateCompanion<ChallengeAttemptRow> {
  final Value<String> id;
  final Value<String> challengeDate;
  final Value<int> seed;
  final Value<int> score;
  final Value<String?> runId;
  final Value<int> completedAt;
  final Value<int> rowid;
  const ChallengeAttemptsCompanion({
    this.id = const Value.absent(),
    this.challengeDate = const Value.absent(),
    this.seed = const Value.absent(),
    this.score = const Value.absent(),
    this.runId = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChallengeAttemptsCompanion.insert({
    required String id,
    required String challengeDate,
    required int seed,
    required int score,
    this.runId = const Value.absent(),
    required int completedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       challengeDate = Value(challengeDate),
       seed = Value(seed),
       score = Value(score),
       completedAt = Value(completedAt);
  static Insertable<ChallengeAttemptRow> custom({
    Expression<String>? id,
    Expression<String>? challengeDate,
    Expression<int>? seed,
    Expression<int>? score,
    Expression<String>? runId,
    Expression<int>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (challengeDate != null) 'challenge_date': challengeDate,
      if (seed != null) 'seed': seed,
      if (score != null) 'score': score,
      if (runId != null) 'run_id': runId,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChallengeAttemptsCompanion copyWith({
    Value<String>? id,
    Value<String>? challengeDate,
    Value<int>? seed,
    Value<int>? score,
    Value<String?>? runId,
    Value<int>? completedAt,
    Value<int>? rowid,
  }) {
    return ChallengeAttemptsCompanion(
      id: id ?? this.id,
      challengeDate: challengeDate ?? this.challengeDate,
      seed: seed ?? this.seed,
      score: score ?? this.score,
      runId: runId ?? this.runId,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (challengeDate.present) {
      map['challenge_date'] = Variable<String>(challengeDate.value);
    }
    if (seed.present) {
      map['seed'] = Variable<int>(seed.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (runId.present) {
      map['run_id'] = Variable<String>(runId.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChallengeAttemptsCompanion(')
          ..write('id: $id, ')
          ..write('challengeDate: $challengeDate, ')
          ..write('seed: $seed, ')
          ..write('score: $score, ')
          ..write('runId: $runId, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LeaderboardCacheEntriesTable extends LeaderboardCacheEntries
    with TableInfo<$LeaderboardCacheEntriesTable, LeaderboardCacheRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LeaderboardCacheEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _boardTypeMeta = const VerificationMeta(
    'boardType',
  );
  @override
  late final GeneratedColumn<String> boardType = GeneratedColumn<String>(
    'board_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodKeyMeta = const VerificationMeta(
    'periodKey',
  );
  @override
  late final GeneratedColumn<String> periodKey = GeneratedColumn<String>(
    'period_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rankMeta = const VerificationMeta('rank');
  @override
  late final GeneratedColumn<int> rank = GeneratedColumn<int>(
    'rank',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPlayerMeta = const VerificationMeta(
    'isPlayer',
  );
  @override
  late final GeneratedColumn<bool> isPlayer = GeneratedColumn<bool>(
    'is_player',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_player" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    boardType,
    periodKey,
    rank,
    userId,
    username,
    score,
    isPlayer,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'leaderboard_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<LeaderboardCacheRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('board_type')) {
      context.handle(
        _boardTypeMeta,
        boardType.isAcceptableOrUnknown(data['board_type']!, _boardTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_boardTypeMeta);
    }
    if (data.containsKey('period_key')) {
      context.handle(
        _periodKeyMeta,
        periodKey.isAcceptableOrUnknown(data['period_key']!, _periodKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_periodKeyMeta);
    }
    if (data.containsKey('rank')) {
      context.handle(
        _rankMeta,
        rank.isAcceptableOrUnknown(data['rank']!, _rankMeta),
      );
    } else if (isInserting) {
      context.missing(_rankMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('is_player')) {
      context.handle(
        _isPlayerMeta,
        isPlayer.isAcceptableOrUnknown(data['is_player']!, _isPlayerMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {boardType, periodKey, rank};
  @override
  LeaderboardCacheRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LeaderboardCacheRow(
      boardType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}board_type'],
      )!,
      periodKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period_key'],
      )!,
      rank: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rank'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      isPlayer: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_player'],
      )!,
    );
  }

  @override
  $LeaderboardCacheEntriesTable createAlias(String alias) {
    return $LeaderboardCacheEntriesTable(attachedDatabase, alias);
  }
}

class LeaderboardCacheRow extends DataClass
    implements Insertable<LeaderboardCacheRow> {
  final String boardType;
  final String periodKey;
  final int rank;
  final String userId;
  final String username;
  final int score;
  final bool isPlayer;
  const LeaderboardCacheRow({
    required this.boardType,
    required this.periodKey,
    required this.rank,
    required this.userId,
    required this.username,
    required this.score,
    required this.isPlayer,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['board_type'] = Variable<String>(boardType);
    map['period_key'] = Variable<String>(periodKey);
    map['rank'] = Variable<int>(rank);
    map['user_id'] = Variable<String>(userId);
    map['username'] = Variable<String>(username);
    map['score'] = Variable<int>(score);
    map['is_player'] = Variable<bool>(isPlayer);
    return map;
  }

  LeaderboardCacheEntriesCompanion toCompanion(bool nullToAbsent) {
    return LeaderboardCacheEntriesCompanion(
      boardType: Value(boardType),
      periodKey: Value(periodKey),
      rank: Value(rank),
      userId: Value(userId),
      username: Value(username),
      score: Value(score),
      isPlayer: Value(isPlayer),
    );
  }

  factory LeaderboardCacheRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LeaderboardCacheRow(
      boardType: serializer.fromJson<String>(json['boardType']),
      periodKey: serializer.fromJson<String>(json['periodKey']),
      rank: serializer.fromJson<int>(json['rank']),
      userId: serializer.fromJson<String>(json['userId']),
      username: serializer.fromJson<String>(json['username']),
      score: serializer.fromJson<int>(json['score']),
      isPlayer: serializer.fromJson<bool>(json['isPlayer']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'boardType': serializer.toJson<String>(boardType),
      'periodKey': serializer.toJson<String>(periodKey),
      'rank': serializer.toJson<int>(rank),
      'userId': serializer.toJson<String>(userId),
      'username': serializer.toJson<String>(username),
      'score': serializer.toJson<int>(score),
      'isPlayer': serializer.toJson<bool>(isPlayer),
    };
  }

  LeaderboardCacheRow copyWith({
    String? boardType,
    String? periodKey,
    int? rank,
    String? userId,
    String? username,
    int? score,
    bool? isPlayer,
  }) => LeaderboardCacheRow(
    boardType: boardType ?? this.boardType,
    periodKey: periodKey ?? this.periodKey,
    rank: rank ?? this.rank,
    userId: userId ?? this.userId,
    username: username ?? this.username,
    score: score ?? this.score,
    isPlayer: isPlayer ?? this.isPlayer,
  );
  LeaderboardCacheRow copyWithCompanion(LeaderboardCacheEntriesCompanion data) {
    return LeaderboardCacheRow(
      boardType: data.boardType.present ? data.boardType.value : this.boardType,
      periodKey: data.periodKey.present ? data.periodKey.value : this.periodKey,
      rank: data.rank.present ? data.rank.value : this.rank,
      userId: data.userId.present ? data.userId.value : this.userId,
      username: data.username.present ? data.username.value : this.username,
      score: data.score.present ? data.score.value : this.score,
      isPlayer: data.isPlayer.present ? data.isPlayer.value : this.isPlayer,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LeaderboardCacheRow(')
          ..write('boardType: $boardType, ')
          ..write('periodKey: $periodKey, ')
          ..write('rank: $rank, ')
          ..write('userId: $userId, ')
          ..write('username: $username, ')
          ..write('score: $score, ')
          ..write('isPlayer: $isPlayer')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    boardType,
    periodKey,
    rank,
    userId,
    username,
    score,
    isPlayer,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LeaderboardCacheRow &&
          other.boardType == this.boardType &&
          other.periodKey == this.periodKey &&
          other.rank == this.rank &&
          other.userId == this.userId &&
          other.username == this.username &&
          other.score == this.score &&
          other.isPlayer == this.isPlayer);
}

class LeaderboardCacheEntriesCompanion
    extends UpdateCompanion<LeaderboardCacheRow> {
  final Value<String> boardType;
  final Value<String> periodKey;
  final Value<int> rank;
  final Value<String> userId;
  final Value<String> username;
  final Value<int> score;
  final Value<bool> isPlayer;
  final Value<int> rowid;
  const LeaderboardCacheEntriesCompanion({
    this.boardType = const Value.absent(),
    this.periodKey = const Value.absent(),
    this.rank = const Value.absent(),
    this.userId = const Value.absent(),
    this.username = const Value.absent(),
    this.score = const Value.absent(),
    this.isPlayer = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LeaderboardCacheEntriesCompanion.insert({
    required String boardType,
    required String periodKey,
    required int rank,
    required String userId,
    required String username,
    required int score,
    this.isPlayer = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : boardType = Value(boardType),
       periodKey = Value(periodKey),
       rank = Value(rank),
       userId = Value(userId),
       username = Value(username),
       score = Value(score);
  static Insertable<LeaderboardCacheRow> custom({
    Expression<String>? boardType,
    Expression<String>? periodKey,
    Expression<int>? rank,
    Expression<String>? userId,
    Expression<String>? username,
    Expression<int>? score,
    Expression<bool>? isPlayer,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (boardType != null) 'board_type': boardType,
      if (periodKey != null) 'period_key': periodKey,
      if (rank != null) 'rank': rank,
      if (userId != null) 'user_id': userId,
      if (username != null) 'username': username,
      if (score != null) 'score': score,
      if (isPlayer != null) 'is_player': isPlayer,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LeaderboardCacheEntriesCompanion copyWith({
    Value<String>? boardType,
    Value<String>? periodKey,
    Value<int>? rank,
    Value<String>? userId,
    Value<String>? username,
    Value<int>? score,
    Value<bool>? isPlayer,
    Value<int>? rowid,
  }) {
    return LeaderboardCacheEntriesCompanion(
      boardType: boardType ?? this.boardType,
      periodKey: periodKey ?? this.periodKey,
      rank: rank ?? this.rank,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      score: score ?? this.score,
      isPlayer: isPlayer ?? this.isPlayer,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (boardType.present) {
      map['board_type'] = Variable<String>(boardType.value);
    }
    if (periodKey.present) {
      map['period_key'] = Variable<String>(periodKey.value);
    }
    if (rank.present) {
      map['rank'] = Variable<int>(rank.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (isPlayer.present) {
      map['is_player'] = Variable<bool>(isPlayer.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LeaderboardCacheEntriesCompanion(')
          ..write('boardType: $boardType, ')
          ..write('periodKey: $periodKey, ')
          ..write('rank: $rank, ')
          ..write('userId: $userId, ')
          ..write('username: $username, ')
          ..write('score: $score, ')
          ..write('isPlayer: $isPlayer, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LeaderboardSyncMetaTable extends LeaderboardSyncMeta
    with TableInfo<$LeaderboardSyncMetaTable, LeaderboardSyncMetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LeaderboardSyncMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _boardTypeMeta = const VerificationMeta(
    'boardType',
  );
  @override
  late final GeneratedColumn<String> boardType = GeneratedColumn<String>(
    'board_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodKeyMeta = const VerificationMeta(
    'periodKey',
  );
  @override
  late final GeneratedColumn<String> periodKey = GeneratedColumn<String>(
    'period_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<int> lastSyncedAt = GeneratedColumn<int>(
    'last_synced_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playerRankMeta = const VerificationMeta(
    'playerRank',
  );
  @override
  late final GeneratedColumn<int> playerRank = GeneratedColumn<int>(
    'player_rank',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _playerScoreMeta = const VerificationMeta(
    'playerScore',
  );
  @override
  late final GeneratedColumn<int> playerScore = GeneratedColumn<int>(
    'player_score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    boardType,
    periodKey,
    lastSyncedAt,
    playerRank,
    playerScore,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'leaderboard_sync_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<LeaderboardSyncMetaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('board_type')) {
      context.handle(
        _boardTypeMeta,
        boardType.isAcceptableOrUnknown(data['board_type']!, _boardTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_boardTypeMeta);
    }
    if (data.containsKey('period_key')) {
      context.handle(
        _periodKeyMeta,
        periodKey.isAcceptableOrUnknown(data['period_key']!, _periodKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_periodKeyMeta);
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSyncedAtMeta);
    }
    if (data.containsKey('player_rank')) {
      context.handle(
        _playerRankMeta,
        playerRank.isAcceptableOrUnknown(data['player_rank']!, _playerRankMeta),
      );
    }
    if (data.containsKey('player_score')) {
      context.handle(
        _playerScoreMeta,
        playerScore.isAcceptableOrUnknown(
          data['player_score']!,
          _playerScoreMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {boardType};
  @override
  LeaderboardSyncMetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LeaderboardSyncMetaRow(
      boardType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}board_type'],
      )!,
      periodKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period_key'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced_at'],
      )!,
      playerRank: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}player_rank'],
      ),
      playerScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}player_score'],
      ),
    );
  }

  @override
  $LeaderboardSyncMetaTable createAlias(String alias) {
    return $LeaderboardSyncMetaTable(attachedDatabase, alias);
  }
}

class LeaderboardSyncMetaRow extends DataClass
    implements Insertable<LeaderboardSyncMetaRow> {
  final String boardType;
  final String periodKey;
  final int lastSyncedAt;
  final int? playerRank;
  final int? playerScore;
  const LeaderboardSyncMetaRow({
    required this.boardType,
    required this.periodKey,
    required this.lastSyncedAt,
    this.playerRank,
    this.playerScore,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['board_type'] = Variable<String>(boardType);
    map['period_key'] = Variable<String>(periodKey);
    map['last_synced_at'] = Variable<int>(lastSyncedAt);
    if (!nullToAbsent || playerRank != null) {
      map['player_rank'] = Variable<int>(playerRank);
    }
    if (!nullToAbsent || playerScore != null) {
      map['player_score'] = Variable<int>(playerScore);
    }
    return map;
  }

  LeaderboardSyncMetaCompanion toCompanion(bool nullToAbsent) {
    return LeaderboardSyncMetaCompanion(
      boardType: Value(boardType),
      periodKey: Value(periodKey),
      lastSyncedAt: Value(lastSyncedAt),
      playerRank: playerRank == null && nullToAbsent
          ? const Value.absent()
          : Value(playerRank),
      playerScore: playerScore == null && nullToAbsent
          ? const Value.absent()
          : Value(playerScore),
    );
  }

  factory LeaderboardSyncMetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LeaderboardSyncMetaRow(
      boardType: serializer.fromJson<String>(json['boardType']),
      periodKey: serializer.fromJson<String>(json['periodKey']),
      lastSyncedAt: serializer.fromJson<int>(json['lastSyncedAt']),
      playerRank: serializer.fromJson<int?>(json['playerRank']),
      playerScore: serializer.fromJson<int?>(json['playerScore']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'boardType': serializer.toJson<String>(boardType),
      'periodKey': serializer.toJson<String>(periodKey),
      'lastSyncedAt': serializer.toJson<int>(lastSyncedAt),
      'playerRank': serializer.toJson<int?>(playerRank),
      'playerScore': serializer.toJson<int?>(playerScore),
    };
  }

  LeaderboardSyncMetaRow copyWith({
    String? boardType,
    String? periodKey,
    int? lastSyncedAt,
    Value<int?> playerRank = const Value.absent(),
    Value<int?> playerScore = const Value.absent(),
  }) => LeaderboardSyncMetaRow(
    boardType: boardType ?? this.boardType,
    periodKey: periodKey ?? this.periodKey,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    playerRank: playerRank.present ? playerRank.value : this.playerRank,
    playerScore: playerScore.present ? playerScore.value : this.playerScore,
  );
  LeaderboardSyncMetaRow copyWithCompanion(LeaderboardSyncMetaCompanion data) {
    return LeaderboardSyncMetaRow(
      boardType: data.boardType.present ? data.boardType.value : this.boardType,
      periodKey: data.periodKey.present ? data.periodKey.value : this.periodKey,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      playerRank: data.playerRank.present
          ? data.playerRank.value
          : this.playerRank,
      playerScore: data.playerScore.present
          ? data.playerScore.value
          : this.playerScore,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LeaderboardSyncMetaRow(')
          ..write('boardType: $boardType, ')
          ..write('periodKey: $periodKey, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('playerRank: $playerRank, ')
          ..write('playerScore: $playerScore')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(boardType, periodKey, lastSyncedAt, playerRank, playerScore);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LeaderboardSyncMetaRow &&
          other.boardType == this.boardType &&
          other.periodKey == this.periodKey &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.playerRank == this.playerRank &&
          other.playerScore == this.playerScore);
}

class LeaderboardSyncMetaCompanion
    extends UpdateCompanion<LeaderboardSyncMetaRow> {
  final Value<String> boardType;
  final Value<String> periodKey;
  final Value<int> lastSyncedAt;
  final Value<int?> playerRank;
  final Value<int?> playerScore;
  final Value<int> rowid;
  const LeaderboardSyncMetaCompanion({
    this.boardType = const Value.absent(),
    this.periodKey = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.playerRank = const Value.absent(),
    this.playerScore = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LeaderboardSyncMetaCompanion.insert({
    required String boardType,
    required String periodKey,
    required int lastSyncedAt,
    this.playerRank = const Value.absent(),
    this.playerScore = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : boardType = Value(boardType),
       periodKey = Value(periodKey),
       lastSyncedAt = Value(lastSyncedAt);
  static Insertable<LeaderboardSyncMetaRow> custom({
    Expression<String>? boardType,
    Expression<String>? periodKey,
    Expression<int>? lastSyncedAt,
    Expression<int>? playerRank,
    Expression<int>? playerScore,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (boardType != null) 'board_type': boardType,
      if (periodKey != null) 'period_key': periodKey,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (playerRank != null) 'player_rank': playerRank,
      if (playerScore != null) 'player_score': playerScore,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LeaderboardSyncMetaCompanion copyWith({
    Value<String>? boardType,
    Value<String>? periodKey,
    Value<int>? lastSyncedAt,
    Value<int?>? playerRank,
    Value<int?>? playerScore,
    Value<int>? rowid,
  }) {
    return LeaderboardSyncMetaCompanion(
      boardType: boardType ?? this.boardType,
      periodKey: periodKey ?? this.periodKey,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      playerRank: playerRank ?? this.playerRank,
      playerScore: playerScore ?? this.playerScore,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (boardType.present) {
      map['board_type'] = Variable<String>(boardType.value);
    }
    if (periodKey.present) {
      map['period_key'] = Variable<String>(periodKey.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt.value);
    }
    if (playerRank.present) {
      map['player_rank'] = Variable<int>(playerRank.value);
    }
    if (playerScore.present) {
      map['player_score'] = Variable<int>(playerScore.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LeaderboardSyncMetaCompanion(')
          ..write('boardType: $boardType, ')
          ..write('periodKey: $periodKey, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('playerRank: $playerRank, ')
          ..write('playerScore: $playerScore, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsEntriesTable extends SettingsEntries
    with TableInfo<$SettingsEntriesTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsEntriesTable createAlias(String alias) {
    return $SettingsEntriesTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsEntriesCompanion toCompanion(bool nullToAbsent) {
    return SettingsEntriesCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(SettingsEntriesCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsEntriesCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsEntriesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsEntriesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxTable extends SyncOutbox
    with TableInfo<$SyncOutboxTable, SyncOutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('create'),
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _nextRetryAtMeta = const VerificationMeta(
    'nextRetryAt',
  );
  @override
  late final GeneratedColumn<int> nextRetryAt = GeneratedColumn<int>(
    'next_retry_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    operation,
    payload,
    createdAt,
    attempts,
    status,
    nextRetryAt,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOutboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
        _nextRetryAtMeta,
        nextRetryAt.isAcceptableOrUnknown(
          data['next_retry_at']!,
          _nextRetryAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncOutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      nextRetryAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_retry_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $SyncOutboxTable createAlias(String alias) {
    return $SyncOutboxTable(attachedDatabase, alias);
  }
}

class SyncOutboxRow extends DataClass implements Insertable<SyncOutboxRow> {
  final String id;

  /// SyncEntityType enum name: runCompleted | coinTxn | achievementUnlock |
  /// challengeResult | statsDelta | scoreSubmit | streakUpdate |
  /// accountLinked.
  final String entityType;
  final String operation;
  final String payload;
  final int createdAt;
  final int attempts;

  /// pending | inFlight | done | failed
  final String status;
  final int? nextRetryAt;
  final String? lastError;
  const SyncOutboxRow({
    required this.id,
    required this.entityType,
    required this.operation,
    required this.payload,
    required this.createdAt,
    required this.attempts,
    required this.status,
    this.nextRetryAt,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<int>(createdAt);
    map['attempts'] = Variable<int>(attempts);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || nextRetryAt != null) {
      map['next_retry_at'] = Variable<int>(nextRetryAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      id: Value(id),
      entityType: Value(entityType),
      operation: Value(operation),
      payload: Value(payload),
      createdAt: Value(createdAt),
      attempts: Value(attempts),
      status: Value(status),
      nextRetryAt: nextRetryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRetryAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncOutboxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxRow(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      status: serializer.fromJson<String>(json['status']),
      nextRetryAt: serializer.fromJson<int?>(json['nextRetryAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<int>(createdAt),
      'attempts': serializer.toJson<int>(attempts),
      'status': serializer.toJson<String>(status),
      'nextRetryAt': serializer.toJson<int?>(nextRetryAt),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncOutboxRow copyWith({
    String? id,
    String? entityType,
    String? operation,
    String? payload,
    int? createdAt,
    int? attempts,
    String? status,
    Value<int?> nextRetryAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
  }) => SyncOutboxRow(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    attempts: attempts ?? this.attempts,
    status: status ?? this.status,
    nextRetryAt: nextRetryAt.present ? nextRetryAt.value : this.nextRetryAt,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  SyncOutboxRow copyWithCompanion(SyncOutboxCompanion data) {
    return SyncOutboxRow(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      status: data.status.present ? data.status.value : this.status,
      nextRetryAt: data.nextRetryAt.present
          ? data.nextRetryAt.value
          : this.nextRetryAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxRow(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('status: $status, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    operation,
    payload,
    createdAt,
    attempts,
    status,
    nextRetryAt,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxRow &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.attempts == this.attempts &&
          other.status == this.status &&
          other.nextRetryAt == this.nextRetryAt &&
          other.lastError == this.lastError);
}

class SyncOutboxCompanion extends UpdateCompanion<SyncOutboxRow> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> operation;
  final Value<String> payload;
  final Value<int> createdAt;
  final Value<int> attempts;
  final Value<String> status;
  final Value<int?> nextRetryAt;
  final Value<String?> lastError;
  final Value<int> rowid;
  const SyncOutboxCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.status = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    required String id,
    required String entityType,
    this.operation = const Value.absent(),
    required String payload,
    required int createdAt,
    this.attempts = const Value.absent(),
    this.status = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityType = Value(entityType),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<SyncOutboxRow> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<int>? createdAt,
    Expression<int>? attempts,
    Expression<String>? status,
    Expression<int>? nextRetryAt,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (attempts != null) 'attempts': attempts,
      if (status != null) 'status': status,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOutboxCompanion copyWith({
    Value<String>? id,
    Value<String>? entityType,
    Value<String>? operation,
    Value<String>? payload,
    Value<int>? createdAt,
    Value<int>? attempts,
    Value<String>? status,
    Value<int?>? nextRetryAt,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return SyncOutboxCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      status: status ?? this.status,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<int>(nextRetryAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('status: $status, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MetaUpgradesTable extends MetaUpgrades
    with TableInfo<$MetaUpgradesTable, MetaUpgradeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetaUpgradesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _perkIdMeta = const VerificationMeta('perkId');
  @override
  late final GeneratedColumn<String> perkId = GeneratedColumn<String>(
    'perk_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [perkId, level, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meta_upgrades';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetaUpgradeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('perk_id')) {
      context.handle(
        _perkIdMeta,
        perkId.isAcceptableOrUnknown(data['perk_id']!, _perkIdMeta),
      );
    } else if (isInserting) {
      context.missing(_perkIdMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {perkId};
  @override
  MetaUpgradeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetaUpgradeRow(
      perkId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}perk_id'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MetaUpgradesTable createAlias(String alias) {
    return $MetaUpgradesTable(attachedDatabase, alias);
  }
}

class MetaUpgradeRow extends DataClass implements Insertable<MetaUpgradeRow> {
  final String perkId;
  final int level;
  final int updatedAt;
  const MetaUpgradeRow({
    required this.perkId,
    required this.level,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['perk_id'] = Variable<String>(perkId);
    map['level'] = Variable<int>(level);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  MetaUpgradesCompanion toCompanion(bool nullToAbsent) {
    return MetaUpgradesCompanion(
      perkId: Value(perkId),
      level: Value(level),
      updatedAt: Value(updatedAt),
    );
  }

  factory MetaUpgradeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetaUpgradeRow(
      perkId: serializer.fromJson<String>(json['perkId']),
      level: serializer.fromJson<int>(json['level']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'perkId': serializer.toJson<String>(perkId),
      'level': serializer.toJson<int>(level),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  MetaUpgradeRow copyWith({String? perkId, int? level, int? updatedAt}) =>
      MetaUpgradeRow(
        perkId: perkId ?? this.perkId,
        level: level ?? this.level,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  MetaUpgradeRow copyWithCompanion(MetaUpgradesCompanion data) {
    return MetaUpgradeRow(
      perkId: data.perkId.present ? data.perkId.value : this.perkId,
      level: data.level.present ? data.level.value : this.level,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetaUpgradeRow(')
          ..write('perkId: $perkId, ')
          ..write('level: $level, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(perkId, level, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetaUpgradeRow &&
          other.perkId == this.perkId &&
          other.level == this.level &&
          other.updatedAt == this.updatedAt);
}

class MetaUpgradesCompanion extends UpdateCompanion<MetaUpgradeRow> {
  final Value<String> perkId;
  final Value<int> level;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const MetaUpgradesCompanion({
    this.perkId = const Value.absent(),
    this.level = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetaUpgradesCompanion.insert({
    required String perkId,
    this.level = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : perkId = Value(perkId),
       updatedAt = Value(updatedAt);
  static Insertable<MetaUpgradeRow> custom({
    Expression<String>? perkId,
    Expression<int>? level,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (perkId != null) 'perk_id': perkId,
      if (level != null) 'level': level,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetaUpgradesCompanion copyWith({
    Value<String>? perkId,
    Value<int>? level,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return MetaUpgradesCompanion(
      perkId: perkId ?? this.perkId,
      level: level ?? this.level,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (perkId.present) {
      map['perk_id'] = Variable<String>(perkId.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetaUpgradesCompanion(')
          ..write('perkId: $perkId, ')
          ..write('level: $level, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TournamentsTable extends Tournaments
    with TableInfo<$TournamentsTable, TournamentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TournamentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cadenceMeta = const VerificationMeta(
    'cadence',
  );
  @override
  late final GeneratedColumn<String> cadence = GeneratedColumn<String>(
    'cadence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
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
  static const VerificationMeta _taglineMeta = const VerificationMeta(
    'tagline',
  );
  @override
  late final GeneratedColumn<String> tagline = GeneratedColumn<String>(
    'tagline',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _startsAtMeta = const VerificationMeta(
    'startsAt',
  );
  @override
  late final GeneratedColumn<int> startsAt = GeneratedColumn<int>(
    'starts_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endsAtMeta = const VerificationMeta('endsAt');
  @override
  late final GeneratedColumn<int> endsAt = GeneratedColumn<int>(
    'ends_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seedMeta = const VerificationMeta('seed');
  @override
  late final GeneratedColumn<int> seed = GeneratedColumn<int>(
    'seed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _configJsonMeta = const VerificationMeta(
    'configJson',
  );
  @override
  late final GeneratedColumn<String> configJson = GeneratedColumn<String>(
    'config_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _entryFeeCoinsMeta = const VerificationMeta(
    'entryFeeCoins',
  );
  @override
  late final GeneratedColumn<int> entryFeeCoins = GeneratedColumn<int>(
    'entry_fee_coins',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _rewardTableJsonMeta = const VerificationMeta(
    'rewardTableJson',
  );
  @override
  late final GeneratedColumn<String> rewardTableJson = GeneratedColumn<String>(
    'reward_table_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _joinedMeta = const VerificationMeta('joined');
  @override
  late final GeneratedColumn<bool> joined = GeneratedColumn<bool>(
    'joined',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("joined" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _paidMeta = const VerificationMeta('paid');
  @override
  late final GeneratedColumn<bool> paid = GeneratedColumn<bool>(
    'paid',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("paid" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _bestScoreMeta = const VerificationMeta(
    'bestScore',
  );
  @override
  late final GeneratedColumn<int> bestScore = GeneratedColumn<int>(
    'best_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _rankMeta = const VerificationMeta('rank');
  @override
  late final GeneratedColumn<int> rank = GeneratedColumn<int>(
    'rank',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rewardCoinsMeta = const VerificationMeta(
    'rewardCoins',
  );
  @override
  late final GeneratedColumn<int> rewardCoins = GeneratedColumn<int>(
    'reward_coins',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rewardClaimedMeta = const VerificationMeta(
    'rewardClaimed',
  );
  @override
  late final GeneratedColumn<bool> rewardClaimed = GeneratedColumn<bool>(
    'reward_claimed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reward_claimed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<int> lastSyncedAt = GeneratedColumn<int>(
    'last_synced_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cadence,
    state,
    name,
    tagline,
    startsAt,
    endsAt,
    seed,
    configJson,
    entryFeeCoins,
    rewardTableJson,
    joined,
    paid,
    bestScore,
    rank,
    rewardCoins,
    rewardClaimed,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tournaments';
  @override
  VerificationContext validateIntegrity(
    Insertable<TournamentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cadence')) {
      context.handle(
        _cadenceMeta,
        cadence.isAcceptableOrUnknown(data['cadence']!, _cadenceMeta),
      );
    } else if (isInserting) {
      context.missing(_cadenceMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('tagline')) {
      context.handle(
        _taglineMeta,
        tagline.isAcceptableOrUnknown(data['tagline']!, _taglineMeta),
      );
    }
    if (data.containsKey('starts_at')) {
      context.handle(
        _startsAtMeta,
        startsAt.isAcceptableOrUnknown(data['starts_at']!, _startsAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startsAtMeta);
    }
    if (data.containsKey('ends_at')) {
      context.handle(
        _endsAtMeta,
        endsAt.isAcceptableOrUnknown(data['ends_at']!, _endsAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endsAtMeta);
    }
    if (data.containsKey('seed')) {
      context.handle(
        _seedMeta,
        seed.isAcceptableOrUnknown(data['seed']!, _seedMeta),
      );
    } else if (isInserting) {
      context.missing(_seedMeta);
    }
    if (data.containsKey('config_json')) {
      context.handle(
        _configJsonMeta,
        configJson.isAcceptableOrUnknown(data['config_json']!, _configJsonMeta),
      );
    }
    if (data.containsKey('entry_fee_coins')) {
      context.handle(
        _entryFeeCoinsMeta,
        entryFeeCoins.isAcceptableOrUnknown(
          data['entry_fee_coins']!,
          _entryFeeCoinsMeta,
        ),
      );
    }
    if (data.containsKey('reward_table_json')) {
      context.handle(
        _rewardTableJsonMeta,
        rewardTableJson.isAcceptableOrUnknown(
          data['reward_table_json']!,
          _rewardTableJsonMeta,
        ),
      );
    }
    if (data.containsKey('joined')) {
      context.handle(
        _joinedMeta,
        joined.isAcceptableOrUnknown(data['joined']!, _joinedMeta),
      );
    }
    if (data.containsKey('paid')) {
      context.handle(
        _paidMeta,
        paid.isAcceptableOrUnknown(data['paid']!, _paidMeta),
      );
    }
    if (data.containsKey('best_score')) {
      context.handle(
        _bestScoreMeta,
        bestScore.isAcceptableOrUnknown(data['best_score']!, _bestScoreMeta),
      );
    }
    if (data.containsKey('rank')) {
      context.handle(
        _rankMeta,
        rank.isAcceptableOrUnknown(data['rank']!, _rankMeta),
      );
    }
    if (data.containsKey('reward_coins')) {
      context.handle(
        _rewardCoinsMeta,
        rewardCoins.isAcceptableOrUnknown(
          data['reward_coins']!,
          _rewardCoinsMeta,
        ),
      );
    }
    if (data.containsKey('reward_claimed')) {
      context.handle(
        _rewardClaimedMeta,
        rewardClaimed.isAcceptableOrUnknown(
          data['reward_claimed']!,
          _rewardClaimedMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TournamentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TournamentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cadence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cadence'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      tagline: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tagline'],
      )!,
      startsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}starts_at'],
      )!,
      endsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ends_at'],
      )!,
      seed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seed'],
      )!,
      configJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config_json'],
      )!,
      entryFeeCoins: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entry_fee_coins'],
      )!,
      rewardTableJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reward_table_json'],
      )!,
      joined: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}joined'],
      )!,
      paid: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}paid'],
      )!,
      bestScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_score'],
      )!,
      rank: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rank'],
      ),
      rewardCoins: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reward_coins'],
      ),
      rewardClaimed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reward_claimed'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced_at'],
      )!,
    );
  }

  @override
  $TournamentsTable createAlias(String alias) {
    return $TournamentsTable(attachedDatabase, alias);
  }
}

class TournamentRow extends DataClass implements Insertable<TournamentRow> {
  final String id;
  final String cadence;
  final String state;
  final String name;
  final String tagline;
  final int startsAt;
  final int endsAt;
  final int seed;
  final String configJson;
  final int entryFeeCoins;
  final String rewardTableJson;
  final bool joined;
  final bool paid;
  final int bestScore;
  final int? rank;
  final int? rewardCoins;
  final bool rewardClaimed;
  final int lastSyncedAt;
  const TournamentRow({
    required this.id,
    required this.cadence,
    required this.state,
    required this.name,
    required this.tagline,
    required this.startsAt,
    required this.endsAt,
    required this.seed,
    required this.configJson,
    required this.entryFeeCoins,
    required this.rewardTableJson,
    required this.joined,
    required this.paid,
    required this.bestScore,
    this.rank,
    this.rewardCoins,
    required this.rewardClaimed,
    required this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['cadence'] = Variable<String>(cadence);
    map['state'] = Variable<String>(state);
    map['name'] = Variable<String>(name);
    map['tagline'] = Variable<String>(tagline);
    map['starts_at'] = Variable<int>(startsAt);
    map['ends_at'] = Variable<int>(endsAt);
    map['seed'] = Variable<int>(seed);
    map['config_json'] = Variable<String>(configJson);
    map['entry_fee_coins'] = Variable<int>(entryFeeCoins);
    map['reward_table_json'] = Variable<String>(rewardTableJson);
    map['joined'] = Variable<bool>(joined);
    map['paid'] = Variable<bool>(paid);
    map['best_score'] = Variable<int>(bestScore);
    if (!nullToAbsent || rank != null) {
      map['rank'] = Variable<int>(rank);
    }
    if (!nullToAbsent || rewardCoins != null) {
      map['reward_coins'] = Variable<int>(rewardCoins);
    }
    map['reward_claimed'] = Variable<bool>(rewardClaimed);
    map['last_synced_at'] = Variable<int>(lastSyncedAt);
    return map;
  }

  TournamentsCompanion toCompanion(bool nullToAbsent) {
    return TournamentsCompanion(
      id: Value(id),
      cadence: Value(cadence),
      state: Value(state),
      name: Value(name),
      tagline: Value(tagline),
      startsAt: Value(startsAt),
      endsAt: Value(endsAt),
      seed: Value(seed),
      configJson: Value(configJson),
      entryFeeCoins: Value(entryFeeCoins),
      rewardTableJson: Value(rewardTableJson),
      joined: Value(joined),
      paid: Value(paid),
      bestScore: Value(bestScore),
      rank: rank == null && nullToAbsent ? const Value.absent() : Value(rank),
      rewardCoins: rewardCoins == null && nullToAbsent
          ? const Value.absent()
          : Value(rewardCoins),
      rewardClaimed: Value(rewardClaimed),
      lastSyncedAt: Value(lastSyncedAt),
    );
  }

  factory TournamentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TournamentRow(
      id: serializer.fromJson<String>(json['id']),
      cadence: serializer.fromJson<String>(json['cadence']),
      state: serializer.fromJson<String>(json['state']),
      name: serializer.fromJson<String>(json['name']),
      tagline: serializer.fromJson<String>(json['tagline']),
      startsAt: serializer.fromJson<int>(json['startsAt']),
      endsAt: serializer.fromJson<int>(json['endsAt']),
      seed: serializer.fromJson<int>(json['seed']),
      configJson: serializer.fromJson<String>(json['configJson']),
      entryFeeCoins: serializer.fromJson<int>(json['entryFeeCoins']),
      rewardTableJson: serializer.fromJson<String>(json['rewardTableJson']),
      joined: serializer.fromJson<bool>(json['joined']),
      paid: serializer.fromJson<bool>(json['paid']),
      bestScore: serializer.fromJson<int>(json['bestScore']),
      rank: serializer.fromJson<int?>(json['rank']),
      rewardCoins: serializer.fromJson<int?>(json['rewardCoins']),
      rewardClaimed: serializer.fromJson<bool>(json['rewardClaimed']),
      lastSyncedAt: serializer.fromJson<int>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cadence': serializer.toJson<String>(cadence),
      'state': serializer.toJson<String>(state),
      'name': serializer.toJson<String>(name),
      'tagline': serializer.toJson<String>(tagline),
      'startsAt': serializer.toJson<int>(startsAt),
      'endsAt': serializer.toJson<int>(endsAt),
      'seed': serializer.toJson<int>(seed),
      'configJson': serializer.toJson<String>(configJson),
      'entryFeeCoins': serializer.toJson<int>(entryFeeCoins),
      'rewardTableJson': serializer.toJson<String>(rewardTableJson),
      'joined': serializer.toJson<bool>(joined),
      'paid': serializer.toJson<bool>(paid),
      'bestScore': serializer.toJson<int>(bestScore),
      'rank': serializer.toJson<int?>(rank),
      'rewardCoins': serializer.toJson<int?>(rewardCoins),
      'rewardClaimed': serializer.toJson<bool>(rewardClaimed),
      'lastSyncedAt': serializer.toJson<int>(lastSyncedAt),
    };
  }

  TournamentRow copyWith({
    String? id,
    String? cadence,
    String? state,
    String? name,
    String? tagline,
    int? startsAt,
    int? endsAt,
    int? seed,
    String? configJson,
    int? entryFeeCoins,
    String? rewardTableJson,
    bool? joined,
    bool? paid,
    int? bestScore,
    Value<int?> rank = const Value.absent(),
    Value<int?> rewardCoins = const Value.absent(),
    bool? rewardClaimed,
    int? lastSyncedAt,
  }) => TournamentRow(
    id: id ?? this.id,
    cadence: cadence ?? this.cadence,
    state: state ?? this.state,
    name: name ?? this.name,
    tagline: tagline ?? this.tagline,
    startsAt: startsAt ?? this.startsAt,
    endsAt: endsAt ?? this.endsAt,
    seed: seed ?? this.seed,
    configJson: configJson ?? this.configJson,
    entryFeeCoins: entryFeeCoins ?? this.entryFeeCoins,
    rewardTableJson: rewardTableJson ?? this.rewardTableJson,
    joined: joined ?? this.joined,
    paid: paid ?? this.paid,
    bestScore: bestScore ?? this.bestScore,
    rank: rank.present ? rank.value : this.rank,
    rewardCoins: rewardCoins.present ? rewardCoins.value : this.rewardCoins,
    rewardClaimed: rewardClaimed ?? this.rewardClaimed,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
  );
  TournamentRow copyWithCompanion(TournamentsCompanion data) {
    return TournamentRow(
      id: data.id.present ? data.id.value : this.id,
      cadence: data.cadence.present ? data.cadence.value : this.cadence,
      state: data.state.present ? data.state.value : this.state,
      name: data.name.present ? data.name.value : this.name,
      tagline: data.tagline.present ? data.tagline.value : this.tagline,
      startsAt: data.startsAt.present ? data.startsAt.value : this.startsAt,
      endsAt: data.endsAt.present ? data.endsAt.value : this.endsAt,
      seed: data.seed.present ? data.seed.value : this.seed,
      configJson: data.configJson.present
          ? data.configJson.value
          : this.configJson,
      entryFeeCoins: data.entryFeeCoins.present
          ? data.entryFeeCoins.value
          : this.entryFeeCoins,
      rewardTableJson: data.rewardTableJson.present
          ? data.rewardTableJson.value
          : this.rewardTableJson,
      joined: data.joined.present ? data.joined.value : this.joined,
      paid: data.paid.present ? data.paid.value : this.paid,
      bestScore: data.bestScore.present ? data.bestScore.value : this.bestScore,
      rank: data.rank.present ? data.rank.value : this.rank,
      rewardCoins: data.rewardCoins.present
          ? data.rewardCoins.value
          : this.rewardCoins,
      rewardClaimed: data.rewardClaimed.present
          ? data.rewardClaimed.value
          : this.rewardClaimed,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TournamentRow(')
          ..write('id: $id, ')
          ..write('cadence: $cadence, ')
          ..write('state: $state, ')
          ..write('name: $name, ')
          ..write('tagline: $tagline, ')
          ..write('startsAt: $startsAt, ')
          ..write('endsAt: $endsAt, ')
          ..write('seed: $seed, ')
          ..write('configJson: $configJson, ')
          ..write('entryFeeCoins: $entryFeeCoins, ')
          ..write('rewardTableJson: $rewardTableJson, ')
          ..write('joined: $joined, ')
          ..write('paid: $paid, ')
          ..write('bestScore: $bestScore, ')
          ..write('rank: $rank, ')
          ..write('rewardCoins: $rewardCoins, ')
          ..write('rewardClaimed: $rewardClaimed, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cadence,
    state,
    name,
    tagline,
    startsAt,
    endsAt,
    seed,
    configJson,
    entryFeeCoins,
    rewardTableJson,
    joined,
    paid,
    bestScore,
    rank,
    rewardCoins,
    rewardClaimed,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TournamentRow &&
          other.id == this.id &&
          other.cadence == this.cadence &&
          other.state == this.state &&
          other.name == this.name &&
          other.tagline == this.tagline &&
          other.startsAt == this.startsAt &&
          other.endsAt == this.endsAt &&
          other.seed == this.seed &&
          other.configJson == this.configJson &&
          other.entryFeeCoins == this.entryFeeCoins &&
          other.rewardTableJson == this.rewardTableJson &&
          other.joined == this.joined &&
          other.paid == this.paid &&
          other.bestScore == this.bestScore &&
          other.rank == this.rank &&
          other.rewardCoins == this.rewardCoins &&
          other.rewardClaimed == this.rewardClaimed &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class TournamentsCompanion extends UpdateCompanion<TournamentRow> {
  final Value<String> id;
  final Value<String> cadence;
  final Value<String> state;
  final Value<String> name;
  final Value<String> tagline;
  final Value<int> startsAt;
  final Value<int> endsAt;
  final Value<int> seed;
  final Value<String> configJson;
  final Value<int> entryFeeCoins;
  final Value<String> rewardTableJson;
  final Value<bool> joined;
  final Value<bool> paid;
  final Value<int> bestScore;
  final Value<int?> rank;
  final Value<int?> rewardCoins;
  final Value<bool> rewardClaimed;
  final Value<int> lastSyncedAt;
  final Value<int> rowid;
  const TournamentsCompanion({
    this.id = const Value.absent(),
    this.cadence = const Value.absent(),
    this.state = const Value.absent(),
    this.name = const Value.absent(),
    this.tagline = const Value.absent(),
    this.startsAt = const Value.absent(),
    this.endsAt = const Value.absent(),
    this.seed = const Value.absent(),
    this.configJson = const Value.absent(),
    this.entryFeeCoins = const Value.absent(),
    this.rewardTableJson = const Value.absent(),
    this.joined = const Value.absent(),
    this.paid = const Value.absent(),
    this.bestScore = const Value.absent(),
    this.rank = const Value.absent(),
    this.rewardCoins = const Value.absent(),
    this.rewardClaimed = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TournamentsCompanion.insert({
    required String id,
    required String cadence,
    required String state,
    required String name,
    this.tagline = const Value.absent(),
    required int startsAt,
    required int endsAt,
    required int seed,
    this.configJson = const Value.absent(),
    this.entryFeeCoins = const Value.absent(),
    this.rewardTableJson = const Value.absent(),
    this.joined = const Value.absent(),
    this.paid = const Value.absent(),
    this.bestScore = const Value.absent(),
    this.rank = const Value.absent(),
    this.rewardCoins = const Value.absent(),
    this.rewardClaimed = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cadence = Value(cadence),
       state = Value(state),
       name = Value(name),
       startsAt = Value(startsAt),
       endsAt = Value(endsAt),
       seed = Value(seed);
  static Insertable<TournamentRow> custom({
    Expression<String>? id,
    Expression<String>? cadence,
    Expression<String>? state,
    Expression<String>? name,
    Expression<String>? tagline,
    Expression<int>? startsAt,
    Expression<int>? endsAt,
    Expression<int>? seed,
    Expression<String>? configJson,
    Expression<int>? entryFeeCoins,
    Expression<String>? rewardTableJson,
    Expression<bool>? joined,
    Expression<bool>? paid,
    Expression<int>? bestScore,
    Expression<int>? rank,
    Expression<int>? rewardCoins,
    Expression<bool>? rewardClaimed,
    Expression<int>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cadence != null) 'cadence': cadence,
      if (state != null) 'state': state,
      if (name != null) 'name': name,
      if (tagline != null) 'tagline': tagline,
      if (startsAt != null) 'starts_at': startsAt,
      if (endsAt != null) 'ends_at': endsAt,
      if (seed != null) 'seed': seed,
      if (configJson != null) 'config_json': configJson,
      if (entryFeeCoins != null) 'entry_fee_coins': entryFeeCoins,
      if (rewardTableJson != null) 'reward_table_json': rewardTableJson,
      if (joined != null) 'joined': joined,
      if (paid != null) 'paid': paid,
      if (bestScore != null) 'best_score': bestScore,
      if (rank != null) 'rank': rank,
      if (rewardCoins != null) 'reward_coins': rewardCoins,
      if (rewardClaimed != null) 'reward_claimed': rewardClaimed,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TournamentsCompanion copyWith({
    Value<String>? id,
    Value<String>? cadence,
    Value<String>? state,
    Value<String>? name,
    Value<String>? tagline,
    Value<int>? startsAt,
    Value<int>? endsAt,
    Value<int>? seed,
    Value<String>? configJson,
    Value<int>? entryFeeCoins,
    Value<String>? rewardTableJson,
    Value<bool>? joined,
    Value<bool>? paid,
    Value<int>? bestScore,
    Value<int?>? rank,
    Value<int?>? rewardCoins,
    Value<bool>? rewardClaimed,
    Value<int>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return TournamentsCompanion(
      id: id ?? this.id,
      cadence: cadence ?? this.cadence,
      state: state ?? this.state,
      name: name ?? this.name,
      tagline: tagline ?? this.tagline,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      seed: seed ?? this.seed,
      configJson: configJson ?? this.configJson,
      entryFeeCoins: entryFeeCoins ?? this.entryFeeCoins,
      rewardTableJson: rewardTableJson ?? this.rewardTableJson,
      joined: joined ?? this.joined,
      paid: paid ?? this.paid,
      bestScore: bestScore ?? this.bestScore,
      rank: rank ?? this.rank,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      rewardClaimed: rewardClaimed ?? this.rewardClaimed,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cadence.present) {
      map['cadence'] = Variable<String>(cadence.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (tagline.present) {
      map['tagline'] = Variable<String>(tagline.value);
    }
    if (startsAt.present) {
      map['starts_at'] = Variable<int>(startsAt.value);
    }
    if (endsAt.present) {
      map['ends_at'] = Variable<int>(endsAt.value);
    }
    if (seed.present) {
      map['seed'] = Variable<int>(seed.value);
    }
    if (configJson.present) {
      map['config_json'] = Variable<String>(configJson.value);
    }
    if (entryFeeCoins.present) {
      map['entry_fee_coins'] = Variable<int>(entryFeeCoins.value);
    }
    if (rewardTableJson.present) {
      map['reward_table_json'] = Variable<String>(rewardTableJson.value);
    }
    if (joined.present) {
      map['joined'] = Variable<bool>(joined.value);
    }
    if (paid.present) {
      map['paid'] = Variable<bool>(paid.value);
    }
    if (bestScore.present) {
      map['best_score'] = Variable<int>(bestScore.value);
    }
    if (rank.present) {
      map['rank'] = Variable<int>(rank.value);
    }
    if (rewardCoins.present) {
      map['reward_coins'] = Variable<int>(rewardCoins.value);
    }
    if (rewardClaimed.present) {
      map['reward_claimed'] = Variable<bool>(rewardClaimed.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TournamentsCompanion(')
          ..write('id: $id, ')
          ..write('cadence: $cadence, ')
          ..write('state: $state, ')
          ..write('name: $name, ')
          ..write('tagline: $tagline, ')
          ..write('startsAt: $startsAt, ')
          ..write('endsAt: $endsAt, ')
          ..write('seed: $seed, ')
          ..write('configJson: $configJson, ')
          ..write('entryFeeCoins: $entryFeeCoins, ')
          ..write('rewardTableJson: $rewardTableJson, ')
          ..write('joined: $joined, ')
          ..write('paid: $paid, ')
          ..write('bestScore: $bestScore, ')
          ..write('rank: $rank, ')
          ..write('rewardCoins: $rewardCoins, ')
          ..write('rewardClaimed: $rewardClaimed, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TournamentLeaderboardCacheTable extends TournamentLeaderboardCache
    with TableInfo<$TournamentLeaderboardCacheTable, TournamentLeaderboardRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TournamentLeaderboardCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tournamentIdMeta = const VerificationMeta(
    'tournamentId',
  );
  @override
  late final GeneratedColumn<String> tournamentId = GeneratedColumn<String>(
    'tournament_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rankMeta = const VerificationMeta('rank');
  @override
  late final GeneratedColumn<int> rank = GeneratedColumn<int>(
    'rank',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPlayerMeta = const VerificationMeta(
    'isPlayer',
  );
  @override
  late final GeneratedColumn<bool> isPlayer = GeneratedColumn<bool>(
    'is_player',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_player" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    tournamentId,
    rank,
    userId,
    username,
    score,
    isPlayer,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tournament_leaderboard_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<TournamentLeaderboardRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tournament_id')) {
      context.handle(
        _tournamentIdMeta,
        tournamentId.isAcceptableOrUnknown(
          data['tournament_id']!,
          _tournamentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tournamentIdMeta);
    }
    if (data.containsKey('rank')) {
      context.handle(
        _rankMeta,
        rank.isAcceptableOrUnknown(data['rank']!, _rankMeta),
      );
    } else if (isInserting) {
      context.missing(_rankMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('is_player')) {
      context.handle(
        _isPlayerMeta,
        isPlayer.isAcceptableOrUnknown(data['is_player']!, _isPlayerMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tournamentId, rank};
  @override
  TournamentLeaderboardRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TournamentLeaderboardRow(
      tournamentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tournament_id'],
      )!,
      rank: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rank'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      isPlayer: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_player'],
      )!,
    );
  }

  @override
  $TournamentLeaderboardCacheTable createAlias(String alias) {
    return $TournamentLeaderboardCacheTable(attachedDatabase, alias);
  }
}

class TournamentLeaderboardRow extends DataClass
    implements Insertable<TournamentLeaderboardRow> {
  final String tournamentId;
  final int rank;
  final String userId;
  final String username;
  final int score;
  final bool isPlayer;
  const TournamentLeaderboardRow({
    required this.tournamentId,
    required this.rank,
    required this.userId,
    required this.username,
    required this.score,
    required this.isPlayer,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tournament_id'] = Variable<String>(tournamentId);
    map['rank'] = Variable<int>(rank);
    map['user_id'] = Variable<String>(userId);
    map['username'] = Variable<String>(username);
    map['score'] = Variable<int>(score);
    map['is_player'] = Variable<bool>(isPlayer);
    return map;
  }

  TournamentLeaderboardCacheCompanion toCompanion(bool nullToAbsent) {
    return TournamentLeaderboardCacheCompanion(
      tournamentId: Value(tournamentId),
      rank: Value(rank),
      userId: Value(userId),
      username: Value(username),
      score: Value(score),
      isPlayer: Value(isPlayer),
    );
  }

  factory TournamentLeaderboardRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TournamentLeaderboardRow(
      tournamentId: serializer.fromJson<String>(json['tournamentId']),
      rank: serializer.fromJson<int>(json['rank']),
      userId: serializer.fromJson<String>(json['userId']),
      username: serializer.fromJson<String>(json['username']),
      score: serializer.fromJson<int>(json['score']),
      isPlayer: serializer.fromJson<bool>(json['isPlayer']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tournamentId': serializer.toJson<String>(tournamentId),
      'rank': serializer.toJson<int>(rank),
      'userId': serializer.toJson<String>(userId),
      'username': serializer.toJson<String>(username),
      'score': serializer.toJson<int>(score),
      'isPlayer': serializer.toJson<bool>(isPlayer),
    };
  }

  TournamentLeaderboardRow copyWith({
    String? tournamentId,
    int? rank,
    String? userId,
    String? username,
    int? score,
    bool? isPlayer,
  }) => TournamentLeaderboardRow(
    tournamentId: tournamentId ?? this.tournamentId,
    rank: rank ?? this.rank,
    userId: userId ?? this.userId,
    username: username ?? this.username,
    score: score ?? this.score,
    isPlayer: isPlayer ?? this.isPlayer,
  );
  TournamentLeaderboardRow copyWithCompanion(
    TournamentLeaderboardCacheCompanion data,
  ) {
    return TournamentLeaderboardRow(
      tournamentId: data.tournamentId.present
          ? data.tournamentId.value
          : this.tournamentId,
      rank: data.rank.present ? data.rank.value : this.rank,
      userId: data.userId.present ? data.userId.value : this.userId,
      username: data.username.present ? data.username.value : this.username,
      score: data.score.present ? data.score.value : this.score,
      isPlayer: data.isPlayer.present ? data.isPlayer.value : this.isPlayer,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TournamentLeaderboardRow(')
          ..write('tournamentId: $tournamentId, ')
          ..write('rank: $rank, ')
          ..write('userId: $userId, ')
          ..write('username: $username, ')
          ..write('score: $score, ')
          ..write('isPlayer: $isPlayer')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(tournamentId, rank, userId, username, score, isPlayer);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TournamentLeaderboardRow &&
          other.tournamentId == this.tournamentId &&
          other.rank == this.rank &&
          other.userId == this.userId &&
          other.username == this.username &&
          other.score == this.score &&
          other.isPlayer == this.isPlayer);
}

class TournamentLeaderboardCacheCompanion
    extends UpdateCompanion<TournamentLeaderboardRow> {
  final Value<String> tournamentId;
  final Value<int> rank;
  final Value<String> userId;
  final Value<String> username;
  final Value<int> score;
  final Value<bool> isPlayer;
  final Value<int> rowid;
  const TournamentLeaderboardCacheCompanion({
    this.tournamentId = const Value.absent(),
    this.rank = const Value.absent(),
    this.userId = const Value.absent(),
    this.username = const Value.absent(),
    this.score = const Value.absent(),
    this.isPlayer = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TournamentLeaderboardCacheCompanion.insert({
    required String tournamentId,
    required int rank,
    required String userId,
    required String username,
    required int score,
    this.isPlayer = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : tournamentId = Value(tournamentId),
       rank = Value(rank),
       userId = Value(userId),
       username = Value(username),
       score = Value(score);
  static Insertable<TournamentLeaderboardRow> custom({
    Expression<String>? tournamentId,
    Expression<int>? rank,
    Expression<String>? userId,
    Expression<String>? username,
    Expression<int>? score,
    Expression<bool>? isPlayer,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tournamentId != null) 'tournament_id': tournamentId,
      if (rank != null) 'rank': rank,
      if (userId != null) 'user_id': userId,
      if (username != null) 'username': username,
      if (score != null) 'score': score,
      if (isPlayer != null) 'is_player': isPlayer,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TournamentLeaderboardCacheCompanion copyWith({
    Value<String>? tournamentId,
    Value<int>? rank,
    Value<String>? userId,
    Value<String>? username,
    Value<int>? score,
    Value<bool>? isPlayer,
    Value<int>? rowid,
  }) {
    return TournamentLeaderboardCacheCompanion(
      tournamentId: tournamentId ?? this.tournamentId,
      rank: rank ?? this.rank,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      score: score ?? this.score,
      isPlayer: isPlayer ?? this.isPlayer,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tournamentId.present) {
      map['tournament_id'] = Variable<String>(tournamentId.value);
    }
    if (rank.present) {
      map['rank'] = Variable<int>(rank.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (isPlayer.present) {
      map['is_player'] = Variable<bool>(isPlayer.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TournamentLeaderboardCacheCompanion(')
          ..write('tournamentId: $tournamentId, ')
          ..write('rank: $rank, ')
          ..write('userId: $userId, ')
          ..write('username: $username, ')
          ..write('score: $score, ')
          ..write('isPlayer: $isPlayer, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CosmeticOwnedTable extends CosmeticOwned
    with TableInfo<$CosmeticOwnedTable, CosmeticOwnedRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CosmeticOwnedTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cosmeticIdMeta = const VerificationMeta(
    'cosmeticId',
  );
  @override
  late final GeneratedColumn<String> cosmeticId = GeneratedColumn<String>(
    'cosmetic_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [cosmeticId, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cosmetic_owned';
  @override
  VerificationContext validateIntegrity(
    Insertable<CosmeticOwnedRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cosmetic_id')) {
      context.handle(
        _cosmeticIdMeta,
        cosmeticId.isAcceptableOrUnknown(data['cosmetic_id']!, _cosmeticIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cosmeticIdMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cosmeticId};
  @override
  CosmeticOwnedRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CosmeticOwnedRow(
      cosmeticId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cosmetic_id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CosmeticOwnedTable createAlias(String alias) {
    return $CosmeticOwnedTable(attachedDatabase, alias);
  }
}

class CosmeticOwnedRow extends DataClass
    implements Insertable<CosmeticOwnedRow> {
  final String cosmeticId;
  final int updatedAt;
  const CosmeticOwnedRow({required this.cosmeticId, required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cosmetic_id'] = Variable<String>(cosmeticId);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  CosmeticOwnedCompanion toCompanion(bool nullToAbsent) {
    return CosmeticOwnedCompanion(
      cosmeticId: Value(cosmeticId),
      updatedAt: Value(updatedAt),
    );
  }

  factory CosmeticOwnedRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CosmeticOwnedRow(
      cosmeticId: serializer.fromJson<String>(json['cosmeticId']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cosmeticId': serializer.toJson<String>(cosmeticId),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  CosmeticOwnedRow copyWith({String? cosmeticId, int? updatedAt}) =>
      CosmeticOwnedRow(
        cosmeticId: cosmeticId ?? this.cosmeticId,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CosmeticOwnedRow copyWithCompanion(CosmeticOwnedCompanion data) {
    return CosmeticOwnedRow(
      cosmeticId: data.cosmeticId.present
          ? data.cosmeticId.value
          : this.cosmeticId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CosmeticOwnedRow(')
          ..write('cosmeticId: $cosmeticId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cosmeticId, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CosmeticOwnedRow &&
          other.cosmeticId == this.cosmeticId &&
          other.updatedAt == this.updatedAt);
}

class CosmeticOwnedCompanion extends UpdateCompanion<CosmeticOwnedRow> {
  final Value<String> cosmeticId;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const CosmeticOwnedCompanion({
    this.cosmeticId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CosmeticOwnedCompanion.insert({
    required String cosmeticId,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : cosmeticId = Value(cosmeticId),
       updatedAt = Value(updatedAt);
  static Insertable<CosmeticOwnedRow> custom({
    Expression<String>? cosmeticId,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cosmeticId != null) 'cosmetic_id': cosmeticId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CosmeticOwnedCompanion copyWith({
    Value<String>? cosmeticId,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return CosmeticOwnedCompanion(
      cosmeticId: cosmeticId ?? this.cosmeticId,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cosmeticId.present) {
      map['cosmetic_id'] = Variable<String>(cosmeticId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CosmeticOwnedCompanion(')
          ..write('cosmeticId: $cosmeticId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CosmeticEquippedTable extends CosmeticEquipped
    with TableInfo<$CosmeticEquippedTable, CosmeticEquippedRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CosmeticEquippedTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<String> slot = GeneratedColumn<String>(
    'slot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cosmeticIdMeta = const VerificationMeta(
    'cosmeticId',
  );
  @override
  late final GeneratedColumn<String> cosmeticId = GeneratedColumn<String>(
    'cosmetic_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [slot, cosmeticId, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cosmetic_equipped';
  @override
  VerificationContext validateIntegrity(
    Insertable<CosmeticEquippedRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('slot')) {
      context.handle(
        _slotMeta,
        slot.isAcceptableOrUnknown(data['slot']!, _slotMeta),
      );
    } else if (isInserting) {
      context.missing(_slotMeta);
    }
    if (data.containsKey('cosmetic_id')) {
      context.handle(
        _cosmeticIdMeta,
        cosmeticId.isAcceptableOrUnknown(data['cosmetic_id']!, _cosmeticIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cosmeticIdMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {slot};
  @override
  CosmeticEquippedRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CosmeticEquippedRow(
      slot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slot'],
      )!,
      cosmeticId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cosmetic_id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CosmeticEquippedTable createAlias(String alias) {
    return $CosmeticEquippedTable(attachedDatabase, alias);
  }
}

class CosmeticEquippedRow extends DataClass
    implements Insertable<CosmeticEquippedRow> {
  final String slot;
  final String cosmeticId;
  final int updatedAt;
  const CosmeticEquippedRow({
    required this.slot,
    required this.cosmeticId,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['slot'] = Variable<String>(slot);
    map['cosmetic_id'] = Variable<String>(cosmeticId);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  CosmeticEquippedCompanion toCompanion(bool nullToAbsent) {
    return CosmeticEquippedCompanion(
      slot: Value(slot),
      cosmeticId: Value(cosmeticId),
      updatedAt: Value(updatedAt),
    );
  }

  factory CosmeticEquippedRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CosmeticEquippedRow(
      slot: serializer.fromJson<String>(json['slot']),
      cosmeticId: serializer.fromJson<String>(json['cosmeticId']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'slot': serializer.toJson<String>(slot),
      'cosmeticId': serializer.toJson<String>(cosmeticId),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  CosmeticEquippedRow copyWith({
    String? slot,
    String? cosmeticId,
    int? updatedAt,
  }) => CosmeticEquippedRow(
    slot: slot ?? this.slot,
    cosmeticId: cosmeticId ?? this.cosmeticId,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CosmeticEquippedRow copyWithCompanion(CosmeticEquippedCompanion data) {
    return CosmeticEquippedRow(
      slot: data.slot.present ? data.slot.value : this.slot,
      cosmeticId: data.cosmeticId.present
          ? data.cosmeticId.value
          : this.cosmeticId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CosmeticEquippedRow(')
          ..write('slot: $slot, ')
          ..write('cosmeticId: $cosmeticId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(slot, cosmeticId, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CosmeticEquippedRow &&
          other.slot == this.slot &&
          other.cosmeticId == this.cosmeticId &&
          other.updatedAt == this.updatedAt);
}

class CosmeticEquippedCompanion extends UpdateCompanion<CosmeticEquippedRow> {
  final Value<String> slot;
  final Value<String> cosmeticId;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const CosmeticEquippedCompanion({
    this.slot = const Value.absent(),
    this.cosmeticId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CosmeticEquippedCompanion.insert({
    required String slot,
    required String cosmeticId,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : slot = Value(slot),
       cosmeticId = Value(cosmeticId),
       updatedAt = Value(updatedAt);
  static Insertable<CosmeticEquippedRow> custom({
    Expression<String>? slot,
    Expression<String>? cosmeticId,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (slot != null) 'slot': slot,
      if (cosmeticId != null) 'cosmetic_id': cosmeticId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CosmeticEquippedCompanion copyWith({
    Value<String>? slot,
    Value<String>? cosmeticId,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return CosmeticEquippedCompanion(
      slot: slot ?? this.slot,
      cosmeticId: cosmeticId ?? this.cosmeticId,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (slot.present) {
      map['slot'] = Variable<String>(slot.value);
    }
    if (cosmeticId.present) {
      map['cosmetic_id'] = Variable<String>(cosmeticId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CosmeticEquippedCompanion(')
          ..write('slot: $slot, ')
          ..write('cosmeticId: $cosmeticId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlayerProfilesTable playerProfiles = $PlayerProfilesTable(this);
  late final $PlayerStatsTableTable playerStatsTable = $PlayerStatsTableTable(
    this,
  );
  late final $StatCountersTable statCounters = $StatCountersTable(this);
  late final $CoinLedgerEntriesTable coinLedgerEntries =
      $CoinLedgerEntriesTable(this);
  late final $CoinBalancesTable coinBalances = $CoinBalancesTable(this);
  late final $RunsTable runs = $RunsTable(this);
  late final $AchievementStatesTable achievementStates =
      $AchievementStatesTable(this);
  late final $DailyLoginClaimsTable dailyLoginClaims = $DailyLoginClaimsTable(
    this,
  );
  late final $ChallengeAttemptsTable challengeAttempts =
      $ChallengeAttemptsTable(this);
  late final $LeaderboardCacheEntriesTable leaderboardCacheEntries =
      $LeaderboardCacheEntriesTable(this);
  late final $LeaderboardSyncMetaTable leaderboardSyncMeta =
      $LeaderboardSyncMetaTable(this);
  late final $SettingsEntriesTable settingsEntries = $SettingsEntriesTable(
    this,
  );
  late final $SyncOutboxTable syncOutbox = $SyncOutboxTable(this);
  late final $MetaUpgradesTable metaUpgrades = $MetaUpgradesTable(this);
  late final $TournamentsTable tournaments = $TournamentsTable(this);
  late final $TournamentLeaderboardCacheTable tournamentLeaderboardCache =
      $TournamentLeaderboardCacheTable(this);
  late final $CosmeticOwnedTable cosmeticOwned = $CosmeticOwnedTable(this);
  late final $CosmeticEquippedTable cosmeticEquipped = $CosmeticEquippedTable(
    this,
  );
  late final ProfileDao profileDao = ProfileDao(this as AppDatabase);
  late final StatsDao statsDao = StatsDao(this as AppDatabase);
  late final CoinLedgerDao coinLedgerDao = CoinLedgerDao(this as AppDatabase);
  late final RunsDao runsDao = RunsDao(this as AppDatabase);
  late final AchievementsDao achievementsDao = AchievementsDao(
    this as AppDatabase,
  );
  late final StreakDao streakDao = StreakDao(this as AppDatabase);
  late final ChallengeDao challengeDao = ChallengeDao(this as AppDatabase);
  late final LeaderboardCacheDao leaderboardCacheDao = LeaderboardCacheDao(
    this as AppDatabase,
  );
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  late final SyncOutboxDao syncOutboxDao = SyncOutboxDao(this as AppDatabase);
  late final MetaUpgradesDao metaUpgradesDao = MetaUpgradesDao(
    this as AppDatabase,
  );
  late final TournamentDao tournamentDao = TournamentDao(this as AppDatabase);
  late final CosmeticsDao cosmeticsDao = CosmeticsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    playerProfiles,
    playerStatsTable,
    statCounters,
    coinLedgerEntries,
    coinBalances,
    runs,
    achievementStates,
    dailyLoginClaims,
    challengeAttempts,
    leaderboardCacheEntries,
    leaderboardSyncMeta,
    settingsEntries,
    syncOutbox,
    metaUpgrades,
    tournaments,
    tournamentLeaderboardCache,
    cosmeticOwned,
    cosmeticEquipped,
  ];
}

typedef $$PlayerProfilesTableCreateCompanionBuilder =
    PlayerProfilesCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String?> username,
      Value<String?> displayName,
      Value<String?> photoUrl,
      Value<bool> isGuest,
      Value<bool> initialSyncCompleted,
      required int createdAt,
      required int updatedAt,
    });
typedef $$PlayerProfilesTableUpdateCompanionBuilder =
    PlayerProfilesCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String?> username,
      Value<String?> displayName,
      Value<String?> photoUrl,
      Value<bool> isGuest,
      Value<bool> initialSyncCompleted,
      Value<int> createdAt,
      Value<int> updatedAt,
    });

class $$PlayerProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $PlayerProfilesTable> {
  $$PlayerProfilesTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isGuest => $composableBuilder(
    column: $table.isGuest,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get initialSyncCompleted => $composableBuilder(
    column: $table.initialSyncCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlayerProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayerProfilesTable> {
  $$PlayerProfilesTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isGuest => $composableBuilder(
    column: $table.isGuest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get initialSyncCompleted => $composableBuilder(
    column: $table.initialSyncCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayerProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayerProfilesTable> {
  $$PlayerProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<bool> get isGuest =>
      $composableBuilder(column: $table.isGuest, builder: (column) => column);

  GeneratedColumn<bool> get initialSyncCompleted => $composableBuilder(
    column: $table.initialSyncCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PlayerProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayerProfilesTable,
          PlayerProfileRow,
          $$PlayerProfilesTableFilterComposer,
          $$PlayerProfilesTableOrderingComposer,
          $$PlayerProfilesTableAnnotationComposer,
          $$PlayerProfilesTableCreateCompanionBuilder,
          $$PlayerProfilesTableUpdateCompanionBuilder,
          (
            PlayerProfileRow,
            BaseReferences<
              _$AppDatabase,
              $PlayerProfilesTable,
              PlayerProfileRow
            >,
          ),
          PlayerProfileRow,
          PrefetchHooks Function()
        > {
  $$PlayerProfilesTableTableManager(
    _$AppDatabase db,
    $PlayerProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayerProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayerProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayerProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<bool> isGuest = const Value.absent(),
                Value<bool> initialSyncCompleted = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => PlayerProfilesCompanion(
                id: id,
                userId: userId,
                username: username,
                displayName: displayName,
                photoUrl: photoUrl,
                isGuest: isGuest,
                initialSyncCompleted: initialSyncCompleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<bool> isGuest = const Value.absent(),
                Value<bool> initialSyncCompleted = const Value.absent(),
                required int createdAt,
                required int updatedAt,
              }) => PlayerProfilesCompanion.insert(
                id: id,
                userId: userId,
                username: username,
                displayName: displayName,
                photoUrl: photoUrl,
                isGuest: isGuest,
                initialSyncCompleted: initialSyncCompleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlayerProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayerProfilesTable,
      PlayerProfileRow,
      $$PlayerProfilesTableFilterComposer,
      $$PlayerProfilesTableOrderingComposer,
      $$PlayerProfilesTableAnnotationComposer,
      $$PlayerProfilesTableCreateCompanionBuilder,
      $$PlayerProfilesTableUpdateCompanionBuilder,
      (
        PlayerProfileRow,
        BaseReferences<_$AppDatabase, $PlayerProfilesTable, PlayerProfileRow>,
      ),
      PlayerProfileRow,
      PrefetchHooks Function()
    >;
typedef $$PlayerStatsTableTableCreateCompanionBuilder =
    PlayerStatsTableCompanion Function({
      Value<int> id,
      Value<int> runsPlayed,
      Value<int> totalKills,
      Value<int> bestScore,
      Value<int> bestChain,
      Value<int> bestBounceKill,
      Value<int> totalWavesCleared,
      Value<int> totalCoinsEarned,
      Value<int> bestWave,
      Value<int> totalPlayMs,
      required int updatedAt,
    });
typedef $$PlayerStatsTableTableUpdateCompanionBuilder =
    PlayerStatsTableCompanion Function({
      Value<int> id,
      Value<int> runsPlayed,
      Value<int> totalKills,
      Value<int> bestScore,
      Value<int> bestChain,
      Value<int> bestBounceKill,
      Value<int> totalWavesCleared,
      Value<int> totalCoinsEarned,
      Value<int> bestWave,
      Value<int> totalPlayMs,
      Value<int> updatedAt,
    });

class $$PlayerStatsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlayerStatsTableTable> {
  $$PlayerStatsTableTableFilterComposer({
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

  ColumnFilters<int> get runsPlayed => $composableBuilder(
    column: $table.runsPlayed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalKills => $composableBuilder(
    column: $table.totalKills,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestScore => $composableBuilder(
    column: $table.bestScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestChain => $composableBuilder(
    column: $table.bestChain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestBounceKill => $composableBuilder(
    column: $table.bestBounceKill,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalWavesCleared => $composableBuilder(
    column: $table.totalWavesCleared,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCoinsEarned => $composableBuilder(
    column: $table.totalCoinsEarned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestWave => $composableBuilder(
    column: $table.bestWave,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPlayMs => $composableBuilder(
    column: $table.totalPlayMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlayerStatsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayerStatsTableTable> {
  $$PlayerStatsTableTableOrderingComposer({
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

  ColumnOrderings<int> get runsPlayed => $composableBuilder(
    column: $table.runsPlayed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalKills => $composableBuilder(
    column: $table.totalKills,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestScore => $composableBuilder(
    column: $table.bestScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestChain => $composableBuilder(
    column: $table.bestChain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestBounceKill => $composableBuilder(
    column: $table.bestBounceKill,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalWavesCleared => $composableBuilder(
    column: $table.totalWavesCleared,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCoinsEarned => $composableBuilder(
    column: $table.totalCoinsEarned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestWave => $composableBuilder(
    column: $table.bestWave,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPlayMs => $composableBuilder(
    column: $table.totalPlayMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayerStatsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayerStatsTableTable> {
  $$PlayerStatsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get runsPlayed => $composableBuilder(
    column: $table.runsPlayed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalKills => $composableBuilder(
    column: $table.totalKills,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bestScore =>
      $composableBuilder(column: $table.bestScore, builder: (column) => column);

  GeneratedColumn<int> get bestChain =>
      $composableBuilder(column: $table.bestChain, builder: (column) => column);

  GeneratedColumn<int> get bestBounceKill => $composableBuilder(
    column: $table.bestBounceKill,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalWavesCleared => $composableBuilder(
    column: $table.totalWavesCleared,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCoinsEarned => $composableBuilder(
    column: $table.totalCoinsEarned,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bestWave =>
      $composableBuilder(column: $table.bestWave, builder: (column) => column);

  GeneratedColumn<int> get totalPlayMs => $composableBuilder(
    column: $table.totalPlayMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PlayerStatsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayerStatsTableTable,
          PlayerStatsRow,
          $$PlayerStatsTableTableFilterComposer,
          $$PlayerStatsTableTableOrderingComposer,
          $$PlayerStatsTableTableAnnotationComposer,
          $$PlayerStatsTableTableCreateCompanionBuilder,
          $$PlayerStatsTableTableUpdateCompanionBuilder,
          (
            PlayerStatsRow,
            BaseReferences<
              _$AppDatabase,
              $PlayerStatsTableTable,
              PlayerStatsRow
            >,
          ),
          PlayerStatsRow,
          PrefetchHooks Function()
        > {
  $$PlayerStatsTableTableTableManager(
    _$AppDatabase db,
    $PlayerStatsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayerStatsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayerStatsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayerStatsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> runsPlayed = const Value.absent(),
                Value<int> totalKills = const Value.absent(),
                Value<int> bestScore = const Value.absent(),
                Value<int> bestChain = const Value.absent(),
                Value<int> bestBounceKill = const Value.absent(),
                Value<int> totalWavesCleared = const Value.absent(),
                Value<int> totalCoinsEarned = const Value.absent(),
                Value<int> bestWave = const Value.absent(),
                Value<int> totalPlayMs = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => PlayerStatsTableCompanion(
                id: id,
                runsPlayed: runsPlayed,
                totalKills: totalKills,
                bestScore: bestScore,
                bestChain: bestChain,
                bestBounceKill: bestBounceKill,
                totalWavesCleared: totalWavesCleared,
                totalCoinsEarned: totalCoinsEarned,
                bestWave: bestWave,
                totalPlayMs: totalPlayMs,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> runsPlayed = const Value.absent(),
                Value<int> totalKills = const Value.absent(),
                Value<int> bestScore = const Value.absent(),
                Value<int> bestChain = const Value.absent(),
                Value<int> bestBounceKill = const Value.absent(),
                Value<int> totalWavesCleared = const Value.absent(),
                Value<int> totalCoinsEarned = const Value.absent(),
                Value<int> bestWave = const Value.absent(),
                Value<int> totalPlayMs = const Value.absent(),
                required int updatedAt,
              }) => PlayerStatsTableCompanion.insert(
                id: id,
                runsPlayed: runsPlayed,
                totalKills: totalKills,
                bestScore: bestScore,
                bestChain: bestChain,
                bestBounceKill: bestBounceKill,
                totalWavesCleared: totalWavesCleared,
                totalCoinsEarned: totalCoinsEarned,
                bestWave: bestWave,
                totalPlayMs: totalPlayMs,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlayerStatsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayerStatsTableTable,
      PlayerStatsRow,
      $$PlayerStatsTableTableFilterComposer,
      $$PlayerStatsTableTableOrderingComposer,
      $$PlayerStatsTableTableAnnotationComposer,
      $$PlayerStatsTableTableCreateCompanionBuilder,
      $$PlayerStatsTableTableUpdateCompanionBuilder,
      (
        PlayerStatsRow,
        BaseReferences<_$AppDatabase, $PlayerStatsTableTable, PlayerStatsRow>,
      ),
      PlayerStatsRow,
      PrefetchHooks Function()
    >;
typedef $$StatCountersTableCreateCompanionBuilder =
    StatCountersCompanion Function({
      required String kind,
      required String key,
      Value<int> count,
      Value<int> rowid,
    });
typedef $$StatCountersTableUpdateCompanionBuilder =
    StatCountersCompanion Function({
      Value<String> kind,
      Value<String> key,
      Value<int> count,
      Value<int> rowid,
    });

class $$StatCountersTableFilterComposer
    extends Composer<_$AppDatabase, $StatCountersTable> {
  $$StatCountersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StatCountersTableOrderingComposer
    extends Composer<_$AppDatabase, $StatCountersTable> {
  $$StatCountersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StatCountersTableAnnotationComposer
    extends Composer<_$AppDatabase, $StatCountersTable> {
  $$StatCountersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);
}

class $$StatCountersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StatCountersTable,
          StatCounterRow,
          $$StatCountersTableFilterComposer,
          $$StatCountersTableOrderingComposer,
          $$StatCountersTableAnnotationComposer,
          $$StatCountersTableCreateCompanionBuilder,
          $$StatCountersTableUpdateCompanionBuilder,
          (
            StatCounterRow,
            BaseReferences<_$AppDatabase, $StatCountersTable, StatCounterRow>,
          ),
          StatCounterRow,
          PrefetchHooks Function()
        > {
  $$StatCountersTableTableManager(_$AppDatabase db, $StatCountersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StatCountersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StatCountersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StatCountersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> kind = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StatCountersCompanion(
                kind: kind,
                key: key,
                count: count,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String kind,
                required String key,
                Value<int> count = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StatCountersCompanion.insert(
                kind: kind,
                key: key,
                count: count,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StatCountersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StatCountersTable,
      StatCounterRow,
      $$StatCountersTableFilterComposer,
      $$StatCountersTableOrderingComposer,
      $$StatCountersTableAnnotationComposer,
      $$StatCountersTableCreateCompanionBuilder,
      $$StatCountersTableUpdateCompanionBuilder,
      (
        StatCounterRow,
        BaseReferences<_$AppDatabase, $StatCountersTable, StatCounterRow>,
      ),
      StatCounterRow,
      PrefetchHooks Function()
    >;
typedef $$CoinLedgerEntriesTableCreateCompanionBuilder =
    CoinLedgerEntriesCompanion Function({
      required String id,
      required int amount,
      required String reason,
      Value<String?> runId,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$CoinLedgerEntriesTableUpdateCompanionBuilder =
    CoinLedgerEntriesCompanion Function({
      Value<String> id,
      Value<int> amount,
      Value<String> reason,
      Value<String?> runId,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$CoinLedgerEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CoinLedgerEntriesTable> {
  $$CoinLedgerEntriesTableFilterComposer({
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

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get runId => $composableBuilder(
    column: $table.runId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CoinLedgerEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CoinLedgerEntriesTable> {
  $$CoinLedgerEntriesTableOrderingComposer({
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

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get runId => $composableBuilder(
    column: $table.runId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CoinLedgerEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CoinLedgerEntriesTable> {
  $$CoinLedgerEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get runId =>
      $composableBuilder(column: $table.runId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CoinLedgerEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CoinLedgerEntriesTable,
          CoinLedgerRow,
          $$CoinLedgerEntriesTableFilterComposer,
          $$CoinLedgerEntriesTableOrderingComposer,
          $$CoinLedgerEntriesTableAnnotationComposer,
          $$CoinLedgerEntriesTableCreateCompanionBuilder,
          $$CoinLedgerEntriesTableUpdateCompanionBuilder,
          (
            CoinLedgerRow,
            BaseReferences<
              _$AppDatabase,
              $CoinLedgerEntriesTable,
              CoinLedgerRow
            >,
          ),
          CoinLedgerRow,
          PrefetchHooks Function()
        > {
  $$CoinLedgerEntriesTableTableManager(
    _$AppDatabase db,
    $CoinLedgerEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoinLedgerEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoinLedgerEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CoinLedgerEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String?> runId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CoinLedgerEntriesCompanion(
                id: id,
                amount: amount,
                reason: reason,
                runId: runId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int amount,
                required String reason,
                Value<String?> runId = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CoinLedgerEntriesCompanion.insert(
                id: id,
                amount: amount,
                reason: reason,
                runId: runId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CoinLedgerEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CoinLedgerEntriesTable,
      CoinLedgerRow,
      $$CoinLedgerEntriesTableFilterComposer,
      $$CoinLedgerEntriesTableOrderingComposer,
      $$CoinLedgerEntriesTableAnnotationComposer,
      $$CoinLedgerEntriesTableCreateCompanionBuilder,
      $$CoinLedgerEntriesTableUpdateCompanionBuilder,
      (
        CoinLedgerRow,
        BaseReferences<_$AppDatabase, $CoinLedgerEntriesTable, CoinLedgerRow>,
      ),
      CoinLedgerRow,
      PrefetchHooks Function()
    >;
typedef $$CoinBalancesTableCreateCompanionBuilder =
    CoinBalancesCompanion Function({
      Value<int> id,
      Value<int> balance,
      Value<int> lastLedgerCreatedAt,
    });
typedef $$CoinBalancesTableUpdateCompanionBuilder =
    CoinBalancesCompanion Function({
      Value<int> id,
      Value<int> balance,
      Value<int> lastLedgerCreatedAt,
    });

class $$CoinBalancesTableFilterComposer
    extends Composer<_$AppDatabase, $CoinBalancesTable> {
  $$CoinBalancesTableFilterComposer({
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

  ColumnFilters<int> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastLedgerCreatedAt => $composableBuilder(
    column: $table.lastLedgerCreatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CoinBalancesTableOrderingComposer
    extends Composer<_$AppDatabase, $CoinBalancesTable> {
  $$CoinBalancesTableOrderingComposer({
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

  ColumnOrderings<int> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastLedgerCreatedAt => $composableBuilder(
    column: $table.lastLedgerCreatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CoinBalancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CoinBalancesTable> {
  $$CoinBalancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<int> get lastLedgerCreatedAt => $composableBuilder(
    column: $table.lastLedgerCreatedAt,
    builder: (column) => column,
  );
}

class $$CoinBalancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CoinBalancesTable,
          CoinBalanceRow,
          $$CoinBalancesTableFilterComposer,
          $$CoinBalancesTableOrderingComposer,
          $$CoinBalancesTableAnnotationComposer,
          $$CoinBalancesTableCreateCompanionBuilder,
          $$CoinBalancesTableUpdateCompanionBuilder,
          (
            CoinBalanceRow,
            BaseReferences<_$AppDatabase, $CoinBalancesTable, CoinBalanceRow>,
          ),
          CoinBalanceRow,
          PrefetchHooks Function()
        > {
  $$CoinBalancesTableTableManager(_$AppDatabase db, $CoinBalancesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoinBalancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoinBalancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CoinBalancesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> balance = const Value.absent(),
                Value<int> lastLedgerCreatedAt = const Value.absent(),
              }) => CoinBalancesCompanion(
                id: id,
                balance: balance,
                lastLedgerCreatedAt: lastLedgerCreatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> balance = const Value.absent(),
                Value<int> lastLedgerCreatedAt = const Value.absent(),
              }) => CoinBalancesCompanion.insert(
                id: id,
                balance: balance,
                lastLedgerCreatedAt: lastLedgerCreatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CoinBalancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CoinBalancesTable,
      CoinBalanceRow,
      $$CoinBalancesTableFilterComposer,
      $$CoinBalancesTableOrderingComposer,
      $$CoinBalancesTableAnnotationComposer,
      $$CoinBalancesTableCreateCompanionBuilder,
      $$CoinBalancesTableUpdateCompanionBuilder,
      (
        CoinBalanceRow,
        BaseReferences<_$AppDatabase, $CoinBalancesTable, CoinBalanceRow>,
      ),
      CoinBalanceRow,
      PrefetchHooks Function()
    >;
typedef $$RunsTableCreateCompanionBuilder =
    RunsCompanion Function({
      required String id,
      required int score,
      required int waveReached,
      required int kills,
      required int bestChain,
      required int maxBounceKill,
      required int durationMs,
      required int coinsEarned,
      Value<bool> isDailyChallenge,
      Value<String?> challengeDate,
      Value<String?> tournamentId,
      required String arenaId,
      Value<String> upgradesPicked,
      required int endedAt,
      Value<int> rowid,
    });
typedef $$RunsTableUpdateCompanionBuilder =
    RunsCompanion Function({
      Value<String> id,
      Value<int> score,
      Value<int> waveReached,
      Value<int> kills,
      Value<int> bestChain,
      Value<int> maxBounceKill,
      Value<int> durationMs,
      Value<int> coinsEarned,
      Value<bool> isDailyChallenge,
      Value<String?> challengeDate,
      Value<String?> tournamentId,
      Value<String> arenaId,
      Value<String> upgradesPicked,
      Value<int> endedAt,
      Value<int> rowid,
    });

class $$RunsTableFilterComposer extends Composer<_$AppDatabase, $RunsTable> {
  $$RunsTableFilterComposer({
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

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get waveReached => $composableBuilder(
    column: $table.waveReached,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get kills => $composableBuilder(
    column: $table.kills,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestChain => $composableBuilder(
    column: $table.bestChain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxBounceKill => $composableBuilder(
    column: $table.maxBounceKill,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coinsEarned => $composableBuilder(
    column: $table.coinsEarned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDailyChallenge => $composableBuilder(
    column: $table.isDailyChallenge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get challengeDate => $composableBuilder(
    column: $table.challengeDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tournamentId => $composableBuilder(
    column: $table.tournamentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arenaId => $composableBuilder(
    column: $table.arenaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get upgradesPicked => $composableBuilder(
    column: $table.upgradesPicked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RunsTableOrderingComposer extends Composer<_$AppDatabase, $RunsTable> {
  $$RunsTableOrderingComposer({
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

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get waveReached => $composableBuilder(
    column: $table.waveReached,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kills => $composableBuilder(
    column: $table.kills,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestChain => $composableBuilder(
    column: $table.bestChain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxBounceKill => $composableBuilder(
    column: $table.maxBounceKill,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coinsEarned => $composableBuilder(
    column: $table.coinsEarned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDailyChallenge => $composableBuilder(
    column: $table.isDailyChallenge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get challengeDate => $composableBuilder(
    column: $table.challengeDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tournamentId => $composableBuilder(
    column: $table.tournamentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arenaId => $composableBuilder(
    column: $table.arenaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get upgradesPicked => $composableBuilder(
    column: $table.upgradesPicked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RunsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RunsTable> {
  $$RunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get waveReached => $composableBuilder(
    column: $table.waveReached,
    builder: (column) => column,
  );

  GeneratedColumn<int> get kills =>
      $composableBuilder(column: $table.kills, builder: (column) => column);

  GeneratedColumn<int> get bestChain =>
      $composableBuilder(column: $table.bestChain, builder: (column) => column);

  GeneratedColumn<int> get maxBounceKill => $composableBuilder(
    column: $table.maxBounceKill,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get coinsEarned => $composableBuilder(
    column: $table.coinsEarned,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDailyChallenge => $composableBuilder(
    column: $table.isDailyChallenge,
    builder: (column) => column,
  );

  GeneratedColumn<String> get challengeDate => $composableBuilder(
    column: $table.challengeDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tournamentId => $composableBuilder(
    column: $table.tournamentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get arenaId =>
      $composableBuilder(column: $table.arenaId, builder: (column) => column);

  GeneratedColumn<String> get upgradesPicked => $composableBuilder(
    column: $table.upgradesPicked,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);
}

class $$RunsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RunsTable,
          RunRow,
          $$RunsTableFilterComposer,
          $$RunsTableOrderingComposer,
          $$RunsTableAnnotationComposer,
          $$RunsTableCreateCompanionBuilder,
          $$RunsTableUpdateCompanionBuilder,
          (RunRow, BaseReferences<_$AppDatabase, $RunsTable, RunRow>),
          RunRow,
          PrefetchHooks Function()
        > {
  $$RunsTableTableManager(_$AppDatabase db, $RunsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<int> waveReached = const Value.absent(),
                Value<int> kills = const Value.absent(),
                Value<int> bestChain = const Value.absent(),
                Value<int> maxBounceKill = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int> coinsEarned = const Value.absent(),
                Value<bool> isDailyChallenge = const Value.absent(),
                Value<String?> challengeDate = const Value.absent(),
                Value<String?> tournamentId = const Value.absent(),
                Value<String> arenaId = const Value.absent(),
                Value<String> upgradesPicked = const Value.absent(),
                Value<int> endedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RunsCompanion(
                id: id,
                score: score,
                waveReached: waveReached,
                kills: kills,
                bestChain: bestChain,
                maxBounceKill: maxBounceKill,
                durationMs: durationMs,
                coinsEarned: coinsEarned,
                isDailyChallenge: isDailyChallenge,
                challengeDate: challengeDate,
                tournamentId: tournamentId,
                arenaId: arenaId,
                upgradesPicked: upgradesPicked,
                endedAt: endedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int score,
                required int waveReached,
                required int kills,
                required int bestChain,
                required int maxBounceKill,
                required int durationMs,
                required int coinsEarned,
                Value<bool> isDailyChallenge = const Value.absent(),
                Value<String?> challengeDate = const Value.absent(),
                Value<String?> tournamentId = const Value.absent(),
                required String arenaId,
                Value<String> upgradesPicked = const Value.absent(),
                required int endedAt,
                Value<int> rowid = const Value.absent(),
              }) => RunsCompanion.insert(
                id: id,
                score: score,
                waveReached: waveReached,
                kills: kills,
                bestChain: bestChain,
                maxBounceKill: maxBounceKill,
                durationMs: durationMs,
                coinsEarned: coinsEarned,
                isDailyChallenge: isDailyChallenge,
                challengeDate: challengeDate,
                tournamentId: tournamentId,
                arenaId: arenaId,
                upgradesPicked: upgradesPicked,
                endedAt: endedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RunsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RunsTable,
      RunRow,
      $$RunsTableFilterComposer,
      $$RunsTableOrderingComposer,
      $$RunsTableAnnotationComposer,
      $$RunsTableCreateCompanionBuilder,
      $$RunsTableUpdateCompanionBuilder,
      (RunRow, BaseReferences<_$AppDatabase, $RunsTable, RunRow>),
      RunRow,
      PrefetchHooks Function()
    >;
typedef $$AchievementStatesTableCreateCompanionBuilder =
    AchievementStatesCompanion Function({
      required String achievementId,
      Value<int> progress,
      Value<int?> unlockedAt,
      Value<int?> claimedAt,
      Value<int> rowid,
    });
typedef $$AchievementStatesTableUpdateCompanionBuilder =
    AchievementStatesCompanion Function({
      Value<String> achievementId,
      Value<int> progress,
      Value<int?> unlockedAt,
      Value<int?> claimedAt,
      Value<int> rowid,
    });

class $$AchievementStatesTableFilterComposer
    extends Composer<_$AppDatabase, $AchievementStatesTable> {
  $$AchievementStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get achievementId => $composableBuilder(
    column: $table.achievementId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get claimedAt => $composableBuilder(
    column: $table.claimedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AchievementStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $AchievementStatesTable> {
  $$AchievementStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get achievementId => $composableBuilder(
    column: $table.achievementId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get claimedAt => $composableBuilder(
    column: $table.claimedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AchievementStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AchievementStatesTable> {
  $$AchievementStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get achievementId => $composableBuilder(
    column: $table.achievementId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<int> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get claimedAt =>
      $composableBuilder(column: $table.claimedAt, builder: (column) => column);
}

class $$AchievementStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AchievementStatesTable,
          AchievementStateRow,
          $$AchievementStatesTableFilterComposer,
          $$AchievementStatesTableOrderingComposer,
          $$AchievementStatesTableAnnotationComposer,
          $$AchievementStatesTableCreateCompanionBuilder,
          $$AchievementStatesTableUpdateCompanionBuilder,
          (
            AchievementStateRow,
            BaseReferences<
              _$AppDatabase,
              $AchievementStatesTable,
              AchievementStateRow
            >,
          ),
          AchievementStateRow,
          PrefetchHooks Function()
        > {
  $$AchievementStatesTableTableManager(
    _$AppDatabase db,
    $AchievementStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AchievementStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AchievementStatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> achievementId = const Value.absent(),
                Value<int> progress = const Value.absent(),
                Value<int?> unlockedAt = const Value.absent(),
                Value<int?> claimedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AchievementStatesCompanion(
                achievementId: achievementId,
                progress: progress,
                unlockedAt: unlockedAt,
                claimedAt: claimedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String achievementId,
                Value<int> progress = const Value.absent(),
                Value<int?> unlockedAt = const Value.absent(),
                Value<int?> claimedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AchievementStatesCompanion.insert(
                achievementId: achievementId,
                progress: progress,
                unlockedAt: unlockedAt,
                claimedAt: claimedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AchievementStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AchievementStatesTable,
      AchievementStateRow,
      $$AchievementStatesTableFilterComposer,
      $$AchievementStatesTableOrderingComposer,
      $$AchievementStatesTableAnnotationComposer,
      $$AchievementStatesTableCreateCompanionBuilder,
      $$AchievementStatesTableUpdateCompanionBuilder,
      (
        AchievementStateRow,
        BaseReferences<
          _$AppDatabase,
          $AchievementStatesTable,
          AchievementStateRow
        >,
      ),
      AchievementStateRow,
      PrefetchHooks Function()
    >;
typedef $$DailyLoginClaimsTableCreateCompanionBuilder =
    DailyLoginClaimsCompanion Function({
      required String claimDate,
      required int dayIndex,
      required int coinsAwarded,
      required int claimedAt,
      Value<int> rowid,
    });
typedef $$DailyLoginClaimsTableUpdateCompanionBuilder =
    DailyLoginClaimsCompanion Function({
      Value<String> claimDate,
      Value<int> dayIndex,
      Value<int> coinsAwarded,
      Value<int> claimedAt,
      Value<int> rowid,
    });

class $$DailyLoginClaimsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyLoginClaimsTable> {
  $$DailyLoginClaimsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get claimDate => $composableBuilder(
    column: $table.claimDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayIndex => $composableBuilder(
    column: $table.dayIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coinsAwarded => $composableBuilder(
    column: $table.coinsAwarded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get claimedAt => $composableBuilder(
    column: $table.claimedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyLoginClaimsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyLoginClaimsTable> {
  $$DailyLoginClaimsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get claimDate => $composableBuilder(
    column: $table.claimDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayIndex => $composableBuilder(
    column: $table.dayIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coinsAwarded => $composableBuilder(
    column: $table.coinsAwarded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get claimedAt => $composableBuilder(
    column: $table.claimedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyLoginClaimsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyLoginClaimsTable> {
  $$DailyLoginClaimsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get claimDate =>
      $composableBuilder(column: $table.claimDate, builder: (column) => column);

  GeneratedColumn<int> get dayIndex =>
      $composableBuilder(column: $table.dayIndex, builder: (column) => column);

  GeneratedColumn<int> get coinsAwarded => $composableBuilder(
    column: $table.coinsAwarded,
    builder: (column) => column,
  );

  GeneratedColumn<int> get claimedAt =>
      $composableBuilder(column: $table.claimedAt, builder: (column) => column);
}

class $$DailyLoginClaimsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyLoginClaimsTable,
          DailyLoginClaimRow,
          $$DailyLoginClaimsTableFilterComposer,
          $$DailyLoginClaimsTableOrderingComposer,
          $$DailyLoginClaimsTableAnnotationComposer,
          $$DailyLoginClaimsTableCreateCompanionBuilder,
          $$DailyLoginClaimsTableUpdateCompanionBuilder,
          (
            DailyLoginClaimRow,
            BaseReferences<
              _$AppDatabase,
              $DailyLoginClaimsTable,
              DailyLoginClaimRow
            >,
          ),
          DailyLoginClaimRow,
          PrefetchHooks Function()
        > {
  $$DailyLoginClaimsTableTableManager(
    _$AppDatabase db,
    $DailyLoginClaimsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyLoginClaimsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyLoginClaimsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyLoginClaimsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> claimDate = const Value.absent(),
                Value<int> dayIndex = const Value.absent(),
                Value<int> coinsAwarded = const Value.absent(),
                Value<int> claimedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyLoginClaimsCompanion(
                claimDate: claimDate,
                dayIndex: dayIndex,
                coinsAwarded: coinsAwarded,
                claimedAt: claimedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String claimDate,
                required int dayIndex,
                required int coinsAwarded,
                required int claimedAt,
                Value<int> rowid = const Value.absent(),
              }) => DailyLoginClaimsCompanion.insert(
                claimDate: claimDate,
                dayIndex: dayIndex,
                coinsAwarded: coinsAwarded,
                claimedAt: claimedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyLoginClaimsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyLoginClaimsTable,
      DailyLoginClaimRow,
      $$DailyLoginClaimsTableFilterComposer,
      $$DailyLoginClaimsTableOrderingComposer,
      $$DailyLoginClaimsTableAnnotationComposer,
      $$DailyLoginClaimsTableCreateCompanionBuilder,
      $$DailyLoginClaimsTableUpdateCompanionBuilder,
      (
        DailyLoginClaimRow,
        BaseReferences<
          _$AppDatabase,
          $DailyLoginClaimsTable,
          DailyLoginClaimRow
        >,
      ),
      DailyLoginClaimRow,
      PrefetchHooks Function()
    >;
typedef $$ChallengeAttemptsTableCreateCompanionBuilder =
    ChallengeAttemptsCompanion Function({
      required String id,
      required String challengeDate,
      required int seed,
      required int score,
      Value<String?> runId,
      required int completedAt,
      Value<int> rowid,
    });
typedef $$ChallengeAttemptsTableUpdateCompanionBuilder =
    ChallengeAttemptsCompanion Function({
      Value<String> id,
      Value<String> challengeDate,
      Value<int> seed,
      Value<int> score,
      Value<String?> runId,
      Value<int> completedAt,
      Value<int> rowid,
    });

class $$ChallengeAttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $ChallengeAttemptsTable> {
  $$ChallengeAttemptsTableFilterComposer({
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

  ColumnFilters<String> get challengeDate => $composableBuilder(
    column: $table.challengeDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seed => $composableBuilder(
    column: $table.seed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get runId => $composableBuilder(
    column: $table.runId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChallengeAttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChallengeAttemptsTable> {
  $$ChallengeAttemptsTableOrderingComposer({
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

  ColumnOrderings<String> get challengeDate => $composableBuilder(
    column: $table.challengeDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seed => $composableBuilder(
    column: $table.seed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get runId => $composableBuilder(
    column: $table.runId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChallengeAttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChallengeAttemptsTable> {
  $$ChallengeAttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get challengeDate => $composableBuilder(
    column: $table.challengeDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seed =>
      $composableBuilder(column: $table.seed, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<String> get runId =>
      $composableBuilder(column: $table.runId, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$ChallengeAttemptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChallengeAttemptsTable,
          ChallengeAttemptRow,
          $$ChallengeAttemptsTableFilterComposer,
          $$ChallengeAttemptsTableOrderingComposer,
          $$ChallengeAttemptsTableAnnotationComposer,
          $$ChallengeAttemptsTableCreateCompanionBuilder,
          $$ChallengeAttemptsTableUpdateCompanionBuilder,
          (
            ChallengeAttemptRow,
            BaseReferences<
              _$AppDatabase,
              $ChallengeAttemptsTable,
              ChallengeAttemptRow
            >,
          ),
          ChallengeAttemptRow,
          PrefetchHooks Function()
        > {
  $$ChallengeAttemptsTableTableManager(
    _$AppDatabase db,
    $ChallengeAttemptsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChallengeAttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChallengeAttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChallengeAttemptsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> challengeDate = const Value.absent(),
                Value<int> seed = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<String?> runId = const Value.absent(),
                Value<int> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChallengeAttemptsCompanion(
                id: id,
                challengeDate: challengeDate,
                seed: seed,
                score: score,
                runId: runId,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String challengeDate,
                required int seed,
                required int score,
                Value<String?> runId = const Value.absent(),
                required int completedAt,
                Value<int> rowid = const Value.absent(),
              }) => ChallengeAttemptsCompanion.insert(
                id: id,
                challengeDate: challengeDate,
                seed: seed,
                score: score,
                runId: runId,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChallengeAttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChallengeAttemptsTable,
      ChallengeAttemptRow,
      $$ChallengeAttemptsTableFilterComposer,
      $$ChallengeAttemptsTableOrderingComposer,
      $$ChallengeAttemptsTableAnnotationComposer,
      $$ChallengeAttemptsTableCreateCompanionBuilder,
      $$ChallengeAttemptsTableUpdateCompanionBuilder,
      (
        ChallengeAttemptRow,
        BaseReferences<
          _$AppDatabase,
          $ChallengeAttemptsTable,
          ChallengeAttemptRow
        >,
      ),
      ChallengeAttemptRow,
      PrefetchHooks Function()
    >;
typedef $$LeaderboardCacheEntriesTableCreateCompanionBuilder =
    LeaderboardCacheEntriesCompanion Function({
      required String boardType,
      required String periodKey,
      required int rank,
      required String userId,
      required String username,
      required int score,
      Value<bool> isPlayer,
      Value<int> rowid,
    });
typedef $$LeaderboardCacheEntriesTableUpdateCompanionBuilder =
    LeaderboardCacheEntriesCompanion Function({
      Value<String> boardType,
      Value<String> periodKey,
      Value<int> rank,
      Value<String> userId,
      Value<String> username,
      Value<int> score,
      Value<bool> isPlayer,
      Value<int> rowid,
    });

class $$LeaderboardCacheEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LeaderboardCacheEntriesTable> {
  $$LeaderboardCacheEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get boardType => $composableBuilder(
    column: $table.boardType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get periodKey => $composableBuilder(
    column: $table.periodKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPlayer => $composableBuilder(
    column: $table.isPlayer,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LeaderboardCacheEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LeaderboardCacheEntriesTable> {
  $$LeaderboardCacheEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get boardType => $composableBuilder(
    column: $table.boardType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodKey => $composableBuilder(
    column: $table.periodKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPlayer => $composableBuilder(
    column: $table.isPlayer,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LeaderboardCacheEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LeaderboardCacheEntriesTable> {
  $$LeaderboardCacheEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get boardType =>
      $composableBuilder(column: $table.boardType, builder: (column) => column);

  GeneratedColumn<String> get periodKey =>
      $composableBuilder(column: $table.periodKey, builder: (column) => column);

  GeneratedColumn<int> get rank =>
      $composableBuilder(column: $table.rank, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<bool> get isPlayer =>
      $composableBuilder(column: $table.isPlayer, builder: (column) => column);
}

class $$LeaderboardCacheEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LeaderboardCacheEntriesTable,
          LeaderboardCacheRow,
          $$LeaderboardCacheEntriesTableFilterComposer,
          $$LeaderboardCacheEntriesTableOrderingComposer,
          $$LeaderboardCacheEntriesTableAnnotationComposer,
          $$LeaderboardCacheEntriesTableCreateCompanionBuilder,
          $$LeaderboardCacheEntriesTableUpdateCompanionBuilder,
          (
            LeaderboardCacheRow,
            BaseReferences<
              _$AppDatabase,
              $LeaderboardCacheEntriesTable,
              LeaderboardCacheRow
            >,
          ),
          LeaderboardCacheRow,
          PrefetchHooks Function()
        > {
  $$LeaderboardCacheEntriesTableTableManager(
    _$AppDatabase db,
    $LeaderboardCacheEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LeaderboardCacheEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LeaderboardCacheEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LeaderboardCacheEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> boardType = const Value.absent(),
                Value<String> periodKey = const Value.absent(),
                Value<int> rank = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<bool> isPlayer = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LeaderboardCacheEntriesCompanion(
                boardType: boardType,
                periodKey: periodKey,
                rank: rank,
                userId: userId,
                username: username,
                score: score,
                isPlayer: isPlayer,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String boardType,
                required String periodKey,
                required int rank,
                required String userId,
                required String username,
                required int score,
                Value<bool> isPlayer = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LeaderboardCacheEntriesCompanion.insert(
                boardType: boardType,
                periodKey: periodKey,
                rank: rank,
                userId: userId,
                username: username,
                score: score,
                isPlayer: isPlayer,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LeaderboardCacheEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LeaderboardCacheEntriesTable,
      LeaderboardCacheRow,
      $$LeaderboardCacheEntriesTableFilterComposer,
      $$LeaderboardCacheEntriesTableOrderingComposer,
      $$LeaderboardCacheEntriesTableAnnotationComposer,
      $$LeaderboardCacheEntriesTableCreateCompanionBuilder,
      $$LeaderboardCacheEntriesTableUpdateCompanionBuilder,
      (
        LeaderboardCacheRow,
        BaseReferences<
          _$AppDatabase,
          $LeaderboardCacheEntriesTable,
          LeaderboardCacheRow
        >,
      ),
      LeaderboardCacheRow,
      PrefetchHooks Function()
    >;
typedef $$LeaderboardSyncMetaTableCreateCompanionBuilder =
    LeaderboardSyncMetaCompanion Function({
      required String boardType,
      required String periodKey,
      required int lastSyncedAt,
      Value<int?> playerRank,
      Value<int?> playerScore,
      Value<int> rowid,
    });
typedef $$LeaderboardSyncMetaTableUpdateCompanionBuilder =
    LeaderboardSyncMetaCompanion Function({
      Value<String> boardType,
      Value<String> periodKey,
      Value<int> lastSyncedAt,
      Value<int?> playerRank,
      Value<int?> playerScore,
      Value<int> rowid,
    });

class $$LeaderboardSyncMetaTableFilterComposer
    extends Composer<_$AppDatabase, $LeaderboardSyncMetaTable> {
  $$LeaderboardSyncMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get boardType => $composableBuilder(
    column: $table.boardType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get periodKey => $composableBuilder(
    column: $table.periodKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playerRank => $composableBuilder(
    column: $table.playerRank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playerScore => $composableBuilder(
    column: $table.playerScore,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LeaderboardSyncMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $LeaderboardSyncMetaTable> {
  $$LeaderboardSyncMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get boardType => $composableBuilder(
    column: $table.boardType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodKey => $composableBuilder(
    column: $table.periodKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playerRank => $composableBuilder(
    column: $table.playerRank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playerScore => $composableBuilder(
    column: $table.playerScore,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LeaderboardSyncMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $LeaderboardSyncMetaTable> {
  $$LeaderboardSyncMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get boardType =>
      $composableBuilder(column: $table.boardType, builder: (column) => column);

  GeneratedColumn<String> get periodKey =>
      $composableBuilder(column: $table.periodKey, builder: (column) => column);

  GeneratedColumn<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get playerRank => $composableBuilder(
    column: $table.playerRank,
    builder: (column) => column,
  );

  GeneratedColumn<int> get playerScore => $composableBuilder(
    column: $table.playerScore,
    builder: (column) => column,
  );
}

class $$LeaderboardSyncMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LeaderboardSyncMetaTable,
          LeaderboardSyncMetaRow,
          $$LeaderboardSyncMetaTableFilterComposer,
          $$LeaderboardSyncMetaTableOrderingComposer,
          $$LeaderboardSyncMetaTableAnnotationComposer,
          $$LeaderboardSyncMetaTableCreateCompanionBuilder,
          $$LeaderboardSyncMetaTableUpdateCompanionBuilder,
          (
            LeaderboardSyncMetaRow,
            BaseReferences<
              _$AppDatabase,
              $LeaderboardSyncMetaTable,
              LeaderboardSyncMetaRow
            >,
          ),
          LeaderboardSyncMetaRow,
          PrefetchHooks Function()
        > {
  $$LeaderboardSyncMetaTableTableManager(
    _$AppDatabase db,
    $LeaderboardSyncMetaTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LeaderboardSyncMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LeaderboardSyncMetaTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LeaderboardSyncMetaTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> boardType = const Value.absent(),
                Value<String> periodKey = const Value.absent(),
                Value<int> lastSyncedAt = const Value.absent(),
                Value<int?> playerRank = const Value.absent(),
                Value<int?> playerScore = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LeaderboardSyncMetaCompanion(
                boardType: boardType,
                periodKey: periodKey,
                lastSyncedAt: lastSyncedAt,
                playerRank: playerRank,
                playerScore: playerScore,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String boardType,
                required String periodKey,
                required int lastSyncedAt,
                Value<int?> playerRank = const Value.absent(),
                Value<int?> playerScore = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LeaderboardSyncMetaCompanion.insert(
                boardType: boardType,
                periodKey: periodKey,
                lastSyncedAt: lastSyncedAt,
                playerRank: playerRank,
                playerScore: playerScore,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LeaderboardSyncMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LeaderboardSyncMetaTable,
      LeaderboardSyncMetaRow,
      $$LeaderboardSyncMetaTableFilterComposer,
      $$LeaderboardSyncMetaTableOrderingComposer,
      $$LeaderboardSyncMetaTableAnnotationComposer,
      $$LeaderboardSyncMetaTableCreateCompanionBuilder,
      $$LeaderboardSyncMetaTableUpdateCompanionBuilder,
      (
        LeaderboardSyncMetaRow,
        BaseReferences<
          _$AppDatabase,
          $LeaderboardSyncMetaTable,
          LeaderboardSyncMetaRow
        >,
      ),
      LeaderboardSyncMetaRow,
      PrefetchHooks Function()
    >;
typedef $$SettingsEntriesTableCreateCompanionBuilder =
    SettingsEntriesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsEntriesTableUpdateCompanionBuilder =
    SettingsEntriesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsEntriesTable> {
  $$SettingsEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsEntriesTable> {
  $$SettingsEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsEntriesTable> {
  $$SettingsEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsEntriesTable,
          SettingRow,
          $$SettingsEntriesTableFilterComposer,
          $$SettingsEntriesTableOrderingComposer,
          $$SettingsEntriesTableAnnotationComposer,
          $$SettingsEntriesTableCreateCompanionBuilder,
          $$SettingsEntriesTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $SettingsEntriesTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingsEntriesTableTableManager(
    _$AppDatabase db,
    $SettingsEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsEntriesCompanion(
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsEntriesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsEntriesTable,
      SettingRow,
      $$SettingsEntriesTableFilterComposer,
      $$SettingsEntriesTableOrderingComposer,
      $$SettingsEntriesTableAnnotationComposer,
      $$SettingsEntriesTableCreateCompanionBuilder,
      $$SettingsEntriesTableUpdateCompanionBuilder,
      (
        SettingRow,
        BaseReferences<_$AppDatabase, $SettingsEntriesTable, SettingRow>,
      ),
      SettingRow,
      PrefetchHooks Function()
    >;
typedef $$SyncOutboxTableCreateCompanionBuilder =
    SyncOutboxCompanion Function({
      required String id,
      required String entityType,
      Value<String> operation,
      required String payload,
      required int createdAt,
      Value<int> attempts,
      Value<String> status,
      Value<int?> nextRetryAt,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$SyncOutboxTableUpdateCompanionBuilder =
    SyncOutboxCompanion Function({
      Value<String> id,
      Value<String> entityType,
      Value<String> operation,
      Value<String> payload,
      Value<int> createdAt,
      Value<int> attempts,
      Value<String> status,
      Value<int?> nextRetryAt,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$SyncOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableFilterComposer({
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

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableOrderingComposer({
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

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncOutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncOutboxTable,
          SyncOutboxRow,
          $$SyncOutboxTableFilterComposer,
          $$SyncOutboxTableOrderingComposer,
          $$SyncOutboxTableAnnotationComposer,
          $$SyncOutboxTableCreateCompanionBuilder,
          $$SyncOutboxTableUpdateCompanionBuilder,
          (
            SyncOutboxRow,
            BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxRow>,
          ),
          SyncOutboxRow,
          PrefetchHooks Function()
        > {
  $$SyncOutboxTableTableManager(_$AppDatabase db, $SyncOutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> nextRetryAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxCompanion(
                id: id,
                entityType: entityType,
                operation: operation,
                payload: payload,
                createdAt: createdAt,
                attempts: attempts,
                status: status,
                nextRetryAt: nextRetryAt,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityType,
                Value<String> operation = const Value.absent(),
                required String payload,
                required int createdAt,
                Value<int> attempts = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> nextRetryAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxCompanion.insert(
                id: id,
                entityType: entityType,
                operation: operation,
                payload: payload,
                createdAt: createdAt,
                attempts: attempts,
                status: status,
                nextRetryAt: nextRetryAt,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncOutboxTable,
      SyncOutboxRow,
      $$SyncOutboxTableFilterComposer,
      $$SyncOutboxTableOrderingComposer,
      $$SyncOutboxTableAnnotationComposer,
      $$SyncOutboxTableCreateCompanionBuilder,
      $$SyncOutboxTableUpdateCompanionBuilder,
      (
        SyncOutboxRow,
        BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxRow>,
      ),
      SyncOutboxRow,
      PrefetchHooks Function()
    >;
typedef $$MetaUpgradesTableCreateCompanionBuilder =
    MetaUpgradesCompanion Function({
      required String perkId,
      Value<int> level,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$MetaUpgradesTableUpdateCompanionBuilder =
    MetaUpgradesCompanion Function({
      Value<String> perkId,
      Value<int> level,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$MetaUpgradesTableFilterComposer
    extends Composer<_$AppDatabase, $MetaUpgradesTable> {
  $$MetaUpgradesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get perkId => $composableBuilder(
    column: $table.perkId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetaUpgradesTableOrderingComposer
    extends Composer<_$AppDatabase, $MetaUpgradesTable> {
  $$MetaUpgradesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get perkId => $composableBuilder(
    column: $table.perkId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetaUpgradesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetaUpgradesTable> {
  $$MetaUpgradesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get perkId =>
      $composableBuilder(column: $table.perkId, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MetaUpgradesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MetaUpgradesTable,
          MetaUpgradeRow,
          $$MetaUpgradesTableFilterComposer,
          $$MetaUpgradesTableOrderingComposer,
          $$MetaUpgradesTableAnnotationComposer,
          $$MetaUpgradesTableCreateCompanionBuilder,
          $$MetaUpgradesTableUpdateCompanionBuilder,
          (
            MetaUpgradeRow,
            BaseReferences<_$AppDatabase, $MetaUpgradesTable, MetaUpgradeRow>,
          ),
          MetaUpgradeRow,
          PrefetchHooks Function()
        > {
  $$MetaUpgradesTableTableManager(_$AppDatabase db, $MetaUpgradesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetaUpgradesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetaUpgradesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetaUpgradesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> perkId = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MetaUpgradesCompanion(
                perkId: perkId,
                level: level,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String perkId,
                Value<int> level = const Value.absent(),
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MetaUpgradesCompanion.insert(
                perkId: perkId,
                level: level,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetaUpgradesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MetaUpgradesTable,
      MetaUpgradeRow,
      $$MetaUpgradesTableFilterComposer,
      $$MetaUpgradesTableOrderingComposer,
      $$MetaUpgradesTableAnnotationComposer,
      $$MetaUpgradesTableCreateCompanionBuilder,
      $$MetaUpgradesTableUpdateCompanionBuilder,
      (
        MetaUpgradeRow,
        BaseReferences<_$AppDatabase, $MetaUpgradesTable, MetaUpgradeRow>,
      ),
      MetaUpgradeRow,
      PrefetchHooks Function()
    >;
typedef $$TournamentsTableCreateCompanionBuilder =
    TournamentsCompanion Function({
      required String id,
      required String cadence,
      required String state,
      required String name,
      Value<String> tagline,
      required int startsAt,
      required int endsAt,
      required int seed,
      Value<String> configJson,
      Value<int> entryFeeCoins,
      Value<String> rewardTableJson,
      Value<bool> joined,
      Value<bool> paid,
      Value<int> bestScore,
      Value<int?> rank,
      Value<int?> rewardCoins,
      Value<bool> rewardClaimed,
      Value<int> lastSyncedAt,
      Value<int> rowid,
    });
typedef $$TournamentsTableUpdateCompanionBuilder =
    TournamentsCompanion Function({
      Value<String> id,
      Value<String> cadence,
      Value<String> state,
      Value<String> name,
      Value<String> tagline,
      Value<int> startsAt,
      Value<int> endsAt,
      Value<int> seed,
      Value<String> configJson,
      Value<int> entryFeeCoins,
      Value<String> rewardTableJson,
      Value<bool> joined,
      Value<bool> paid,
      Value<int> bestScore,
      Value<int?> rank,
      Value<int?> rewardCoins,
      Value<bool> rewardClaimed,
      Value<int> lastSyncedAt,
      Value<int> rowid,
    });

class $$TournamentsTableFilterComposer
    extends Composer<_$AppDatabase, $TournamentsTable> {
  $$TournamentsTableFilterComposer({
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

  ColumnFilters<String> get cadence => $composableBuilder(
    column: $table.cadence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagline => $composableBuilder(
    column: $table.tagline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startsAt => $composableBuilder(
    column: $table.startsAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endsAt => $composableBuilder(
    column: $table.endsAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seed => $composableBuilder(
    column: $table.seed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entryFeeCoins => $composableBuilder(
    column: $table.entryFeeCoins,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rewardTableJson => $composableBuilder(
    column: $table.rewardTableJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get joined => $composableBuilder(
    column: $table.joined,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get paid => $composableBuilder(
    column: $table.paid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestScore => $composableBuilder(
    column: $table.bestScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rewardCoins => $composableBuilder(
    column: $table.rewardCoins,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get rewardClaimed => $composableBuilder(
    column: $table.rewardClaimed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TournamentsTableOrderingComposer
    extends Composer<_$AppDatabase, $TournamentsTable> {
  $$TournamentsTableOrderingComposer({
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

  ColumnOrderings<String> get cadence => $composableBuilder(
    column: $table.cadence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagline => $composableBuilder(
    column: $table.tagline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startsAt => $composableBuilder(
    column: $table.startsAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endsAt => $composableBuilder(
    column: $table.endsAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seed => $composableBuilder(
    column: $table.seed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entryFeeCoins => $composableBuilder(
    column: $table.entryFeeCoins,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rewardTableJson => $composableBuilder(
    column: $table.rewardTableJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get joined => $composableBuilder(
    column: $table.joined,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get paid => $composableBuilder(
    column: $table.paid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestScore => $composableBuilder(
    column: $table.bestScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rewardCoins => $composableBuilder(
    column: $table.rewardCoins,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get rewardClaimed => $composableBuilder(
    column: $table.rewardClaimed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TournamentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TournamentsTable> {
  $$TournamentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cadence =>
      $composableBuilder(column: $table.cadence, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get tagline =>
      $composableBuilder(column: $table.tagline, builder: (column) => column);

  GeneratedColumn<int> get startsAt =>
      $composableBuilder(column: $table.startsAt, builder: (column) => column);

  GeneratedColumn<int> get endsAt =>
      $composableBuilder(column: $table.endsAt, builder: (column) => column);

  GeneratedColumn<int> get seed =>
      $composableBuilder(column: $table.seed, builder: (column) => column);

  GeneratedColumn<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get entryFeeCoins => $composableBuilder(
    column: $table.entryFeeCoins,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rewardTableJson => $composableBuilder(
    column: $table.rewardTableJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get joined =>
      $composableBuilder(column: $table.joined, builder: (column) => column);

  GeneratedColumn<bool> get paid =>
      $composableBuilder(column: $table.paid, builder: (column) => column);

  GeneratedColumn<int> get bestScore =>
      $composableBuilder(column: $table.bestScore, builder: (column) => column);

  GeneratedColumn<int> get rank =>
      $composableBuilder(column: $table.rank, builder: (column) => column);

  GeneratedColumn<int> get rewardCoins => $composableBuilder(
    column: $table.rewardCoins,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get rewardClaimed => $composableBuilder(
    column: $table.rewardClaimed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$TournamentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TournamentsTable,
          TournamentRow,
          $$TournamentsTableFilterComposer,
          $$TournamentsTableOrderingComposer,
          $$TournamentsTableAnnotationComposer,
          $$TournamentsTableCreateCompanionBuilder,
          $$TournamentsTableUpdateCompanionBuilder,
          (
            TournamentRow,
            BaseReferences<_$AppDatabase, $TournamentsTable, TournamentRow>,
          ),
          TournamentRow,
          PrefetchHooks Function()
        > {
  $$TournamentsTableTableManager(_$AppDatabase db, $TournamentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TournamentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TournamentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TournamentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> cadence = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> tagline = const Value.absent(),
                Value<int> startsAt = const Value.absent(),
                Value<int> endsAt = const Value.absent(),
                Value<int> seed = const Value.absent(),
                Value<String> configJson = const Value.absent(),
                Value<int> entryFeeCoins = const Value.absent(),
                Value<String> rewardTableJson = const Value.absent(),
                Value<bool> joined = const Value.absent(),
                Value<bool> paid = const Value.absent(),
                Value<int> bestScore = const Value.absent(),
                Value<int?> rank = const Value.absent(),
                Value<int?> rewardCoins = const Value.absent(),
                Value<bool> rewardClaimed = const Value.absent(),
                Value<int> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TournamentsCompanion(
                id: id,
                cadence: cadence,
                state: state,
                name: name,
                tagline: tagline,
                startsAt: startsAt,
                endsAt: endsAt,
                seed: seed,
                configJson: configJson,
                entryFeeCoins: entryFeeCoins,
                rewardTableJson: rewardTableJson,
                joined: joined,
                paid: paid,
                bestScore: bestScore,
                rank: rank,
                rewardCoins: rewardCoins,
                rewardClaimed: rewardClaimed,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cadence,
                required String state,
                required String name,
                Value<String> tagline = const Value.absent(),
                required int startsAt,
                required int endsAt,
                required int seed,
                Value<String> configJson = const Value.absent(),
                Value<int> entryFeeCoins = const Value.absent(),
                Value<String> rewardTableJson = const Value.absent(),
                Value<bool> joined = const Value.absent(),
                Value<bool> paid = const Value.absent(),
                Value<int> bestScore = const Value.absent(),
                Value<int?> rank = const Value.absent(),
                Value<int?> rewardCoins = const Value.absent(),
                Value<bool> rewardClaimed = const Value.absent(),
                Value<int> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TournamentsCompanion.insert(
                id: id,
                cadence: cadence,
                state: state,
                name: name,
                tagline: tagline,
                startsAt: startsAt,
                endsAt: endsAt,
                seed: seed,
                configJson: configJson,
                entryFeeCoins: entryFeeCoins,
                rewardTableJson: rewardTableJson,
                joined: joined,
                paid: paid,
                bestScore: bestScore,
                rank: rank,
                rewardCoins: rewardCoins,
                rewardClaimed: rewardClaimed,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TournamentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TournamentsTable,
      TournamentRow,
      $$TournamentsTableFilterComposer,
      $$TournamentsTableOrderingComposer,
      $$TournamentsTableAnnotationComposer,
      $$TournamentsTableCreateCompanionBuilder,
      $$TournamentsTableUpdateCompanionBuilder,
      (
        TournamentRow,
        BaseReferences<_$AppDatabase, $TournamentsTable, TournamentRow>,
      ),
      TournamentRow,
      PrefetchHooks Function()
    >;
typedef $$TournamentLeaderboardCacheTableCreateCompanionBuilder =
    TournamentLeaderboardCacheCompanion Function({
      required String tournamentId,
      required int rank,
      required String userId,
      required String username,
      required int score,
      Value<bool> isPlayer,
      Value<int> rowid,
    });
typedef $$TournamentLeaderboardCacheTableUpdateCompanionBuilder =
    TournamentLeaderboardCacheCompanion Function({
      Value<String> tournamentId,
      Value<int> rank,
      Value<String> userId,
      Value<String> username,
      Value<int> score,
      Value<bool> isPlayer,
      Value<int> rowid,
    });

class $$TournamentLeaderboardCacheTableFilterComposer
    extends Composer<_$AppDatabase, $TournamentLeaderboardCacheTable> {
  $$TournamentLeaderboardCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tournamentId => $composableBuilder(
    column: $table.tournamentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPlayer => $composableBuilder(
    column: $table.isPlayer,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TournamentLeaderboardCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $TournamentLeaderboardCacheTable> {
  $$TournamentLeaderboardCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tournamentId => $composableBuilder(
    column: $table.tournamentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPlayer => $composableBuilder(
    column: $table.isPlayer,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TournamentLeaderboardCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $TournamentLeaderboardCacheTable> {
  $$TournamentLeaderboardCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tournamentId => $composableBuilder(
    column: $table.tournamentId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rank =>
      $composableBuilder(column: $table.rank, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<bool> get isPlayer =>
      $composableBuilder(column: $table.isPlayer, builder: (column) => column);
}

class $$TournamentLeaderboardCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TournamentLeaderboardCacheTable,
          TournamentLeaderboardRow,
          $$TournamentLeaderboardCacheTableFilterComposer,
          $$TournamentLeaderboardCacheTableOrderingComposer,
          $$TournamentLeaderboardCacheTableAnnotationComposer,
          $$TournamentLeaderboardCacheTableCreateCompanionBuilder,
          $$TournamentLeaderboardCacheTableUpdateCompanionBuilder,
          (
            TournamentLeaderboardRow,
            BaseReferences<
              _$AppDatabase,
              $TournamentLeaderboardCacheTable,
              TournamentLeaderboardRow
            >,
          ),
          TournamentLeaderboardRow,
          PrefetchHooks Function()
        > {
  $$TournamentLeaderboardCacheTableTableManager(
    _$AppDatabase db,
    $TournamentLeaderboardCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TournamentLeaderboardCacheTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TournamentLeaderboardCacheTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TournamentLeaderboardCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> tournamentId = const Value.absent(),
                Value<int> rank = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<bool> isPlayer = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TournamentLeaderboardCacheCompanion(
                tournamentId: tournamentId,
                rank: rank,
                userId: userId,
                username: username,
                score: score,
                isPlayer: isPlayer,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String tournamentId,
                required int rank,
                required String userId,
                required String username,
                required int score,
                Value<bool> isPlayer = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TournamentLeaderboardCacheCompanion.insert(
                tournamentId: tournamentId,
                rank: rank,
                userId: userId,
                username: username,
                score: score,
                isPlayer: isPlayer,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TournamentLeaderboardCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TournamentLeaderboardCacheTable,
      TournamentLeaderboardRow,
      $$TournamentLeaderboardCacheTableFilterComposer,
      $$TournamentLeaderboardCacheTableOrderingComposer,
      $$TournamentLeaderboardCacheTableAnnotationComposer,
      $$TournamentLeaderboardCacheTableCreateCompanionBuilder,
      $$TournamentLeaderboardCacheTableUpdateCompanionBuilder,
      (
        TournamentLeaderboardRow,
        BaseReferences<
          _$AppDatabase,
          $TournamentLeaderboardCacheTable,
          TournamentLeaderboardRow
        >,
      ),
      TournamentLeaderboardRow,
      PrefetchHooks Function()
    >;
typedef $$CosmeticOwnedTableCreateCompanionBuilder =
    CosmeticOwnedCompanion Function({
      required String cosmeticId,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$CosmeticOwnedTableUpdateCompanionBuilder =
    CosmeticOwnedCompanion Function({
      Value<String> cosmeticId,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$CosmeticOwnedTableFilterComposer
    extends Composer<_$AppDatabase, $CosmeticOwnedTable> {
  $$CosmeticOwnedTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cosmeticId => $composableBuilder(
    column: $table.cosmeticId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CosmeticOwnedTableOrderingComposer
    extends Composer<_$AppDatabase, $CosmeticOwnedTable> {
  $$CosmeticOwnedTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cosmeticId => $composableBuilder(
    column: $table.cosmeticId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CosmeticOwnedTableAnnotationComposer
    extends Composer<_$AppDatabase, $CosmeticOwnedTable> {
  $$CosmeticOwnedTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cosmeticId => $composableBuilder(
    column: $table.cosmeticId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CosmeticOwnedTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CosmeticOwnedTable,
          CosmeticOwnedRow,
          $$CosmeticOwnedTableFilterComposer,
          $$CosmeticOwnedTableOrderingComposer,
          $$CosmeticOwnedTableAnnotationComposer,
          $$CosmeticOwnedTableCreateCompanionBuilder,
          $$CosmeticOwnedTableUpdateCompanionBuilder,
          (
            CosmeticOwnedRow,
            BaseReferences<
              _$AppDatabase,
              $CosmeticOwnedTable,
              CosmeticOwnedRow
            >,
          ),
          CosmeticOwnedRow,
          PrefetchHooks Function()
        > {
  $$CosmeticOwnedTableTableManager(_$AppDatabase db, $CosmeticOwnedTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CosmeticOwnedTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CosmeticOwnedTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CosmeticOwnedTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cosmeticId = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CosmeticOwnedCompanion(
                cosmeticId: cosmeticId,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cosmeticId,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CosmeticOwnedCompanion.insert(
                cosmeticId: cosmeticId,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CosmeticOwnedTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CosmeticOwnedTable,
      CosmeticOwnedRow,
      $$CosmeticOwnedTableFilterComposer,
      $$CosmeticOwnedTableOrderingComposer,
      $$CosmeticOwnedTableAnnotationComposer,
      $$CosmeticOwnedTableCreateCompanionBuilder,
      $$CosmeticOwnedTableUpdateCompanionBuilder,
      (
        CosmeticOwnedRow,
        BaseReferences<_$AppDatabase, $CosmeticOwnedTable, CosmeticOwnedRow>,
      ),
      CosmeticOwnedRow,
      PrefetchHooks Function()
    >;
typedef $$CosmeticEquippedTableCreateCompanionBuilder =
    CosmeticEquippedCompanion Function({
      required String slot,
      required String cosmeticId,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$CosmeticEquippedTableUpdateCompanionBuilder =
    CosmeticEquippedCompanion Function({
      Value<String> slot,
      Value<String> cosmeticId,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$CosmeticEquippedTableFilterComposer
    extends Composer<_$AppDatabase, $CosmeticEquippedTable> {
  $$CosmeticEquippedTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cosmeticId => $composableBuilder(
    column: $table.cosmeticId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CosmeticEquippedTableOrderingComposer
    extends Composer<_$AppDatabase, $CosmeticEquippedTable> {
  $$CosmeticEquippedTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cosmeticId => $composableBuilder(
    column: $table.cosmeticId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CosmeticEquippedTableAnnotationComposer
    extends Composer<_$AppDatabase, $CosmeticEquippedTable> {
  $$CosmeticEquippedTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  GeneratedColumn<String> get cosmeticId => $composableBuilder(
    column: $table.cosmeticId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CosmeticEquippedTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CosmeticEquippedTable,
          CosmeticEquippedRow,
          $$CosmeticEquippedTableFilterComposer,
          $$CosmeticEquippedTableOrderingComposer,
          $$CosmeticEquippedTableAnnotationComposer,
          $$CosmeticEquippedTableCreateCompanionBuilder,
          $$CosmeticEquippedTableUpdateCompanionBuilder,
          (
            CosmeticEquippedRow,
            BaseReferences<
              _$AppDatabase,
              $CosmeticEquippedTable,
              CosmeticEquippedRow
            >,
          ),
          CosmeticEquippedRow,
          PrefetchHooks Function()
        > {
  $$CosmeticEquippedTableTableManager(
    _$AppDatabase db,
    $CosmeticEquippedTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CosmeticEquippedTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CosmeticEquippedTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CosmeticEquippedTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> slot = const Value.absent(),
                Value<String> cosmeticId = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CosmeticEquippedCompanion(
                slot: slot,
                cosmeticId: cosmeticId,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String slot,
                required String cosmeticId,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CosmeticEquippedCompanion.insert(
                slot: slot,
                cosmeticId: cosmeticId,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CosmeticEquippedTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CosmeticEquippedTable,
      CosmeticEquippedRow,
      $$CosmeticEquippedTableFilterComposer,
      $$CosmeticEquippedTableOrderingComposer,
      $$CosmeticEquippedTableAnnotationComposer,
      $$CosmeticEquippedTableCreateCompanionBuilder,
      $$CosmeticEquippedTableUpdateCompanionBuilder,
      (
        CosmeticEquippedRow,
        BaseReferences<
          _$AppDatabase,
          $CosmeticEquippedTable,
          CosmeticEquippedRow
        >,
      ),
      CosmeticEquippedRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlayerProfilesTableTableManager get playerProfiles =>
      $$PlayerProfilesTableTableManager(_db, _db.playerProfiles);
  $$PlayerStatsTableTableTableManager get playerStatsTable =>
      $$PlayerStatsTableTableTableManager(_db, _db.playerStatsTable);
  $$StatCountersTableTableManager get statCounters =>
      $$StatCountersTableTableManager(_db, _db.statCounters);
  $$CoinLedgerEntriesTableTableManager get coinLedgerEntries =>
      $$CoinLedgerEntriesTableTableManager(_db, _db.coinLedgerEntries);
  $$CoinBalancesTableTableManager get coinBalances =>
      $$CoinBalancesTableTableManager(_db, _db.coinBalances);
  $$RunsTableTableManager get runs => $$RunsTableTableManager(_db, _db.runs);
  $$AchievementStatesTableTableManager get achievementStates =>
      $$AchievementStatesTableTableManager(_db, _db.achievementStates);
  $$DailyLoginClaimsTableTableManager get dailyLoginClaims =>
      $$DailyLoginClaimsTableTableManager(_db, _db.dailyLoginClaims);
  $$ChallengeAttemptsTableTableManager get challengeAttempts =>
      $$ChallengeAttemptsTableTableManager(_db, _db.challengeAttempts);
  $$LeaderboardCacheEntriesTableTableManager get leaderboardCacheEntries =>
      $$LeaderboardCacheEntriesTableTableManager(
        _db,
        _db.leaderboardCacheEntries,
      );
  $$LeaderboardSyncMetaTableTableManager get leaderboardSyncMeta =>
      $$LeaderboardSyncMetaTableTableManager(_db, _db.leaderboardSyncMeta);
  $$SettingsEntriesTableTableManager get settingsEntries =>
      $$SettingsEntriesTableTableManager(_db, _db.settingsEntries);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db, _db.syncOutbox);
  $$MetaUpgradesTableTableManager get metaUpgrades =>
      $$MetaUpgradesTableTableManager(_db, _db.metaUpgrades);
  $$TournamentsTableTableManager get tournaments =>
      $$TournamentsTableTableManager(_db, _db.tournaments);
  $$TournamentLeaderboardCacheTableTableManager
  get tournamentLeaderboardCache =>
      $$TournamentLeaderboardCacheTableTableManager(
        _db,
        _db.tournamentLeaderboardCache,
      );
  $$CosmeticOwnedTableTableManager get cosmeticOwned =>
      $$CosmeticOwnedTableTableManager(_db, _db.cosmeticOwned);
  $$CosmeticEquippedTableTableManager get cosmeticEquipped =>
      $$CosmeticEquippedTableTableManager(_db, _db.cosmeticEquipped);
}
