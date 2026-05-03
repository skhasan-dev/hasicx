import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hasicx/common/index.dart';
import 'package:hasicx/core/index.dart';
import 'package:hasicx/features/player/index.dart';
import 'package:hasicx/features/player/presentation/widgets/play_box.dart';
import 'package:hasicx/features/player/presentation/widgets/queue_box.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

class PlayerView extends StatefulWidget {
  const PlayerView({super.key});

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  final MusicPlayerProvider musicPlayerProvider = getIt<MusicPlayerProvider>();
  final PlayerViewModel playerViewModel = PlayerViewModel();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return ChangeNotifierProvider.value(
      value: playerViewModel,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          context.pop(true);
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: AdvanceIcon(
              icon: Icons.arrow_back,
              color: AppColors.textColor,
              onTap: () {
                context.pop(true);
              },
            ),
            actions: [
              Selector<MusicPlayerProvider, bool>(
                selector: (_, vm) => vm.isLoading,
                builder: (_, isLoading, _) => IconButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final failure = await musicPlayerProvider.addToFav();
                          AppToasts.showFailureToast(failure);
                        },
                  icon: isLoading
                      ? CircularProgressIndicator()
                      : Selector<MusicPlayerProvider, bool>(
                          selector: (_, vm) => vm.isPlayingSongMarkedFavourite,
                          builder: (_, isFav, _) {
                            return isFav
                                ? Image.asset(
                                    "assets/images/fillHeart.png",
                                    height: 30,
                                    width: 30,
                                  )
                                : Image.asset(
                                    "assets/images/heart.png",
                                    height: 30,
                                    width: 30,
                                  );
                          },
                        ),
                ),
              ),
            ],
          ),

          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Selector<MusicPlayerProvider, Song?>(
                    selector: (_, vm) => vm.currentyPlaying,
                    builder: (_, song, _) => Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: QueryArtworkWidget(
                        id: song?.id ?? 0,
                        artworkHeight: width * 0.8,
                        artworkWidth: width * 0.8,
                        artworkFit: BoxFit.cover,
                        artworkClipBehavior: Clip.antiAliasWithSaveLayer,
                        type: ArtworkType.AUDIO,
                        nullArtworkWidget: Container(
                          height: width * 0.8,
                          width: width * 0.8,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.buttonColor,
                              width: 8,
                            ),
                          ),
                          child: Icon(
                            Icons.music_note,
                            color: AppColors.buttonColor,
                            size: 250,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Selector<PlayerViewModel, bool>(
                    selector: (_, vm) => vm.showQueue,
                    builder: (context, showQueue, child) {
                      return Column(
                        children: [
                          if (!showQueue)
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.tabColor,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      right: 12,
                                      left: 12,
                                      top: 12,
                                    ),
                                    child: SingleChildScrollView(
                                      child:
                                          Selector<MusicPlayerProvider, Song?>(
                                            selector: (_, vm) =>
                                                vm.currentyPlaying,
                                            builder: (_, song, _) => Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Text(
                                                  song?.name ?? '-',
                                                  style: AppTextStyles.s20W600,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 16),
                                                Text(
                                                  song?.artist ?? '-',
                                                  style: AppTextStyles.s16W600,
                                                ),
                                                SizedBox(height: 16),
                                                SongController(),
                                              ],
                                            ),
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          PlayBox(showQueue: showQueue),

                          if (showQueue)
                            Selector<MusicPlayerProvider, int>(
                              selector: (_, vm) => vm.currentIndex,
                              builder: (_, currentIndex, _) => QueueBox(
                                currentIndex: currentIndex,
                                songs: musicPlayerProvider.currentPlayingSongs,
                                onSongSelect: (index) {
                                  musicPlayerProvider.playSong(index);
                                  playerViewModel.toggleQueueVisibility();
                                },
                                onRemoveSong: (index) async {
                                  await musicPlayerProvider.removeFromQueue(
                                    index,
                                  );
                                  playerViewModel.toggleQueueVisibility();
                                },
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
