import 'package:flutter/material.dart';
import 'package:hasicx/common/index.dart' show AppColors, AppTextStyles;
import 'package:hasicx/core/index.dart' show MusicPlayerProvider, Song;
import 'package:hasicx/core/services/dependency_injector.dart';
import 'package:hasicx/features/player/index.dart' show PlayerViewModel;
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class PlayBox extends StatelessWidget {
  const PlayBox({required this.showQueue, super.key});

  final bool showQueue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: AppColors.deepTabColor,
        border: Border(
          bottom: BorderSide(width: 0.5, color: AppColors.buttonColor),
        ),
        borderRadius: showQueue
            ? BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              )
            : null,
      ),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        spacing: 16,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Selector<MusicPlayerProvider, Song?>(
            selector: (_, vm) => vm.currentyPlaying,
            builder: (context, song, child) {
              return Flexible(
                child: Column(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Now Playing", style: AppTextStyles.s14W600),
                    Text(
                      song?.name ?? '-',
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.s12W400,
                    ),
                  ],
                ),
              );
            },
          ),

          Row(
            children: [
              Selector<MusicPlayerProvider, LoopMode>(
                selector: (_, vm) => vm.loopMode,
                builder: (context, loopMode, child) {
                  return IconButton(
                    onPressed: () async {
                      final next = _nextLoopMode(loopMode);
                      getIt<MusicPlayerProvider>().loopMode = next;
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

              Selector<MusicPlayerProvider, bool>(
                selector: (_, vm) => vm.showListExpandButton,
                builder: (context, showQueueButton, child) {
                  if (showQueueButton) {
                    return IconButton(
                      onPressed: () {
                        context.read<PlayerViewModel>().toggleQueueVisibility();
                      },
                      icon: Selector<PlayerViewModel, bool>(
                        builder: (_, isExpanded, _) {
                          return Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_up,
                            color: AppColors.textColor,
                            size: 30,
                          );
                        },
                        selector: (_, vm) => vm.showQueue,
                      ),
                    );
                  }

                  return SizedBox.shrink();
                },
              ),
            ],
          ),
        ],
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
