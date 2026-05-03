import 'package:hasicx/core/index.dart'
    show
        ViewStateProvider,
        Song,
        Failure,
        ViewState,
        LocalRepository,
        getIt,
        Playlist,
        AppFailure;

class PlaylistSongsViewModel extends ViewStateProvider {
  final LocalRepository _localRepository = getIt<LocalRepository>();

  List<Song> _songs = [];
  List<Song> get songs => _songs;
  set songs(List<Song> list) {
    _songs = list;
    notifyListeners();
  }

  Future<Failure?> addSongsPlaylist(
    Playlist? playlist,
    List<Song> songs,
  ) async {
    Failure? failure;

    if (playlist == null) {
      return AppFailure('Playlist not found');
    }

    setViewState(ViewState.busy);

    final result = await _localRepository.addSongsToPlaylist(
      playlistId: playlist.id,
      songs: songs,
    );

    result.fold((e) => failure = e, (r) async {
      {
        await getSongs(playlist.name);
      }
    });

    setViewState(ViewState.complete);

    return failure;
  }

  Future<Failure?> removeSong(Playlist? playlist, Song song) async {
    Failure? failure;

    if (playlist == null) {
      return AppFailure('Playlist not found');
    }

    setViewState(ViewState.busy);

    final result = await _localRepository.removeSongFromPlaylist(
      playlistId: playlist.id,
      songId: song.id,
    );

    result.fold((e) => failure = e, (r) async {
      {
        await getSongs(playlist.name);
      }
    });

    setViewState(ViewState.complete);

    return failure;
  }

  Future<Failure?> getSongs(String playlistName) async {
    Failure? failure;

    setViewState(ViewState.busy);

    final result = await _localRepository.getSongsByPlaylist(playlistName);

    result.fold((e) => failure = e, (r) async {
      {
        songs = r;
      }
    });

    setViewState(ViewState.complete);

    return failure;
  }
}
