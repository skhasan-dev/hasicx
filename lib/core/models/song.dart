class Song {
  final int id; // device media ID — PK in songs table
  final int? artworkId; // artwork_id — can differ from id
  final String name;
  final String? artist;
  final String? album;
  final String? uri;
  final bool isFav; // maps to is_fav INTEGER 0|1
  final int playCount; // maps to play_count
  final String? lastPlayedAt; // ISO8601 nullable

  // ── Not persisted in songs table ─────────────────────────────────────────
  // Populated at the call site when you need to know which playlist context
  // a song was loaded from (e.g. for display or removal). Not stored in DB.
  final int? playlistId;

  const Song({
    required this.id,
    this.artworkId,
    required this.name,
    this.artist,
    this.album,
    this.uri,
    this.isFav = false,
    this.playCount = 0,
    this.lastPlayedAt,
    this.playlistId,
  });

  // ── fromJson ──────────────────────────────────────────────────────────────
  // Handles both v2 DB rows and device media query maps.

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: _parseInt(json['id']) ?? 0,
      artworkId: _parseInt(json['artwork_id']),
      name: json['name']?.toString() ?? '',
      artist: json['artist']?.toString(),
      album: json['album']?.toString(),
      uri: json['uri']?.toString(),
      isFav: _parseBool(json['is_fav']),
      playCount: _parseInt(json['play_count']) ?? 0,
      lastPlayedAt: json['last_played_at']?.toString(),
      playlistId: _parseInt(json['playlist_id']),
    );
  }

  // ── toJson ────────────────────────────────────────────────────────────────
  // Only includes columns that live in the songs table.
  // playlistId is intentionally excluded — the junction table owns that link.

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'artwork_id': artworkId ?? id,
      'name': name,
      'artist': artist,
      'album': album,
      'uri': uri,
      'is_fav': isFav ? 1 : 0,
      'play_count': playCount,
      'last_played_at': lastPlayedAt,
    };
  }

  // ── copyWith ──────────────────────────────────────────────────────────────

  Song copyWith({
    int? id,
    int? artworkId,
    String? name,
    String? artist,
    String? album,
    String? uri,
    bool? isFav,
    int? playCount,
    String? lastPlayedAt,
    int? playlistId,
  }) {
    return Song(
      id: id ?? this.id,
      artworkId: artworkId ?? this.artworkId,
      name: name ?? this.name,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      uri: uri ?? this.uri,
      isFav: isFav ?? this.isFav,
      playCount: playCount ?? this.playCount,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      playlistId: playlistId ?? this.playlistId,
    );
  }

  // ── Equality ──────────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Song && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Song(id: $id, name: $name, artist: $artist, isFav: $isFav, playCount: $playCount)';

  // ── Helpers ───────────────────────────────────────────────────────────────

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value == 'true';
    return false;
  }
}
