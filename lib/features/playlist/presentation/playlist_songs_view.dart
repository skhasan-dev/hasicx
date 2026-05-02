import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hasicx/common/index.dart'
    show AppTextStyles, AppColors, SongTile, NoDataFound;
import 'package:hasicx/core/index.dart'
    show
        MusicPlayerProvider,
        Playlist,
        Song,
        getIt,
        FailureExt,
        AppToasts,
        AppUtils,
        RouteNames,
        AdvanceMiniPlayer;
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
                child: NoDataFound(
                  icon: Icon(Icons.music_note, size: 96),
                  title: Text(
                    "No songs in this playlist",
                    style: AppTextStyles.s16W600,
                  ),
                  subtitle: Text(
                    "Add songs to start building your playlist.",
                    style: AppTextStyles.s12W400,
                  ),
                  actionText: 'Add Songs',
                  onPressed: () async {
                    final songs = await context.pushNamed(
                      RouteNames.songSelection,
                      extra: musicPlayerProvider.allSongs,
                    );

                    if (songs is List<Song>) {
                      playlistSongsViewModel.addSongsPlaylist(
                        widget.playlist,
                        songs,
                      );
                    }
                  },
                ),
              );
            }

            return ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              physics: BouncingScrollPhysics(),
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

        floatingActionButton: Selector<PlaylistSongsViewModel, bool>(
          selector: (_, vm) => vm.songs.isEmpty,
          builder: (_, hideButton, _) => hideButton
              ? SizedBox.shrink()
              : FloatingActionButton(
                  onPressed: () async {
                    final songs = await context.pushNamed(
                      RouteNames.songSelection,
                      extra: musicPlayerProvider.allSongs,
                    );

                    if (songs is List<Song>) {
                      playlistSongsViewModel.addSongsPlaylist(
                        widget.playlist,
                        songs,
                      );
                    }
                  },
                  backgroundColor: AppColors.buttonColor,
                  child: Icon(Icons.add, color: AppColors.buttonTxtColor),
                ),
        ),

        bottomNavigationBar: AdvanceMiniPlayer(),
      ),
    );
  }
}
