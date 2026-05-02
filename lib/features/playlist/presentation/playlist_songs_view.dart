import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hasicx/common/index.dart'
    show AppTextStyles, AppColors, SongTile, MiniPlayer;
import 'package:hasicx/core/index.dart'
    show
        MusicPlayerProvider,
        Playlist,
        Song,
        PlayerState,
        getIt,
        FailureExt,
        AppToasts,
        AppUtils,
        RouteNames;
import 'package:hasicx/features/playlist/index.dart'
    show PlaylistSongsViewModel;
import 'package:provider/provider.dart';

class PlaylistSongsView extends StatefulWidget {
  const PlaylistSongsView({required this.playlist, super.key});
  final Playlist? playlist;

  @override
  State<PlaylistSongsView> createState() => _PlaylistSongsViewState();
}

class _PlaylistSongsViewState extends State<PlaylistSongsView> {
  PlaylistSongsViewModel playlistSongsViewModel = PlaylistSongsViewModel();
  final musicPlayerProvider = getIt<MusicPlayerProvider>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final failure = await playlistSongsViewModel.getSongs(
        widget.playlist?.name ?? '',
      );

      failure?.showToast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: playlistSongsViewModel,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.tabColor,
          title: Text(
            widget.playlist?.name ?? '-',
            style: AppTextStyles.s16W600,
          ),
        ),

        body: Selector<PlaylistSongsViewModel, List<Song>>(
          selector: (_, vm) => vm.songs,
          builder: (_, songs, _) {
            if (songs.isEmpty) {
              return Center(
                child: Text(
                  'No Songs Added in the Playlist',
                  style: AppTextStyles.s18W400,
                ),
              );
            }

            return ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              itemBuilder: (_, index) {
                final song = songs[index];
                return SongTile(
                  song: song,
                  onLongPress: () {
                    AppUtils.showDeleteDialog(
                      context,
                      onDelete: () async {
                        final failure = await playlistSongsViewModel.removeSong(
                          widget.playlist,
                          song,
                        );
                        AppToasts.showFailureToast(
                          failure,
                          successMsg: 'Remove form Playlist',
                        );
                      },
                    );
                  },
                  onTap: () {
                    musicPlayerProvider.playSong(index, songs: songs);
                  },
                  onOpened: () async {
                    await musicPlayerProvider.getIsFav(song: song);
                  },
                  items: [
                    PopupMenuItem(
                      child: Text('Play Single'),
                      onTap: () {
                        musicPlayerProvider.playSong(
                          0,
                          songs: [song],
                          setLoopMode: true,
                        );
                        AppToasts.showToast('Playing Single');
                      },
                    ),
                    PopupMenuItem(
                      child: Text('Play Next'),
                      onTap: () {
                        musicPlayerProvider.addToQueue(song, atLast: false);
                        AppToasts.showToast('Playing Next');
                      },
                    ),
                    PopupMenuItem(
                      child: Text('Add to Queue'),
                      onTap: () {
                        musicPlayerProvider.addToQueue(song);
                        AppToasts.showToast('Added to Queue');
                      },
                    ),
                    PopupMenuItem(
                      child: Selector<MusicPlayerProvider, bool>(
                        selector: (_, vm) => vm.isSelectedSongFavourite,
                        builder: (_, isFav, _) => Text(
                          '${isFav ? 'Remove from' : 'Add to'} Favourites',
                        ),
                      ),
                      onTap: () {
                        musicPlayerProvider.addToFav(song: song);
                      },
                    ),
                    PopupMenuItem(
                      child: Text('Remove from Playlist'),
                      onTap: () async {
                        final failure = await playlistSongsViewModel.removeSong(
                          widget.playlist,
                          song,
                        );
                        AppToasts.showFailureToast(
                          failure,
                          successMsg: 'Removed form Playlist',
                        );
                      },
                    ),
                  ],
                );
              },
              itemCount: songs.length,
              shrinkWrap: true,
              separatorBuilder: (_, _) => SizedBox(height: 8),
            );
          },
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final songs = await context.pushNamed(
              RouteNames.songSelection,
              extra: musicPlayerProvider.allSongs,
            );

            if (songs is List<Song>) {
              playlistSongsViewModel.addSongsPlaylist(widget.playlist, songs);
            }
          },
          backgroundColor: AppColors.buttonColor,
          child: Icon(Icons.add, color: AppColors.buttonTxtColor),
        ),

        bottomNavigationBar: Selector<MusicPlayerProvider, PlayerState>(
          selector: (_, vm) => vm.playerState,
          builder: (_, state, _) {
            if (state == PlayerState.idle) return SizedBox.shrink();

            return Selector<MusicPlayerProvider, int>(
              selector: (_, vm) => vm.currentIndex,
              builder: (_, index, _) => MiniPlayer(
                playerState: state,
                songs: musicPlayerProvider.currentPlayingSongs,
                currentIndex: index,
                onPlayPauseCallback: (isPlaying) {
                  if (isPlaying) {
                    musicPlayerProvider.pauseSong();
                  } else {
                    musicPlayerProvider.resumeSong();
                  }
                },
                onSkip: musicPlayerProvider.playNext,
                onPrev: musicPlayerProvider.playPrevious,
              ),
            );
          },
        ),
      ),
    );
  }
}
