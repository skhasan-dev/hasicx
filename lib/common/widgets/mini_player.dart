import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hasicx/common/index.dart'
    show AppColors, AppTextStyles, AdvanceIcon;
import 'package:hasicx/core/index.dart'
    show PlayerState, Song, RouteNames, getIt;
import 'package:hasicx/features/favourites/presentation/view_models/favourites_view_model.dart';
import 'package:marquee/marquee.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({
    required this.songs,
    required this.playerState,
    required this.currentIndex,
    required this.onSkip,
    required this.onPrev,
    required this.onPlayPauseCallback,
    super.key,
  });

  final PlayerState playerState;
  final int currentIndex;
  final List<Song> songs;
  final void Function(bool isPlaying) onPlayPauseCallback;
  final VoidCallback onSkip;
  final VoidCallback onPrev;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () async {
              final result = await context.pushNamed(RouteNames.player);
              if (result == true) {
                await getIt<FavouritesViewModel>().getSongs();
              }
            },
            child: AnimatedContainer(
              width: double.maxFinite,
              color: AppColors.tabColor,
              duration: Duration(milliseconds: 400),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          QueryArtworkWidget(
                            id: songs.isEmpty ? 0 : songs[currentIndex].id,
                            type: ArtworkType.AUDIO,
                            artworkHeight: 45,
                            artworkWidth: 45,
                            nullArtworkWidget: Container(
                              height: 45,
                              width: 45,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.buttonColor,
                              ),
                              child: Icon(
                                Icons.music_note,
                                size: 32,
                                color: AppColors.textColor,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 24,
                                  child: songs[currentIndex].name.length > 20
                                      ? Marquee(
                                          text: songs.isEmpty
                                              ? '-'
                                              : songs[currentIndex].name,
                                          style: AppTextStyles.s14W600,
                                          scrollAxis: Axis.horizontal,
                                          blankSpace: 40.0,
                                          velocity: 50.0,
                                          pauseAfterRound: Duration(seconds: 1),
                                        )
                                      : Text(
                                          songs.isEmpty
                                              ? '-'
                                              : songs[currentIndex].name,
                                          style: AppTextStyles.s14W600,
                                        ),
                                ),
                                Text(
                                  songs.isEmpty
                                      ? '<Unknown>'
                                      : songs[currentIndex].artist ??
                                            '<Unknown>',
                                  style: AppTextStyles.s12W400,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 24),
                    AdvanceIcon(
                      onTap: () => onPlayPauseCallback.call(
                        playerState == PlayerState.playing,
                      ),
                      size: 34,
                      icon: playerState.icon,
                    ),
                    SizedBox(width: 12),
                    if (currentIndex < songs.length - 1)
                      AdvanceIcon(
                        onTap: onSkip,
                        icon: Icons.skip_next,
                        size: 34,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
