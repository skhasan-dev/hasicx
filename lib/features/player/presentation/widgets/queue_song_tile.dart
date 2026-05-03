import 'package:flutter/material.dart';
import 'package:hasicx/common/index.dart'
    show AdvanceIcon, AppColors, AppTextStyles;
import 'package:hasicx/core/index.dart' show Song;
import 'package:on_audio_query/on_audio_query.dart';

class QueueSongTile extends StatelessWidget {
  const QueueSongTile({
    required this.song,
    required this.isCurrentlyPlaying,
    required this.onTap,
    required this.onRemove,
    super.key,
  });

  final Song song;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final bool isCurrentlyPlaying;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCurrentlyPlaying ? AppColors.tabColor : AppColors.deepTabColor,
        border: Border.all(color: Colors.white, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: QueryArtworkWidget(
          id: song.id,
          type: ArtworkType.AUDIO,
          nullArtworkWidget: Icon(
            Icons.music_note,
            color: AppColors.textColor,
            size: 50,
          ),
        ),
        title: Text(
          song.name,
          style: AppTextStyles.s15W500.copyWith(
            color: AppColors.textColor.withValues(
              alpha: isCurrentlyPlaying ? 1 : 0.6,
            ),
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        subtitle: Text(
          '${song.album ?? '<Unknown>'} x ${song.artist ?? '<Unknown>'}',
          style: AppTextStyles.s12W300,
        ),
        // trailing: InkWell(onTap: onMoreTap, child: Icon(Icons.more_vert)),
        onTap: onTap,
        trailing: isCurrentlyPlaying
            ? Icon(Icons.play_arrow)
            : AdvanceIcon(onTap: onRemove, icon: Icons.close),
      ),
    );
  }
}
