import 'package:hasicx/core/index.dart';

class PlayerViewModel extends ViewStateProvider {
  bool _isCurrentSongFav =
      getIt<MusicPlayerProvider>().isPlayingSongMarkedFavourite;
  bool get isCurrentSongFav => _isCurrentSongFav;
  set setIsCurrentSongFav(bool value) {
    _isCurrentSongFav = value;
    notifyListeners();
  }

  bool get isQueueEmpty =>
      getIt<MusicPlayerProvider>().currentPlayingSongs.isEmpty;

  bool _showQueue = false;
  bool get showQueue => _showQueue;
  set showQueue(bool value) {
    _showQueue = value;
    notifyListeners();
  }

  void toggleQueueVisibility() {
    _showQueue = !showQueue;
    notifyListeners();
  }
}
