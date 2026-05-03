import 'package:flutter/material.dart';
import 'package:hasicx/common/index.dart' show AppTextStyles, AppColors;
import 'package:hasicx/core/index.dart';
import 'package:provider/provider.dart';

class SongController extends StatelessWidget {
  SongController({super.key});

  final MusicPlayerProvider musicPlayerProvider = getIt<MusicPlayerProvider>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Consumer<MusicPlayerProvider>(
          builder: (_, vm, _) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(vm.currentTime, style: AppTextStyles.s12W400),
              Expanded(
                child: Slider(
                  activeColor: AppColors.buttonColor,
                  value: vm.currentSliderValue,
                  onChangeStart: (value) => vm.startDragging,
                  onChangeEnd: (value) => vm.seekTo(value),
                  onChanged: vm.updateSliderUI,
                  min: Duration(seconds: 0).inSeconds.toDouble(),
                  max: vm.maxSliderValue > 0.0 ? vm.maxSliderValue : 99999,
                ),
              ),
              Text(vm.length, style: AppTextStyles.s12W400),
            ],
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Selector<MusicPlayerProvider, bool>(
              selector: (_, vm) => vm.player.hasPrevious,
              builder: (_, hasPrevious, _) => IconButton(
                onPressed: hasPrevious
                    ? () {
                        musicPlayerProvider.playPrevious();
                        // getFav();
                      }
                    : null,
                icon: Icon(
                  Icons.skip_previous,
                  color: AppColors.textColor.withValues(
                    alpha: hasPrevious ? 1 : 0.6,
                  ),
                  size: 40,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                musicPlayerProvider.skipForward(false);
              },
              child: Image.asset("assets/images/reverse.png", height: 40),
            ),
            Selector<MusicPlayerProvider, bool>(
              selector: (_, vm) => vm.isPlaying,
              builder: (_, isPlaying, _) => IconButton(
                onPressed: () {
                  if (isPlaying) {
                    musicPlayerProvider.pauseSong();
                  } else {
                    musicPlayerProvider.resumeSong();
                  }
                },
                icon: isPlaying
                    ? Icon(Icons.pause, color: AppColors.textColor, size: 60)
                    : Icon(
                        Icons.play_arrow,
                        color: AppColors.textColor,
                        size: 60,
                      ),
              ),
            ),
            InkWell(
              onTap: () {
                musicPlayerProvider.skipForward(true);
              },
              child: Image.asset("assets/images/fast.png", height: 40),
            ),
            Selector<MusicPlayerProvider, bool>(
              selector: (_, vm) => vm.player.hasNext,
              builder: (_, hasNext, _) => IconButton(
                onPressed: hasNext
                    ? () {
                        musicPlayerProvider.playNext();
                        // getFav();
                      }
                    : null,
                icon: Icon(
                  Icons.skip_next,
                  color: AppColors.textColor.withValues(
                    alpha: hasNext ? 1 : 0.6,
                  ),
                  size: 40,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
