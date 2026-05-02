import 'package:flutter/material.dart';
import 'package:hasicx/common/index.dart'
    show AppColors, AppTextStyles, MiniPlayer;
import 'package:hasicx/common/widgets/song_tile.dart';
import 'package:hasicx/core/index.dart';
import 'package:hasicx/features/search/presentation/view_model/search_view_model.dart';
import 'package:provider/provider.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  SearchViewModel searchViewModel = SearchViewModel();
  MusicPlayerProvider musicPlayerProvider = getIt<MusicPlayerProvider>();
  FocusNode focusNode = FocusNode();
  TextEditingController searchQueryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
      searchViewModel.result = musicPlayerProvider.allSongs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: searchViewModel,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.tabColor,
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: TextFormField(
              controller: searchQueryController,
              focusNode: focusNode,
              onTapOutside: (_) {
                focusNode.unfocus();
              },
              style: AppTextStyles.s14W600,
              onChanged: (value) {
                searchViewModel.search(value);
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search Song...',
                hintStyle: AppTextStyles.s14W600.copyWith(
                  color: Colors.white70,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    searchQueryController.clear();
                  },
                  icon: Icon(Icons.close, color: AppColors.textColor),
                ),
              ),
            ),
          ),
        ),

        body: Consumer<SearchViewModel>(
          builder: (vmContext, vm, _) {
            if (vm.result.isEmpty) {
              return Center(child: Text('No Songs Found'));
            }

            return ListView.builder(
              padding: EdgeInsets.all(20),
              itemBuilder: (_, index) {
                return SongTile(
                  song: vm.result[index],
                  onTap: () {
                    musicPlayerProvider.playSong(0, songs: [vm.result[index]]);
                  },
                );
              },
              itemCount: vm.result.length,
            );
          },
        ),

        bottomNavigationBar: Selector<MusicPlayerProvider, PlayerState>(
          selector: (_, vm) => vm.playerState,
          builder: (_, state, _) {
            if (state == PlayerState.idle) return SizedBox.shrink();

            return Selector<MusicPlayerProvider, int>(
              selector: (_, vm) => vm.currentIndex,
              builder: (_, index, _) => MiniPlayer(
                playerState: state,
                songs: musicPlayerProvider.currentPlayingSongs,
                currentIndex: index,
                onPlayPauseCallback: (isPlaying) {
                  if (isPlaying) {
                    musicPlayerProvider.pauseSong();
                  } else {
                    musicPlayerProvider.resumeSong();
                  }
                },
                onSkip: musicPlayerProvider.playNext,
                onPrev: musicPlayerProvider.playPrevious,
              ),
            );
          },
        ),
      ),
    );
  }
}
