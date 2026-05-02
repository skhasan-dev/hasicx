import 'package:go_router/go_router.dart';
import 'package:hasicx/common/widgets/songs_screen.dart';
import 'package:hasicx/core/index.dart' show Playlist, RouteNames, Song;
import 'package:hasicx/features/home/index.dart';
import 'package:hasicx/features/home/presentation/home_view.dart';
import 'package:hasicx/features/player/presentation/player_view.dart';
import 'package:hasicx/features/playlist/presentation/playlist_songs_view.dart';
import 'package:hasicx/features/playlist/presentation/recent_songs_view.dart';

GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.splash,
  routes: [
    GoRoute(
      path: '/',
      name: RouteNames.splash,
      builder: (_, _) => SplashView(),
    ),
    GoRoute(
      path: '/home',
      name: RouteNames.home,
      builder: (_, _) => HomeView(),
    ),
    GoRoute(
      path: '/player',
      name: RouteNames.player,
      builder: (_, _) => PlayerView(),
    ),
    GoRoute(
      path: '/recently-added',
      name: RouteNames.recentlyAdded,
      builder: (_, _) => RecentSongsView(),
    ),
    GoRoute(
      path: '/playlist-song',
      name: RouteNames.playlistSong,
      builder: (_, state) =>
          PlaylistSongsView(playlist: state.extra as Playlist?),
    ),
    GoRoute(
      path: '/song-selection',
      name: RouteNames.songSelection,
      builder: (_, state) =>
          SongselectionView(songs: state.extra as List<Song>? ?? []),
    ),
  ],
);
