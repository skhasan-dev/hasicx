import 'package:hasicx/core/index.dart';

class SearchViewModel extends ViewStateProvider {
  String? _query;
  String? get query => _query;
  set query(String value) {
    _query = value;
  }

  List<Song> _result = [];
  List<Song> get result => _result;
  set result(List<Song> songs) {
    _result = songs;
    notifyListeners();
  }

  void search(String value) {
    result = getIt<MusicPlayerProvider>().allSongs
        .where((s) => s.name.toLowerCase().contains(value.toLowerCase()))
        .toList();
  }
}
