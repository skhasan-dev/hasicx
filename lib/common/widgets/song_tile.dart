import 'package:flutter/material.dart';
import 'package:hasicx/common/index.dart' show AppColors, AppTextStyles;
import 'package:hasicx/core/index.dart' show Song;
import 'package:on_audio_query/on_audio_query.dart';

class SongTile extends StatelessWidget {
  const SongTile({
    required this.song,
    required this.onTap,
    this.onLongPress,
    this.onOpened,
    this.items,
    super.key,
  });

  final Song song;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onOpened;
  final List<PopupMenuItem>? items;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bgColor,
        border: Border.all(color: Colors.white, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onLongPress: onLongPress,
        contentPadding: EdgeInsets.only(left: 16, right: 4),
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
          style: AppTextStyles.s15W500,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        subtitle: Text(
          '${song.album ?? '<Unknown>'} x ${song.artist ?? '<Unknown>'}',
          style: AppTextStyles.s12W300,
        ),
        trailing: (items ?? []).isNotEmpty
            ? PopupMenuButton(
                onOpened: onOpened,
                padding: EdgeInsets.zero,
                itemBuilder: (_) {
                  return items ?? [];
                },
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
