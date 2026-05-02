import 'package:hasicx/core/index.dart' show Song;
import 'package:on_audio_query/on_audio_query.dart';

extension SongModelExt on SongModel {
  Song get toSong => Song(
    id: id,
    name: displayNameWOExt,
    artist: artist,
    album: album,
    isFav: false,
    uri: uri,
  );
}

extension SongModelListExt on List<SongModel> {
  List<Song> get toSong => map((s) => s.toSong).toList();
}
