import 'package:hasicx/core/index.dart'
    show
        AppFailure,
        Failure,
        LocalRepository,
        PlayerState,
        SharedPrefs,
        Song,
        SongModelListExt,
        ViewState,
        ViewStateProvider,
        getIt;
import 'package:just_audio/just_audio.dart' hide PlayerState;
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MusicPlayerProvider extends ViewStateProvider {
  MusicPlayerProvider() {
    // getSongs();
    initPlayer();
  }

  final LocalRepository _localRepository = getIt<LocalRepository>();

  final OnAudioQuery audioQuery = OnAudioQuery();
  final AudioPlayer player = AudioPlayer();

  PlayerState _playerState = PlayerState.idle;
  PlayerState get playerState => _playerState;
  void setPlayerState(PlayerState value) {
    _playerState = value;
    notifyListeners();
  }

  bool get isPlaying => playerState == PlayerState.playing;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  List<Song> _currentPlayingSongs = [];
  List<Song> get currentPlayingSongs => _currentPlayingSongs;
  set currentPlayingSongs(List<Song> songs) {
    _currentPlayingSongs = songs;
    notifyListeners();
  }

  bool get showListExpandButton => currentPlayingSongs.length > 1;

  // int currentIndexForRemainingSongs(int index) {
  //   final curr = remainingSongs[index];
  //   final song = currentPlayingSongs.firstWhereOrNull((s) => s.id == curr.id);
  //   return song != null ? currentPlayingSongs.indexOf(song) : index;
  // }

  // List<Song> get remainingSongs {
  //   final alreadyPlayed = currentPlayingSongs
  //       .getRange(0, currentIndex)
  //       .toList();
  //   final remainingToPlay = currentPlayingSongs.skip(currentIndex + 1).toList();
  //   return loopMode == LoopMode.all
  //       ? [...remainingToPlay, ...alreadyPlayed]
  //       : remainingToPlay;
  // }

  Song get currentyPlaying {
    // final length = currentPlayingSongs.length;
    // if (length == 0) {
    //   return null;
    // } else if (length == 1) {
    //   _currentIndex = 0;
    //   return currentPlayingSongs.first;
    // } else {
    //   return currentPlayingSongs[currentIndex];
    // }
    return currentPlayingSongs[currentIndex];
  }

  bool _isPlayingSongMarkedFavourite = false;
  bool get isPlayingSongMarkedFavourite => _isPlayingSongMarkedFavourite;
  set isPlayingSongMarkedFavourite(bool value) {
    _isPlayingSongMarkedFavourite = value;
    notifyListeners();
  }

  bool _isSelectedSongFavourite = false;
  bool get isSelectedSongFavourite => _isSelectedSongFavourite;
  set isSelectedSongFavourite(bool value) {
    _isSelectedSongFavourite = value;
    notifyListeners();
  }

  List<Song> _allSongs = [];
  List<Song> get allSongs => _allSongs;
  set allSongs(List<Song> songs) {
    _allSongs = songs;
    notifyListeners();
  }

  Future<Failure?> playSong(
    int index, {
    List<Song>? songs,
    bool setLoopMode = false,
  }) async {
    currentIndex = index;
    currentPlayingSongs = songs ?? currentPlayingSongs;
    if (setLoopMode) {
      loopMode = LoopMode.one;
      player.setLoopMode(loopMode);
    }
    try {
      await player.setAudioSources(
        currentPlayingSongs.map((song) {
          return AudioSource.uri(
            Uri.parse(song.uri!),
            tag: MediaItem(
              id: song.id.toString(),
              artist: song.artist,
              title: song.name,
            ),
          );
        }).toList(),
        initialIndex: index,
      );
      player.play();
      setPlayerState(PlayerState.playing);
      setTimes();
      getIsFav();
    } on Exception catch (e) {
      return AppFailure(e.toString());
    }

    return null;
  }

  Future<void> resumeSong() async {
    player.play();
    setPlayerState(PlayerState.playing);
  }

  Future<void> pauseSong() async {
    player.pause();
    setPlayerState(PlayerState.paused);
  }

  Future<void> playNext() async {
    if (player.hasNext) {
      player.seekToNext();
      // currentIndex = currentIndex + 1;
      getIsFav();
      if (!isPlaying) {
        resumeSong();
      }
    }
  }

  Future<void> playPrevious() async {
    if (player.hasPrevious) {
      player.seekToPrevious();
      // currentIndex = currentIndex - 1;
      getIsFav();
      if (!isPlaying) {
        resumeSong();
      }
    }
  }

  LoopMode _loopMode = SharedPrefs.getLoopMode() ?? LoopMode.all;
  LoopMode get loopMode => _loopMode;
  set loopMode(LoopMode mode) {
    setLoopMode(mode);
    _loopMode = mode;
    notifyListeners();
  }

  void setLoopMode(LoopMode mode) {
    player.setLoopMode(mode);
    SharedPrefs.setLoopMode(mode);
  }

  Future<String?> getSongs({
    OrderType? orderType,
    SongSortType? songSortType,
    UriType? uriType,
    bool? ignoreCase,
  }) async {
    setViewState(ViewState.busy);

    try {
      final songs = await audioQuery.querySongs(
        ignoreCase: ignoreCase ?? true,
        orderType: orderType ?? OrderType.ASC_OR_SMALLER,
        sortType: songSortType ?? SongSortType.DATE_ADDED,
        uriType: uriType ?? UriType.EXTERNAL,
      );

      allSongs = songs.toSong;
    } catch (e) {
      return e.toString();
    }

    setViewState(ViewState.complete);

    return null;
  }

  Future<Failure?> addToFav({Song? song}) async {
    Failure? failure;

    setViewState(ViewState.busy);

    final result = await _localRepository.setFav(
      isFav: song == null
          ? !isPlayingSongMarkedFavourite
          : !isSelectedSongFavourite,
      songId: song?.id ?? currentyPlaying.id,
    );

    result.fold((e) => failure = e, (r) {
      getIsFav();
    });

    setViewState(ViewState.complete);

    return failure;
  }

  Future<Failure?> getIsFav({Song? song}) async {
    Failure? failure;

    setViewState(ViewState.busy);

    final result = await _localRepository.getIsFav(
      (song ?? currentyPlaying).id,
    );
    result.fold((e) => failure = e, (r) {
      if (song == null) {
        isPlayingSongMarkedFavourite = r;
      } else {
        isSelectedSongFavourite = r;
      }
    });

    setViewState(ViewState.complete);

    return failure;
  }

  ///PLAYER SEEKER & CONTROL LOGIC
  String length = '';
  String currentTime = '';
  double maxSliderValue = 0.0;
  double currentSliderValue = 0.0;
  bool isUserDragging = false;

  void initPlayer() {
    player.setLoopMode(SharedPrefs.getLoopMode() ?? LoopMode.all);
    player.currentIndexStream.listen((index) async {
      if (index != null) {
        if (currentIndex != index) {
          currentIndex = index;
          await getIsFav();
        }
      }
    });
    player.playbackEventStream.listen((event) {
      final newState = _mapPlaybackStateToPlayerState(player.playing);
      if (_playerState != newState && _playerState != PlayerState.idle) {
        setPlayerState(newState);
      }
    });
  }

  PlayerState _mapPlaybackStateToPlayerState(bool isPlaying) {
    if (isPlaying) {
      return PlayerState.playing;
    } else {
      return PlayerState.paused;
    }
  }

  void startDragging() {
    isUserDragging = true;
  }

  void updateSliderUI(double value) {
    currentSliderValue = value;
    notifyListeners();
  }

  void seekTo(double value) {
    isUserDragging = false;
    player.seek(Duration(seconds: value.toInt()));
  }

  void setTimes() {
    player.durationStream.listen((d) {
      length = d.toString().split(".")[0];
      maxSliderValue = (d?.inSeconds ?? 0).toDouble();
      notifyListeners();
    });
    player.positionStream.listen((p) {
      if (!isUserDragging) {
        currentTime = p.toString().split(".")[0];
        currentSliderValue = p.inSeconds.toDouble();
        notifyListeners();
      }
    });
  }

  void skipForward(bool logic) {
    if (logic && (currentSliderValue + 10.0) < maxSliderValue) {
      player.seek(Duration(seconds: currentSliderValue.toInt() + 10));
    } else if (!logic && (currentSliderValue - 10.0) > 0) {
      player.seek(Duration(seconds: currentSliderValue.toInt() - 10));
    }
  }

  ///QUEUE MANAGEMENT
  Future<void> addToQueue(Song song, {bool atLast = true}) async {
    final updated = [...currentPlayingSongs];

    if (atLast) {
      updated.add(song);
    } else {
      updated.insert(currentIndex + 1, song);
    }

    currentPlayingSongs = updated;

    await _syncQueue(); // 🔥 critical
  }

  Future<void> removeFromQueue(int index) async {
    if (index < 0 || index >= currentPlayingSongs.length) return;

    final updated = [...currentPlayingSongs];

    updated.removeAt(index);

    // Adjust currentIndex safely
    if (index < currentIndex) {
      currentIndex -= 1;
    } else if (index == currentIndex) {
      // If current song removed → move to next valid index
      if (currentIndex >= updated.length) {
        currentIndex = updated.isEmpty ? 0 : updated.length - 1;
      }
    }

    currentPlayingSongs = updated;

    await _syncQueue();
  }

  Future<void> _syncQueue({bool keepPosition = true}) async {
    final currentPosition = player.position;
    final wasPlaying = player.playing;

    await player.setAudioSources(
      _buildSources(currentPlayingSongs),
      initialIndex: currentIndex,
      initialPosition: keepPosition ? currentPosition : Duration.zero,
    );

    if (wasPlaying) {
      await player.play();
    }
  }

  List<AudioSource> _buildSources(List<Song> songs) {
    return songs.map((song) {
      return AudioSource.uri(
        Uri.parse(song.uri!),
        tag: MediaItem(
          id: song.id.toString(),
          artist: song.artist,
          title: song.name,
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }
}
