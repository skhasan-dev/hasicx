import 'package:hasicx/core/index.dart';

class HomeViewModel extends ViewStateProvider {
  final musicPlayerProvider = getIt<MusicPlayerProvider>();

  List<Song> get allSongs => musicPlayerProvider.allSongs;
}
