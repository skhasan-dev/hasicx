import 'package:hasicx/core/index.dart';

class FavouritesViewModel extends ViewStateProvider {
  final LocalRepository _localRepository = getIt<LocalRepository>();

  List<Song> _favourites = [];
  List<Song> get favourites => _favourites;
  set favourites(List<Song> songs) {
    _favourites = songs;
    notifyListeners();
  }

  Future<Failure?> getSongs() async {
    Failure? failure;

    setViewState(ViewState.busy);

    final result = await _localRepository.getFavSongs();

    result.fold((e) => failure = e, (songs) {
      favourites = songs;
    });

    setViewState(ViewState.complete);

    return failure;
  }
}
