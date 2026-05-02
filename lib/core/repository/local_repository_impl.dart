import 'package:fpdart/fpdart.dart';
import 'package:hasicx/core/index.dart'
    show
        Song,
        LocalDatabase,
        DatabaseFailure,
        SongNotFound,
        Playlist,
        PlaylistAlreadyExists,
        PlaylistNotFound,
        SongAlreadyInPlaylist,
        SongNotInPlaylist,
        UnexpectedDatabaseFailure,
        ResultFuture,
        LocalRepository;

class LocalRepositoryImpl implements LocalRepository {
  final LocalDatabase _db = LocalDatabase.getInstance();

  // ─── Guard ────────────────────────────────────────────────────────────────

  ResultFuture<T> _guard<T>(Future<T> Function() call) async {
    try {
      return Right(await call());
    } on DatabaseFailure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnexpectedDatabaseFailure(e.toString()));
    }
  }

  // ─── Songs ────────────────────────────────────────────────────────────────

  @override
  ResultFuture<Song> upsertSong(Song? song) async {
    if (song == null) {
      return const Left(SongNotFound('Cannot upsert a song with no id.'));
    }

    return _guard(() async {
      await _db.upsertSong(song: song.toJson());
      return song;
    });
  }

  @override
  ResultFuture<List<Song>> upsertBulkSongs(List<Song> songs) async {
    if (songs.isEmpty) return const Right([]);

    return _guard(() async {
      await _db.upsertBulkSongs(songs: songs.map((s) => s.toJson()).toList());
      return songs;
    });
  }

  @override
  ResultFuture<List<Song>> getAllSongs() async {
    return _guard(() async {
      final rows = await _db.getAllSongs();
      return rows.map(_rowToSong).whereType<Song>().toList();
    });
  }

  @override
  ResultFuture<Unit> deleteSong(int? songId) async {
    if (songId == null) return const Left(SongNotFound());

    return _guard(() async {
      final deleted = await _db.deleteSong(songId: songId);
      if (!deleted) throw const SongNotFound();
      return unit;
    });
  }

  // ─── Favourites ───────────────────────────────────────────────────────────

  @override
  ResultFuture<Unit> setFav({required int? songId, required bool isFav}) async {
    if (songId == null) {
      return const Left(SongNotFound('Cannot set fav on a song with no id.'));
    }

    return _guard(() async {
      final updated = await _db.setFav(songId: songId, isFav: isFav);
      if (!updated) {
        throw const SongNotFound('Song not found to update fav state.');
      }
      return unit;
    });
  }

  @override
  ResultFuture<bool> getIsFav(int? songId) async {
    if (songId == null) return const Left(SongNotFound());

    return _guard(() => _db.getIsFav(songId: songId));
  }

  @override
  ResultFuture<List<Song>> getFavSongs() async {
    return _guard(() async {
      final rows = await _db.getFavSongs();
      return rows.map(_rowToSong).whereType<Song>().toList();
    });
  }

  // ─── Play history ─────────────────────────────────────────────────────────

  @override
  ResultFuture<Unit> recordPlay(int? songId) async {
    if (songId == null) return const Left(SongNotFound());

    return _guard(() async {
      await _db.recordPlay(songId: songId);
      return unit;
    });
  }

  // ─── Playlists ────────────────────────────────────────────────────────────

  @override
  ResultFuture<Playlist> addPlaylist(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const Left(
        UnexpectedDatabaseFailure('Playlist name cannot be empty.'),
      );
    }

    return _guard(() async {
      final created = await _db.addPlaylist(name: trimmed);
      if (!created) throw const PlaylistAlreadyExists();

      // Re-fetch to get the auto-generated id from DB
      final all = await _db.getPlaylists();
      final matchRow = all.firstWhere(
        (r) => r[LocalDatabase.colPlaylistName] == trimmed,
        orElse: () => throw const PlaylistNotFound(
          'Playlist was created but could not be retrieved.',
        ),
      );

      return _rowToPlaylist(matchRow) ?? (throw const PlaylistNotFound());
    });
  }

  @override
  ResultFuture<List<Playlist>> getPlaylists() async {
    return _guard(() async {
      final rows = await _db.getPlaylists();
      return rows.map(_rowToPlaylist).whereType<Playlist>().toList();
    });
  }

  @override
  ResultFuture<Unit> deletePlaylist(int? playlistId) async {
    if (playlistId == null) return const Left(PlaylistNotFound());

    return _guard(() async {
      final deleted = await _db.deletePlaylist(playlistId: playlistId);
      if (!deleted) throw const PlaylistNotFound();
      return unit;
    });
  }

  // ─── Membership ───────────────────────────────────────────────────────────

  @override
  ResultFuture<List<Song>> getSongsByPlaylist(String playlistName) async {
    return _guard(() async {
      final rows = await _db.getSongsByPlaylist(playlistName: playlistName);
      return rows.map(_rowToSong).whereType<Song>().toList();
    });
  }

  @override
  ResultFuture<Unit> addSongToPlaylist({
    required Song? song,
    required int? playlistId,
    int position = 0,
  }) async {
    if (song == null) {
      return const Left(
        SongNotFound('Cannot add a song with no id to a playlist.'),
      );
    }
    if (playlistId == null) return const Left(PlaylistNotFound());

    return _guard(() async {
      await _db.upsertSong(song: song.toJson());

      final added = await _db.addSongToPlaylist(
        songId: song.id,
        playlistId: playlistId,
        position: position,
      );
      if (!added) throw const SongAlreadyInPlaylist();
      return unit;
    });
  }

  @override
  ResultFuture<Unit> addSongsToPlaylist({
    required List<Song>? songs,
    required int? playlistId,
    int startPosition = 0,
  }) async {
    if (songs == null || songs.isEmpty) {
      return const Left(SongNotFound('No songs provided to add to playlist.'));
    }
    if (playlistId == null) return const Left(PlaylistNotFound());

    return _guard(() async {
      await _db.upsertBulkSongs(songs: songs.map((s) => s.toJson()).toList());

      var failedCount = 0;

      for (var i = 0; i < songs.length; i++) {
        final added = await _db.addSongToPlaylist(
          songId: songs[i].id,
          playlistId: playlistId,
          position: startPosition + i,
        );
        if (!added) failedCount++;
      }

      if (failedCount == songs.length) throw const SongAlreadyInPlaylist();

      return unit;
    });
  }

  @override
  ResultFuture<Unit> removeSongFromPlaylist({
    required int? songId,
    required int? playlistId,
  }) async {
    if (songId == null) return const Left(SongNotFound());
    if (playlistId == null) return const Left(PlaylistNotFound());

    return _guard(() async {
      final removed = await _db.removeSongFromPlaylist(
        songId: songId,
        playlistId: playlistId,
      );
      if (!removed) throw const SongNotInPlaylist();
      return unit;
    });
  }

  @override
  ResultFuture<List<Playlist>> getPlaylistsForSong(int? songId) async {
    if (songId == null) return const Left(SongNotFound());

    return _guard(() async {
      final rows = await _db.getPlaylistsForSong(songId: songId);
      return rows.map(_rowToPlaylist).whereType<Playlist>().toList();
    });
  }

  @override
  ResultFuture<int> getPlaylistCountForSong(int? songId) async {
    if (songId == null) return const Left(SongNotFound());

    return _guard(() => _db.getPlaylistCountForSong(songId: songId));
  }

  // ─── Settings ─────────────────────────────────────────────────────────────

  @override
  ResultFuture<Unit> setSetting({
    required String key,
    required String value,
  }) async {
    return _guard(() async {
      await _db.setSetting(key: key, value: value);
      return unit;
    });
  }

  @override
  ResultFuture<String?> getSetting(String key) async {
    return _guard(() => _db.getSetting(key: key));
  }

  @override
  ResultFuture<Unit> deleteSetting(String key) async {
    return _guard(() async {
      await _db.deleteSetting(key: key);
      return unit;
    });
  }

  // ─── Row → Domain mappers ─────────────────────────────────────────────────
  //
  // These are the ONLY place Song and Playlist objects are constructed.
  // Any row missing critical fields returns null — callers use .whereType<T>()
  // to silently drop corrupt rows without crashing.

  /// Maps a raw DB row to a [Song].
  /// Returns null if [id], [name], or [uri] are missing/empty — those are
  /// the minimum fields for a usable song.
  Song? _rowToSong(Map<String, dynamic> row) {
    final id = _parseInt(row[LocalDatabase.colId]);
    final name = row[LocalDatabase.colName]?.toString();
    final uri = row[LocalDatabase.colUri]?.toString();

    if (id == null) return null;
    if (name == null || name.isEmpty) return null;
    if (uri == null || uri.isEmpty) return null;

    return Song(
      id: id,
      artworkId: _parseInt(row[LocalDatabase.colArtworkId]),
      name: name,
      artist: row[LocalDatabase.colArtist]?.toString(),
      album: row[LocalDatabase.colAlbum]?.toString(),
      uri: uri,
      isFav: _parseBool(row[LocalDatabase.colIsFav]),
      playCount: _parseInt(row[LocalDatabase.colPlayCount]) ?? 0,
      lastPlayedAt: row[LocalDatabase.colLastPlayedAt]?.toString(),
      // playlist_id is only present on JOIN queries (getSongsByPlaylist)
      playlistId: _parseInt(row[LocalDatabase.colPsPlaylistId]),
    );
  }

  Playlist? _rowToPlaylist(Map<String, dynamic> row) {
    final id = _parseInt(row[LocalDatabase.colPlaylistId]);
    final name = row[LocalDatabase.colPlaylistName]?.toString();

    if (id == null || id <= 0) return null;
    if (name == null || name.trim().isEmpty) return null;

    return Playlist(
      id: id,
      name: name,
      createdAt: row[LocalDatabase.colCreatedAt]?.toString(),
    );
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static bool _parseBool(dynamic v) {
    if (v is bool) return v;
    if (v is int) return v == 1;
    if (v is String) return v == '1' || v == 'true';
    return false;
  }
}
