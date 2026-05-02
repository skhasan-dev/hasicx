import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Version history:
/// v1 — original schema (songs had playlist column, no junction table)
/// v2 — songs table is now standalone; playlist_songs junction table added;
///       is_fav moved to clean INTEGER; play_count + last_played_at added;
///       settings key-value table added.
class LocalDatabase {
  LocalDatabase._internal();

  // ─── Singleton ────────────────────────────────────────────────────────────

  static final LocalDatabase _instance = LocalDatabase._internal();

  static LocalDatabase getInstance() => _instance;

  // ─── Table names ──────────────────────────────────────────────────────────

  static const String _tableSongs = 'songs';
  static const String _tablePlaylists = 'playlists';
  static const String _tablePlaylistSongs = 'playlist_songs';
  static const String _tableSettings = 'settings';

  // ─── Column names — songs ─────────────────────────────────────────────────

  static const String colId = 'id'; // PK autoincrement (device media id)
  static const String colArtworkId = 'artwork_id';
  static const String colName = 'name';
  static const String colArtist = 'artist';
  static const String colAlbum = 'album';
  static const String colUri = 'uri';
  static const String colIsFav = 'is_fav'; // INTEGER 0 | 1
  static const String colPlayCount = 'play_count'; // INTEGER default 0
  static const String colLastPlayedAt =
      'last_played_at'; // TEXT ISO8601 nullable

  // ─── Column names — playlists ─────────────────────────────────────────────

  static const String colPlaylistId = 'id';
  static const String colPlaylistName = 'name';
  static const String colCreatedAt = 'created_at'; // TEXT ISO8601

  // ─── Column names — playlist_songs ────────────────────────────────────────

  static const String colPsId = 'id';
  static const String colPsSongId = 'song_id';
  static const String colPsPlaylistId = 'playlist_id';
  static const String colPsPosition = 'position'; // for manual ordering later

  // ─── Column names — settings ──────────────────────────────────────────────

  static const String colSettingKey = 'key';
  static const String colSettingValue = 'value';

  // ─── DB instance ──────────────────────────────────────────────────────────

  Database? _db;

  Future<Database> getDb() async {
    _db ??= await _openDb();
    return _db!;
  }

  Future<Database> _openDb() async {
    final Directory dir = await getApplicationCacheDirectory();
    final String path = join(dir.path, 'hasicx.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ─── Schema creation ──────────────────────────────────────────────────────

  Future<void> _onCreate(Database db, int version) async {
    await _createTablesV2(db);
  }

  Future<void> _createTablesV2(Database db) async {
    // Canonical song registry — one row per unique device song.
    // Removing from a playlist does NOT touch this table.
    await db.execute('''
      CREATE TABLE $_tableSongs (
        $colId          INTEGER PRIMARY KEY,
        $colArtworkId   INTEGER,
        $colName        TEXT    NOT NULL,
        $colArtist      TEXT,
        $colAlbum       TEXT,
        $colUri         TEXT    NOT NULL,
        $colIsFav       INTEGER NOT NULL DEFAULT 0,
        $colPlayCount   INTEGER NOT NULL DEFAULT 0,
        $colLastPlayedAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $_tablePlaylists (
        $colPlaylistId   INTEGER PRIMARY KEY AUTOINCREMENT,
        $colPlaylistName TEXT    NOT NULL UNIQUE,
        $colCreatedAt    TEXT    NOT NULL
      )
    ''');

    // Junction table — a song can belong to many playlists.
    await db.execute('''
      CREATE TABLE $_tablePlaylistSongs (
        $colPsId         INTEGER PRIMARY KEY AUTOINCREMENT,
        $colPsPlaylistId INTEGER NOT NULL,
        $colPsSongId     INTEGER NOT NULL,
        $colPsPosition   INTEGER NOT NULL DEFAULT 0,
        UNIQUE ($colPsPlaylistId, $colPsSongId),
        FOREIGN KEY ($colPsPlaylistId) REFERENCES $_tablePlaylists ($colPlaylistId) ON DELETE CASCADE,
        FOREIGN KEY ($colPsSongId)     REFERENCES $_tableSongs ($colId)             ON DELETE CASCADE
      )
    ''');

    // Flexible key-value store for user preferences.
    await db.execute('''
      CREATE TABLE $_tableSettings (
        $colSettingKey   TEXT PRIMARY KEY,
        $colSettingValue TEXT
      )
    ''');
  }

  // ─── Migration ────────────────────────────────────────────────────────────

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _migrateV1ToV2(db);
    }
  }

