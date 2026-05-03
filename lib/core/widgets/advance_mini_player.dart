import 'package:flutter/material.dart';
import 'package:hasicx/common/index.dart' show MiniPlayer;
import 'package:hasicx/core/index.dart'
    show MusicPlayerProvider, PlayerState, Song, getIt;
import 'package:provider/provider.dart';

class AdvanceMiniPlayer extends StatelessWidget {
  AdvanceMiniPlayer({super.key});

  final player = getIt<MusicPlayerProvider>();

  @override
  Widget build(BuildContext context) {
    return Selector<MusicPlayerProvider, PlayerState>(
      selector: (_, vm) => vm.playerState,
      builder: (_, state, _) {
        if (state == PlayerState.idle) return SizedBox.shrink();

        return Selector<MusicPlayerProvider, Song>(
          selector: (_, vm) => vm.currentyPlaying,
          builder: (_, index, _) => MiniPlayer(
            playerState: state,
            songs: player.currentPlayingSongs,
            currentIndex: player.currentPlayingSongs.indexOf(index),
            onPlayPauseCallback: (isPlaying) {
              if (isPlaying) {
                player.pauseSong();
              } else {
                player.resumeSong();
              }
            },
            onSkip: player.playNext,
            onPrev: player.playPrevious,
          ),
        );
      },
    );
  }
}
