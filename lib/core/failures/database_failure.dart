import 'package:hasicx/core/index.dart' show Failure;

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);

  @override
  String toString() => '$runtimeType: $message';
}

// ── Song failures ──────────────────────────────────────────────────────────

final class SongNotFound extends DatabaseFailure {
  const SongNotFound([super.message = 'Song not found.']);
}

final class SongAlreadyExists extends DatabaseFailure {
  const SongAlreadyExists([super.message = 'Song already exists.']);
}

// ── Playlist failures ──────────────────────────────────────────────────────

final class PlaylistNotFound extends DatabaseFailure {
  const PlaylistNotFound([super.message = 'Playlist not found.']);
}

final class PlaylistAlreadyExists extends Failure {
  const PlaylistAlreadyExists([
    super.message = 'A playlist with this name already exists.',
  ]);
}

// ── Membership failures ────────────────────────────────────────────────────

final class SongAlreadyInPlaylist extends DatabaseFailure {
  const SongAlreadyInPlaylist([
    super.message = 'Song is already in this playlist.',
  ]);
}

final class SongNotInPlaylist extends DatabaseFailure {
  const SongNotInPlaylist([super.message = 'Song is not in this playlist.']);
}

// ── Generic failures ───────────────────────────────────────────────────────
final class UnexpectedDatabaseFailure extends Failure {
  const UnexpectedDatabaseFailure([
    super.message = 'An unexpected database error occurred.',
  ]);
}
