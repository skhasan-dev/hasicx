import 'package:flutter/material.dart';
import 'package:hasicx/common/index.dart' show AppTextStyles, NoDataFound;
import 'package:hasicx/common/widgets/song_tile.dart';
import 'package:hasicx/core/index.dart';
import 'package:hasicx/features/favourites/presentation/view_models/favourites_view_model.dart';
import 'package:provider/provider.dart';

class FavouritesView extends StatefulWidget {
  const FavouritesView({super.key});

  @override
  State<FavouritesView> createState() => _FavouritesViewState();
}

class _FavouritesViewState extends State<FavouritesView> {
  final FavouritesViewModel favouritesViewModel = getIt<FavouritesViewModel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final failure = await favouritesViewModel.getSongs();

      AppToasts.showFailureToast(failure);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: favouritesViewModel,
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.only(right: 20, left: 20, top: 20, bottom: 8),
          child: Selector<FavouritesViewModel, bool>(
            selector: (_, vm) => vm.isLoading,
            builder: (context, isLoading, _) {
              if (isLoading) return CircularProgressIndicator();

              return Selector<FavouritesViewModel, List<Song>>(
                selector: (_, vm) => vm.favourites,
                builder: (context, songs, _) {
                  if (songs.isEmpty) {
                    return Center(
                      child: NoDataFound(
                        icon: Icon(Icons.favorite_outline, size: 96),
                        title: Text(
                          "No favorite songs yet",
                          style: AppTextStyles.s16W600,
                        ),
                        subtitle: Text(
                          "Add songs to your favorites to see them here",
                          style: AppTextStyles.s12W400,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      var song = songs[index];
                      return SongTile(
                        song: song,
                        onTap: () {
                          getIt<MusicPlayerProvider>().playSong(
                            index,
                            songs: songs,
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
