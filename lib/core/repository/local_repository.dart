import 'package:fpdart/fpdart.dart';
import 'package:hasicx/core/index.dart' show Song, ResultFuture, Playlist;

abstract interface class LocalRepository {
  ResultFuture<Song> upsertSong(Song song);

  ResultFuture<List<Song>> upsertBulkSongs(List<Song> songs);

  ResultFuture<List<Song>> getAllSongs();

  ResultFuture<Unit> deleteSong(int songId);

  // ── Favourites ───────────────────────────────────────────────────────────

  ResultFuture<Unit> setFav({required Song? song, required bool isFav});

  ResultFuture<bool> getIsFav(int? songId);

  ResultFuture<List<Song>> getFavSongs();

  // ── Play history ─────────────────────────────────────────────────────────

  ResultFuture<Unit> recordPlay(int songId);

  // ── Playlists ────────────────────────────────────────────────────────────

  ResultFuture<Playlist> addPlaylist(String name);

  ResultFuture<List<Playlist>> getPlaylists();

  ResultFuture<Unit> deletePlaylist(int playlistId);

  // ── Membership ───────────────────────────────────────────────────────────

  ResultFuture<List<Song>> getSongsByPlaylist(String playlistName);

  ResultFuture<Unit> addSongToPlaylist({
    required Song song,
    required int playlistId,
    int position,
  });

  ResultFuture<Unit> addSongsToPlaylist({
    required List<Song> songs,
    required int playlistId,
    int startPosition = 0,
  });

  ResultFuture<Unit> removeSongFromPlaylist({
    required int songId,
    required int playlistId,
  });

  ResultFuture<List<Playlist>> getPlaylistsForSong(int songId);

  ResultFuture<int> getPlaylistCountForSong(int songId);

  // ── Settings ─────────────────────────────────────────────────────────────

  ResultFuture<Unit> setSetting({required String key, required String value});

  ResultFuture<String?> getSetting(String key);

  ResultFuture<Unit> deleteSetting(String key);
}
