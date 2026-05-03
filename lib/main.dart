import 'package:flutter/material.dart';
import 'package:hasicx/common/index.dart' show AppColors;
import 'package:hasicx/core/index.dart'
    show
        initDependencyLocator,
        MusicPlayerProvider,
        SharedPrefs,
        getIt,
        appRouter;
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencyLocator();
  await SharedPrefs.init();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MusicPlayerProvider>.value(
          value: getIt<MusicPlayerProvider>(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HasicX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.bgColor,
      ),
      routerConfig: appRouter,
    );
  }
}
