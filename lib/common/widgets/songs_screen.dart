import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hasicx/common/index.dart' show NoDataFound;
import 'package:hasicx/common/theme/colors.dart';
import 'package:hasicx/common/theme/text_styles.dart';
import 'package:hasicx/common/widgets/song_tile.dart';
import 'package:hasicx/core/index.dart';

class SongselectionView extends StatefulWidget {
  const SongselectionView({required this.songs, super.key});

  final List<Song> songs;

  @override
  State<SongselectionView> createState() => _SongselectionViewState();
}

class _SongselectionViewState extends State<SongselectionView> {
  ValueNotifier<List<Song>> songsNotifier = ValueNotifier([]);
  ValueNotifier<List<Song>> selectedSongList = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    songsNotifier.value = widget.songs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Songs', style: AppTextStyles.s16W600),
        backgroundColor: AppColors.tabColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: ValueListenableBuilder(
          valueListenable: songsNotifier,
          builder: (context, value, child) {
            if (value.isEmpty) {
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

            return ListView.separated(
              physics: BouncingScrollPhysics(),
              itemBuilder: (_, index) {
                return SongTile(
                  song: value[index],
                  onTap: () async {
                    final updatedList = List<Song>.from(songsNotifier.value);
                    final removedSong = updatedList.removeAt(index);
                    songsNotifier.value = updatedList;
                    selectedSongList.value = [
                      ...selectedSongList.value,
                      removedSong,
                    ];
                  },
                );
              },
              separatorBuilder: (_, _) => SizedBox(height: 8),
              itemCount: value.length,
            );
          },
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: songsNotifier,
        builder: (context, value, child) {
          return value.isEmpty
              ? SizedBox.shrink()
              : Container(
                  color: AppColors.bgColor,
                  width: double.maxFinite,
                  padding: EdgeInsets.only(
                    right: 16,
                    left: 16,
                    bottom: 60,
                    top: 4,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      context.pop(selectedSongList.value);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: AppColors.buttonColor,
                    ),
                    child: ValueListenableBuilder(
                      valueListenable: selectedSongList,
                      builder: (context, value, child) {
                        return Text(
                          'Add ${selectedSongList.value.length} Selected Song',
                          style: AppTextStyles.s16W400.copyWith(
                            color: AppColors.textColor,
                          ),
                        );
                      },
                    ),
                  ),
                );
        },
      ),
    );
  }
}
