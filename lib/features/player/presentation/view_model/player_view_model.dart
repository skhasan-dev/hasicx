import 'package:hasicx/core/index.dart';

class PlayerViewModel extends ViewStateProvider {
  LocalDatabase database = LocalDatabase.getInstance();

  bool _isCurrentSongFav =
      getIt<MusicPlayerProvider>().isPlayingSongMarkedFavourite;
  bool get isCurrentSongFav => _isCurrentSongFav;
  set setIsCurrentSongFav(bool value) {
    _isCurrentSongFav = value;
    notifyListeners();
  }

  // Future<String?> toggleFav() async {
  //   setViewState(ViewState.busy);

  //   try {
  //     final isSucceed = await database.addToFav(
  //       uri: getIt<MusicPlayerProvider>().currentyPlaying.uri ?? '',
  //       toggle: isCurrentSongFav,
  //     );

  //     if (isSucceed) {
  //       database.getIsFav(
  //         uri: getIt<MusicPlayerProvider>().currentyPlaying.uri ?? '',
  //       );
  //     }
  //   } catch (e) {
  //     return e.toString();
  //   }

  //   setViewState(ViewState.complete);

  //   return null;
  // }
}
