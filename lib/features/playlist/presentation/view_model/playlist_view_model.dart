import 'package:hasicx/core/index.dart'
    show
        ViewStateProvider,
        LocalRepository,
        getIt,
        ViewState,
        Failure,
        Playlist;

class PlaylistViewModel extends ViewStateProvider {
  final LocalRepository _localRepository = getIt<LocalRepository>();

  List<Playlist> _playlists = [];
  List<Playlist> get playlists => _playlists;
  set playlists(List<Playlist> list) {
    _playlists = list;
    notifyListeners();
  }

  Future<Failure?> addPlaylist(String name) async {
    Failure? failure;

    setViewState(ViewState.busy);

    final result = await _localRepository.addPlaylist(name);

    result.fold((e) => failure = e, (r) async {
      await getPlaylists(showLoading: false);
    });

    setViewState(ViewState.complete);

    return failure;
  }

  Future<Failure?> deletePlaylist(Playlist playlist) async {
    Failure? failure;

    setViewState(ViewState.busy);

    final result = await _localRepository.deletePlaylist(playlist.id);

    result.fold((e) => failure = e, (r) async {
      await getPlaylists(showLoading: false);
    });

    setViewState(ViewState.complete);

    return failure;
  }

  Future<Failure?> getPlaylists({bool showLoading = true}) async {
    Failure? failure;

    if (showLoading) setViewState(ViewState.busy);

    final result = await _localRepository.getPlaylists();

    result.fold((e) => failure = e, (r) async {
      await getPlaylists(showLoading: false);
    });

    if (showLoading) setViewState(ViewState.complete);

    return failure;
  }
}
