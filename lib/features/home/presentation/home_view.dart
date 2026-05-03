import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hasicx/ads/index.dart'
    show BannerAdWidget, kBANNERAD, kINTERSTITIALAD;
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

  late InterstitialAd ads;
  bool isInterLoaded = false;

  void initInterAd() {
    InterstitialAd.load(
      adUnitId: kINTERSTITIALAD,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ads = ad;
          setState(() {
            isInterLoaded = true;
          });
        },
        onAdFailedToLoad: (error) {
          ads.dispose();
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initInterAd();
    Timer(Duration(seconds: 5), () {
      if (isInterLoaded) {
        ads.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            isInterLoaded = false;
            initInterAd();
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            isInterLoaded = false;
            ad.dispose();
          },
        );

        ads.show();
      }
    });
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

        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AdvanceMiniPlayer(),
            BannerAdWidget(adKey: kBANNERAD),
          ],
        ),
      ),
    );
  }
}