  /// Migrates data from the v1 flat schema to v2.
  /// Old tables are renamed for backup, new tables created fresh,
  /// then existing songs + playlists are migrated safely.
  Future<void> _migrateV1ToV2(Database db) async {
    // 1. Rename old tables to backup
    await db.execute('ALTER TABLE songs     RENAME TO songs_v1_backup');
    await db.execute('ALTER TABLE playlist  RENAME TO playlists_v1_backup');

    // 2. Create new schema
    await _createTablesV2(db);

    // 3. Migrate playlists
    final oldPlaylists = await db.query('playlists_v1_backup');
    for (final row in oldPlaylists) {
      await db.insert(_tablePlaylists, {
        colPlaylistName: row['playlist'] as String,
        colCreatedAt: DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // 4. Migrate songs
    // Old schema had playlist TEXT on each song row.
    // We insert the song once into songs, then link via playlist_songs.
    final oldSongs = await db.query('songs_v1_backup');
    for (final row in oldSongs) {
      final songId = row['artwork_id'] as int? ?? 0;
      final playlistName = row['playlist'] as String? ?? '';

      // Upsert into songs (ignore if already inserted from another playlist)
      await db.insert(_tableSongs, {
        colId: songId,
        colArtworkId: songId,
        colName: row['name'] ?? '',
        colArtist: row['artist'] ?? '',
        colAlbum: row['album'] ?? '',
        colUri: row['uri'] ?? '',
        colIsFav: _parseBool(row['fav']) ? 1 : 0,
        colPlayCount: 0,
        colLastPlayedAt: null,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

      // Link song to its playlist
      if (playlistName.isNotEmpty) {
        final plResult = await db.query(
          _tablePlaylists,
          columns: [colPlaylistId],
          where: '$colPlaylistName = ?',
          whereArgs: [playlistName],
        );

        if (plResult.isNotEmpty) {
          final playlistId = plResult.first[colPlaylistId] as int;
          await db.insert(_tablePlaylistSongs, {
            colPsPlaylistId: playlistId,
            colPsSongId: songId,
            colPsPosition: 0,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      }
    }

    // 5. Drop backup tables (comment these out if you want to keep them for safety)
    await db.execute('DROP TABLE IF EXISTS songs_v1_backup');
    await db.execute('DROP TABLE IF EXISTS playlists_v1_backup');
  }

  bool _parseBool(dynamic value) {
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value == 'true';
    return false;
  }

  // ─── Song methods ─────────────────────────────────────────────────────────
  Future<bool> upsertSong({required Map<String, dynamic> song}) async {
    final db = await getDb();

    final id = await db.insert(
      _tableSongs,
      song,
      conflictAlgorithm: ConflictAlgorithm.ignore, // song already exists → skip
    );

    return id > 0;
  }

  /// Upserts multiple songs into the registry in a single batch.
  Future<bool> upsertBulkSongs({
    required List<Map<String, dynamic>> songs,
  }) async {
    if (songs.isEmpty) return false;

    final db = await getDb();
    final batch = db.batch();

    for (final song in songs) {
      batch.insert(
        _tableSongs,
        song,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    final results = await batch.commit(noResult: false);
    return results.isNotEmpty;
  }

  /// Returns all songs that belong to [playlistName] via the junction table.
  Future<List<Map<String, dynamic>>> getSongsByPlaylist({
    required String playlistName,
  }) async {
    final db = await getDb();

    // JOIN songs → playlist_songs → playlists filtered by name
    final rows = await db.rawQuery(
      '''
      SELECT s.$colId,
             s.$colArtworkId,
             s.$colName,
             s.$colArtist,
             s.$colAlbum,
             s.$colUri,
             s.$colIsFav,
             s.$colPlayCount,
             ps.$colPsPosition
      FROM $_tableSongs s
      INNER JOIN $_tablePlaylistSongs ps ON ps.$colPsSongId = s.$colId
      INNER JOIN $_tablePlaylists     pl ON pl.$colPlaylistId = ps.$colPsPlaylistId
      WHERE pl.$colPlaylistName = ?
      ORDER BY ps.$colPsPosition ASC
    ''',
      [playlistName],
    );

    return rows;
  }

  /// Returns all songs across every playlist (distinct).
  Future<List<Map<String, dynamic>>> getAllSongs() async {
    final db = await getDb();
    final rows = await db.query(_tableSongs);
    return rows;
  }

  /// Returns all songs marked as favourite.
  Future<List<Map<String, dynamic>>> getFavSongs() async {
    final db = await getDb();

    final rows = await db.query(
      _tableSongs,
      where: '$colIsFav = ?',
      whereArgs: [1],
    );

    return rows;
  }

  /// Permanently deletes a song from the registry.
  /// Also removes it from all playlists via CASCADE.
  Future<bool> deleteSong({required int songId}) async {
    final db = await getDb();

    final deleted = await db.delete(
      _tableSongs,
      where: '$colId = ?',
      whereArgs: [songId],
    );

    return deleted > 0;
  }

  // ─── Favourite methods ────────────────────────────────────────────────────

  /// Toggles the favourite state of a song.
  /// The fav flag lives on the song row — removing a song from a playlist
  /// has zero effect on this value.
  Future<bool> setFav({required int songId, required bool isFav}) async {
    final db = await getDb();

    final updated = await db.update(
      _tableSongs,
      {colIsFav: isFav ? 1 : 0},
      where: '$colId = ?',
      whereArgs: [songId],
    );

    return updated > 0;
  }

  /// Returns whether a song is currently marked as favourite.
  Future<bool> getIsFav({required int songId}) async {
    final db = await getDb();

    final result = await db.query(
      _tableSongs,
      columns: [colIsFav],
      where: '$colId = ?',
      whereArgs: [songId],
    );

    if (result.isEmpty) return false;

    return result.first[colIsFav] == 1;
  }

  // ─── Play count methods ───────────────────────────────────────────────────

  /// Increments play count and records last played timestamp for a song.
  Future<void> recordPlay({required int songId}) async {
    final db = await getDb();

    await db.rawUpdate(
      '''
      UPDATE $_tableSongs
      SET $colPlayCount    = $colPlayCount + 1,
          $colLastPlayedAt = ?
      WHERE $colId = ?
    ''',
      [DateTime.now().toIso8601String(), songId],
    );
  }

  // ─── Playlist methods ─────────────────────────────────────────────────────

  /// Creates a new playlist. Returns false if name already exists.
  Future<bool> addPlaylist({required String name}) async {
    final db = await getDb();

    try {
      final id = await db.insert(_tablePlaylists, {
        colPlaylistName: name,
        colCreatedAt: DateTime.now().toIso8601String(),
      });
      return id > 0;
    } catch (_) {
      // UNIQUE constraint on name
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getPlaylists() async {
    final db = await getDb();

    final rows = await db.query(_tablePlaylists, orderBy: '$colCreatedAt ASC');

    return rows;
  }

  /// Deletes a playlist and its junction rows.
  /// Songs in the registry are NOT deleted — only the membership is removed.
  Future<bool> deletePlaylist({required int playlistId}) async {
    final db = await getDb();

    // Remove junction rows first
    await db.delete(
      _tablePlaylistSongs,
      where: '$colPsPlaylistId = ?',
      whereArgs: [playlistId],
    );

    final deleted = await db.delete(
      _tablePlaylists,
      where: '$colPlaylistId = ?',
      whereArgs: [playlistId],
    );

    return deleted > 0;
  }

  // ─── Playlist ↔ Song membership ───────────────────────────────────────────

  /// Links an existing song to a playlist.
  /// The song must already exist in the songs registry (call [upsertSong] first).
  Future<bool> addSongToPlaylist({
    required int songId,
    required int playlistId,
    int position = 0,
  }) async {
    final db = await getDb();

    try {
      final id = await db.insert(
        _tablePlaylistSongs,
        {
          colPsSongId: songId,
          colPsPlaylistId: playlistId,
          colPsPosition: position,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore, // already linked → skip
      );
      return id > 0;
    } catch (_) {
      return false;
    }
  }

  /// Convenience: upserts the song then links it to the playlist in one call.
  Future<bool> addSongToPlaylistFull({
    required Map<String, dynamic> song,
    required int playlistId,
    int position = 0,
  }) async {
    await upsertSong(song: song);
    return addSongToPlaylist(
      songId: song['id'],
      playlistId: playlistId,
      position: position,
    );
  }

  /// Removes a song from a specific playlist ONLY.
  /// The song row and its is_fav state are completely untouched.
  Future<bool> removeSongFromPlaylist({
    required int songId,
    required int playlistId,
  }) async {
    final db = await getDb();

    final deleted = await db.delete(
      _tablePlaylistSongs,
      where: '$colPsSongId = ? AND $colPsPlaylistId = ?',
      whereArgs: [songId, playlistId],
    );

    return deleted > 0;
  }

  /// Returns how many playlists a song currently belongs to.
  Future<int> getPlaylistCountForSong({required int songId}) async {
    final db = await getDb();

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM $_tablePlaylistSongs
      WHERE $colPsSongId = ?
    ''',
      [songId],
    );

    return (result.first['count'] as int?) ?? 0;
  }

  /// Returns all playlists a specific song belongs to.
  Future<List<Map<String, dynamic>>> getPlaylistsForSong({
    required int songId,
  }) async {
    final db = await getDb();

    final rows = await db.rawQuery(
      '''
      SELECT pl.*
      FROM $_tablePlaylists pl
      INNER JOIN $_tablePlaylistSongs ps ON ps.$colPsPlaylistId = pl.$colPlaylistId
      WHERE ps.$colPsSongId = ?
    ''',
      [songId],
    );

    return rows;
  }

  // ─── Settings methods ─────────────────────────────────────────────────────

  Future<void> setSetting({required String key, required String value}) async {
    final db = await getDb();

    await db.insert(_tableSettings, {
      colSettingKey: key,
      colSettingValue: value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getSetting({required String key}) async {
    final db = await getDb();

    final result = await db.query(
      _tableSettings,
      columns: [colSettingValue],
      where: '$colSettingKey = ?',
      whereArgs: [key],
    );

    if (result.isEmpty) return null;
    return result.first[colSettingValue] as String?;
  }

  Future<void> deleteSetting({required String key}) async {
    final db = await getDb();

    await db.delete(
      _tableSettings,
      where: '$colSettingKey = ?',
      whereArgs: [key],
    );
  }
}
