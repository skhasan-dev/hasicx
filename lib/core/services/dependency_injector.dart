import 'package:get_it/get_it.dart';
import 'package:hasicx/core/index.dart';
import 'package:hasicx/features/favourites/presentation/view_models/favourites_view_model.dart';

GetIt getIt = GetIt.instance;

Future<void> initDependencyLocator() async {
  getIt
    ..registerLazySingleton<AppStateProvider>(AppStateProvider.new)
    ..registerLazySingleton<MusicPlayerProvider>(MusicPlayerProvider.new)
    ..registerLazySingleton<FavouritesViewModel>(FavouritesViewModel.new)
    ..registerLazySingleton<LocalRepository>(LocalRepositoryImpl.new);
}
