import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hasicx/common/index.dart' show AppColors;
import 'package:hasicx/core/index.dart'
    show FailureExt, Playlist, RouteNames, AppUtils, AppToasts;
import 'package:hasicx/features/playlist/index.dart'
    show PlaylistViewModel, PlaylistTile, PlaylistUtils;
import 'package:provider/provider.dart';

class PlaylistView extends StatefulWidget {
  const PlaylistView({super.key});

  @override
  State<PlaylistView> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView> {
  PlaylistViewModel playlistViewModel = PlaylistViewModel();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final failure = await playlistViewModel.getPlaylists();
      failure?.showToast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: playlistViewModel,
      child: Scaffold(
        body: Selector<PlaylistViewModel, bool>(
          selector: (_, vm) => vm.isLoading,
          builder: (_, isLoading, _) {
            if (isLoading) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.buttonColor),
              );
            }
            return SingleChildScrollView(
              padding: EdgeInsets.only(top: 12, bottom: 8),
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  PlaylistTile(
                    title: 'Recently Added',
                    leading: Icons.add_box_rounded,
                    onTap: () {
                      context.pushNamed(RouteNames.recentlyAdded);
                    },
                  ),
                  Divider(),
                  Selector<PlaylistViewModel, List<Playlist>>(
                    selector: (_, vm) => vm.playlists,
                    builder: (_, playlists, _) => ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (_, index) {
                        final playlist = playlists[index];
                        return PlaylistTile(
                          title: playlist.name,
                          leading: Icons.playlist_play,
                          onLongPress: () {
                            AppUtils.showDeleteDialog(
                              context,
                              isSong: false,
                              onDelete: () async {
                                final failure = await playlistViewModel
                                    .deletePlaylist(playlist);
                                if (failure != null) {
                                  failure.showToast();
                                } else {
                                  final failure = await playlistViewModel
                                      .getPlaylists();
                                  failure?.showToast();
                                }
                              },
                            );
                          },
                          onTap: () {
                            context.pushNamed(
                              RouteNames.playlistSong,
                              extra: playlist,
                            );
                          },
                        );
                      },
                      itemCount: playlists.length,
                      shrinkWrap: true,
                      separatorBuilder: (_, _) => Divider(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            PlaylistUtils.showAddPlaylistDialog(
              context,
              onCreate: (value) async {
                final failure = await playlistViewModel.addPlaylist(value);

                AppToasts.showFailureToast(failure);
              },
            );
          },
          backgroundColor: AppColors.buttonColor,
          child: Icon(Icons.add, color: AppColors.buttonTxtColor),
        ),
      ),
    );
  }
}
