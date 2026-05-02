import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hasicx/common/index.dart';
import 'package:hasicx/core/index.dart';
import 'package:hasicx/features/player/index.dart';
import 'package:just_audio/just_audio.dart';
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

  ValueNotifier<bool> isListEnabledNotifer = ValueNotifier<bool>(false);

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
              IconButton(
                onPressed: () async {
                  final failure = await musicPlayerProvider.addToFav();
                  AppToasts.showFailureToast(failure);
                },
                icon: Selector<MusicPlayerProvider, bool>(
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
            ],
          ),

          body: Column(
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
                child: ValueListenableBuilder(
                  valueListenable: isListEnabledNotifer,
                  builder: (context, value, child) {
                    return Column(
                      children: [
                        if (!value)
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
                                    child: Selector<MusicPlayerProvider, Song?>(
                                      selector: (_, vm) => vm.currentyPlaying,
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
                                            overflow: TextOverflow.ellipsis,
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

                        Container(
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            color: AppColors.deepTabColor,
                            borderRadius: value
                                ? BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  )
                                : null,
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Now Playing",
                                    style: AppTextStyles.s14W600,
                                  ),
                                  // ValueListenableBuilder(
                                  //   valueListenable: loopModeNotifer,
                                  //   builder: (context, value, child) {
                                  //     return Text(
                                  //       'Repeat ${value.name}',
                                  //       style: AppTextStyles.s14W400,
                                  //       overflow: TextOverflow.ellipsis,
                                  //       maxLines: 1,
                                  //     );
                                  //   },
                                  // ),
                                ],
                              ),
                              Row(
                                children: [
                                  Selector<MusicPlayerProvider, LoopMode>(
                                    selector: (_, vm) => vm.loopMode,
                                    builder: (context, loopMode, child) {
                                      return IconButton(
                                        onPressed: () async {
                                          final next = _nextLoopMode(loopMode);
                                          musicPlayerProvider.player
                                              .setLoopMode(next);
                                          musicPlayerProvider.loopMode = next;
                                        },
                                        icon: Icon(
                                          loopMode == LoopMode.one
                                              ? Icons.repeat_one
                                              : Icons.repeat,
                                          color: loopMode == LoopMode.off
                                              ? null
                                              : AppColors.textColor,
                                          size: 28,
                                        ),
                                      );
                                    },
                                  ),
                                  ValueListenableBuilder(
                                    valueListenable: isListEnabledNotifer,
                                    builder: (context, value, child) {
                                      return IconButton(
                                        onPressed: () {
                                          isListEnabledNotifer.value = !value;
                                        },
                                        icon: value
                                            ? Icon(
                                                Icons.keyboard_arrow_down,
                                                color: AppColors.textColor,
                                                size: 30,
                                              )
                                            : Icon(
                                                Icons.keyboard_arrow_up,
                                                color: AppColors.textColor,
                                                size: 30,
                                              ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        if (value)
                          Expanded(
                            child: ColoredBox(
                              color: AppColors.deepTabColor,
                              child: ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                shrinkWrap: true,
                                itemBuilder: (_, index) {
                                  final songs =
                                      musicPlayerProvider.remainingSongs;
                                  final song = songs[index];
                                  return QueueSongTile(
                                    song: song,
                                    onTap: () {
                                      isListEnabledNotifer.value = false;
                                      musicPlayerProvider.playSong(
                                        musicPlayerProvider
                                            .currentIndexForRemainingSongs(
                                              index,
                                            ),
                                      );
                                    },
                                    onMoreTap: () {},
                                  );
                                },
                                itemCount:
                                    musicPlayerProvider.remainingSongs.length,
                              ),
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
    );
  }

  LoopMode _nextLoopMode(LoopMode mode) {
    switch (mode) {
      case LoopMode.off:
        return LoopMode.all;
      case LoopMode.all:
        return LoopMode.one;
      case LoopMode.one:
        return LoopMode.off;
    }
  }
}
