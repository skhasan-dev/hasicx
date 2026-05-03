import 'package:flutter/material.dart';
import 'package:hasicx/common/index.dart' show AppColors;
import 'package:hasicx/core/index.dart' show Song;
import 'package:hasicx/features/player/index.dart' show QueueSongTile;

class QueueBox extends StatelessWidget {
  const QueueBox({
    required this.currentIndex,
    required this.songs,
    required this.onSongSelect,
    required this.onRemoveSong,
    super.key,
  });

  final List<Song> songs;
  final int currentIndex;
  final ValueChanged<int> onSongSelect;
  final ValueChanged<int> onRemoveSong;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ColoredBox(
        color: AppColors.deepTabColor,
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          shrinkWrap: true,
          itemBuilder: (_, index) {
            final song = songs[index];
            return QueueSongTile(
              song: song,
              isCurrentlyPlaying: index == currentIndex,
              onTap: () {
                onSongSelect.call(index);
              },
              onRemove: () {
                onRemoveSong.call(index);
              },
            );
          },
          itemCount: songs.length,
        ),
      ),
    );
  }
}
