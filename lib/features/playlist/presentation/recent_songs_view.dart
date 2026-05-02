import 'package:flutter/material.dart';
import 'package:hasicx/common/index.dart'
    show AppTextStyles, AppColors, SongTile, MiniPlayer, NoDataFound;
import 'package:hasicx/core/index.dart'
    show MusicPlayerProvider, PlayerState, getIt, SharedPrefs;
import 'package:hasicx/features/playlist/index.dart' show PlaylistUtils;
import 'package:provider/provider.dart';

class RecentSongsView extends StatefulWidget {
  const RecentSongsView({super.key});

  @override
  State<RecentSongsView> createState() => _RecentSongsViewState();
}

class _RecentSongsViewState extends State<RecentSongsView> {
  final MusicPlayerProvider musicPlayerProvider = getIt<MusicPlayerProvider>();
  ValueNotifier<int> countNotifier = ValueNotifier<int>(10);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      countNotifier.value = SharedPrefs.getRecentCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.tabColor,
        title: Text('Recently Added', style: AppTextStyles.s16W600),
      ),

      body: ValueListenableBuilder(
        valueListenable: countNotifier,
        builder: (_, value, _) {
          final songs = musicPlayerProvider.allSongs.take(value).toList();

          if (songs.isEmpty) {
            return Center(
              child: NoDataFound(
                icon: Icon(Icons.history, size: 96),
                title: Text(
                  "No recently added songs",
                  style: AppTextStyles.s16W600,
                ),
                subtitle: Text(
                  "Songs you add will appear here.",
                  style: AppTextStyles.s12W400,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            itemBuilder: (_, index) {
              final song = songs[index];
              return SongTile(
                song: song,
                onTap: () {
                  musicPlayerProvider.playSong(index, songs: songs);
                },
              );
            },
            itemCount: songs.length,
            shrinkWrap: true,
            separatorBuilder: (_, _) => SizedBox(height: 8),
          );
        },
      ),

      floatingActionButton: ElevatedButton(
        onPressed: () async {
          PlaylistUtils.showCountDialog(
            context,
            onCountSet: (value) async {
              final isSucceed = await SharedPrefs.setRecentCount(value);
              if (isSucceed) {
                countNotifier.value = value;
              }
            },
          );
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: AppColors.buttonColor,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: Text(
          'Set Count',
          style: AppTextStyles.s16W600.copyWith(color: AppColors.textColor),
        ),
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
    );
  }
}
