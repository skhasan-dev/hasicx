import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hasicx/common/index.dart';
import 'package:hasicx/core/index.dart';
import 'package:hasicx/features/favourites/presentation/favourites_view.dart';
import 'package:hasicx/features/home/presentation/view_models/home_view_model.dart';
import 'package:hasicx/features/home/presentation/widgets/dashboard.dart';
import 'package:hasicx/features/playlist/presentation/playlist_view.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  HomeViewModel homeViewModel = HomeViewModel();
  final player = getIt<MusicPlayerProvider>();

  late TabController tabController = TabController(length: 3, vsync: this);
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: homeViewModel,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.tabColor,
          actions: [
            IconButton(
              onPressed: () {
                context.pushNamed(RouteNames.search);
              },
              icon: Icon(Icons.search, color: AppColors.textColor),
            ),
          ],
          title: Text(
            "HasicX",
            style: AppTextStyles.s18W600.copyWith(letterSpacing: 2),
          ),
          bottom: TabBar(
            controller: tabController,
            dividerColor: Colors.transparent,
            indicatorColor: AppColors.buttonColor,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(icon: Icon(Icons.music_note, color: AppColors.textColor)),
              Tab(icon: Icon(Icons.favorite, color: AppColors.textColor)),
              Tab(icon: Icon(Icons.folder, color: AppColors.textColor)),
            ],
          ),
        ),

        body: TabBarView(
          controller: tabController,
          children: [Dashboard(), FavouritesView(), PlaylistView()],
        ),

        bottomNavigationBar: Selector<MusicPlayerProvider, PlayerState>(
          selector: (_, vm) => vm.playerState,
          builder: (_, state, _) {
            if (state == PlayerState.idle) return SizedBox.shrink();

            return Selector<MusicPlayerProvider, int>(
              selector: (_, vm) => vm.currentIndex,
              builder: (_, index, _) => MiniPlayer(
                playerState: state,
                songs: player.currentPlayingSongs,
                currentIndex: index,
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
        ),
      ),
    );
  }
}
