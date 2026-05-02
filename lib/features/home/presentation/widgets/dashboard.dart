import 'package:flutter/material.dart';
import 'package:hasicx/common/theme/text_styles.dart';
import 'package:hasicx/common/widgets/no_data_found.dart';
import 'package:hasicx/common/widgets/song_tile.dart';
import 'package:hasicx/core/index.dart';
import 'package:hasicx/features/home/presentation/view_models/home_view_model.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatelessWidget {
  Dashboard({super.key});

  final MusicPlayerProvider musicPlayerProvider = getIt<MusicPlayerProvider>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(right: 20, left: 20, top: 20, bottom: 8),
        child: Selector<HomeViewModel, bool>(
          selector: (_, vm) => vm.isLoading,
          builder: (context, isLoading, _) {
            if (isLoading) return CircularProgressIndicator();

            return Selector<HomeViewModel, List<Song>>(
              selector: (_, vm) => vm.allSongs,
              builder: (context, songs, _) {
                if (songs.isEmpty) {
                  return Center(
                    child: NoDataFound(
                      icon: Icon(Icons.music_note, size: 96),
                      title: Text(
                        "No songs available",
                        style: AppTextStyles.s16W600,
                      ),
                      subtitle: Text(
                        "Looks like your library is empty. Add songs to get started.",
                        style: AppTextStyles.s12W400,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    var song = songs[index];
                    return SongTile(
                      song: song,
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
                          },
                        ),
                        PopupMenuItem(
                          child: Text('Play Next'),
                          onTap: () {
                            musicPlayerProvider.addToQueue(song, atLast: false);
                          },
                        ),
                        PopupMenuItem(
                          child: Text('Add to Queue'),
                          onTap: () {
                            musicPlayerProvider.addToQueue(song);
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
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
